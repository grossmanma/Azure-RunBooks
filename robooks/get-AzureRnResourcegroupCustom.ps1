$null = Add-AzureRmAccount -Credential (Get-AutomationPSCredential -Name 'AzureAdmin')
$null = Set-AzureRmContext -SubscriptionName (get-AutomationVariable -Name 'SubVar' -Value <System.Object>)

$null = (Get-AzureRmResourceGroup).ResourceGroupName