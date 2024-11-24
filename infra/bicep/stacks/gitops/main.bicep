targetScope = 'subscription'

import { Kustomization } from '../../modules/aks/udd-type.bicep'

param env string

param solution string

param gitUrl string

param kustomizations Kustomization[]

param branchName string

@secure()
param gitUsername string

@secure()
param gitPat string

resource rg 'Microsoft.Resources/resourceGroups@2023-07-01' existing = {
  name: 'rg-${solution}-${env}'
}

resource aks 'Microsoft.ContainerService/managedClusters@2024-08-01' existing = {
  name: 'aks-${solution}-${env}'
  scope: rg
}

module gitOps '../../modules/aks/gitops.bicep' = {
  name: 'gitOps'
  params: {
    resourceId: aks.id
    configurationName: 'apps'
    gitUrl: gitUrl
    kustomizations: kustomizations
    gitPat: gitPat
    gitUsername: gitUsername
    branchName: branchName
  }
  scope: rg
}
