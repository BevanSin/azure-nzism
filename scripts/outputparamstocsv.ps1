# Read JSON data from file
$json = Get-Content -Path "C:\Repos\azure-nzism\json\params.3.5.json" | ConvertFrom-Json

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
$data | Export-Csv -Path "C:\Repos\azure-nzism\csv\params.csv" -NoTypeInformation