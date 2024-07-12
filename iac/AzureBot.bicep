@minLength(2)
param botName string
param appInsightsName string
param botWebAppName string
param microsoftAppId string
param slackClientId string
@secure()
param slackClientSecret string
@secure()
param slackSigningSecret string

resource botWebApp 'Microsoft.Web/sites@2023-12-01' existing = {
  name: botWebAppName
}

resource appInsights 'Microsoft.Insights/components@2020-02-02' existing = {
  name: appInsightsName
}

resource azureBot 'Microsoft.BotService/botServices@2023-09-15-preview' = {
  name: botWebApp.name
  location: 'global'
  kind: 'azurebot'
  sku: {
    name: 'F0'
  }
  properties: {
    displayName: botName
    iconUrl: 'https://docs.botframework.com/static/devportal/client/images/bot-framework-default.png'
    description: 'A bot service for answering technical questions'
    endpoint: 'https://${botWebApp.name}.azurewebsites.net/api/messages'
    msaAppId: microsoftAppId
    msaAppType: 'MultiTenant'
    developerAppInsightKey: appInsights.properties.InstrumentationKey
    developerAppInsightsApiKey: appInsights.listKeys().keys[0].value
    developerAppInsightsApplicationId: appInsights.properties.AppId
    isCmekEnabled: false
    schemaTransformationVersion: '1.3'
  }
}

resource slackChannel 'Microsoft.BotService/botServices/channels@2023-09-15-preview' = {
  parent: azureBot
  name: 'SlackChannel'
  properties: {
    channelName: 'SlackChannel'
    properties: {
      clientId: slackClientId
      clientSecret: slackClientSecret
      signingSecret: slackSigningSecret
      isEnabled: true
    }
  }
}
