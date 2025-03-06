data "azurerm_resource_group" "rg" {
  name     = var.resourcegroupname
}

# Create Public IP
resource "azurerm_public_ip" "public_ip" {
  name                = var.public_ip_name
  resource_group_name = var.resourcegroupname
  location            = var.resourcegrouplocation
  allocation_method   = "Static" # Or Static
}

# Create Network Interface
resource "azurerm_network_interface" "nic" {
  name                = var.network_interface_name
  resource_group_name = var.resourcegroupname
  location            = var.resourcegrouplocation

  ip_configuration {
    name                          = "internal"
    subnet_id                     = var.subnet_id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.public_ip.id
  }
}

# Create Network Security Group (Firewall)
resource "azurerm_network_security_group" "nsg" {
  name                = "my-nsg"
  resource_group_name = var.resourcegroupname
  location            = var.resourcegrouplocation
}

# Network Security Rule for HTTP (Port 80)
resource "azurerm_network_security_rule" "http_rule" {
  name                        = "AllowHTTP"
  priority                    = 100
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "80"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  resource_group_name = var.resourcegroupname
  network_security_group_name = azurerm_network_security_group.nsg.name
}

# Network Security Rule for RDP (Port 3389)
resource "azurerm_network_security_rule" "rdp_rule" {
  name                        = "AllowRDP"
  priority                    = 110
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "3389"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  resource_group_name = var.resourcegroupname
  network_security_group_name = azurerm_network_security_group.nsg.name
}

# Network Security Rule for Postgres (Port 5000)
# resource "azurerm_network_security_rule" "postgresweb_rule" {
#   name                        = "AllowPostgresweb"
#   priority                    = 120
#   direction                   = "Inbound"
#   access                      = "Allow"
#   protocol                    = "Tcp"
#   source_port_range           = "*"
#   destination_port_range      = "5000"
#   source_address_prefix       = "*"
#   destination_address_prefix  = "*"
#   resource_group_name = var.resourcegroupname
#   network_security_group_name = azurerm_network_security_group.nsg.name
# }

# Associate NSG with Subnet
resource "azurerm_subnet_network_security_group_association" "nsg_association" {
  subnet_id                 = var.subnet_id
  network_security_group_id = azurerm_network_security_group.nsg.id
}

# Create Windows Virtual Machine
resource "azurerm_windows_virtual_machine" "vm" {
  name                = var.virtual_machine_name
  resource_group_name = var.resourcegroupname
  location            = var.resourcegrouplocation
  size                = var.vm_size
  admin_username      = var.admin_username
  admin_password      = var.admin_password
  network_interface_ids = [
    azurerm_network_interface.nic.id,
  ]
  

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2019-Datacenter" # Or other Windows Server SKU
    version   = "latest"
  }

}

resource "azurerm_storage_account" "storage" {
  name = "installwimp"
  resource_group_name      = data.azurerm_resource_group.rg.name
  location                 = data.azurerm_resource_group.rg.location
  account_tier             = "Standard"
  account_replication_type = "LRS" # Locally-redundant storage

  tags = {
    environment = "staging"
  }
}

resource "azurerm_storage_container" "wimp" {
  name                  = "wimp" # Replace with your desired container name
  storage_account_name  = azurerm_storage_account.storage.name
  container_access_type = "blob" # Or "blob", "container"
}



resource "azurerm_virtual_machine_extension" "flask" {
  name                 = "install-flask"
  virtual_machine_id   = azurerm_windows_virtual_machine.vm.id
  publisher            = "Microsoft.Compute"
  type                 = "CustomScriptExtension"
  type_handler_version = "1.10"
  settings = <<SETTINGS
    {
      "fileUris": ["${azurerm_storage_blob.flask.url}"],
      "commandToExecute": "powershell -ExecutionPolicy Unrestricted -File flask.ps1"
    }
  SETTINGS
}


resource "local_file" "install_flask" {
  filename = "install-flask.ps1"
  content  = <<-EOF
    Install-WindowsFeature -name Web-Server -IncludeAllSubFeature -IncludeManagementTools
    # Install Python if not installed
    $pythonInstalled = Get-Command python -ErrorAction SilentlyContinue
    if (-not $pythonInstalled) {
        Write-Output "Python not found. Installing..."
        Invoke-WebRequest -Uri "https://www.python.org/ftp/python/3.9.0/python-3.9.0-amd64.exe" -OutFile "python_installer.exe"
        Start-Process -FilePath "python_installer.exe" -ArgumentList "/quiet InstallAllUsers=1 PrependPath=1" -Wait
        Remove-Item "python_installer.exe"
    }

    # Ensure pip is installed
    py -m ensurepip --default-pip

    # Install Flask and PostgreSQL dependencies
    py -m pip install flask psycopg2-binary

    # Create a Flask app with PostgreSQL connection
    $flaskAppPath = "C:\flask_app"
    if (-Not (Test-Path $flaskAppPath)) {
        New-Item -ItemType Directory -Path $flaskAppPath | Out-Null
    }

    $flaskAppContent = @"
    from flask import Flask, jsonify
    import psycopg2

    app = Flask(__name__)

    # PostgreSQL connection settings


    def list_databases():
        try:
            # Connect to PostgreSQL
            
            conn = psycopg2.connect(
                dbname="ledger-db",
                user="psqladmin",
                password="psqladmin",
                host="lloyds-psql-02.postgres.database.azure.com",
                port="5432"
                )
            
            cur = conn.cursor()
            cur.execute("SELECT datname FROM pg_database WHERE datistemplate = false;")
        
            # Fetch database names
            databases = [row[0] for row in cur.fetchall()]

            # Close connection
            cur.close()
            conn.close()

            return databases
        except Exception as e:
            return str(e)

    @app.route('/databases', methods=['GET'])
    def get_databases():
        dbs = list_databases()
        return jsonify({"databases": dbs})

    if __name__ == '__main__':
        app.run(debug=True)
    "@

    Set-Content -Path "$flaskAppPath\app.py" -Value $flaskAppContent

    # Run the Flask app
    cd $flaskAppPath
    Start-Process -NoNewWindow -FilePath "python" -ArgumentList "app.py"
    cp C:\flask_app\app.py C:\flask_app\app.pyw

    @"
    @echo off
    start /min pythonw c:\flask_app\app.pyw
    "@ | Out-File -FilePath "C:\flask_app\start_flask.bat" -Encoding ASCII

    Start-Process -FilePath "C:\flask_app\start_flask.bat" -WindowStyle Hidden

    Invoke-WebRequest -Uri "https://ftp.postgresql.org/pub/pgadmin/pgadmin4/v9.1/windows/pgadmin4-9.1-x64.exe" -OutFile "pgadmin.exe"
  EOF
}

resource "azurerm_storage_blob" "flask" {
  name                   = "flask.ps1"
  storage_account_name   = azurerm_storage_account.storage.name
  storage_container_name = azurerm_storage_container.wimp.name
  type                   = "Block"
  source                 = "install-flask.ps1" # Path to your PowerShell script
}