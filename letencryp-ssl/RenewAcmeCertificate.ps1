
    param (
    [string] $AcmeDirectory,
    [string] $AcmeContact,
    [string] $CertificateName,
    [string] $SubscriptionId ,
    [string] $azureAccessToken,
    [string] $resourceGroupName,
    [string] $storageAccountName,
    [string] $storageContainerName
 )

try {


$StorageContainerSASToken = GetstorageAccountSasToken -resourceGroupName  $resourceGroupName  -storageAccountName $storageAccountName -storageContainerName $storageContainerName

# Supress progress messages. Azure DevOps doesn't format them correctly (used by New-PACertificate)
$global:ProgressPreference = 'SilentlyContinue'

# Split certificate names by comma or semi-colin
$CertificateNamesArr = $CertificateName.Trim(); 

# Create working directory
$workingDirectory = Join-Path -Path "." -ChildPath "pa"
New-Item -Path $workingDirectory -ItemType Directory | Out-Null

# Sync contents of storage container to working directory
# & '/usr/bin/azcopy' sync "$StorageContainerSASToken" "$workingDirectory"
azcopy sync "$StorageContainerSASToken" "$workingDirectory"
Write-Host "**************************** Sync contents of storage container to working directory  done ********************************* " 

# Set Posh-ACME working directory
$env:POSHACME_HOME = $workingDirectory
Import-Module Posh-ACME -Force

# Configure Posh-ACME server
Set-PAServer -DirectoryUrl $AcmeDirectory

# Configure Posh-ACME account
$account = Get-PAAccount
if (-not $account) {
    # New account
    $account = New-PAAccount -Contact $AcmeContact -AcceptTOS
}
elseif ($account.contact -ne "mailto:$AcmeContact") {
    # Update account contact
    Set-PAAccount -ID $account.id -Contact $AcmeContact
}


# Request certificate
$paPluginArgs = @{
    AZSubscriptionId = $SubscriptionId
    AZAccessToken    = $azureAccessToken;
}

#$IsCertificateExpires = IsCertificateExpires -certifcateEnvironment $AcmeDirectory -certificateName $CertificateName
Write-Host "**************************** Order or Renew certificate  starting********************************* " 
#if($true -eq $IsCertificateExpires) {
    New-PACertificate -Domain $CertificateNamesArr -DnsPlugin Azure -PluginArgs $paPluginArgs -Force
# }else{
#     Write-Host "This certificate order ($($CertificateNamesArr)) has already been completed, can be renewed 7 days before expiration data "
# }
Write-Host "**************************** Order or Renew certificate  done ********************************* " 
# Sync working directory back to storage container

# & '/usr/bin/azcopy' sync "$workingDirectory" "$StorageContainerSASToken"

azcopy sync "$workingDirectory" "$StorageContainerSASToken"

Write-Host "**************************** Sync working directory back to storage container  done ********************************* " 
Write-Host "**************************** Order or Renew certificate  END  ********************************* " 

}
catch {
      Write-Host "error when ordering or renewing certificate" -ForegroundColor Red
      Write-Host "Message : $($_.Exception.Message)" -ForegroundColor Red
      Write-Host "Stack trace : $($_.Exception.StackTrace)" -ForegroundColor Red
      throw 
}

