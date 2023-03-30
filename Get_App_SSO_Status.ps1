$arrAAD_Applications = @()
$arrAAD_Applications = Get-MgServicePrincipal -All:$true | Where-Object {$_.Tags -eq "WindowsAzureActiveDirectoryIntegratedApp"}
$app = $null
$strAppDisplayName = ""
$strEntAppObjectID = ""
$strAppID = ""
foreach ($app in $arrAAD_Applications) {
    $strAppDisplayName = $app.DisplayName 
    $strEntAppObjectID = $app.Id
    $strAppID = $app.AppId
}