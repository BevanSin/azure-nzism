# Set the path to the input CSV file
$csvpath = "C:\Repos\azure-nzism\controls.csv"

#outputfile
$jsonPath = "C:\Repos\azure-nzism\json\controls.json"

# Import the CSV data as an array of objects with custom property names
$data = Import-Csv $csvPath | Select-Object @{Name='name';Expression={$_.name}}, @{Name='category';Expression={$_.category}}, @{Name='displayName';Expression={$_.displayName}}, @{Name='description';Expression={"{0} {1}" -f $_.description, $_.url}}

# Convert the array of objects to a JSON string and wrap it in a policyDefinitionGroups array
$jsonString = '{ "policyDefinitionGroups": ' + (ConvertTo-Json $data) + ' }'

# Write the JSON string to the output file
$jsonString | Out-File -Encoding utf8 $jsonPath
