$null = Add-AzureRmAccount -Credential (Get-AutomationPSCredential -Name 'AzureAdmin')
$null = Set-AzureRmContext -SubscriptionName (Get-AutomationVariable -Name 'SubVar')

(Get-AzureRmResourceGroup).ResourceGroupName