# Define variables
$repoRoot = Join-Path $PSScriptRoot '..\'

# Construct the path to the 'json' folder
$jsonPath = Join-Path $repoRoot 'json'
$csvPath = Join-Path $repoRoot 'csv'

$initname = "nzism-3.6-policyset" 
$initdisplayname = "New Zealand ISM Restricted v3.6" 
$initdescription = "This initiative includes policies that address a subset of New Zealand Information Security Manual v3.6 controls. Additional policies will be added in upcoming releases. For more information, visit https://aka.ms/nzism-initiative." 
$initmetadata = "category=Regulatory Compliance","version=1.0"
$initdefinitionsfile = Join-Path $jsonPath 'nzism3.6.definitions.json'
$initparamsfile = Join-Path $jsonPath 'nzism3.6.parameters.json'
$initgroupfile = Join-Path $jsonPath 'nzism3.6.groups.json'
$outputFilePath = Join-Path $jsonPath 'nzism3.6.json'
$parametersFilePath = Join-Path $csvPath 'params.csv'
$policyFilePath = Join-Path $csvPath 'policies.csv'
$controlsFilePath = Join-Path $csvPath 'controls.csv'

# Check if the policies are already cached locally
$cacheFilePath = Join-Path $jsonPath 'allpolicies.json'
if (Test-Path -Path $cacheFilePath) {
    # If cached, read the policies from the local cache file
    $policyCache = Get-Content -Raw -Path $cacheFilePath | ConvertFrom-Json
} else {
    # If not cached, get all policies from Azure and cache them locally
    $policyCache = Get-AzPolicyDefinition | ForEach-Object { [PSCustomObject]@{ PolicyDefinitionId = $_.Name; PolicyReferenceId = $_.Properties.DisplayName; ResourceID = $_.ResourceID } }
    $policyCache | ConvertTo-Json | Out-File -FilePath $cacheFilePath -Encoding UTF8
}

#Create parts of the initiative

#create the params file##############################################################################################
$controls = Get-Content -Path $parametersFilePath -Encoding UTF8 | ConvertFrom-Csv -Delimiter '|'

# Initialize a hashtable to store the policy definitions
$paramsControls = @{}

# Iterate through each row in the CSV and construct the JSON object
foreach ($row in $controls) {
    $paramName = $row.ParameterName

    $type = $row.Type
    $isInteger = $type -eq "Integer"
    $isBoolean = $type -eq "Boolean"
    $isObject = $type -eq "Object"
    $isArray = $type -eq "Array"

    $paramsControls[$paramname] = [ordered]@{
        "type" = $type
        "metadata" = @{
            "displayName" = $row.DisplayName
            "description" = $row.Description
        }
    }
    
    if ($row.AllowedValues -ne "") {
        $allowedValues = $row.AllowedValues -split ';'
        if ($isInteger) {
            $allowedValues = $allowedValues | ForEach-Object { [int]$_ }
        } elseif ($isBoolean) {
            $allowedValues = $allowedValues | ForEach-Object { [bool]$_ }
        }
        $paramsControls[$paramname].Add("allowedValues", $allowedValues)
    }

    $defaultValue = $row.DefaultValue

    if ($isObject -and $defaultValue.Length -eq 0) {
        $defaultValue = [ordered]@{}
    } elseif ($isInteger -and $defaultValue) {
        $defaultValue = [int]$defaultValue
    } elseif ($isBoolean -and $defaultValue) {
        $defaultValue = [bool]$defaultValue
    } elseif ($isArray -and $defaultValue) {
        $defaultValue = @($defaultValue -split ';')       
    }  

    if ($defaultValue -ne "") {
        $paramsControls[$paramname].Add("defaultValue", $defaultValue)
    }
}

# Convert the hashtable to JSON format
$jsonParamsOutput = ConvertTo-Json $paramsControls

# Save the JSON output to a file
$jsonParamsOutput | Out-File -FilePath $initparamsfile -Encoding utf8

#create the policies file##############################################################################################
# Load policies from CSV file
$policies = Import-Csv -Path $policyFilePath

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
            $paramName, $paramValue = $param.Split('-', 2)
            $paramHashtable[$paramName] = @{ "value" = "[parameters('$param')]"}
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
$jsonDefOutput = ConvertTo-Json $policyDefinitionsArray -Depth 100

# Save the JSON output to a file
$jsonDefOutput | Out-File -FilePath $initdefinitionsfile -Encoding UTF8

#create the groups file##############################################################################################
# Read the CSV file
$csvData = Get-Content -Path $controlsFilePath -Encoding UTF8 | ConvertFrom-Csv -Delimiter '|'

# Initialize an array to store the policy definitions
$policyControlsArray = @()

$definitionscache = Get-Content -Raw -Path $initdefinitionsfile -Encoding utf8 | ConvertFrom-Json

# Iterate through each row in the CSV and construct the JSON object
foreach ($row in $csvData) {
    $definition = $null
    $definition = $definitionscache | Where-Object { $_.groupNames -eq $row.name }

    if($row.name.Length -lt 8){
        
        $policyControls = [ordered]@{
            "name" = $row.name
            "category" = $row.category
            "displayName" = $row.displayName
            "description" = "$($row.description)  $($row.url)"
        }
        $policyControlsArray += $policyControls        
    }
    elseif($null -ne $definition) {
        $policyControls = [ordered]@{
            "name" = $row.name
            "category" = $row.category
            "displayName" = $row.displayName
            "description" = "$($row.description)  $($row.url)"
        }
        $policyControlsArray += $policyControls
    }
}

# Convert the array of policy definitions to JSON format
$jsonControlsOutput = ConvertTo-Json $policyControlsArray

# Save the JSON output to a file
$jsonControlsOutput | Out-File -FilePath $initgroupfile -Encoding utf8

# Convert policy set definition to JSON and output to file
$policySetDefinitionJson = az policy set-definition create --name $initname --display-name $initdisplayname --metadata $initmetadata --description $initdescription  --definitions $initdefinitionsfile --params $initparamsfile --definition-groups $initgroupfile
$policySetDefinitionJson | Out-File -Encoding utf8 $outputFilePath

Write-Host "Policy set definition saved to $outputFilePath"