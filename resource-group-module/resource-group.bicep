targetScope = 'subscription'

param location string
@maxLength(90)
param name string


resource mainRG 'Microsoft.Resources/resourceGroups@2021-04-01' = {
  name: name
  location: location
}
