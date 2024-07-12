# Local Deployment

This guide covers the steps to deploy the bot infrastructure, application, and Azure Bot Services locally.

## Deploy Bot Infrastructure

```powershell
$resourceGroup = 'os-demo-ada'

az deployment group create --resource-group $resourceGroup --parameters BotApp.bicepparam
```

## Deploy Bot Application

```powershell
$resourceGroup = 'os-demo-ada'
$botWebAppName = 'local-ada-bot'

az bot prepare-deploy --lang Csharp --code-dir "." --proj-file-path ./AdaBot.csproj

Compress-Archive -Path .\* -DestinationPath .\deployment.zip

az webapp deployment source config-zip --resource-group $resourceGroup --name $botWebAppName --src .\deployment.zip

```

## Deploy Azure Bot Services

```powershell
$resourceGroup = 'os-demo-ada'

az deployment group create --resource-group $resourceGroup --parameters AzureBot.bicepparam
```
