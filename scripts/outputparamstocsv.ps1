# Define variables
$repoRoot = Join-Path $PSScriptRoot '..\'

# Construct the path to the 'json' folder
$jsonPath = Join-Path $repoRoot 'json'
$csvPath = Join-Path $repoRoot 'csv'

$paramsJson = Join-Path $jsonPath 'params.3.5.json'
$paramsCsv = Join-Path $csvPath 'params.csv'


# Read JSON data from file
$json = Get-Content -Path $paramsJson | ConvertFrom-Json

# Convert to PowerShell objects and select relevant properties
$data = foreach ($parameter in $json.parameters.psobject.Properties) {
    [pscustomobject]@{
        ParameterName = $parameter.Name
        Type = $parameter.Value.type
        DisplayName = $parameter.Value.metadata.displayName
        Description = $parameter.Value.metadata.description
        AllowedValues = $parameter.Value.allowedValues -join ';'
        DefaultValue = $parameter.Value.defaultValue
    }
}

# Export to CSV file
$data | Export-Csv -Path $paramsCsv -NoTypeInformation