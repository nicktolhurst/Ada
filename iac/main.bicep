param location string = resourceGroup().location
param botName string
param appServicePlanName string
param cosmosDbAccountName string
param cosmosDbDatabaseName string
param cosmosDbContainerName string
param cosmosDbThroughput int
param microsoftAppId string
param storageAccountName string

resource appServicePlan 'Microsoft.Web/serverfarms@2023-12-01' = {
  name: appServicePlanName
  location: location
  sku: {
    name: 'B1'
    tier: 'Basic'
  }
  kind: 'app'
}

resource botWebApp 'Microsoft.Web/sites@2023-12-01' = {
  name: botName
  location: location
  kind: 'app'
  properties: {
    serverFarmId: appServicePlan.id
    siteConfig: {
      appSettings: [
        {
          name: 'WEBSITE_NODE_DEFAULT_VERSION'
          value: '~14'
        }
        {
          name: 'AzureWebJobsStorage'
          value: 'DefaultEndpointsProtocol=https;AccountName=${storageAccount.name};AccountKey=${storageAccount.listKeys().keys[0].value};EndpointSuffix=core.windows.net'
        }
        {
          name: 'MicrosoftAppId'
          value: '8838a7ca-7aaa-484d-b9b4-3dcee80c11f8'
        }
        {
          name: 'MicrosoftAppPassword'
          value: ''
        }
        {
          name: 'LuisAppId'
          value: 'yourLuisAppId'
        }
        {
          name: 'LuisAPIKey'
          value: 'yourLuisAPIKey'
        }
        {
          name: 'LuisAPIHostName'
          value: 'yourLuisAPIHostName'
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
    }
  }
}

resource cosmosDbAccount 'Microsoft.DocumentDB/databaseAccounts@2024-05-15' = {
  name: cosmosDbAccountName
  location: location
  kind: 'GlobalDocumentDB'
  properties: {
    databaseAccountOfferType: 'Standard'
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

// Application Insights
resource appInsights 'Microsoft.Insights/components@2020-02-02' = {
  name: '${botName}-appinsights'
  location: location
  kind: 'web'
  properties: {
    Application_Type: 'web'
  }
}

resource azureBot 'Microsoft.BotService/botServices@2023-09-15-preview' = {
  name: botName
  location: 'global'
  sku: {
    name: 'F0'
  }
  properties: {
    displayName: botName
    description: 'A bot service for answering technical questions'
    endpoint: 'https://${botWebApp.name}.azurewebsites.net/api/messages'
    msaAppId: microsoftAppId
    developerAppInsightKey: appInsights.properties.InstrumentationKey
    developerAppInsightsApiKey: appInsights.listKeys().keys[0].value
    developerAppInsightsApplicationId: appInsights.properties.AppId
    isCmekEnabled: false
  }
}

// Slack Channel
resource slackChannel 'Microsoft.BotService/botServices/channels@2023-09-15-preview' = {
  parent: azureBot
  name: 'SlackChannel'
  properties: {
    channelName: 'SlackChannel'
    properties: {
      clientId: '858072937409.7378481505317'
      clientSecret: ''
      verificationToken: ''
      signingSecret: ''
      isEnabled: true
    }
  }
}
