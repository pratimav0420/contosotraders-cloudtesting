$ErrorActionPreference = 'Stop'

# Get storage account using managed identity (no keys)
$storageAccount = Get-AzStorageAccount -ResourceGroupName $env:ResourceGroupName -AccountName $env:StorageAccountName

# Create context using managed identity instead of keys
$ctx = New-AzStorageContext -StorageAccountName $env:StorageAccountName -UseConnectedAccount

# Enable static website with managed identity context
Enable-AzStorageStaticWebsite -Context $ctx -IndexDocument 'index.html' -ErrorDocument404Path 'index.html'
