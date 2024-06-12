targetScope = 'subscription'

param location string
@maxLength(5)
param env string
@maxLength(12)
param baseName string

var swaRGName = 'rg-${baseName}-${env}'

module resourceGroup './resource-group-module/resource-group.bicep' = {
  name: 'resource-group'
  params: {
    location: location
    name: swaRGName
  }
}
