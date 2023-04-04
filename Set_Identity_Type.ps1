# Connect to Microsoft Graph using the Azure Automation managed identity and set the profile to beta
Connect-Graph -Identity
Select-MgProfile beta

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
$arrManagedIdentityAccountTypeAttribute = @{}
$arrManagedIdentityAccountTypeAttribute = @{
	CustomSecurityAttributes = @{
		CybersecurityCore = @{
			"@odata.type" = "#Microsoft.DirectoryServices.CustomSecurityAttributeValue"
			AccountType = "Managed Identity"
		}
	}
}
$arrLegacyAccountTypeAttribute = @{}
$arrLegacyAccountTypeAttribute = @{
	CustomSecurityAttributes = @{
		CybersecurityCore = @{
			"@odata.type" = "#Microsoft.DirectoryServices.CustomSecurityAttributeValue"
			AccountType = "Legacy"
		}
	}
}
$arrUserAccountTypeAttribute = @{}
$arrUserAccountTypeAttribute = @{
	CustomSecurityAttributes = @{
		CybersecurityCore = @{
			"@odata.type" = "#Microsoft.DirectoryServices.CustomSecurityAttributeValue"
			AccountType = "User"
		}
	}
}
# Set attribute parameters for each account type
$arrServiceAccountTypeAttribute = @{}
$arrServiceAccountTypeAttribute = @{
	CustomSecurityAttributes = @{
		CybersecurityCore = @{
			"@odata.type" = "#Microsoft.DirectoryServices.CustomSecurityAttributeValue"
			AccountType = "Service Account"
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




Update-MgUser -UserId "" -BodyParameter $arrUserAccountTypeAttribute



