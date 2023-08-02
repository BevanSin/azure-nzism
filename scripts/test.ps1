# Read the CSV file
$csvFilePath = "C:\Repos\azure-nzism\csv\policies.csv"
$policies = Import-Csv -Path $csvFilePath

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

# Initialize an array to store the policy definitions
$policyDefinitionsArray = @()

# Iterate through each row in the CSV and construct the JSON object
foreach ($row in $policies) {
    $policy = $policyCache | Where-Object { $_.PolicyDefinitionId -eq $row.policyDefinitionId }

    If ($null -eq $policy) {
        Write-Host "Policy not found: $($row.policyDefinitionId)"
        Continue
    }

    If ($row.parameters.trim() -eq "") {
        $rowparams = @{}
    } Else {
        $rowparams = $row.parameters -split ';'
        $paramHashtable = @{}
        foreach ($param in $rowparams) {
            $paramHashtable[$param] = @{ "value" = "[parameters('$param')]"}
        }
        $rowparams = $paramHashtable
    }

    $policyDefinition = [ordered]@{
        "policyDefinitionReferenceId" = "$($policy.PolicyReferenceId)_1"
        "policyDefinitionId" = $policy.ResourceID
        "parameters" = $rowparams
        "groupNames" = @($row.groupnames -split ',')
    }
    $policyDefinitionsArray += $policyDefinition
}

# Convert the array of policy definitions to JSON format
$jsonDefOutput = $policyDefinitionsArray | ConvertTo-Json -Depth 100

# Save the JSON output to a file
$initdefinitionsfile = "C:\Repos\azure-nzism\json\test.json"
$jsonDefOutput | Out-File -FilePath $initdefinitionsfile -Encoding utf8
