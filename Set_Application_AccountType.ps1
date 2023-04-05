# Connect to Microsoft Graph as a service principal
Write-Host "Connecting to Microsoft Graph as a service principal" -BackgroundColor Black -ForegroundColor Green
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
Write-Host "Current profile: $strProfileName" -BackgroundColor Black -ForegroundColor Green
if ($strProfileName -eq "v1.0") {
    Select-MgProfile beta
    Write-Host "Profile check has changed the profile to beta" -BackgroundColor Black -ForegroundColor Green
}
else { 
    Write-Host "No action required from the profile check" -BackgroundColor Black -ForegroundColor Green
}

# Collect array of application service principals
Write-Host "Collecting array of enterprise applications" -BackgroundColor Black -ForegroundColor Green
$arrAAD_Applications = @()
$arrAAD_Applications = Get-MgServicePrincipal -All:$true | Where-Object {$_.ServicePrincipalType -eq "Application" -and $_.Tags -eq "WindowsAzureActiveDirectoryIntegratedApp"}

# Set attribute parameters for the "Application" account type
Write-Host "Setting attribute parameters for the "Application" account type" -BackgroundColor Black -ForegroundColor Green
$arrApplicationAccountTypeAttribute = @{}
$arrApplicationAccountTypeAttribute = @{
	CustomSecurityAttributes = @{
		CyberSecurityData = @{ #CybersecurityCore
			"@odata.type" = "#Microsoft.DirectoryServices.CustomSecurityAttributeValue"
			AccountType = "Enterprise Application" #"Application"
		}
	}
}

# Loop through the application array and set the account type attribute
$intProgressStatus = 0
Write-Host "Progress counter reset to $intProgressStatus" -BackgroundColor Black -ForegroundColor Green
$intFailures = 0
Write-Host "Failure counter reset to $intFailures" -BackgroundColor Black -ForegroundColor Green
Write-Host "Checking $($arrAAD_Applications.Count) applications for the account type custom security attribute" -BackgroundColor Black -ForegroundColor Green
foreach($app in $arrAAD_Applications){
    $arrLoopAppAttributes = @()
    try {
        $arrLoopAppAttributes = Get-MgServicePrincipal -Select Id,DisplayName,CustomSecurityAttributes -ServicePrincipalId $app.Id -ErrorAction Stop
    }
    catch {
        Write-Host "Unable to get the current attributes for $($app.DisplayName)" -BackgroundColor Black -ForegroundColor Red
        $arrLoopAppAttributes = $null
    }
    $hashCybersecityCoreAttributes = @{}
    $hashCybersecityCoreAttributes = $arrLoopAppAttributes.CustomSecurityAttributes.AdditionalProperties.CyberSecurityData           #CustomSecurityAttributes.AdditionalProperties.CybersecurityCore
    $strAccountType = ""
    $strAccountType = $hashCybersecityCoreAttributes.AccountType
    if($strAccountType -eq $null){
        $strAccountType = "Blank"
    }
    Write-Host "Checking $($app.DisplayName) account type" -BackgroundColor Black -ForegroundColor Green
    Write-Host "Current account type is $strAccountType" -BackgroundColor Black -ForegroundColor Green
    if($strAccountType -eq "Application"){
        Write-Host "Application account type for $($app.DisplayName) is correct. Moving on to the next application." -BackgroundColor Black -ForegroundColor Green
    }
    else{
        Write-Host "Application account type for $($app.DisplayName) is incorrect" -BackgroundColor Black -ForegroundColor Red
        Write-Host "Updating application account type to "Application"" -BackgroundColor Black -ForegroundColor Green
        try {
            Update-MgServicePrincipal -ServicePrincipalId $app.Id -BodyParameter $arrApplicationAccountTypeAttribute -ErrorAction Stop
        }
        catch {
            $intFailures++
            Write-Host "Undable to set attribute for $($app.DisplayName)" -BackgroundColor Black -ForegroundColor Red
            Write-Host $Error[0].Exception.Message -BackgroundColor Black -ForegroundColor Red
        }
    }
    $intProgressStatus++
}
# Return the profile to standard before exiting
if ($strProfileName -eq "beta") {
    Select-MgProfile v1.0
    Write-Host "Script has completed. Profile check has changed the profile back to v1.0." -BackgroundColor Black -ForegroundColor Green
}
else {
    Write-Host "No action required from the profile check. v1.0 is selected." -BackgroundColor Black -ForegroundColor Green
}



