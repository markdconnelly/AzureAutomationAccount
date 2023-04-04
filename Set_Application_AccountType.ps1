# Connect to Microsoft Graph as a service principal
$strClientID = Get-Secret -Name PSAppID -AsPlainText
$strTenantID = Get-Secret -Name PSAppTenantID -AsPlainText
$strClientSecret = Get-Secret -Name PSAppSecret -AsPlainText
$strAPI_URI = "https://login.microsoftonline.com/$strTenantID/oauth2/token"
$arrAPI_Body = @{
    grant_type = "client_credentials"
    client_id = $strClientID
    client_secret = $strClientSecret
    resource = "https://graph.microsoft.com"
}
$objAccessTokenRaw = Invoke-RestMethod -Method Post -Uri $strAPI_URI -Body $arrAPI_Body -ContentType "application/x-www-form-urlencoded"
$objAccessToken = $objAccessTokenRaw.access_token
Connect-Graph -Accesstoken $objAccessToken

# Validate that the beta profile is in use
$strProfileName = Get-MgProfile | Select-Object -ExpandProperty Name
Write-Host "Current profile: $strProfileName"
if ($strProfileName -eq "v1.0") {
    Select-MgProfile beta
    Write-Host "Profile check has changed the profile to beta"
}
else {
    Write-Host "No action required from the profile check"
}

# Collect array of application service principals
$arrAAD_Applications = @()
$arrAAD_Applications = Get-MgServicePrincipal -All:$true | Where-Object {$_.ServicePrincipalType -eq "Application" -and $_.Tags -eq "WindowsAzureActiveDirectoryIntegratedApp"}

# Set attribute parameters for the "Application" account type
$arrApplicationAccountTypeAttribute = @{}
$arrApplicationAccountTypeAttribute = @{
	CustomSecurityAttributes = @{
		CybersecurityCore = @{
			"@odata.type" = "#Microsoft.DirectoryServices.CustomSecurityAttributeValue"
			AccountType = "Application"
		}
	}
}

# Loop through the application array and set the account type attribute
$intProgressStatus = 0
$intFailures = 0
foreach($app in $arrAAD_Applications){
    $hashCybersecityCoreAttributes = @{}
    $hashCybersecityCoreAttributes = $app.CustomSecurityAttributes.AdditionalProperties.CybersecurityCore
    $strAccountType = ""
    $strAccountType = $hashCybersecityCoreAttributes.AccountType
    if($strAccountType -eq "Application"){
        Write-Host "Application account type is correct"
    }
    else{
        Write-Host "Application account type is incorrect"
        Write-Host "Updating application account type"
        try {
            Update-MgServicePrincipal -ServicePrincipalId $app.Id -BodyParameter $arrApplicationAccountTypeAttribute
        }
        catch {
            $intFailures++
            Write-Host "Undable to set attribute for $($app.DisplayName)"
            Write-Host $Error[0].Exception.Message
        }
    }
    $intProgressStatus++
}



