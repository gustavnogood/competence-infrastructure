param name string
param location string
@description('Specifies the OS used for the Azure Function hosting plan.')
@allowed([
  'Windows'
  'Linux'
])
param resourcePlanOS string = 'Windows'
param skuName string
param skuTier string
var isReserved = ((resourcePlanOS == 'Linux') ? true : false)


resource appServicePlan 'Microsoft.Web/serverfarms@2021-03-01' = {
  name: name
  location: location
  sku: {
    name: skuName
    tier: skuTier
  }
  properties: {
    reserved: isReserved
  }
  kind: toLower(resourcePlanOS)
}

output servicePlanId string = appServicePlan.id
