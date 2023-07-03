New-AzPolicySetDefinition -Name 'VMPolicySetDefinition-new' -PolicyDefinition "C:\temp\initiative.json"


$initiativeName = "VMPolicySetDefinition"
$outputFilePath = "C:\temp\initiative.json"

Get-AzPolicySetDefinition -Name $initiativeName | ConvertTo-Json | Out-File -Encoding utf8 $outputFilePath


$jsonContent = @"
{
  "Name": "VMPolicySetDefinition-new",
  "ResourceId": "/subscriptions/85adcf7e-671a-4072-8e0e-951d6d6b4e92/providers/Microsoft.Authorization/policySetDefinitions/VMPolicySetDefinition",
  "ResourceName": "VMPolicySetDefinition",
  "ResourceType": "Microsoft.Authorization/policySetDefinitions",
  "SubscriptionId": "85adcf7e-671a-4072-8e0e-951d6d6b4e92",
  "PolicySetDefinitionId": "/subscriptions/85adcf7e-671a-4072-8e0e-951d6d6b4e92/providers/Microsoft.Authorization/policySetDefinitions/VMPolicySetDefinition",
  "Properties": {
    "Description": "",
    "DisplayName": "VMPolicySetDefinition",
    "Metadata": {
      "category": "Virtual Machine",
      "createdBy": "b2218229-7b87-4dd8-90ce-5ab4a290c3f6",
      "createdOn": "2023-06-12T23:55:38.2134976Z",
      "updatedBy": "b2218229-7b87-4dd8-90ce-5ab4a290c3f6",
      "updatedOn": "2023-06-13T01:43:21.6396487Z"
    },
    "Parameters": {
      "tagname": "@{type=string; metadata=; defaultValue=eastus2}"
    },
    "PolicyDefinitionGroups": [
      {
        "name": "test group",
        "category": "Regulation Category New",
        "displayName": "test group name",
        "description": "description field"
      }
    ],
    "PolicyDefinitions": [
      {
        "policyDefinitionReferenceId": "855759410695797516",
        "policyDefinitionId": "/providers/Microsoft.Authorization/policyDefinitions/2a0e14a6-b0a6-4fab-991a-187a4f81c498",
        "parameters": {},
        "groupNames": []
      },
      {
        "policyDefinitionReferenceId": "11182806939153959432",
        "policyDefinitionId": "/providers/Microsoft.Authorization/policyDefinitions/464dbb85-3d5f-4a1d-bb09-95a9b5dd19cf",
        "parameters": {},
        "groupNames": []
      }
    ],
    "PolicyType": 1
  }
}
"@

$policySetDefinition = ConvertFrom-Json $jsonContent
New-AzPolicySetDefinition -Name $policySetDefinition.Name -DisplayName $policySetDefinition.Properties.DisplayName -PolicyDefinition $policySetDefinition.Properties.PolicyDefinitions
