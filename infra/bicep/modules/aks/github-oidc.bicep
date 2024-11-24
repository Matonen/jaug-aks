@description('The resource name.')
param name string

@description('The geo-location where the resource lives.')
param location string

@description('The organization name.')
param organization string

@description('The repository name.')
param repository string

@description('The branch name.')
param branch string = 'main'

resource id 'Microsoft.ManagedIdentity/userAssignedIdentities@2023-07-31-preview' = {
  name: name
  location: location
}

resource federatedIdentityCredential 'Microsoft.ManagedIdentity/userAssignedIdentities/federatedIdentityCredentials@2023-07-31-preview' = {
  name: '${organization}-${repository}-${branch}'
  parent: id
  properties: {
    issuer: 'https://token.actions.githubusercontent.com'
    subject: 'repo:${organization}/${repository}:ref:refs/heads/${branch}'
    audiences: [
      'api://AzureADTokenExchange'
    ]
  }
}

output principalId string = id.properties.principalId
