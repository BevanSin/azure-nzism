<#
    HowTo-Create_Complex_Initiative_Example.ps1

    Created by: Brooks Vaughn (programming@brooksvaughn.net)
        Microsoft Tech Communty Id: @BrooksV

    Note: This example was based on Microsoft Tech Communty Discussion 
          https://techcommunity.microsoft.com/t5/azure-governance-and-management/policy-initiative/m-p/2728941

    This script supports the following:

    - Initiatives based on Custom and Built-In Polices
    - Dynamic creation for multiple Assignment Scopes
    - Dynamic creation for Parameters and Values including Effect Parameter
    - Dynamic creation of Default and Tag specific NonComplianceMessages for Assignments
    - Dynamic creation RBAC Role Assignments for Managed Identity when required. 
        Modify (as well as deployIfNotExists) Policies requires RBAC role assignments to be
          created as part of the Policy Assignments Process

    
#>

#--------------------------------------------------------------
# Define Constants and Script Variables
#--------------------------------------------------------------
$EoL = [Environment]::NewLine

#--------------------------------------------------------------
# Define your list of Tags to include in the Initiative
#--------------------------------------------------------------
$TagNames = @(
    "Approver",
    "Service",
    "Owner",
    "Project",
    "Environment",
    "Compliance",
    "Program",
    "TestTag"
)

#------------------------------------------------------------------------------------------
# Suggestion: Number your Management Groups according to nesting levels Name (DisplayName)
# This keeps the Name/ID short and simple and easier to query
#------------------------------------------------------------------------------------------
#   Name/GroupId: MG-01-0001, DisplayName: "Level-1 MG for Accounting"
#   Name/GroupId: MG-02-0001, DisplayName: "Level-2 MG for Accounting - Receivables"
#   Name/GroupId: MG-02-0002, DisplayName: "Level-2 MG for Accounting - Payable"
#   Name/GroupId: MG-01-0002, DisplayName: "Level-1 MG for HR"
#   Name/GroupId: MG-02-0001, DisplayName: "Level-2 MG for HR - Recruitment"
#   Name/GroupId: MG-02-0002, DisplayName: "Level-2 MG for HR - Staff"
#   Name/GroupId: MG-03-0001, DisplayName: "Level-3 MG for HR - Employees"
#   Name/GroupId: MG-03-0002, DisplayName: "Level-3 MG for HR - Contractrors"
#----------------------------------------------------------------------------------------------
$initiativeScope = 'MGNAME'

#--------------------------------------------------------------------------
# Assignment Scopes - Configured for ManagementGroups Only in this Example
#--------------------------------------------------------------------------
$assignmentScopes = @(
    'MGNAME'
)

#--------------------------------------------------------------------------------------------
# This Initiative Example Uses Builtin Polcy Example and / or a Custom Example:
#   ea3f2387-9b95-492a-a190-fcdc54f7b070 (Inherit a tag from the resource group if missing)
#   The Effect of the Built-on policy is hardcoded as Modify
# If a custom version is created with a parameterized Effect, then the
#   Initiative could also included an Effect for each TagName so they can be set to 
#   Audit, Deny, or Disabled by editing the Assignment for the Initiative
#--------------------------------------------------------------------------------------------
# Note: PolicyDisplayName does not have to match the Built-In policy name
# The $policyGroupId for a Custom Policy does not have to be a GUID either
#--------------------------------------------------------------------------------------------
$doGenerateCustomExample = $false
If ($doGenerateCustomExample) {
    $policyDisplayName = 'Custom-Inherit-approver-tag-from-the-resource-group-if-missing' 
    $policyName = 'b331c88b-44e3-4bc4-82ab-b6b558df9048'
} Else {
    $policyDisplayName = 'Inherit a tag from the resource group if missing' # 'Inherit approver tag from the resource group if missing' 
    $policyName = 'ea3f2387-9b95-492a-a190-fcdc54f7b070'
}

$roleDefinitionIds = @()
#-------------------------------------------------------
# Get the Policy Definition for the Policy
#-------------------------------------------------------
$PolicyDefintion = Get-AzPolicyDefinition -Name $policyName
#-------------------------------------------------------
# If the Effect is Modify or DeployIfNotExists, then an 
#   Identity and RBAC role assignments will be required
#-------------------------------------------------------
$Effect = $PolicyDefintion.Properties.PolicyRule.then.effect
$AssignIdentity = ($Effect -in @('modify','deployIfNotExists'))
If ($AssignIdentity) {
    $roleDefinitionIds = $PolicyDefintion.Properties.PolicyRule.then.details.roleDefinitionIds
}

#----------------------------------------------------------------------------
# Important set to $true is Policy Definition uses the effect Parameter
#   Custom Policies should include the effect parameter
#   Not All Built-In Policies include the effect parameter
#----------------------------------------------------------------------------
$doPolicyHasEffectParam = $false

