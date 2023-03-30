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

    $arrEntAppCertificateRaw = @()
    $strPreferredSSOMode = ""
    $arrAppWebRaw = @()
    $strAppSignInAudience = ""
    $strSAMLSSOSettings = ""
    $strAppSignInAudience = ""
    $strSAMLSSOSettings = ""
    $strPrefferedTokenSignThumbprint = ""
    $strIdentifierURI = ""
    $strSAMLMetadataURL = ""
    $strSignInURL = ""
    $strLogoutURL = ""
    $strReplyURLs
    $strNotificationEmail = ""
 
}