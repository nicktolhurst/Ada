using 'main.bicep'

param location = 'UkSouth'

param botName = 'drdr-scr-nt-pd-bot'

param appServicePlanName = 'drdr-scr-nt-pd-plan'

param cosmosDbAccountName = 'drdr-scr-nt-pd-cosmosdb'

param cosmosDbDatabaseName = 'BrainDB'

param cosmosDbContainerName = 'QnAContainer'

param cosmosDbThroughput = 400

param microsoftAppId = '8838a7ca-7aaa-484d-b9b4-3dcee80c11f8'

param storageAccountName = 'drdrscrntpdstorage'
