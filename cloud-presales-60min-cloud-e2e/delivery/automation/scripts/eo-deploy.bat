@echo off
setlocal enabledelayedexpansion

REM Amatra Agentic Orchestration Platform - Terraform Deployment Script (Windows)
REM Discovers and loads all config\*.tfvars files automatically

set "COMMAND=%~1"
set "VAR_FILES="

echo ==========================================
echo  Amatra - Terraform Deployment Wrapper
echo ==========================================
echo.

if exist config\ (
    for %%f in (config\*.tfvars) do (
        if exist "%%f" (
            set "VAR_FILES=!VAR_FILES! -var-file=%%f"
            echo   [+] %%f
        )
    )
)

if "%COMMAND%"=="init"         terraform init %2 %3 %4 %5
if "%COMMAND%"=="init-backend" terraform init -backend-config=backend.tfvars %2 %3 %4 %5
if "%COMMAND%"=="plan"         terraform plan !VAR_FILES! %2 %3 %4 %5
if "%COMMAND%"=="apply"        terraform apply !VAR_FILES! %2 %3 %4 %5
if "%COMMAND%"=="destroy"      terraform destroy !VAR_FILES! %2 %3 %4 %5
if "%COMMAND%"=="validate"     terraform validate %2 %3 %4 %5
if "%COMMAND%"=="fmt"          terraform fmt %2 %3 %4 %5
if "%COMMAND%"=="output"       terraform output %2 %3 %4 %5

if "%COMMAND%"=="" (
    echo Usage: eo-deploy.bat ^<init^|init-backend^|plan^|apply^|destroy^|validate^|fmt^|output^>
)

echo.
echo ==========================================
echo  Done!
echo ==========================================
endlocal
