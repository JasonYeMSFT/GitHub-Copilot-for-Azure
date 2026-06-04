targetScope = 'subscription'

@description('Principal ID of the managed identity to assign the Contributor role to at subscription scope.')
param principalId string

var contributorRoleId = 'b24988ac-6180-42a0-ab88-20f7382dd24c'

resource contributorRole 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid(subscription().id, principalId, contributorRoleId)
  properties: {
    roleDefinitionId: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', contributorRoleId)
    principalId: principalId
    principalType: 'ServicePrincipal'
  }
}
