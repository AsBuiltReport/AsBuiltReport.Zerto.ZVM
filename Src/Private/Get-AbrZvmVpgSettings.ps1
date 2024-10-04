function Get-AbrZvmVpgSettings {
    <#
    .SYNOPSIS
    Used by As Built Report to retrieve Zerto ZVM VPG settings information
    .DESCRIPTION

    .NOTES
        Version:        0.1.0
        Author:         Tim Carman
        Twitter:        @tpcarman
        Github:         tpcarman
    .EXAMPLE

    .LINK

    #>
    [CmdletBinding()]
    param (
        [Parameter(
            Mandatory = $true
        )]
        [ValidateNotNullOrEmpty()]
        [String] $VpgIdentifier
    )

    begin {
        $username = $Credential.UserName
        $password = $Credential.GetNetworkCredential().Password
        $auth = [System.Convert]::ToBase64String([System.Text.Encoding]::UTF8.GetBytes($username + ":" + $password ))
        $api = "https://" + $Zvm + "/v1"

        # Authenticate to the ZVM
        $ZvmApiToken = Get-ZvmApiToken
        $headers = @{
            'Content-Type' = 'application/json'
            'Authorization' = "Bearer $ZvmApiToken"
        }
        $VpgJson =
        "{
            ""VpgIdentifier"":""$VpgIdentifier""
        }"
    }

    process {
        $VpgEditSettingsUrl = $api + "/vpgSettings"
        $VpgSettingsId = Invoke-RestMethod -Method Post -Uri $VpgEditSettingsUrl -Body $VpgJson -Headers $headers -SkipCertificateCheck
    }

    end {
        Return $VpgSettingsId
    }
}