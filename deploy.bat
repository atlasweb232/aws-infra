@echo off
echo === Atlas Infrastructure Deployment ===
echo.
echo This will create:
echo   - Build Server (t3.large) for Docker builds and ECS deployments
echo   - Gitea Server (t3.medium) for self-hosted Git (optional)
echo   - GHES Server (m5.2xlarge) for GitHub Enterprise (optional)
echo.

REM Check if Terraform is installed
where terraform >nul 2>&1
if %ERRORLEVEL% neq 0 (
    echo ERROR: Terraform not found. Install from https://www.terraform.io/downloads
    echo.
    echo Download for Windows:
    echo   https://releases.hashicorp.com/terraform/1.6.6/terraform_1.6.6_windows_amd64.zip
    pause
    exit /b 1
)

cd /d %~dp0

REM Initialize
echo [1/5] Initializing Terraform...
terraform init
if %ERRORLEVEL% neq 0 (
    echo ERROR: Terraform init failed
    pause
    exit /b 1
)

REM Plan
echo.
echo [2/5] Planning deployment...
terraform plan -out=tfplan
if %ERRORLEVEL% neq 0 (
    echo ERROR: Terraform plan failed
    pause
    exit /b 1
)

REM Apply
echo.
echo [3/5] Applying deployment...
terraform apply tfplan
if %ERRORLEVEL% neq 0 (
    echo ERROR: Terraform apply failed
    pause
    exit /b 1
)

REM Show outputs
echo.
echo [4/5] Deployment complete!
echo.
terraform output -json

REM Extract and display important info
echo.
echo [5/5] Summary
echo.

for /f "tokens=*" %%i in ('terraform output -raw build_server_public_ip') do set BUILD_IP=%%i
for /f "tokens=*" %%i in ('terraform output -raw build_server_ssh_command') do set BUILD_SSH=%%i

echo === Build Server ===
echo IP: %BUILD_IP%
echo SSH: %BUILD_SSH%
echo.

REM Check if Gitea is enabled
terraform output -raw gitea_url > gitea_url.txt 2>&1
findstr /i "http" gitea_url.txt >nul 2>&1
if %ERRORLEVEL% equ 0 (
    echo === Gitea Server (Self-hosted Git) ===
    for /f "tokens=*" %%i in ('terraform output -raw gitea_public_ip') do set GITEA_IP=%%i
    for /f "tokens=*" %%i in ('terraform output -raw gitea_url') do set GITEA_URL=%%i
    for /f "tokens=*" %%i in ('terraform output -raw gitea_ssh_command') do set GITEA_SSH=%%i
    echo IP: %GITEA_IP%
    echo Web UI: %GITEA_URL%
    echo SSH: %GITEA_SSH%
    echo.
) else (
    echo === Gitea: Not enabled ===
    echo.
    echo To enable Gitea, edit terraform.tfvars:
    echo   enable_gitea = true
    echo.
)

REM Cleanup temp files
del gitea_url.txt >nul 2>&1

echo === Next Steps ===
echo.
echo 1. Wait 3-5 minutes for instances to initialize
echo 2. Connect to build server:
echo    %BUILD_SSH%
echo.
echo 3. Clone repository and build:
echo    git clone https://github.com/atlasweb232/atlas-emailreact.git
echo    cd atlas-emailreact
echo    ./deploy-alb.bat
echo.
echo 4. (Optional) Set up Gitea:
echo    - Visit Gitea web UI: %GITEA_URL%
echo    - Create account and configure
echo    - Clone your repos from GitHub to Gitea
echo.
pause
