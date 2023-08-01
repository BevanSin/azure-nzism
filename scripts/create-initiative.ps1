# Define variables
$initname = "nzism-3.6-policyset" 
$initdisplayname = "New Zealand ISM Restricted v3.6" 
$initdescription = "This initiative includes policies that address a subset of New Zealand Information Security Manual v3.6 controls. Additional policies will be added in upcoming releases. For more information, visit https://aka.ms/nzism-initiative." 
$initmetadata = '{"category":"Regulatory Compliance","version":"1.0"}'
$initdefinitionsfile = "C:\repos\azure-nzism\json\nzism3.6.definitions.json" 
$initparamsfile = "C:\repos\azure-nzism\json\nzism3.6.parameters.json" 
$initgroupfile = "C:\repos\azure-nzism\json\nzism3.6.groups.json" 
$outputFilePath = "C:\repos\azure-nzism\json\nzism3.6.json" 
$parametersFilePath = "C:\Repos\azure-nzism\csv\params.csv"
$policyFilePath = "C:\Repos\azure-nzism\csv\policies.csv"
$controlsFilePath = "C:\Repos\azure-nzism\csv\controls.csv"

# Load policies from CSV file
$controls = Import-Csv -Path $controlsFilePath

# Load policies from CSV file
$policies = Import-Csv -Path $policyFilePath

# Load parameters from CSV file
$parameters = Import-Csv -Path $parametersFilePath

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

#Create parts of the initiative
#policydefinitiongroups = controls = groups = metadata - only use groups referenced by policies and also heading groups - nzism3.6.groups.json
#policyDefinitions = policies to include in initiative - nzism3.6.definitions.json
#parameters - params for each policy if required - nzism3.6.parameters.json

# Iterate through each row in the CSV and construct the JSON object
foreach ($row in $policies) {
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
$jsonOutput | Out-File -FilePath $initdefinitionsfile -Encoding UTF8


#create the groups file
# will need a list of groups called from the policy input
# will need to include the heading groups that dont have a C in the name

# Convert policy set definition to JSON and output to file
$policySetDefinitionJson = az policy set-definition create --name $initname --display-name $initdisplayname --metadata $initmetadata --description $initdescription  --definitions $initdefinitionsfile --params $initparamsfile --definition-groups $initgroupfile
$policySetDefinitionJson | Out-File -Encoding utf8 $outputFilePath

Write-Host "Policy set definition saved to $outputFilePath"
