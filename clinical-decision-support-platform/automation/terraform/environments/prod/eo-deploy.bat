@echo off
setlocal enabledelayedexpansion

REM =============================================================================
REM MedCore CDS Platform — Terraform Deployment Wrapper (Windows)
REM Usage: eo-deploy.bat <init|plan|apply|destroy|validate|fmt|output|state>
REM =============================================================================

set "COMMAND=%~1"
set "VAR_FILES="

echo MedCore CDS Platform - Terraform Wrapper
echo ===========================================

if "%COMMAND%"=="init" (
    if exist "backend.tfvars" (
        terraform init -backend-config=backend.tfvars %2 %3 %4 %5
    ) else (
        terraform init %2 %3 %4 %5
    )
    goto :done
)

REM Build var files list for plan/apply/destroy
for %%f in (config\*.tfvars) do (
    if exist "%%f" (
        set "VAR_FILES=!VAR_FILES! -var-file=%%f"
        echo    + %%f
    )
)

if "%COMMAND%"=="plan"    terraform plan !VAR_FILES! %2 %3 %4 %5
if "%COMMAND%"=="apply"   terraform apply !VAR_FILES! %2 %3 %4 %5
if "%COMMAND%"=="destroy" terraform destroy !VAR_FILES! %2 %3 %4 %5
if "%COMMAND%"=="validate" terraform validate %2 %3 %4 %5
if "%COMMAND%"=="fmt"     terraform fmt -recursive %2 %3 %4 %5
if "%COMMAND%"=="output"  terraform output %2 %3 %4 %5
if "%COMMAND%"=="state"   terraform state %2 %3 %4 %5

:done
echo Done.
endlocal