#-----------------------------------------------------------------------------
# Create a JSON String for a Policy Initiatice based on the desired settings
#-----------------------------------------------------------------------------
$jsonPolicyDefinitions = [string]::Empty
$jsonPolicyDefinitions += '[' + $Eol

$jsonParameters = [string]::Empty
$jsonParameters += '{' + $Eol

#-----------------------------------------------------------------------------
# Generate Policy Initiative Definition for a Custom Policy that has Effect Parameter
#-----------------------------------------------------------------------------
If ($doGenerateCustomExample) {
    $iCount = 0
    $TagNames | % {
        $iCount++
        $tagName = $_
        $jsonPolicyDefinitions += @"
      {
        "policyDefinitionReferenceId": "$policyDisplayName group_$($iCount.ToString())",
        "policyDefinitionId": "/providers/Microsoft.Management/managementGroups/$initiativeScope/providers/Microsoft.Authorization/policyDefinitions/$policyName",
        "parameters": {
          "effect": {
            "value": "[parameters('effect-$tagName')]"
          },
          "tagName": {
            "value": "[parameters('tagname-$tagName')]"
          }
        },
        "groupNames": []
      },
"@
    }
} Else {
    #-----------------------------------------------------------------------------
    # Generate Policy Initiative Definition for a Built-in Policy
    #-----------------------------------------------------------------------------
    $iCount = 0
    $TagNames | % {
        $iCount++
        $tagName = $_
        $jsonPolicyDefinitions += @"
      {
        "policyDefinitionReferenceId": "$policyDisplayName group_$($iCount.ToString())",
        "policyDefinitionId": "/providers/Microsoft.Authorization/policyDefinitions/$policyGroupId",
        "parameters": {
          "tagName": {
            "value": "[parameters('tagname-$tagName')]"
          }
        },
        "groupNames": []
      },
"@
    }
}
#-------------------------------------------------------------------------------------
# Convert JSON to PSObject after removing trailing comma and adding closing Array char
#-------------------------------------------------------------------------------------
$jsonPolicyDefinitions = $jsonPolicyDefinitions.TrimEnd(',') + $EoL + ']' + $EoL
$policyDefinitions = $jsonPolicyDefinitions | ConvertFrom-Json

#-----------------------------------------------------------------------------
# Generate TagName and Effect Parameters
#-----------------------------------------------------------------------------
If ($doGenerateCustomExample) {
    $jsonParameters += $TagNames | % {
        $jsonParameters += @"
    "effect-$tagName": {
    "type": "String",
    "metadata": {
        "displayName": "effect-for-$tagName",
        "description": "effect for $tagName"
    },
    "allowedValues": [
        "Audit",
        "Deny",
        "Disabled"
    ],
    "defaultValue": "Audit"
    },
    "tagname-$tagName": {
    "type": "String",
    "metadata": {
        "displayName": "$tagName",
        "description": "$tagName tagName parameter"
    },
    "allowedValues": [
        "$tagName"
    ],
    "defaultValue": "$tagName"
    },
"@
    }
} Else {
    #-----------------------------------------------------------------------------
    # Generate TagName
    #-----------------------------------------------------------------------------
    $TagNames | % {
        $tagName = $_
        $jsonParameters += @"
    "tagname-$tagName": {
    "type": "String",
    "metadata": {
        "displayName": "$tagName",
        "description": "$tagName tagName parameter"
    },
    "allowedValues": [
        "$tagName"
    ],
    "defaultValue": "$tagName"
    },
"@
    }
}
#-------------------------------------------------------------------------------------
# Convert JSON to PSObject after removing trailing comma and adding closing Array char
#-------------------------------------------------------------------------------------
$jsonParameters = $jsonParameters.TrimEnd(',') + $EoL + '}' + $EoL
$Parameters = $jsonParameters | ConvertFrom-Json

#-------------------------------------------------------------------------------------
# Create Initiative by using a Splat for Properties and Property Values
#-------------------------------------------------------------------------------------
$Splat = @{
    Name = 'Tagging-Initiative-001'
    DisplayName = 'Tagging-001-Inherit-From-RG'
    Description = "Tagging Initiative that $policyDisplayName"
    Metadata = '{
    "category": "Tags",
    "version": "1.0"
}'
    PolicyDefinition = ($policyDefinitions | ConvertTo-Json -Depth 99 -Compress)
    Parameter = ($Parameters | ConvertTo-Json -Depth 99 -Compress)
    ManagementGroupName = $initiativeScope
    # SubscriptionId = ''
    GroupDefinition = '[]'
}
Write-Host ('Creating Initiative using: {0}' -f ($Splat | FL | Out-String))

$newInitiative = New-AzPolicySetDefinition @Splat
If (-not $newInitiative) {
    Throw ('Failed to create Initiative: {0}' -f $Splat.Name)
}


If ([string]::IsNullOrEmpty($newInitiative)) {
    $PolicySetDefinitionId = "/providers/Microsoft.Management/managementGroups/$initiativeScope/providers/Microsoft.Authorization/policySetDefinitions/$Splat.Name"
    $PolicySetDefinitionObject = Get-AzPolicySetDefinition -Id $PolicySetDefinitionId
} Else {
    $PolicySetDefinitionObject = Get-AzPolicySetDefinition -Id $newInitiative.PolicySetDefinitionId
}

