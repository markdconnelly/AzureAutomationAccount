<#
.SYNOPSIS
    This function will return the value of a custom security attribute for a user.
.DESCRIPTION
    Queries the established custom security attribute for a user and checks the user specified in the parameter for that attribtue
.NOTES
    This is a custom function written by Mark Connelly, so it may not work as intended. Use at your own risk.
    This function assumes a connection to the Microsoft Graph API is established. If it is not, the function will fail.
.LINK
    N/A
.EXAMPLE
    Get-DevOpsUserCustomSecurityAttributes -UserPrincipalName "user@contoso.org" -CustomSecurityAttributeSet "AttributeSet1" -CustomSecurityAttribute "Attribute1"
        If only a UPN is passed, the function will return all custom security attributes for the user.
        If a UPN and a custom security attribute set are passed, the function will return all custom security attributes for the user in the specified set.
        If a UPN, a custom security attribute set, and a custom security attribute are passed, the function will return the value of the specified custom security attribute for the user.
#>

Function Get-DevOpsUserCustomSecurityAttributes {
    [CmdletBinding()]
    Param (
        [Parameter(Mandatory=$true,Position=0)]
        [string]$UserId,
        [Parameter(Mandatory=$false,Position=1)]
        [string]$CustomSecurityAttributeSet = "Blank",
        [Parameter(Mandatory=$false,Position=2)]
        [string]$CustomSecurityAttribute = "Blank"
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

    # Itterate through the custom security attributes to build a psobject of the attributes
    $arrUser = Get-MgUser -UserId $UserId -Select Id,DisplayName,CustomSecurityAttributes
    $hashCustomAttributesRaw = $arrUser.CustomSecurityAttributes.AdditionalProperties
    $psobjUserCustomSecurityAttributes = @()
    $arrCustomAttributeSetNames = @()
    if($CustomSecurityAttributeSet -eq "Blank"){
        $arrCustomAttributeSetNames = $hashCustomAttributesRaw.Key | Out-String -Stream
        $strPause = ""
    }
    else{
        $arrCustomAttributeSetNames = $CustomSecurityAttributeSet
    }
    foreach($arrCustomAttributeSet in $arrCustomAttributeSetNames){
        $strAttributeSetName = ""
        $strAttributeSetName = $arrCustomAttributeSet | ConvertTo-Json | ConvertFrom-Json | Out-String -Stream
        $hashCustomAttributes = @{}
        $hashCustomAttributes = $arrUser.CustomSecurityAttributes.AdditionalProperties.$strAttributeSetName
        $hashCustomAttributes.Remove("@odata.type")
        $arrCustomAttributes = @()
        if($CustomSecurityAttribute -eq "Blank"){
            $arrCustomAttributes = $hashCustomAttributes.Key | ConvertTo-Json
            $arrCustomAttributes = $arrCustomAttributes | ConvertFrom-Json
            $arrCustomAttributes = $arrCustomAttributes | Out-String -Stream
            $strPause = ""
        }
        else{
            $arrCustomAttributes = $CustomSecurityAttribute
        }
        foreach($Attribute in $arrCustomAttributes){
            $strAttributeName = ""
            $strAttributeName = $Attribute | ConvertTo-Json | ConvertFrom-Json | Out-String -Stream
            $strAttributeValue = ""
            $strAttributeValue = $hashCustomAttributes[$Attribute] | ConvertTo-Json | ConvertFrom-Json | Out-String -Stream

            $strPause = ""
            $psobjUserCustomSecurityAttributes += [PSCustomObject]@{
                AttributeSet = $strAttributeSetName
                AttributeName = $strAttributeName
                AttributeValue = $strAttributeValue
            }
        }
    }
    # Return the profile to standard before exiting
    $strProfileName = Get-MgProfile | Select-Object -ExpandProperty Name
    if ($strProfileName -eq "beta") {
        Select-MgProfile v1.0
        Write-Verbose "Script has completed. Profile check has changed the profile back to v1.0."
    }
    else {
        Write-Verbose "No action required from the profile check. v1.0 is selected."
    }
    Write-Host "Custom Security Attributes for $UserId"
    return $psobjUserCustomSecurityAttributes
}

#Get-DevOpsUserCustomSecurityAttributes -UserId "wade@imperionllc.com" 

#Get-DevOpsUserCustomSecurityAttributes -UserId "bruce@imperionllc.com" -CustomSecurityAttributeSet "CyberSecurityUser"

Get-DevOpsUserCustomSecurityAttributes -UserId "mark@imperionllc.com" #-CustomSecurityAttributeSet "CyberSecurityData" #-CustomSecurityAttribute "Priority"