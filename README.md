# JAUG - AKS



## Deploy AKS

To deploy AKS to Azure, follow these steps:

1. Open terminal
2. Log in using your Azure AD credentials: `az login`
3. Go to the directory: `cd infra/bicep`
4. First verify the changes using what-if command: `az deployment sub what-if --subscription {subscription} --location {location} --template-file main.bicep --parameters {env}.bicepparam`
5. Deploy the stack: `az stack sub create --name {stack} --subscription {subscription} --location {location} --deny-settings-mode none --action-on-unmanage deleteAll --template-file main.bicep --parameters {env}.bicepparam`


## Deploy application

First you need to configure `kubectl` to connect to your Kubernetes cluster using the az aks get-credentials command.

```shell
az aks get-credentials --resource-group {resource group name} --name {cluster name} --subscription {subscription}
```

NOTE! 

Use  kubectl to display and change the contexts:

* Show current context: `kubectl config current-context`
* Show all context: `kubectl config get-contexts`
* Change context: `kubectl config set-context {new-context}`


Installing app on a Kubernetes cluster can be done using following command:

```shell

# Review manifest

kubectl kustomize gitops/clusters/development/aks-jaug/hello-dotnet 

# Apply changes to a resource or create it if it doesn’t exist.
kubectl apply -k gitops/clusters/development/aks-jaug/hello-dotnet 

```


```shell
# Check status of pods
kubectl get pods -n jaug

# Check logs
kubectl logs -l app=hello-dotnet -n jaug --tail=1000

# Check resource usage
kubectl top pod -l app=hello-dotnet -n jaug --containers

# Show detailed information about a pod.
kubectl describe pod -l app=hello-dotnet -n jaug

# Check services
kubectl get service -n jaug

# Cleanup
kubectl delete namespace jaug
```