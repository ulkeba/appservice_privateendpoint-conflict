# Overview

This setup illustrates the restriction described in [Azure Private Endpoint DNS configuration](https://docs.microsoft.com/en-us/azure/private-link/private-endpoint-dns):
> Private networks already using the private DNS zone for a given type, can only connect to public resources if they don't have any private endpoint connections, otherwise a corresponding DNS configuration is required on the private DNS zone in order to complete the DNS resolution sequence. 

The Bicep templates in this repository deploy following components:
- Three resource groups.
- An instance of an Azure AppService with public but _no_ private endpoint (in resource group `appsvc-pedemo-external-withoutpe`)
- An instance of an Azure AppService with both public  _and_ private endpoint (in resource group `appsvc-pedemo-external-withpe`)
- An instance of an Azure AppService with private endpoint only (in resource group `appsvc-pedemo-internal`)
- A VM connected to the VNet deployed in resource group `appsvc-pedemo-internal`.

From the VM, calling the three services show following result:
- The app service in `appsvc-pedemo-internal` is available (via private endpoint deployed in the VNet)
- The app service in `appsvc-pedemo-external-withoutpe` is available (via public endpoint)
- The app service in `appsvc-pedemo-external-withpe` is *not* available since DNS resolution fails.

# Deployment
- Create your own copy of `demo.parameters.json`
- Invoke deployment with `az deployment sub create` (see `deploy.sh`)