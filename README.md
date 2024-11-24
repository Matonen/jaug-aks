# JAUG - AKS

This project provides infrastructure as code (IaC) for deploying an Azure Kubernetes Service (AKS) cluster and managing applications using GitOps. 

It includes Bicep templates for provisioning the AKS cluster and Flux configurations for continuous deployment of applications.

## Deploy AKS

To deploy AKS to Azure, follow these steps:

1. Open terminal
2. Log in using your Microsoft Entra ID credentials: `az login`
3. Go to the directory: `cd infra/bicep/stacks/aks`
4. First verify the changes using what-if command: 
    ```shell
    az deployment sub what-if --subscription {subscription} --location {location} --template-file main.bicep --parameters {env}.bicepparam
    ```
5. Deploy the stack: 
    ```shell
    az stack sub create --name aks --subscription {subscription} --location {location} --deny-settings-mode none --action-on-unmanage deleteAll --template-file main.bicep --parameters {env}.bicepparam
    ```

## Deploy GitOps configuration

To deploy GitOps configuration to AKS, follow these steps:

1. Open terminal
2. Log in using your Microsoft Entra ID credentials: `az login`
3. Go to the directory: `cd infra/bicep/stacks/gitops`
4. First verify the changes using what-if command: 
    ```shell
    az deployment sub what-if --subscription {subscription} --location {location} --template-file main.bicep --parameters {env}.bicepparam
    ```
5. Deploy the stack: 
    ```shell
    az stack sub create --name gitops --subscription {subscription} --location {location} --deny-settings-mode none --action-on-unmanage deleteAll --template-file main.bicep --parameters {env}.bicepparam
    ```

## Manually deploy application

First, you need to configure `kubectl` to connect to your Kubernetes cluster using the `az aks get-credentials` command.

```shell
az aks get-credentials --resource-group {resource group name} --name {cluster name} --subscription {subscription}
```

NOTE! 

Use `kubectl` to display and change the contexts:

* Show current context: `kubectl config current-context`
* Show all contexts: `kubectl config get-contexts`
* Change context: `kubectl config set-context {new-context}`

Installing the app on a Kubernetes cluster can be done using the following command:

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