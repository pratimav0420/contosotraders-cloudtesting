$ErrorActionPreference = 'Stop'

# Wait for role assignments to propagate (increased time)
Write-Output "Waiting for role assignments to propagate..."
Start-Sleep -Seconds 120

try {
    # Ensure we're using managed identity authentication
    Write-Output "Connecting using managed identity..."
    Connect-AzAccount -Identity
    
    # Get access token for Azure Storage
    Write-Output "Getting access token for Azure Storage..."
    $token = [Microsoft.Azure.Commands.Common.Authentication.AzureSession]::Instance.AuthenticationFactory.Authenticate((Get-AzContext).Account, (Get-AzContext).Environment, (Get-AzContext).Tenant.Id, $null, "https://storage.azure.com/", $null).AccessToken
    
    # Enable static website using REST API to avoid key-based authentication
    Write-Output "Enabling static website using REST API..."
    $subscriptionId = (Get-AzContext).Subscription.Id
    $uri = "https://management.azure.com/subscriptions/$subscriptionId/resourceGroups/$env:ResourceGroupName/providers/Microsoft.Storage/storageAccounts/$env:StorageAccountName/blobServices/default?api-version=2022-09-01"
    
    $headers = @{
        'Authorization' = "Bearer $token"
        'Content-Type' = 'application/json'
    }
    
    $body = @{
        properties = @{
            staticWebsite = @{
                enabled = $true
                indexDocument = 'index.html'
                errorDocument404Path = 'index.html'
            }
        }
    } | ConvertTo-Json -Depth 10
    
    $response = Invoke-RestMethod -Uri $uri -Method PUT -Headers $headers -Body $body
    Write-Output "Successfully enabled static website hosting via REST API!"
    Write-Output "Response: $($response | ConvertTo-Json -Depth 2)"
}
catch {
    Write-Error "Failed to enable static website: $($_.Exception.Message)"
    Write-Output "Error details: $($_.Exception.InnerException)"
    if ($_.Exception.Response) {
        Write-Output "HTTP Status: $($_.Exception.Response.StatusCode)"
        Write-Output "HTTP Status Description: $($_.Exception.Response.StatusDescription)"
    }
    throw
}
