targetScope = 'subscription'

param adminVmUsername string

@minLength(12)
@secure()
param adminVmPassword string

param location string = 'northeurope'
var internalServicePrefix = 'appsvc-pedemo-internal-${uniqueString(subscription().id)}'
var externalWithoutPEServicePrefix = 'appsvc-pedemo-external-withoutpe-${uniqueString(subscription().id)}'
var externalWithPEServicePrefix = 'appsvc-pedemo-external-withpe-${uniqueString(subscription().id)}'


resource rg_Internal 'Microsoft.Resources/resourceGroups@2021-04-01' = {
  location: location
  name: internalServicePrefix
}


resource rg_ExternalAppSvc_WithoutPE 'Microsoft.Resources/resourceGroups@2021-04-01' = {
  location: location
  name: externalWithoutPEServicePrefix
}

resource rg_ExternalAppSvc_WithPE 'Microsoft.Resources/resourceGroups@2021-04-01' = {
  location: location
  name: externalWithPEServicePrefix
}

module ressources_ExtAppSvc_WithoutPE 'externalAppSvc.bicep' = {
  scope: rg_ExternalAppSvc_WithoutPE
  name: rg_ExternalAppSvc_WithoutPE.name
  params: {
    location: location
    servicePrefix: externalWithoutPEServicePrefix
    deployPrivateEndpoint: false
    enabledPublicAccess: true
  }
}

module ressources_ExtAppSvc_WithPE 'externalAppSvc.bicep' = {
  scope: rg_ExternalAppSvc_WithPE
  name: rg_ExternalAppSvc_WithPE.name
  params: {
    location: location
    servicePrefix: externalWithPEServicePrefix
    deployPrivateEndpoint: true
    enabledPublicAccess: true
  }
}

module resources_Internal 'internal.bicep' = {
  scope: rg_Internal
  name: rg_Internal.name
  params: {
    location: location
    resourcePrefix: rg_Internal.name
    adminVmPassword: adminVmPassword
    adminVmUsername: adminVmUsername
  }
}
