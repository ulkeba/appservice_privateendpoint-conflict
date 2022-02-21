
param resourcePrefix string

param adminVmUsername string
@secure()
param adminVmPassword string

param location string = resourceGroup().location

resource vNet 'Microsoft.Network/virtualNetworks@2019-11-01' = {
  name: '${resourcePrefix}-vnet'
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
      {
        name: 'vm-subnet'
        properties: {
          addressPrefix: '10.1.2.0/24'
        }
      }
    ]
  }
}
module ressources_ExtAppSvc_WithPE 'externalAppSvc.bicep' = {
  name: '${resourcePrefix}-appsvc'
  params: {
    location: location
    servicePrefix: resourcePrefix
    deployPrivateEndpoint: true
    enabledPublicAccess: false
    existingVNetName: vNet.name
    existingVNetId: vNet.id
  }
}

module internalVm 'vm-simple-windows.bicep' = {
  name: 'internalVm'
  params: {
    location: location
    vmName:  'demo-vm'
    adminUsername: adminVmUsername
    adminPassword: adminVmPassword
    subnetId: vNet.properties.subnets[1].id
  }
}
