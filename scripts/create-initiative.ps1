# Define variables
$policySetDefinitionName = "New Zealand ISM Restricted v3.6"
$policySetDescription = "This initiative includes policies that address a subset of New Zealand Information Security Manual v3.6 controls. Additional policies will be added in upcoming releases. For more information, visit https://aka.ms/nzism-initiative. "
#$policyGroupDelimiter = ";"
$outputFilePath = "policysetdefinition.json"
$initiativeVersion = "1.0.0"
$initiativeCategory = "Regulatory Compliance"
$parametersFilePath = "C:\Repos\azure-nzism\csv\params.csv"
$policyFilePath = "C:\Repos\azure-nzism\csv\policies.csv"
$controlsFilePath = "C:\Repos\azure-nzism\csv\controls.csv"

# Load policies from CSV file
$controls = Import-Csv -Path $controlsFilePath

# Load policies from CSV file
$policies = Import-Csv -Path $policyFilePath

# Load parameters from CSV file
$parameters = Import-Csv -Path $parametersFilePath

#Create parts of the initiative
#properties - displayname, description, metadata-version, metadata-category, version
#policydefinitiongroups = controls = groups = metadata
#policyDefinitions = policies to include in initiative    
#parameters - params for each policy

# Create policy set definition
$policySetDefinition = @{
    "displayName" = $policySetDefinitionName
    "description" = $policySetDescription
    "metadata" = @{
        "version" = $initiativeVersion
        "category" = $initiativeCategory
    }
    "policyDefinitions" = @()
}
foreach ($policy in $policies) {
    # Create policy parameters
    $parametersForPolicy = $parameters | Where-Object { $_.PolicyName -eq $policy.Name }
    $parametersHash = @{}
    foreach ($parameter in $parametersForPolicy) {
        $parameterName = $parameter.Name
        $parameterGroup = $parameter.Group
        $parametersHash.Add("$parameterGroup.$parameterName", @{
            "type" = "String"
            "metadata" = @{
                "displayName" = $parameterName
                "description" = "This is my $policy.DisplayName parameter $parameterName description."
            }
            "defaultValue" = $parameter.DefaultValue
        })
    }
    # Create policy definition
    $policyData = @{
        "if" = @{
            "not" = @{
                "field" = "tags['Environment']"
                "equals" = "Prod"
            }
        }
        "then" = @{
            "effect" = "deny"
        }
        "parameters" = $parametersHash
        "metadata" = @{
            "displayName" = $policy.DisplayName
            "description" = $policy.Description
        }
    }
    $policyDefinition = @{
        "policyDefinitionId" = $policy.DefinitionId
        "parameters" = $parametersHash
    }
    # Add policy definition to policy set definition
    $policySetDefinition.policyDefinitions += $policyDefinition
}

# Convert policy set definition to JSON and output to file
$policySetDefinitionJson = ConvertTo-Json $policySetDefinition -Depth 100
$policySetDefinitionJson | Out-File -Encoding utf8 $outputFilePath

Write-Host "Policy set definition saved to $outputFilePath"