#--------------------------------------------------------------------------
# Create Assignments for Initiative
#--------------------------------------------------------------------------
ForEach ($assignmentScope in $assignmentScopes) {
    $DisplayName = ('{0}-{1}' -f $assignmentScope, $policyDisplayName)

    #------------------------------------------------------
    # Add / Generate Non-Compliance Messages
    #------------------------------------------------------
    $nonComplianceMessages = @()

    # Set Default Non-Compliance Message
    $nonComplianceMessages += $DefaultnonComplianceMessages = @(
	    @{
		    "message" = "This action is blocked by Tagging Policy Initiative ($policyOrg-$policyNumber) which requires Resources to have Tags with valid values. Assignment: ($DisplayName). Please visit https://pwc.sharepoint.com/sites/GBL-IFS-CSO-Policy for remediation instructions and resolution."
        }
    )

    # Set Non-Compliance Message for Each Required tagName
    $PolicySetDefinitionObject.Properties.PolicyDefinitions | % {
        If ($_.parameters.tagName.value -match "\[parameters\('tagname-(?<tagName>.*)'\)\]") {
            $tagName = 'ghs-{0}' -f $Matches.tagName
            $nonComplianceMessages += @(
                @{
		            "message" = "This action is blocked by Policy $policyNumber which requires Resources to have the Tag ($tagName) with a valid value. Please visit https://pwc.sharepoint.com/sites/GBL-IFS-CSO-Policy for remediation instructions and resolution."
                    "policyDefinitionReferenceId" = "$($_.policyDefinitionReferenceId)"
                }
            )
        }
    }
    # $nonComplianceMessages | ConvertTo-Json -Depth 99

    #------------------------------------------------------
    # Generate Assignment Parameters and Values
    #------------------------------------------------------
    $PolicyParameterObject = @{}
    $TagNames | % {
        $tagName = $_
        $PolicyParameterObject.Add("tagname-$tagName", $tagName)
        If ($doPolicyHasEffectParam) {
            $value = 'deny'
            If ($tagName -in @('TestTag')) {
                $value = 'disabled'
            }
            $PolicyParameterObject.Add("effect-$tagName", $value)
        }

    }
    # $PolicyParameterObject | ConvertTo-Json -Depth 99

    #------------------------------------------------------
    # Configure Splat and Create Assignment
    #------------------------------------------------------
    $assgmtSplat = @{
        Name = ('{0}-{1}' -f $assgmtScope, 'in-301-e')
        Scope = "/providers/Microsoft.Management/managementGroups/$assgmtScope"
        # NotScope = @()
        DisplayName = $DisplayName
        Description = 'Tagging Policies az-301 & az-304'
        # PolicyDefinition = $null
        PolicySetDefinition = $PolicySetDefinitionObject
        PolicyParameterObject = $PolicyParameterObject
        # PolicyParameter = '{}'
        # Metadata = ''
        EnforcementMode = 'Default'
        Location = 'eastus'
        NonComplianceMessage = $nonComplianceMessages
    }

    If ($AssignIdentity) {
        $newAssignment = New-AzPolicyAssignment -AssignIdentity @assgmtSplat
    } Else {
        $newAssignment = New-AzPolicyAssignment @assgmtSplat
    }
    # $newAssignment | ConvertTo-Json -Depth 99

    #-------------------------------------------------------------------------
    # If Assigned Identity, then create RBAC Role Assignments
    # Note: Creating Role Assignments requires the "User Access Administrator" role
    #   assignmened to the SPN that is creating the needed RBAC Role Assignments
    #-------------------------------------------------------------------------
    If (-not [string]::IsNullOrEmpty($newAssignment.Identity)) {
        $Identity = Get-AzADServicePrincipal -ObjectId $newAssignment.Identity.principalId
        Write-Host ("This Policy requires Role Assignments for Identity: `n{0}" -f ($Identity | Out-String)) -ForegroundColor Red

        ForEach ($roleDefinitionId in $roleDefinitionIds) {
            $Role = Get-AzRoleDefinition -Id $roleDefinitionId.Split('/')[-1]
            Write-Host ("Role Assignment: `n{0}" -f ($Role | Out-String)) -ForegroundColor Yellow
            Write-Host ("Creating Role Assignment ({0})) at Scope ({1})" -f $Role.Name, $newAssignment.Properties.Scope) -ForegroundColor Green
            $newRoleAssignment = New-AzRoleAssignment -ObjectId $newAssignment.Identity.PrincipalId -Scope $newAssignment.Properties.Scope -RoleDefinitionId $Role.Id -Description "Role Assignment for Policy $policyName"
            If (-not $newRoleAssignment) {
                Write-Host ("Role Assignment Failed") -ForegroundColor Red
            }
        }
    }
}
