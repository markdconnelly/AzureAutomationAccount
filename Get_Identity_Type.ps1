# Collect array of application service principals
$arrAAD_Applications = @()
$arrAAD_Applications = Get-MgServicePrincipal -All:$true | Where-Object {$_.ServicePrincipalType -eq "Application"}
# Collect array of managed identity service principals
$arrAAD_ManagedIdentities = @()
$arrAAD_ManagedIdentities = Get-MgServicePrincipal -All:$true | Where-Object {$_.ServicePrincipalType -eq "ManagedIdentity"}
# Collect array of legacy service principals
$arrAAD_LegacyIdentities = @()
$arrAAD_LegacyIdentities = Get-MgServicePrincipal -All:$true | Where-Object {$_.ServicePrincipalType -eq "Legacy"}
# Collect array of standard users
$arrAAD_StandardUsers = @()
$arrAAD_StandardUsers = Get-MgUser -All:$true `
    | Where-Object {$_.UserPrincipalName -notlike "svc*" `
               -and $_.UserPrincipalName -notlike "*Mailbox*" `
               -and $_.UserPrincipalName -notlike "Sync_*"}
# Collect array of service accounts
$arrAAD_ServiceAccounts = @()
$arrAAD_ServiceAccounts = Get-MgUser -All:$true | Where-Object {$_.UserPrincipalName -like "svc*"}

# Loop through each application service principal and set its custom security attribute to "Application"
foreach($app in $arrAAD_Applications) {
    Get-MgServicePrincipalCustomSecurityAttribute -UserId $app.Id -CustomSecurityAttributeSetId "CybersecurityCore_AccountType" | ConvertTo-Json | out-file -filepath "C:\temp\Get-MgServicePrincipalCustomSecurityAttribute-$($app.DisplayName).json"
    $app.CustomSecurityAttributes = "Application"
    
}








$arrAAD_Applications | ConvertTo-Json | out-file -filepath "C:\temp\Get-MgServicePrincipal-managedidentity.json"

$arrAAD_ApplicationCompare = Get-MgServicePrincipal -All:$true | Format-List DisplayName, ServicePrincipalType, AppOwnerOrganizationId
$arrAAD_ApplicationCompare | out-file -filepath "C:\temp\Get-MgServicePrincipal-managedidentity.csv"

$arrAAD_StandardUsers = Get-MgUser -UserId "peter@imperionllc.com" -Property "CustomSecurityAttributes"
$arrAAD_StandardUsers | ConvertTo-Json | out-file -filepath "C:\temp\Get-MgUser-markconnellyadmin.json"
$test = Get-MgUser -UserId "peter@imperionllc.com" -Property * | ConvertTo-Json | out-file -filepath "C:\temp\Get-MgUser-markconnellyadmin.json"

Select-MgProfile -Name "beta"
Get-MgProfile

Get-MgDirectoryObject -DirectoryObjectId "2cef8d9d-2e2e-499e-89ad-daf5a5e47941" | ConvertTo-Json | out-file -filepath "C:\temp\Get-MgDirectoryObject-2cef8d9d-2e2e-499e-89ad-daf5a5e47941.json"

$arrAAD_StandardUsers.CustomSecurityAttributes

Get-MgDirectoryCustomSecurityAttributeDefinition -CustomSecurityAttributeDefinitionId "CybersecurityCore_AccountType"
$context = Get-MgContext
$context.Scopes
Disconnect-Graph

$user = Get-MgUser -UserId "2cef8d9d-2e2e-499e-89ad-daf5a5e47941" -Property "customSecurityAttributes"
$user | ConvertTo-Json | out-file -filepath "C:\temp\Get-MgUser-markconnellyadmin.json" 
$user.CustomSecurityAttributes
$command = Find-MgGraphCommand -Uri "users*" -Method "GET" -ApiVersion "beta"
$command.Variants