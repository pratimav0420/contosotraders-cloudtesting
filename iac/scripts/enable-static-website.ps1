$ErrorActionPreference = 'Stop'

# Wait for role assignments to propagate
Write-Output "Waiting for role assignments to propagate..."
Start-Sleep -Seconds 90

try {
    # Ensure we're using managed identity authentication
    Write-Output "Connecting using managed identity..."
    Connect-AzAccount -Identity
    
    # Get storage account using managed identity (no keys)
    Write-Output "Getting storage account: $env:StorageAccountName"
    $storageAccount = Get-AzStorageAccount -ResourceGroupName $env:ResourceGroupName -AccountName $env:StorageAccountName
    
    # Create context using managed identity instead of keys
    Write-Output "Creating storage context with managed identity..."
    $ctx = New-AzStorageContext -StorageAccountName $env:StorageAccountName -UseConnectedAccount
    
    # Enable static website with managed identity context
    Write-Output "Enabling static website hosting..."
    Enable-AzStorageStaticWebsite -Context $ctx -IndexDocument 'index.html' -ErrorDocument404Path 'index.html'
    
    Write-Output "Successfully enabled static website hosting!"
}
catch {
    Write-Error "Failed to enable static website: $($_.Exception.Message)"
    throw
}
