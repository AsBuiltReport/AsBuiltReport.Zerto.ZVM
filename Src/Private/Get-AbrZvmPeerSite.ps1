function Get-AbrZvmPeerSite {
    <#
    .SYNOPSIS
    Used by As Built Report to retrieve Zerto ZVM peer site information
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
    )

    begin {
        Write-PScriboMessage "Collecting ZVM peer site information."
    }

    process {
        Try {
            $PeerSites = Invoke-ZvmRestApi -Uri "/peersites"
            $PeerSites = $PeerSites | Sort-Object PeerSiteName
            if ($PeerSites) {
                Section -Style Heading2 'Peer Sites' {
                    # Collect Peer Site information
                    $PeerSiteInfo = foreach ($PeerSite in $PeerSites) {
                        [PSCustomObject] @{
                            'Site Name'= $Peersite.PeerSiteName
                            'Site ID' = $PeerSite.SiteIdentifier
                            'Location' = $Peersite.Location
                            'Platform Type' = $Peersite.SiteType
                            'Platform Version' = $Peersite.Version
                            'Hostname / IP' = $Peersite.HostName
                            'Port' = $Peersite.Port
                            'Provisioned Storage' = "$([math]::Round($Peersite.ProvisionedStorage / 1024)) GB"
                            'Used Storage' = "$([math]::Round($Peersite.UsedStorage / 1024)) GB"
                        }
                    }
                    # Check InfoLevels, if 2 show individual tables, else show a single summarised table
                    if ($InfoLevel.PeerSite -ge 2) {
                        $PeerSiteInfo | ForEach-Object {
                            $PeerSite = $_
                            Section -Style Heading3 $($PeerSite.'Site Name') {
                                $TableParams = @{
                                    Name = "Peer Site $($PeerSite.'Site Name') - $ZVM"
                                    List = $true
                                    ColumnWidths = 40, 60
                                }
                                if ($Report.ShowTableCaptions) {
                                    $TableParams['Caption'] = "- $($TableParams.Name)"
                                }
                                $PeerSite | Table @TableParams
                            }
                        }
                    } else {
                        $TableParams = @{
                            Name = "Peer Sites - $ZVM"
                            Columns = 'Site Name','Location','Hostname / IP','Platform Type','Platform Version'
                            Headers = 'Site Name','Location','Hostname / IP','Platform Type','Version'
                            ColumnWidths = 25, 25, 20, 15, 15
                        }
                        if ($Report.ShowTableCaptions) {
                            $TableParams['Caption'] = "- $($TableParams.Name)"
                        }
                        $PeerSiteInfo | Table @TableParams
                    }
                }
            }
        } Catch {
            Write-PScriboMessage -IsWarning $($_.Exception.Message)
        }
    }

    end {
    }
}