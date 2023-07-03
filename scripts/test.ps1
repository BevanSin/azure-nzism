# Define variables
$policySetDefinitionName = "New Zealand ISM Restricted v3.6"
$policySetDescription = "This initiative includes policies that address a subset of New Zealand Information Security Manual v3.6 controls. Additional policies will be added in upcoming releases. For more information, visit https://aka.ms/nzism-initiative. "
$outputFilePath = "policysetdefinitiontest.json"
$initiativeVersion = "1.0.0"
$initiativeCategory = "Regulatory Compliance"
$csvlocation = "C:\Repos\azure-nzism\csv\"

# Check if all CSV files available
Write-Host "Check CSV Files available"
if (-not (Test-Path -Path "$($csvlocation)allpolicyoutput.csv")) {
    Write-Error "The policy cache file '$($csvlocation)allpolicyoutput.csv' does not exist."
    return
}

if (-not (Test-Path -Path "$($csvlocation)policies.csv")) {
    Write-Error "The policy cache file '$($csvlocation)policies.csv' does not exist."
    return
}

if (-not (Test-Path -Path "$($csvlocation)policies.csv")) {
    Write-Error "The policy cache file '$($csvlocation)controls.csv' does not exist."
    return
}

# Read policies from the locally cached CSV file
Write-Host "Load policy data"
$allPolicyDefinitions = Import-Csv -Path "$($csvlocation)allpolicyoutput.csv"

# Start constructing Intitiative
Write-Host "Creating initiative structure"
$policyInitiative = [ordered]@{
    "properties" = [ordered]@{
        "displayName" = "$policySetDefinitionName"
        "policyType" = "Custom"
        "description" = "$policySetDescription"
        "metadata" = [ordered]@{
            "category" = "$initiativeCategory"
            "version" = "$initiativeVersion"
        }
        "parameters" = @{}
        "policyDefinitions" = @(
        )
        "policyDefinitionGroups" = @(
        )
    }
}

# Read policies from CSV and update the policyDefinitions property
Write-Host "Import policy definitions from CSV"
$policyDefinitionsCSV = Import-Csv -Path "$($csvlocation)policies.csv"

$policyDefinitions = foreach ($policy in $policyDefinitionsCSV) {
    $policyGuid = $policy.policy
    $groupName = $policy.groupname

    # Lookup policy details in the cached policy definitions
    $policyDefinition = $allPolicyDefinitions | Where-Object { $_.ResourceID -eq "/providers/Microsoft.Authorization/policyDefinitions/$policyGuid" }

    if ($policyDefinition) {
        $policyReferenceId = $policyDefinition.DisplayName
        $policyDefinitionId = $policyDefinition.ResourceID

        $policyEntry = [ordered]@{
            "policyDefinitionReferenceId" = $policyReferenceId
            "policyDefinitionId" = $policyDefinitionId
            "parameters" = @{}
            "groupNames" = @($groupName)
        }

        # Add the policy entry to the policyDefinitions array
        $policyInitiative.properties.policyDefinitions += $policyEntry
        
    } else {
        Write-Warning "Policy definition with GUID '$policyGuid' not found."
    }

}

# Read policies from CSV and update the policyDefinitions property
Write-Host "Import policy groups from CSV"
$policyDefinitionGroupsCsv = Import-Csv -Path "$($csvlocation)controls.csv"

foreach ($group in $policyDefinitionGroupsCsv) {
    $policyDefinitionGroup = [ordered]@{
        "name" = $group.name
        "category" = $group.category
        "displayName" = $group.displayName
        "description" = $group.description
    }
    
    # Section removed as initatives only support published metadata in the Azure platform
    # if ($group.url) {
    #     $policyDefinitionGroup.Add("additionalMetadataId", $group.url)
    # }
    
    $policyInitiative.properties.policyDefinitionGroups += $policyDefinitionGroup
}

# Convert policy set definition to JSON
Write-Host "Convert to JSON"
$policySetDefinitionJson = ConvertTo-Json $policyInitiative -Depth 100

# Add square brackets at the start and end of the JSON
$policySetDefinitionJson = "[`n" + $policySetDefinitionJson.TrimStart() + "`n]"

# Output JSON to file
Write-Host "Output to file"
$policySetDefinitionJson | Out-File -Encoding utf8 $outputFilePath

Write-Host "Policy set definition saved to $outputFilePath"