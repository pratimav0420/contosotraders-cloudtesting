$ErrorActionPreference = 'Stop'

# Wait for role assignments to propagate
Write-Output "Waiting for role assignments to propagate..."
Start-Sleep -Seconds 120

try {
    Write-Output "Enabling static website using Azure CLI..."
    Write-Output "Resource Group: $env:ResourceGroupName"
    Write-Output "Storage Account: $env:StorageAccountName"
    
    # Use Azure CLI to enable static website - this uses managed identity and never touches storage keys
    $result = az storage blob service-properties update `
        --account-name $env:StorageAccountName `
        --static-website `
        --index-document 'index.html' `
        --404-document 'index.html' `
        --auth-mode login `
        --only-show-errors
    
    if ($LASTEXITCODE -eq 0) {
        Write-Output "Successfully enabled static website hosting using Azure CLI!"
        Write-Output "Result: $result"
    } else {
        throw "Azure CLI command failed with exit code $LASTEXITCODE"
    }
}
catch {
    Write-Error "Failed to enable static website: $($_.Exception.Message)"
    
    # Fallback: Try alternative Azure CLI approach
    try {
        Write-Output "Trying alternative approach..."
        $result = az rest `
            --method patch `
            --url "https://management.azure.com/subscriptions/$((az account show --query id -o tsv))/resourceGroups/$env:ResourceGroupName/providers/Microsoft.Storage/storageAccounts/$env:StorageAccountName/blobServices/default?api-version=2022-09-01" `
            --body '{"properties":{"staticWebsite":{"enabled":true,"indexDocument":"index.html","errorDocument404Path":"index.html"}}}' `
            --headers "Content-Type=application/json"
            
        if ($LASTEXITCODE -eq 0) {
            Write-Output "Successfully enabled static website hosting using Azure REST API!"
            Write-Output "Result: $result"
        } else {
            throw "Both Azure CLI approaches failed"
        }
    }
    catch {
        Write-Error "All approaches failed: $($_.Exception.Message)"
        throw
    }
}
