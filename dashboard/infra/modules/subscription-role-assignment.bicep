targetScope = 'subscription'

@description('Principal ID of the managed identity receiving the role.')
param principalId string

@description('Role definition GUID to assign at the subscription scope.')
param roleDefinitionId string

resource roleAssignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid(subscription().id, principalId, roleDefinitionId)
  properties: {
    roleDefinitionId: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', roleDefinitionId)
    principalId: principalId
    principalType: 'ServicePrincipal'
  }
}
