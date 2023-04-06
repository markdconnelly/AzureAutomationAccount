<#
.SYNOPSIS
    This function will return an array of users that match the selected custom security attributes.
.DESCRIPTION
    Queries all users filtered by the custom security attributes specified in the parameters.
.NOTES
    This is a custom function written by Mark Connelly, so it may not work as intended. Use at your own risk.
    This function assumes a connection to the Microsoft Graph API is established. If it is not, the function will fail.
.LINK
    N/A
.EXAMPLE
    Get-DevOpsUserByCustomSecurityAttributes -CustomSecurityAttributeSet "AttributeSet1" -CustomSecurityAttributeName "Attribute1" -CustomSecurityAttributeValue "AttributeValue"
#>

Function Get-DevOpsUserByCustomSecurityAttributes {
    [CmdletBinding()]
    Param (
        [Parameter(Mandatory=$true,Position=0)]
        [string]$CustomSecurityAttributeSet,
        [Parameter(Mandatory=$true,Position=1)]
        [string]$CustomSecurityAttributeName,
        [Parameter(Mandatory=$true,Position=2)]
        [string]$CustomSecurityAttributeValue
    )
    # Check to see if a connection to the Microsoft Graph API has been established
    $objGetGraphConnected = $null
    $objGetGraphConnected = Get-MgContext
    $psobjUserCustomSecurityAttributes = @()
    if($objGetGraphConnected -eq $null){
        return "No connection to the Microsoft Graph API has been established. Please connect to the Microsoft Graph API before running this function."
    }
    else{
        Write-Verbose "Connection to the Microsoft Graph API exists." 
    }

    # Validate that the beta profile is in use
    $strProfileName = Get-MgProfile | Select-Object -ExpandProperty Name
    Write-Verbose "Current profile: $strProfileName"
    if ($strProfileName -eq "v1.0") {
        Select-MgProfile beta
        Write-Verbose "Profile check has changed the profile to beta"
    }
    else { 
        Write-Verbose "No action required from the profile check"
    }


    # Get all users and filter by the custom security attributes
    $arrUsersByCustomSecurityAttributes = @()
    $arrUsersByCustomSecurityAttributes = Get-MgUser -All:$true -Select Id,DisplayName,CustomSecurityAttributes `
    | Where-Object {$_.CustomSecurityAttributes.AdditionalProperties.$CustomSecurityAttributeSet.$CustomSecurityAttributeName -eq $CustomSecurityAttributeValue}

    # Return the profile to standard before exiting
    $strProfileName = Get-MgProfile | Select-Object -ExpandProperty Name
    if ($strProfileName -eq "beta") {
        Select-MgProfile v1.0
        Write-Verbose "Script has completed. Profile check has changed the profile back to v1.0."
    }
    else {
        Write-Verbose "No action required from the profile check. v1.0 is selected."
    }
        return $arrUsersByCustomSecurityAttributes
}

Get-DevOpsUserByCustomSecurityAttributes -CustomSecurityAttributeSet "CyberSecurityData" -CustomSecurityAttributeName "AccountType" -CustomSecurityAttributeValue "User"