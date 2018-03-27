Add-AzureRmAccount -Credential (Get-AutomationPSCredential -Name 'AzureAdmin')
Set-AzureRmContext 

(Get-AzureRmResourceGroup).ResourceGroupName