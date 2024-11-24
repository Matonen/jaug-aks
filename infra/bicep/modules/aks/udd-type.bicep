@description('A kustomization to be applied to a Kubernetes cluster.')
@export()
type Kustomization = {
  @description('The name of the kustomization.')
  name: string

  @description('The path within the repository where the Kustomization will begin looking for manifests to reconcile.')
  path: string

  @description('The sync interval defines how often the Kustomization reconciles the cluster with the manifests to ensure that the cluster remains in sync with the Repository.')
  syncIntervalInSeconds: int

  @description('The sync timeout defines how long a Kustomization reconciliation will be allowed to continue before timing out.')
  syncTimeoutInSeconds: int

  @description('The retry interval specifies how often the Kustomization will retry a previously failed reconciliation. If left blank, the value of the sync interval will be used.')
  syncRetryIntervalInSeconds: int?

  @description('Enable prune to assure that objects are removed from the cluster if they are removed from the repository or when this Kustomization or GitOps configuration is removed from the cluster.')
  prune: bool

  @description('nable force to instruct the controller to recreate resources if they cant be changed due to an immutable field change.')
  force: bool
}
