# Read the CSV file
$csvFilePath = "C:\Repos\azure-nzism\csv\policies.csv"
$csvData = Import-Csv -Path $csvFilePath

# Initialize an array to store the policy definitions
$policyDefinitionsArray = @()

# Check if the policies are already cached locally
$cacheFilePath = "C:\Repos\azure-nzism\json\allpolicies.json"
if (Test-Path -Path $cacheFilePath) {
    # If cached, read the policies from the local cache file
    $policyCache = Get-Content -Raw -Path $cacheFilePath | ConvertFrom-Json
} else {
    # If not cached, get all policies from Azure and cache them locally
    $policyCache = Get-AzPolicyDefinition | ForEach-Object { [PSCustomObject]@{ PolicyDefinitionId = $_.Name; PolicyReferenceId = $_.Properties.DisplayName; ResourceID = $_.ResourceID } }
    $policyCache | ConvertTo-Json | Out-File -FilePath $cacheFilePath -Encoding UTF8
}

# Iterate through each row in the CSV and construct the JSON object
foreach ($row in $csvData) {
    $policy = $policyCache | Where-Object { $_.PolicyDefinitionId -eq $row.policyDefinitionId }
    
    If ($null -eq $policy){
        Write-Host "Policy not found: $($row.policyDefinitionId)"
        Continue
    }

    If ($row.parameters.trim() -eq "") {
        $rowparams = @{}
    } Else {
        write-host $row.parameters
        $rowparams = ConvertFrom-Json $row.parameters
    }

    $policyDefinition = [ordered]@{
        "policyDefinitionId" = $policy.PolicyDefinitionId
        "policyDefinitionReferenceId" = "$($policy.PolicyReferenceId)_1"
        "parameters" = $rowparams
        "groupNames" = @($row.groupnames -split ',')
    }
    $policyDefinitionsArray += $policyDefinition
}

# Convert the array of policy definitions to JSON format
$jsonOutput = ConvertTo-Json $policyDefinitionsArray

# Save the JSON output to a file
$jsonOutputFilePath = "C:\Repos\azure-nzism\json\test.json"
$jsonOutput | Out-File -FilePath $jsonOutputFilePath -Encoding UTF8