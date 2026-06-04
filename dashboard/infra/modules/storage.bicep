targetScope = 'resourceGroup'

@description('Primary location for all resources.')
param location string

@description('Tags to apply to all resources.')
param tags object = {}

@description('Environment name used for unique naming.')
param environmentName string

@description('Principal ID of the managed identity to assign the Storage Blob Data Reader role.')
param principalId string

@description('Principal ID of the CI managed identity to assign Blob and Table Data Contributor roles.')
param ciPrincipalId string

var resourceSuffix = take(uniqueString(subscription().id, resourceGroup().name, environmentName), 6)
var storagePrefix = take(replace(environmentName, '-', ''), 14)
var storageBlobDataReaderRoleId = '2a2b9908-6ea1-4ae2-8e65-a410df84e7d1'
var storageBlobDataContributorRoleId = 'ba92f5b4-2d11-453d-a403-e96b0029c9fe'
var storageTableDataContributorRoleId = '0a9a7e1f-b9d0-4cc4-a60d-0319b160aaa3'

resource storageAccount 'Microsoft.Storage/storageAccounts@2023-05-01' = {
  name: 'str${storagePrefix}${resourceSuffix}'
  location: location
  tags: tags
  kind: 'StorageV2'
  sku: {
    name: 'Standard_LRS'
  }
}

resource blobServices 'Microsoft.Storage/storageAccounts/blobServices@2023-05-01' = {
  parent: storageAccount
  name: 'default'
  properties: {
    isVersioningEnabled: true
  }
}

resource managementPolicies 'Microsoft.Storage/storageAccounts/managementPolicies@2023-05-01' = {
  parent: storageAccount
  name: 'default'
  properties: {
    policy: {
      rules: [
        {
          enabled: true
          name: 'deleteBlobVersionsAfter30Days'
          type: 'Lifecycle'
          definition: {
            filters: {
              blobTypes: [
                'blockBlob'
              ]
            }
            actions: {
              version: {
                delete: {
                  daysAfterCreationGreaterThan: 30
                }
              }
            }
          }
        }
      ]
    }
  }
}

resource integrationReportsContainer 'Microsoft.Storage/storageAccounts/blobServices/containers@2023-05-01' = {
  parent: blobServices
  name: 'integration-reports'
}

resource manualIntegrationReportsContainer 'Microsoft.Storage/storageAccounts/blobServices/containers@2023-05-01' = {
  parent: blobServices
  name: 'manual-integration-reports'
}

resource nonIntegrationContainer 'Microsoft.Storage/storageAccounts/blobServices/containers@2023-05-01' = {
  parent: blobServices
  name: 'non-integration'
}

resource storageBlobDataReaderRole 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid(storageAccount.id, principalId, storageBlobDataReaderRoleId)
  scope: storageAccount
  properties: {
    roleDefinitionId: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', storageBlobDataReaderRoleId)
    principalId: principalId
    principalType: 'ServicePrincipal'
  }
}

resource ciStorageBlobDataContributorRole 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid(storageAccount.id, ciPrincipalId, storageBlobDataContributorRoleId)
  scope: storageAccount
  properties: {
    roleDefinitionId: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', storageBlobDataContributorRoleId)
    principalId: ciPrincipalId
    principalType: 'ServicePrincipal'
  }
}

resource ciStorageTableDataContributorRole 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid(storageAccount.id, ciPrincipalId, storageTableDataContributorRoleId)
  scope: storageAccount
  properties: {
    roleDefinitionId: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', storageTableDataContributorRoleId)
    principalId: ciPrincipalId
    principalType: 'ServicePrincipal'
  }
}

output storageAccountName string = storageAccount.name
