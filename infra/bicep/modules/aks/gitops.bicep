import { Kustomization } from './udd-type.bicep'

@description('Resource ID of the AKS cluster')
param resourceId string

@description('Name of the configuration')
param configurationName string

@description('Kustomization configurations')
param kustomizations Kustomization[]

@description('The URL to sync for the flux configuration git repository.')
param gitUrl string

@description('Username for the git repository.')
@secure()
param gitUsername string

@description('Personal Access Token for the git repository.')
@secure()
param gitPat string

@description('The git repository branch name to checkout.')
param branchName string = 'main'

@description('The interval at which to re-reconcile the cluster git repository source with the remote.')
param syncIntervalInSeconds int = 60

@description('The maximum time to attempt to reconcile the cluster git repository source with the remote.')
param syncTimeoutInSeconds int = 60

resource aks 'Microsoft.ContainerService/managedClusters@2024-08-01' existing = {
  name: last(split(resourceId, '/'))
}

resource fluxConfig 'Microsoft.KubernetesConfiguration/fluxConfigurations@2024-04-01-preview' = {
  name: configurationName
  scope: aks
  properties: {
    scope: 'cluster'
    namespace: 'flux-system'
    sourceKind: 'GitRepository'
    suspend: false
    waitForReconciliation: false
    gitRepository: {
      url: gitUrl
      localAuthRef: '${configurationName}-protected-parameters'
      repositoryRef: {
        branch: branchName
      }
      syncIntervalInSeconds: syncIntervalInSeconds
      timeoutInSeconds: syncTimeoutInSeconds
    }
    kustomizations: reduce(
      kustomizations,
      {},
      (acc, item) =>
        union(acc, {
          '${item.name}': {
            path: item.path
            syncIntervalInSeconds: item.syncIntervalInSeconds
            timeoutInSeconds: item.syncTimeoutInSeconds
            retryIntervalInSeconds: item.syncRetryIntervalInSeconds ?? item.syncIntervalInSeconds
            prune: item.prune
            force: item.force
          }
        })
    )
    configurationProtectedSettings: {
      username: base64(gitUsername)
      password: base64(gitPat)
    }
  }
}
