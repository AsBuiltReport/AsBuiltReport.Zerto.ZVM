function Invoke-ZvmRestApi {

    [CmdletBinding()]
    param (
        [Parameter(
            Mandatory = $true
        )]
        [ValidateNotNullOrEmpty()]
        [String] $Uri,

        [Parameter(
            Mandatory = $false
        )]
        [ValidateSet("Get", "Put", "Post")]
        [string] $Method = "Get"
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
    }

    process {
        Try {
            Write-PScriboMessage -Message "Performing API reference call to $(($URI).TrimStart('/')) [$Zvm]"
            # Check PowerShell version
            if ($PSVersionTable.PSVersion.Major -eq "7") {
                Invoke-RestMethod -Method $Method -Uri ($api + $uri) -Headers $headers -SkipCertificateCheck
            } elseif ($PSVersionTable.PSVersion.Major -eq "5") {
                Invoke-RestMethod -Method $Method -Uri ($api + $uri) -Headers $headers
            } else {
                Throw
            }
        } Catch {
            Write-Verbose -Message "Error with API reference call to $(($URI).TrimStart('/')) [$Zvm]"
            Write-Verbose -Message $_
        }
    }

    end {}

}