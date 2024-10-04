function Get-ZvmApiToken {
    $uri = $keycloak = "https://$Zvm/auth/realms/zerto/protocol/openid-connect/token"
    $headers = @{
        'Content-Type' = 'application/x-www-form-urlencoded'
    }
    $body = @{
        'username'  = $username
        'password'  = $password
        'grant_type' = 'password'
        'client_id' = 'zerto-client'
    }

    try {
        $response = Invoke-RestMethod -Uri $uri -Headers $headers -Method Post -Body $body -SkipCertificateCheck
        return $response.access_token
    }
    catch {
        Write-PScriboMessage -Message "Error obtaining token: $_" "ERROR"
        return $null
    }
}