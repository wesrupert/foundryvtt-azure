targetScope = 'subscription'

@description('The base name that will prefixed to all Azure resources deployed to ensure they are unique.')
param baseResourceName string

@description('The resource group that resources will be deployed to')
param resourceGroupName string

@description('The region that resources will be deployed to')
param location string = 'AustraliaEast'

@description('The default language for the server')
param language string = 'en.core'

@description('If provided, serve Foundry content from this domain child route')
param hostname string = '${baseResourceName}.azurewebsites.net'

@description('If provided, use in place of an IP address when generating invites')
param hostRoute string = ''

@description('If true, preserve the container config across deployments and restarts')
@allowed([
  'true'
  'false'
  ''
])
param foundryPreserveConfig string = ''

@description('Your Foundry VTT username.')
@secure()
param foundryUsername string

@description('Your Foundry VTT password.')
@secure()
param foundryPassword string

@description('The admin key to set Foundry VTT up with.')
@secure()
param foundryAdminKey string

@description('The configuration of the Azure Storage SKU to use for storing Foundry VTT user data.')
@allowed([
  'Premium_100GB'
  'Standard_100GB'
])
param storageConfiguration string = 'Premium_100GB'

@description('The configuration of the Azure Container Instance for running the Foundry VTT server.')
@allowed([
  'Small'
  'Medium'
  'Large'
])
param containerConfiguration string = 'Small'

resource rg 'Microsoft.Resources/resourceGroups@2021-04-01' = {
  name: resourceGroupName
  location: location
}

module storageAccount './modules/storageAccount.bicep' = {
  name: 'storageAccount'
  scope: rg
  params: {
    location: location
    storageAccountName: baseResourceName
    storageConfiguration: storageConfiguration
  }
}

module containerGroup './modules/containerGroup.bicep' = {
  name: 'containerGroup'
  scope: rg
  dependsOn: [
    storageAccount
  ]
  params: {
    location: location
    storageAccountName: baseResourceName
    containerGroupName: '${baseResourceName}-aci'
    containerDnsName: baseResourceName
    foundryUsername: foundryUsername
    foundryPassword: foundryPassword
    foundryAdminKey: foundryAdminKey
    containerConfiguration: containerConfiguration
    language: language
    hostname: hostname
    hostRoute: hostRoute
    preserveConfig: foundryPreserveConfig
  }
}

output url string = containerGroup.outputs.url
