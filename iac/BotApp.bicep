param location string = resourceGroup().location
param botWebAppName string
param appInsightsName string
param appServicePlanName string
param cosmosDbAccountName string
param cosmosDbDatabaseName string
param cosmosDbContainerName string
param cosmosDbThroughput int
param luisAppId string
@secure()
param luisAPIKey string
param luisAPIHoestName string
param microsoftAppId string
@secure()
param microsoftAppIdPassword string
param microsoftAppTenantId string
param microsoftAppType string = 'MultiTenant'
param storageAccountName string

resource appServicePlan 'Microsoft.Web/serverfarms@2023-12-01' = {
  name: appServicePlanName
  location: location
  sku: {
    name: 'F1'
    tier: 'Free'
  }
  kind: 'app'
}

resource storageAccount 'Microsoft.Storage/storageAccounts@2023-05-01' = {
  name: storageAccountName
  location: location
  sku: {
    name: 'Standard_LRS'
  }
  kind: 'StorageV2'
  properties: {
    accessTier: 'Hot'
  }
}

resource appInsights 'Microsoft.Insights/components@2020-02-02' = {
  name: appInsightsName
  location: location
  kind: 'web'
  properties: {
    Application_Type: 'web'
  }
}

resource cosmosDbAccount 'Microsoft.DocumentDB/databaseAccounts@2024-05-15' = {
  name: cosmosDbAccountName
  location: location
  kind: 'GlobalDocumentDB'
  properties: {
    databaseAccountOfferType: 'Standard'
    enableFreeTier: true
    locations: [
      {
        locationName: location
        failoverPriority: 0
        isZoneRedundant: false
      }
    ]
    consistencyPolicy: {
      defaultConsistencyLevel: 'Session'
    }
    createMode: 'Default'
  }
}

resource cosmosDbDatabase 'Microsoft.DocumentDB/databaseAccounts/sqlDatabases@2024-05-15' = {
  parent: cosmosDbAccount
  name: cosmosDbDatabaseName
  properties: {
    resource: {
      id: cosmosDbDatabaseName
    }
  }
}

resource cosmosDbContainer 'Microsoft.DocumentDB/databaseAccounts/sqlDatabases/containers@2024-05-15' = {
  parent: cosmosDbDatabase
  name: cosmosDbContainerName
  properties: {
    resource: {
      id: cosmosDbContainerName
      partitionKey: {
        paths: [
          '/category'
        ]
        kind: 'Hash'
      }
    }
    options: {
      throughput: cosmosDbThroughput
    }
  }
}

resource botWebApp 'Microsoft.Web/sites@2023-12-01' = {
  name: botWebAppName
  location: location
  kind: 'app'
  properties: {
    serverFarmId: appServicePlan.id
    siteConfig: {
      webSocketsEnabled: true
      appSettings: [
        {
          name: 'WEBSITE_NODE_DEFAULT_VERSION'
          value: '~18'
        }
        {
          name: 'AzureWebJobsStorage'
          value: 'DefaultEndpointsProtocol=https;AccountName=${storageAccount.name};AccountKey=${storageAccount.listKeys().keys[0].value};EndpointSuffix=core.windows.net'
        }
        {
          name: 'MicrosoftAppType'
          value: microsoftAppType
        }
        {
          name: 'MicrosoftAppId'
          value: microsoftAppId
        }
        {
          name: 'MicrosoftAppPassword'
          value: microsoftAppIdPassword
        }
        {
          name: 'MicrosoftAppTenantId'
          value: microsoftAppTenantId
        }
        {
          name: 'LuisAppId'
          value: luisAppId
        }
        {
          name: 'LuisAPIKey'
          value: luisAPIKey
        }
        {
          name: 'LuisAPIHostName'
          value: luisAPIHoestName
        }
        {
          name: 'CosmosDbEndpoint'
          value: cosmosDbAccount.properties.documentEndpoint
        }
        {
          name: 'CosmosDbKey'
          value: cosmosDbAccount.listKeys().primaryMasterKey
        }
        {
          name: 'CosmosDbDatabaseId'
          value: cosmosDbDatabaseName
        }
        {
          name: 'CosmosDbContainerId'
          value: cosmosDbContainerName
        }
        {
          name: 'APPINSIGHTS_INSTRUMENTATIONKEY'
          value: appInsights.properties.InstrumentationKey
        }
      ]
      cors: {
        allowedOrigins: [
          'https://botservice.hosting.portal.azure.net'
          'https://hosting.onecloud.azure-test.net/"'
        ]
      }
    }
  }
}
