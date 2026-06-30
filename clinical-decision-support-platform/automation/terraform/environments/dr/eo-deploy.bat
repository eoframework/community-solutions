@echo off
setlocal enabledelayedexpansion
set "COMMAND=%~1"
set "VAR_FILES="
echo MedCore CDS Platform - DR Environment
for %%f in (config\*.tfvars) do (
    if exist "%%f" set "VAR_FILES=!VAR_FILES! -var-file=%%f"
)
if "%COMMAND%"=="init"     terraform init %2 %3 %4 %5
if "%COMMAND%"=="plan"     terraform plan !VAR_FILES! %2 %3 %4 %5
if "%COMMAND%"=="apply"    terraform apply !VAR_FILES! %2 %3 %4 %5
if "%COMMAND%"=="destroy"  terraform destroy !VAR_FILES! %2 %3 %4 %5
if "%COMMAND%"=="validate" terraform validate %2 %3 %4 %5
if "%COMMAND%"=="fmt"      terraform fmt -recursive %2 %3 %4 %5
endlocal
