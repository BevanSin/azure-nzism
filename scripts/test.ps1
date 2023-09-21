$rgName = "azgovviz"
$resourceName = "azgovviz-bev"
$tags = @{"hidden-title" = "Azure Governance Visualiser" }

$resource = Get-AzResource -Name $resourceName -ResourceGroup $rgName
New-AzTag -ResourceId $resource.id -Tag $tags