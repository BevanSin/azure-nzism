# Define variables
$repoRoot = Join-Path $PSScriptRoot '..\'

# Construct the path to the 'json' folder
$jsonPath = Join-Path $repoRoot 'json'

$initname = "nzism-3.6-policyset" 
$initdisplayname = "New Zealand ISM Restricted v3.6" 
$initdescription = "This initiative includes policies that address a subset of New Zealand Information Security Manual v3.6 controls. Additional policies will be added in upcoming releases. For more information, visit https://aka.ms/nzism-initiative." 
$initmetadata = "category=Regulatory Compliance","version=1.0"
$initdefinitionsfile = Join-Path $jsonPath 'nzism3.6.definitions.json'
$initparamsfile = Join-Path $jsonPath 'nzism3.6.parameters.json'
$initgroupfile = Join-Path $jsonPath 'nzism3.6.groups.json'
$initMgmtGrp = "Production"
$initSubscription = "85adcf7e-671a-4072-8e0e-951d6d6b4e92"

# Use this line if deploying to a specific management group
# az policy set-definition create --name $initname --display-name $initdisplayname --metadata $initmetadata --description $initdescription  --definitions $initdefinitionsfile --params $initparamsfile --definition-groups $initgroupfile --management-group $initMgmtGrp

# Use this line if deploying to a specific subscription
az policy set-definition create --name $initname --display-name $initdisplayname --metadata $initmetadata --description $initdescription  --definitions $initdefinitionsfile --params $initparamsfile --definition-groups $initgroupfile --subscription $initSubscription