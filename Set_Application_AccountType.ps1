# Connect to Microsoft Graph using the Azure Automation managed identity and set the profile to beta
Connect-Graph -Identity
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




