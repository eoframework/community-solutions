@echo off
REM ANP Streaming AI - State Backend Setup (Windows)
REM Usage: state-backend.bat <prod|test|dr> [region]

setlocal enabledelayedexpansion

set "ENVIRONMENT=%~1"
if "%ENVIRONMENT%"=="" set "ENVIRONMENT=prod"

set "REGION=%~2"
if "%REGION%"=="" set "REGION=us-east-1"

set "SOLUTION=anp-streaming-ai"
set "BUCKET_NAME=%SOLUTION%-tfstate-%ENVIRONMENT%"
set "DYNAMODB_TABLE=%SOLUTION%-tfstate-lock-%ENVIRONMENT%"

echo Creating Terraform state backend for %ENVIRONMENT%
echo   Region:    %REGION%
echo   S3 Bucket: %BUCKET_NAME%
echo   DynamoDB:  %DYNAMODB_TABLE%

aws s3api create-bucket --bucket "%BUCKET_NAME%" --region "%REGION%"
aws s3api put-bucket-versioning --bucket "%BUCKET_NAME%" --versioning-configuration Status=Enabled
aws s3api put-public-access-block --bucket "%BUCKET_NAME%" --public-access-block-configuration "BlockPublicAcls=true,IgnorePublicAcls=true,BlockPublicPolicy=true,RestrictPublicBuckets=true"
aws dynamodb create-table --table-name "%DYNAMODB_TABLE%" --attribute-definitions AttributeName=LockID,AttributeType=S --key-schema AttributeName=LockID,KeyType=HASH --billing-mode PAY_PER_REQUEST --region "%REGION%"

echo.
echo Backend created. To initialise:
echo   cd environments\%ENVIRONMENT%
echo   terraform init -backend-config=backend.tfvars
