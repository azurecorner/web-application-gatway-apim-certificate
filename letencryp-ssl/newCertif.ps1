
      
$AcmeDirectory="LE_PROD"
$AcmeContact="leyegora@gmail.com"
$storageAccountName="certifrenewstorage"
$storageContainerName="certificatecontainer"
$resourceGroupName="CERTIFICAT"
$KeyVaultName="certifkvlogcorner"
$CertificateName="apim.cloud-devops-craft.com"
$SubscriptionId=""
Write-Host "AcmeDirectory : $AcmeDirectory"
Write-Host "AcmeContact : $AcmeContact"
Write-Host "storageAccountName : $storageAccountName"
Write-Host "storageContainerName : $storageContainerName"
Write-Host "resourceGroupName : $resourceGroupName"
Write-Host "KeyVaultName : $KeyVaultName"

$curDir = Get-Location
Write-Host "Current Working Directory: $curDir"

Import-Module "$($curDir)\getStorageSasToken.ps1"
Import-Module "$($curDir)\AuthenticateUsingSP.ps1"

$ClientID =""
$ClientSecret =""
$TenantDomain =""
$SubscriptionId =""
#$CertificateName = "cloud-devops-craft.com" # get from key vault
$azureAccessToken =AuthenticateUsingSP -ClientID $ClientID   -ClientSecret $ClientSecret -TenantDomain $TenantDomain
#Connect-AzAccount -Identity
#$azureAccessToken = Get-AzAccessToken -ResourceUrl "https://management.core.windows.net/";

 # Order or renew a certificate via ACME
./RenewAcmeCertificate.ps1 -AcmeDirectory $AcmeDirectory `
                          -AcmeContact $AcmeContact `
                          -CertificateName $CertificateName `
                          -SubscriptionId $SubscriptionId `
                          -AzureAccessToken $azureAccessToken  `
                          -resourceGroupName $resourceGroupName  `
                          -storageAccountName $storageAccountName  `
                          -storageContainerName $storageContainerName



 # Import the certificate into Azure Key Vault

 
./ImportAcmeCertificateToKeyVault.ps1 -CertificateName $CertificateName  `
                                       -KeyVaultName $KeyVaultName  `
                                       -resourceGroupName $resourceGroupName `
                                       -AcmeDirectory $AcmeDirectory   
