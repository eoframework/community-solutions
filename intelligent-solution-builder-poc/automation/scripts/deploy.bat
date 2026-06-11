@echo off
:: =============================================================================
:: deploy.bat — Amatra Intelligent Solution Builder
:: Terraform deployment wrapper for Windows
:: Usage: deploy.bat <environment> <command>
:: =============================================================================
setlocal enabledelayedexpansion

set "ENVIRONMENT=%~1"
set "COMMAND=%~2"
set "EXTRA=%~3 %~4 %~5"

if "%ENVIRONMENT%"=="" goto :usage
if "%COMMAND%"=="" goto :usage

set "SCRIPT_DIR=%~dp0"
set "TF_ROOT=%SCRIPT_DIR%..\terraform"
set "ENV_DIR=%TF_ROOT%\environments\%ENVIRONMENT%"

if not exist "%ENV_DIR%" (
    echo ERROR: Environment directory not found: %ENV_DIR%
    exit /b 1
)

pushd "%ENV_DIR%"

set "VAR_FILES="
if exist "config" (
    for %%f in (config\*.tfvars) do (
        if exist "%%f" set "VAR_FILES=!VAR_FILES! -var-file=%%f"
    )
)

set "BACKEND_CONFIG="
if exist "backend.tfvars" set "BACKEND_CONFIG=-backend-config=backend.tfvars"

echo ============================================================
echo  Amatra ISB -- %ENVIRONMENT% Environment -- %COMMAND%
echo ============================================================

if "%COMMAND%"=="init"     terraform init !BACKEND_CONFIG! %EXTRA%
if "%COMMAND%"=="plan"     terraform plan !VAR_FILES! %EXTRA%
if "%COMMAND%"=="apply"    terraform apply !VAR_FILES! %EXTRA%
if "%COMMAND%"=="destroy"  terraform destroy !VAR_FILES! %EXTRA%
if "%COMMAND%"=="validate" terraform validate %EXTRA%
if "%COMMAND%"=="fmt"      terraform fmt -recursive "%TF_ROOT%" %EXTRA%
if "%COMMAND%"=="output"   terraform output %EXTRA%
if "%COMMAND%"=="state"    terraform state %EXTRA%

popd
echo Done.
exit /b 0

:usage
echo Usage: deploy.bat ^<environment^> ^<command^>
echo   Environments: prod ^| test ^| dr
echo   Commands:     init ^| plan ^| apply ^| destroy ^| validate ^| fmt ^| output ^| state
exit /b 1
