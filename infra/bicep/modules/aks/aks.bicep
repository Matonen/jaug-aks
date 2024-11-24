@description('The resource name.')
param name string

@description('The geo-location where the resource lives.')
param location string

resource aks 'Microsoft.ContainerService/managedClusters@2024-08-01' = {
  location: location
  name: name
  identity: {
    type: 'SystemAssigned'
  }
  sku: {
    name: 'Base'
    tier: 'Free'
  }
  properties: {
    dnsPrefix: name
    enableRBAC: true
    disableLocalAccounts: true
    aadProfile: {
      managed: true
      enableAzureRBAC: true
    }
    securityProfile: {
      imageCleaner: {
        enabled: true
        intervalHours: 168
      }
    }
    agentPoolProfiles: [
      {
        name: 'agentpool'
        mode: 'System'
        count: 1
        enableAutoScaling: true
        minCount: 1
        maxCount: 3
        vmSize: 'Standard_D2ps_v6'
        osType: 'Linux'
        osSKU: 'AzureLinux'
        osDiskSizeGB: 0 // 0 means default size
      }
    ]
    networkProfile: {
      networkPlugin: 'azure'
      networkPluginMode: 'overlay'
      networkPolicy: 'none'
    }
  }
}

resource aksManagedAutoUpgradeSchedule 'Microsoft.ContainerService/managedClusters/maintenanceConfigurations@2024-08-01' = {
  name: 'aksManagedAutoUpgradeSchedule'
  parent: aks
  properties: {
    maintenanceWindow: {
      schedule: {
        weekly: {
          intervalWeeks: 1
          dayOfWeek: 'Sunday'
        }
      }
      durationHours: 4
      startTime: '00:00'
    }
  }
}

resource aksManagedNodeOSUpgradeSchedule 'Microsoft.ContainerService/managedClusters/maintenanceConfigurations@2024-08-01' = {
  name: 'aksManagedNodeOSUpgradeSchedule'
  parent: aks
  properties: {
    maintenanceWindow: {
      schedule: {
        weekly: {
          intervalWeeks: 1
          dayOfWeek: 'Sunday'
        }
      }
      durationHours: 4
      startTime: '00:00'
    }
  }
}

resource flux 'Microsoft.KubernetesConfiguration/extensions@2023-05-01' = {
  name: 'flux'
  scope: aks
  properties: {
    extensionType: 'microsoft.flux'
    scope: {
      cluster: {
        releaseNamespace: 'flux-system'
      }
    }
    autoUpgradeMinorVersion: true
  }
}

output resourceId string = aks.id
