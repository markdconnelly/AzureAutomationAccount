. C:\Users\MarkConnelly\GitHub\AzureAutomationAccount\Functions\Get-DevOpsUserByCustomSecurityAttribute.ps1
. C:\Users\MarkConnelly\GitHub\AzureAutomationAccount\Functions\Get-DevOpsUserCustomSecurityAttributes.ps1

Get-DevOpsUserByCustomSecurityAttributes -CustomSecurityAttribute "AccountType" -CustomSecurityAttributeValue "User"
Get-DevOpsUserCustomSecurityAttributes -User "mark@imperionllc.com"
Get-DevOpsUserCustomSecurityAttributes -User "bruce@imperionllc.com" -CustomSecurityAttributeSet "CyberSecurityUser"
Get-DevOpsUserCustomSecurityAttributes -User "wade@imperionllc.com" -CustomSecurityAttributeSet "CyberSecurityData" -CustomSecurityAttribute "AccountType"