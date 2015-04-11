# Function to setup Azure subscription, switch azure mode
function SetupAzureResourceManagementSubscription
{
   param
   (
     [Parameter(Mandatory)]
     [string]$SubscriptionName
   )

   Add-AzureAccount

   Write-Host 'Selecting Azure Subscription...' $SubscriptionName -foregroundcolor Cyan
   Select-AzureSubscription -SubscriptionName $SubscriptionName


   Write-Host 'Enabling Azure Resource Manager API...' -foregroundcolor Green
   Switch-AzureMode AzureResourceManager
   Write-Host 'Azure ARM API enabled.' -foregroundcolor Green

}

#Function to decrypt the password based on a certificate thumbprint and certificate StoreLocation
function DecryptBase64Value
{
    param
    (
        [Parameter(Mandatory)]
        [String]$Thumbprint,

        [Parameter(Mandatory)]
        [System.Security.Cryptography.X509Certificates.StoreLocation]$StoreLocation,

        [Parameter(Mandatory)]
        [String]$Base64EncryptedValue
    )

    # Decode Base64 string
    $encryptedBytes = [System.Convert]::FromBase64String($Base64EncryptedValue)

    # Get certificate from store
    $store = new-object System.Security.Cryptography.X509Certificates.X509Store($StoreLocation)
    $store.open([System.Security.Cryptography.X509Certificates.OpenFlags]::ReadOnly)
    $certificate = $store.Certificates | %{if($_.thumbprint -eq $Thumbprint){$_}}
   
    # Decrypt
    $decryptedBytes = $certificate.PrivateKey.Decrypt($encryptedBytes, $false)
    $decryptedValue = [System.Text.Encoding]::UTF8.GetString($decryptedBytes)
    
    return $decryptedValue
}

#Function to encrypt the password based based on a certificate thumbprint and certificate StoreLocation
function EncryptBase64Value
{
    param
    (
        [Parameter(Mandatory)]
        [String]$Thumbprint,

        [Parameter(Mandatory)]
        [System.Security.Cryptography.X509Certificates.StoreLocation]$StoreLocation,

        [Parameter(Mandatory)]
        [String]$TextValue
    )

    # Byte Array of the Input Value
    $ByteArray = [System.Text.Encoding]::UTF8.GetBytes($TextValue)

    # Get certificate from store
    $store = new-object System.Security.Cryptography.X509Certificates.X509Store($StoreLocation)
    $store.open([System.Security.Cryptography.X509Certificates.OpenFlags]::ReadOnly)
    $certificate = $store.Certificates | %{if($_.thumbprint -eq $Thumbprint){$_}}
    
    # Encrypt
    $ecryptedBytes = $certificate.PrivateKey.Encrypt($ByteArray, $false)
    $ecryptedValue = [Convert]::ToBase64String($ecryptedBytes)
    
    return $ecryptedValue
}

#Function to load certificate data based on a certificate thumbprint and certificate StoreLocation
function LoadCertificateData
{
    param
    (
        [Parameter(Mandatory)]
        [String]$Thumbprint,

        [Parameter(Mandatory)]
        [System.Security.Cryptography.X509Certificates.StoreLocation]$StoreLocation
    )

    # Get certificate from store
    $store = new-object System.Security.Cryptography.X509Certificates.X509Store($StoreLocation)   
    
    $store.open([System.Security.Cryptography.X509Certificates.OpenFlags]::ReadOnly)
    
    $certificate = $store.Certificates | %{if($_.thumbprint -eq $Thumbprint){$_}}

    $certByte = $certificate.GetRawCertData()

    $base64cert = [System.Convert]::ToBase64String($certByte)

    return $base64cert
}