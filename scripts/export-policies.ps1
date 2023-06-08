# Connect to your Azure account
Connect-AzAccount

# Set the variables
$outputFile = "c:\temp\allpolicyoutput.csv"

# Get all policies
$policys = Get-AzPolicyDefinition | Select-Object Name,ResourceId -ExpandProperty Properties

# Create an array to store the results
$results = @()

foreach ($policy in $policys) {
    # GUID, DisplayName, Description, Category, Version, ResourceID
    # $policy = Get-AzPolicyDefinition -Id $policyid | Select-Object Name,ResourceId -ExpandProperty Properties
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