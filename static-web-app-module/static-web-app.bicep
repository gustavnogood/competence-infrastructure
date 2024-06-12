param location string
param name string
param backendName string
param linkedBackendName string
param repositoryUrl string
param branch string

@secure()
param repositoryToken string
param appLocation string
param apiLocation string
param appArtifactLocation string


@allowed([
  'Free'
  'Standard'
])
param sku string = 'Standard'

resource name_resource 'Microsoft.Web/staticSites@2021-03-01' = {
  name: name
  location: location
  sku: {
    name: sku
    tier: sku
  }
  identity: {
    type: ((sku == 'Standard') ? 'SystemAssigned' : 'None')
  }
  properties: {
    repositoryUrl: repositoryUrl
    branch: branch
    repositoryToken: repositoryToken
    buildProperties: {
      appLocation: appLocation
      apiLocation: apiLocation
      appArtifactLocation: appArtifactLocation
      
    }
  }
}

resource name_linkedBackend 'Microsoft.Web/staticSites/linkedBackends@2022-03-01' = {
  parent: name_resource
  name: linkedBackendName
  properties: {
    backendResourceId: resourceId('Microsoft.Web/sites', backendName)
    region: location
  }
}

output principalId string = name_resource.identity.principalId
