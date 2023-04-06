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
    Get-UserCustomSecurityAttributes -UserPrincipalName "user@contoso.org" -CustomSecurityAttributeSet "AttributeSet1" -CustomSecurityAttribute "Attribute1"
#>

Function Get-UserCustomSecurityAttributes {
    [CmdletBinding()]
    Param (
        [Parameter(Mandatory=$true,Position=0)]
        [string]$UserPrincipalName,
        [Parameter(Mandatory=$false,Position=1)]
        [string]$CustomSecurityAttributeSet,
        [Parameter(Mandatory=$false,Position=2)]
        [string]$CustomSecurityAttribute
    )
    Begin {
        # This is the beginning of the function
    }
    Process {
        # This is the main body of the function
        $arrUser = Get-MgUser -UserPrincipalName $UserPrincipalName -Select Id,DisplayName,CustomSecurityAttributes
        $arrUser.CustomSecurityAttributes.AdditionalProperties.$CustomSecurityAttributeSet.$CustomSecurityAttribute
    }
    End {
        # This is the end of the function
    }
}
