targetScope = 'subscription'

param apiLocation string
param appArtifactLocation string
param appLocation string
param branch string
param repositoryToken string
param repositoryUrl string
param location string
@maxLength(5)
param env string


var OSWindows = 'Windows'

// ---------------------------- Application insight setup ----------------------------
var applicationInsightsBaseName = 'ai'
var aiResourceGroup = 'rg-${applicationInsightsBaseName}-${env}'
var applicationInsightsName = 'ai-${applicationInsightsBaseName}-${env}'
var logWorkspace = 'lw-${env}-${applicationInsightsBaseName}'


module aiResourceGroupModule './resource-group-module/resource-group.bicep' = {
  name: 'resource-group'
  params: {
    location: location
    name: aiResourceGroup
  }
}

module applicationInsights './application-insights-module/application-insights.bicep' = {
  name: 'application-insights'
  params: {
    location: location
    name: applicationInsightsName
    logWorkspaceName: logWorkspace
  }
  scope: az.resourceGroup (aiResourceGroup)
  dependsOn: [aiResourceGroupModule]
}
// ---------------------------------------------------------------------------------

// ---------------------------- Appservice plan setup ----------------------------
var appServicePlanServerlessWindows = 'asc-host-${env}'
var serviceplanResourceGroup = 'rg-serviceplan-${env}'
var skuY1 = 'Y1'
var skuTierDynamic = 'Dynamic'

module servicePlanResourceGroup './resource-group-module/resource-group.bicep' = {
  name: 'serviceplan-resource-group'
  params: {
    location: location
    name: serviceplanResourceGroup
  }
}

module serverlessWindowsAppServicePlan 'appservice-plan-module/app-service-plan.bicep' = {
  name: 'app-service-plan-serveless-windows'
  params: {
    name: appServicePlanServerlessWindows
    location: location
    skuName: skuY1
    skuTier: skuTierDynamic
    resourcePlanOS: OSWindows
  }
  scope: az.resourceGroup(serviceplanResourceGroup)
  dependsOn: [servicePlanResourceGroup]
}
// ---------------------------------------------------------------------------------

// ---------------------------- Activate portal setup ----------------------------
var portalBaseName = 'OP-Competence'
var portalResourceGroup = 'rg-${portalBaseName}-${env}'
var swaName = 'swa-${portalBaseName}-${env}'
var cosmosDbAccountName = 'cosmos-${portalBaseName}-${env}'
var cosmosDbName = portalBaseName
var bffFunctionStorageAccount = 'stac${portalBaseName}-${env}'
var bffFunctionName = 'bff-${portalBaseName}-${env}'
var backendLinkName = 'liba-${portalBaseName}-${env}'
var portalCosmosContainerName1 = 'roadmap'
var portalCosmosContainerName2 = 'users'

module portalResourceGroupModule './resource-group-module/resource-group.bicep' = {
  name: 'portal-resource-group'
  params: {
    location: location
    name: portalResourceGroup
  }
}

module bffFunction './function-module/functions.bicep' = {
  name: 'function'
  params: {
    location: location
    name: bffFunctionName
    storageAccountName: bffFunctionStorageAccount
    aiName: applicationInsightsName
    appServicePlanName: appServicePlanServerlessWindows
  }
  scope: az.resourceGroup (portalResourceGroup)
  dependsOn: [applicationInsights, portalResourceGroupModule]
}

module cosmos './cosmos-module/cosmos.bicep' = {
  name: 'cosmos-db'
  params: {
    location: location
    databaseName: cosmosDbName
    databaseAccountName: cosmosDbAccountName
  }
  scope: az.resourceGroup (portalResourceGroup)
  dependsOn: [portalResourceGroupModule]
}

module portalCosmosContainer1 'cosmos-module/comsos-container.bicep' = {
  name: 'event-cosmos-container1'
  params: {
    databaseAccountName: cosmosDbAccountName
    databaseName: cosmosDbName
    containerName: portalCosmosContainerName1
    partitionKey: '/name'
  }
  scope: az.resourceGroup(portalResourceGroup)
  dependsOn: [portalResourceGroupModule, cosmos]
}

module portalCosmosContainer2 'cosmos-module/comsos-container.bicep' = {
  name: 'event-cosmos-container2'
  params: {
    databaseAccountName: cosmosDbAccountName
    databaseName: cosmosDbName
    containerName: portalCosmosContainerName2
    partitionKey: '/userId'
  }
  scope: az.resourceGroup(portalResourceGroup)
  dependsOn: [portalResourceGroupModule, cosmos]
}

module staticWebApp './static-web-app-module/static-web-app.bicep' = {
  name: 'static-web-app'
  params: {
    location: location
    name: swaName
    backendName: bffFunctionName
    linkedBackendName: backendLinkName
    apiLocation: apiLocation
    appArtifactLocation: appArtifactLocation
    appLocation: appLocation
    branch: branch
    repositoryToken: repositoryToken
    repositoryUrl: repositoryUrl
  }
  scope: az.resourceGroup (portalResourceGroup)
  dependsOn: [portalResourceGroupModule, bffFunction]
}

module roleAssignmentCosmos './role-assignment-module/role-assignment-sql.bicep' = {
  name: 'role-assignment-cosmos'
  params: {
    cosmosAccountName: cosmosDbAccountName
    principalId: bffFunction.outputs.principalId
  }
  scope: az.resourceGroup (portalResourceGroup)
  dependsOn: [portalResourceGroupModule, cosmos]
}
// ---------------------------------------------------------------------------------

// ---------------------------- Event Service defintion ----------------------------
var eventServiceName = 'eventser'
var eventResourceGroup = 'rg-${eventServiceName}-${env}'
var eventCosmosDbAccountName = 'cosmos-${eventServiceName}-${env}'
var eventCosmosContainerName = 'event'
var eventCosmosDbName = eventServiceName
var eventServiceFunctionStorageAccount = 'stac${eventServiceName}${env}'
var eventServiceFunctionName = '${eventServiceName}-${env}'

module eventResourceGroupModule './resource-group-module/resource-group.bicep' = {
  name: 'event-resource-group'
  params: {
    location: location
    name: eventResourceGroup
  }
}

module eventServiceFunction './function-module/functions.bicep' = {
  name: 'event-service-function-module'
  params: {
    location: location
    name: eventServiceFunctionName
    storageAccountName: eventServiceFunctionStorageAccount
    aiName: applicationInsightsName
    appServicePlanName: appServicePlanServerlessWindows
  }
  scope: az.resourceGroup(eventResourceGroup)
  dependsOn: [applicationInsights, eventResourceGroupModule]
}

module eventCosmos './cosmos-module/cosmos.bicep' = {
  name: 'event-cosmos-db-module'
  params: {
    location: location
    databaseAccountName: eventCosmosDbAccountName
    databaseName: eventCosmosDbName
  }
  scope: az.resourceGroup(eventResourceGroup)
  dependsOn: [eventResourceGroupModule]
}

module eventCosmosContainer 'cosmos-module/comsos-container.bicep' = {
  name: 'event-cosmos-container-module'
  params: {
    databaseAccountName:eventCosmosDbAccountName
    databaseName: eventCosmosDbName
    containerName: eventCosmosContainerName
    partitionKey: '/type'
  }
  scope: az.resourceGroup(eventResourceGroup)
  dependsOn: [eventResourceGroupModule, eventCosmos]
}

// ---------------------------------------------------------------------------------

