

Function AuthenticateUsingSP {
    [CmdletBinding()]
    Param
    (
      [parameter(Mandatory=$true)]
      [string]$ClientID,
      [parameter(Mandatory=$true)]
      [string]$ClientSecret ,
      [parameter(Mandatory=$true)]
      [string]$TenantDomain
    )
    
    .{

    #Convert the Service Principal secret to secure string:
    
    $password = ConvertTo-SecureString $ClientSecret -AsPlainText -Force
    
    #Create a new credentials object containing the application ID and password that will be used to authenticate:
    
    $psCredentials = New-Object System.Management.Automation.PSCredential ($ClientID, $password)
    
   # Authenticate with the credentials object:
    
    Connect-AzAccount -ServicePrincipal -Credential $psCredentials -Tenant $TenantDomain
   
    
    $azureAccessToken = Get-AzAccessToken -ResourceUrl "https://management.core.windows.net/";

    }| Out-Null
    Return $azureAccessToken
}
