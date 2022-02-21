param servicePrefix string
param deployPrivateEndpoint bool
param enabledPublicAccess bool = false

param existingVNetName string = ''
param existingVNetId string = ''
param location string = resourceGroup().location

resource newVNet 'Microsoft.Network/virtualNetworks@2019-11-01' = if (existingVNetName == '') {
  name: '${servicePrefix}-vnet'
  location: location
  properties: {
    addressSpace: {
      addressPrefixes: [
        '10.1.0.0/16'
      ]
    }
    subnets: [
      {
        name: 'webapp-privateendpoint-subnet'
        properties: {
          addressPrefix: '10.1.1.0/24'
          privateEndpointNetworkPolicies: 'Disabled'
        }
      }
    ]
  }
}
resource existingVNet 'Microsoft.Network/virtualNetworks@2021-05-01' existing = if (existingVNetName != '') {
  name: existingVNetName
}

var vNet = (existingVNetName != '') ? existingVNet : newVNet

resource appServicePlan 'Microsoft.Web/serverfarms@2020-06-01' = {
  name: '${servicePrefix}-appsvc-plan'
  location: location
  sku: {
    tier: 'PremiumV2'
    name: 'P2v2'
  }
  kind: 'app'
}

resource webApp 'Microsoft.Web/sites@2021-01-01' = {
  name: '${servicePrefix}-appsvc'
  location: location
  kind: 'app'
  properties: {
    serverFarmId: appServicePlan.id
    httpsOnly: true
    siteConfig: {
      publicNetworkAccess: enabledPublicAccess ? 'Enabled' : 'Disabled'
    }
  }
}


resource webAppPrivateEndpoint 'Microsoft.Network/privateEndpoints@2021-05-01' = if (deployPrivateEndpoint) {
  name: '${webApp.name}-privateendpoint'
  location: location
  properties: {
    subnet: {
      id: vNet.properties.subnets[0].id
    }
    privateLinkServiceConnections: [
      {
        name: 'for-webapp'
        properties: {
          privateLinkServiceId: webApp.id
          groupIds: [
            'sites'
          ]
        }
      }
    ]
  }
}

resource webAppPrivateDnsEntry 'Microsoft.Network/privateEndpoints/privateDnsZoneGroups@2021-05-01' = if (deployPrivateEndpoint) {
  parent: webAppPrivateEndpoint
  name: 'dns-zone-group'
  properties: {
    privateDnsZoneConfigs: [
      {
        name: 'config'
        properties: {
          privateDnsZoneId: prvDnsZoneAzureWebSites.id
        }
      }
    ]
  }
}

resource prvDnsZoneAzureWebSites 'Microsoft.Network/privateDnsZones@2020-06-01' = if (deployPrivateEndpoint) {
  name: 'privatelink.azurewebsites.net'
  location: 'global'
}

resource prvDnsZoneAzureWebSitesVNetLink 'Microsoft.Network/privateDnsZones/virtualNetworkLinks@2020-06-01' = if (deployPrivateEndpoint) {
  parent: prvDnsZoneAzureWebSites
  name: '${prvDnsZoneAzureWebSites.name}-link'
  location: 'global'
  properties: {
    registrationEnabled: false
    virtualNetwork: {
      id: existingVNetId != '' ? existingVNetId : newVNet.id
    }
  }
}
