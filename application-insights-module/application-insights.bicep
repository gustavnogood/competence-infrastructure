targetScope = 'resourceGroup'

param location string
param name string
param logWorkspaceName string

resource logworkspace 'Microsoft.OperationalInsights/workspaces@2021-12-01-preview' = {
  name: logWorkspaceName
  location: location
  properties: {
    sku: {
      name: 'PerGB2018'
    }
  }
}

resource appInsights 'Microsoft.Insights/components@2020-02-02' = {
  name: name
  location: location
  kind: 'web'
  properties: { 
    Application_Type: 'web'
    WorkspaceResourceId: logworkspace.id
  }
}
