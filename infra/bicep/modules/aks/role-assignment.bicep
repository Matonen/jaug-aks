@description('The IDs of the principals to assign the role to.')
param principalIds array

@description('The name of the role to assign.')
param roleName string

@description('The ID of the resource to assign the role to.')
param resourceId string

resource aks 'Microsoft.ContainerService/managedClusters@2024-08-01' existing = {
  name: last(split(resourceId, '/'))
}

var builtInRoleNames = {
  'Azure Kubernetes Service RBAC Cluster Admin': subscriptionResourceId(
    'Microsoft.Authorization/roleDefinitions',
    'b1ff04bb-8a4e-4dc4-8eb5-8693973ce19b'
  )
}

resource roleAssignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = [
  for principalId in principalIds: {
    name: guid(aks.name, principalId, roleName)
    properties: {
      roleDefinitionId: builtInRoleNames[roleName]
      principalId: principalId
    }
    scope: aks
  }
]
