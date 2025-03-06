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
