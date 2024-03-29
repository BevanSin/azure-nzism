# Connect to your Azure account
Connect-AzAccount -Tenant d02e3566-b45b-4488-90ee-3e83ae8982a8

# Set the variables
$policyInitiativeName = "New Zealand ISM Restricted v3.6"
$outputFile = "c:\temp\policyoutput.csv"

# Get the built-in policy initiative
$policyInitiative = Get-AzPolicySetDefinition | select-object -ExpandProperty Properties | Where-Object {$_.DisplayName -eq $policyInitiativeName}

# Get all the policies in the policy initiative
#$policies = Get-AzPolicyDefinition | Where-Object {$_.PolicySetDefinitionId -eq $policyInitiative.Id}
$policyids = $policyInitiative.PolicyDefinitions.policyDefinitionId

# Create an array to store the results
$results = @()

# Export each policy to a JSON file
foreach ($policyid in $policyids) {
    # GUID, DisplayName, Description, Category, Version, ResourceID
    $policy = Get-AzPolicyDefinition -Id $policyid | Select-Object Name,ResourceId -ExpandProperty Properties
    Write-host $policy.name
    # $policydetails = Get-AzPolicyDefinition -Name $policy.name | Select-Object -ExpandProperty Properties
    # $result = "$($policy.name)", "$($policy.DisplayName)", "$($policy.Description)", "$($policy.Metadata.category)", "$($policy.Metadata.version)", "$($policy.ResourceId)"
    $result = [ordered] @{
        'guid' = ""
        'DisplayName' = ""
        'Description' = ""
        'Category' = ""
        'Version' = ""
        'ResourceID' = ""
    }

    $result."guid" = $policy.name
    $result."DisplayName" = $policy.DisplayName
    $result."Description" = $policy.Description
    $result."Category" = $policy.Metadata.category
    $result."Version" = $policy.Metadata.version
    $result."ResourceID" = $policy.ResourceId
    $objRecord = New-Object PSObject -property $Result
    $results += $objRecord
}

# Export the results to a CSV file
$results | Export-Csv -Path $outputFile

Write-Host "All policies exported successfully!"

# Disconnect from Azure
Disconnect-AzAccount