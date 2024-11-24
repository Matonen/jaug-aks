targetScope = 'subscription'

param env string

param solution string

param location string = deployment().location

param clusterAdmins string[] = []

resource rg 'Microsoft.Resources/resourceGroups@2023-07-01' = {
  name: 'rg-${solution}-${env}'
  location: location
}

module aks '../../modules/aks/aks.bicep' = {
  name: 'aks'
  params: {
    location: location
    name: 'aks-${solution}-${env}'
  }
  scope: rg
}

module adminRoleAssignment '../../modules/aks/role-assignment.bicep' = {
  name: 'adminRoleAssignment'
  params: {
    principalIds: clusterAdmins
    resourceId: aks.outputs.resourceId
    roleName: 'Azure Kubernetes Service RBAC Cluster Admin'
  }
  scope: rg
}
