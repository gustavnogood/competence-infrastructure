param principalId string
param cosmosAccountName string
param roleDefinitionName string = 'DataOwner'

var roleDefinitionId = guid(
  'sql-role-definition-',
  principalId,
  resourceId('Microsoft.DocumentDB/databaseAccounts', cosmosAccountName)
)
var roleAssignmentId = guid(
  roleDefinitionId,
  principalId,
  resourceId('Microsoft.DocumentDB/databaseAccounts', cosmosAccountName)
)
var dataActions = [
  'Microsoft.DocumentDB/databaseAccounts/readMetadata'
  'Microsoft.DocumentDB/databaseAccounts/sqlDatabases/containers/items/*'
  'Microsoft.DocumentDB/databaseAccounts/sqlDatabases/containers/executeQuery'
  'Microsoft.DocumentDB/databaseAccounts/sqlDatabases/containers/readChangeFeed'
]

resource cosmosAccountName_roleDefinitionId 'Microsoft.DocumentDB/databaseAccounts/sqlRoleDefinitions@2021-04-15' = {
  name: '${cosmosAccountName}/${roleDefinitionId}'
  properties: {
    roleName: roleDefinitionName
    type: 'CustomRole'
    assignableScopes: [
      resourceId('Microsoft.DocumentDB/databaseAccounts', cosmosAccountName)
    ]
    permissions: [
      {
        dataActions: dataActions
      }
    ]
  }
}

resource cosmosAccountName_roleAssignmentId 'Microsoft.DocumentDB/databaseAccounts/sqlRoleAssignments@2021-04-15' = {
  name: '${cosmosAccountName}/${roleAssignmentId}'
  properties: {
    roleDefinitionId: cosmosAccountName_roleDefinitionId.id
    principalId: principalId
    scope: resourceId('Microsoft.DocumentDB/databaseAccounts', cosmosAccountName)
  }
}
