$strClientID = Get-AutomationVariable -Name "PowerShellAppID"
$strTenantID = Get-AutomationVariable -Name "TenantID"
$strClientSecret = Get-AutomationVariable -Name "PowerShellAppSecret"
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
Select-MgProfile beta

# Collect array of application service principals
$arrAAD_Applications = @()
$arrAAD_Applications = Get-MgServicePrincipal -All:$true | Where-Object {$_.ServicePrincipalType -eq "Application"}

# Set attribute parameters for each account type
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
Write-Host 



