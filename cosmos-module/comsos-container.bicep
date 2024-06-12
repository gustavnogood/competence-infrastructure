param databaseAccountName string
param databaseName string

param containerName string
param partitionKey string

resource cosmosDbAccount 'Microsoft.DocumentDB/databaseAccounts@2021-11-15-preview' existing = {
  name: databaseAccountName
}

resource nosqlDb 'Microsoft.DocumentDB/databaseAccounts/sqlDatabases@2021-06-15' existing = {
  name: databaseName
  parent: cosmosDbAccount
}

resource container 'Microsoft.DocumentDB/databaseAccounts/sqlDatabases/containers@2021-06-15' = {
  parent: nosqlDb
  name: containerName
  properties: {
    resource: {
      id: containerName
      partitionKey: {
        paths: [
          partitionKey
        ]
        kind: 'Hash'
      }
      uniqueKeyPolicy: {
        uniqueKeys: [
          {
            paths: [partitionKey]
          }
        ]
      }
    }
  }
}
