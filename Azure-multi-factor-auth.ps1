<#
	.SYNOPSIS
		Enable , disable, enforce multi-factor authentication for bulk user using powershell
	
	.DESCRIPTION
		Enable , disable, enforce multi-factor authentication for bulk user
	
	.PARAMETER 
		All - set MFA for all user in azure ad
        Synchronized - set MFA for Synchronized users (Synchronized from on premises)
        specific - set MFA for specific users. if you select this option then you will get prompt to enter username.
        Synchronized - set MFA for Synchronized users. if you select this option then you will get prompt to enter txt file full path
	    NewState - Specify if you want to  Enable , disable, enforce multi-factor authentication
	
	.EXAMPLE 1
		PS C:\> Set-MFA -specific -NewState Enabled 
	
	.EXAMPLE 2
		PS C:\> Set-MFA -Synchronized -NewState Disabled 

	.EXAMPLE 3
		PS C:\> Set-MFA -All -NewState Disabled 

	.EXAMPLE 3
		PS C:\> Set-MFA -txt -NewState Enforced 

	
	.NOTES
		    Author:      Arun Sabale
            Company:     VedTech
            Email:       toarun4u@gmail.com
            Created:     13 march 2017
            Version:     1.0 
#>

function Set-MFA
{
	param
	(
		[Parameter(Mandatory = $true, HelpMessage = ' specify if you want to Enabled , disabled, enforced MFA')]
		[string]
		$NewState,
		[Parameter(HelpMessage = 'ONLY IN CASE YOU REALLY WANT TO ENABLE MFA FOR ALL SYNCRONIZED ON PREMISES USER SINCE IT INCLUDES AD SYNC SERVICE ACCOUNT AS WELL')]
		[switch]
		$Synchronized,
		[Parameter(HelpMessage = 'ONLY IN CASE YOU REALLY WANT TO ENABLE MFA FOR ALL AZURE USER SINCE IT INCLUDES AD SYNC SERVICE ACCOUNT AS WELL')]
		[switch]
		$all,
		[Parameter(HelpMessage = 'select this option in case you want to enable MFA for specific (single or bulk) user')]
		[switch]
		$Specific,
		[Parameter(HelpMessage = 'select this option if you have user principle name in txt file')]
		[switch]
		$txt
	)

#start

if($all)
{
#ONLY IN CASE YOU REALLY WANT TO ENABLE MFA FOR ALL AZURE USER SINCE IT INCLUDES AD SYNC SERVICE ACCOUNT AS WELL
$users = Get-MsolUser |select -ExpandProperty UserPrincipalName
}
elseif($Synchronized)
{
#ONLY IN CASE YOU REALLY WANT TO ENABLE MFA FOR ALL SYNCRONIZED ON PREMISES USER SINCE IT INCLUDES AD SYNC SERVICE ACCOUNT AS WELL
$users = Get-MsolUser -Synchronized | select -ExpandProperty UserPrincipalName
}
elseif($Specific)
{
[array]$users = read-host -Prompt "if you want to enable MFA for specific users then add then please enter user principle name in array format like `"jsmith@contoso.com`",`"ljacobson@contoso.com`""
#$users ="arun@arunsabaleatos.onmicrosoft.com","jsmith@contoso.com","ljacobson@contoso.com"
}
elseif($txt)
{
$txtpath = read-host -Prompt "please enter txt file full path in which you have user principle name (one UPN per line)"
if(test-path -Path  $txtpath -ErrorAction SilentlyContinue)
{
$users = Get-Content -Path $txtpath
}
else
{
write-host "txt path is incorrect" -ForegroundColor Red
}
}
if($users)
{
if(!(get-module msonline))
{
install-module msonline -Confirm:$false
}
import-module msonline
write-host "enter azure credentials to connect azure AD" -ForegroundColor yellow
Connect-MsolService


foreach ($user in $users)
{
    $st = New-Object -TypeName Microsoft.Online.Administration.StrongAuthenticationRequirement
    $st.RelyingParty = "*"
    $st.State = $NewState
   $sta = @($st)
    Set-MsolUser -UserPrincipalName $user -StrongAuthenticationRequirements $sta
   $CurrentState =  (Get-MsolUser -UserPrincipalName $user |select -ExpandProperty StrongAuthenticationRequirements).state
   if($CurrentState -eq "Enabled" -or $CurrentState -eq "Enforced")
   {
   write-host "current state of MFA for user $user is - $CurrentState" -ForegroundColor Green
   }
   elseif($CurrentState -eq "disabled")
   {
   write-host "current state of MFA for user $user is - $CurrentState" -ForegroundColor Cyan
   }
   else
   {
   write-host "Unable to get current state of MFA for user $user" -ForegroundColor red
   }
}
}
}
Set-MFA -Specific -NewState Enabled 