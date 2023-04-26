# Set the path to the input CSV file
$controlsjson = "C:\Repos\azure-nzism\json\controls.json"
$policiescsv = "C:\Repos\azure-nzism\csv\policies.csv"
$paramscsv = "C:\Repos\azure-nzism\csv\params.csv"

#outputfiles
$policysetPath = "C:\Repos\azure-nzism\json\policyset.json"
$policysetdefPath = "C:\Repos\azure-nzism\json\policyset.definitions.json"
$policysetparamsPath = "C:\Repos\azure-nzism\json\policyset.parameters.json"

#Create parts of the initiative

# policyset.json ______________ # Initiative definition
    #properties - displayname, description, metadata-version, metadata-category, version
    #policydefinitiongroups = controls = groups = metadata

# policyset.definitions.json __ # Initiative list of policies
    #policyDefinitions = policies to include in initiative

# policyset.parameters.json ___ # Initiative definition of parameters
    #parameters - params for each policy

# Import the CSV data as an array of objects with custom property names
#$data = Import-Csv $csvPath | Select-Object @{Name='name';Expression={$_.name}}, @{Name='category';Expression={$_.category}}, @{Name='displayName';Expression={$_.displayName}}, @{Name='description';Expression={"{0} {1}" -f $_.description, $_.url}}

# Convert the array of objects to a JSON string and wrap it in a policyDefinitionGroups array
$jsonString = '{ "policyDefinitionGroups": ' + (ConvertTo-Json $data) + ' }'

# Write the JSON string to the output files
$jsonString | Out-File -Encoding utf8 $policysetPath
$jsonString | Out-File -Encoding utf8 $policysetdefPath
$jsonString | Out-File -Encoding utf8 $policysetparamsPath
