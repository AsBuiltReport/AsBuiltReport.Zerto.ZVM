function Get-AbrZvmLocalSite {
    <#
    .SYNOPSIS
    Used by As Built Report to retrieve Zerto ZVM local site information
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
        Write-PScriboMessage "Collecting ZVM local site information."
    }

    process {
        Try {
            $LocalSite =  Invoke-ZvmRestApi -Uri "/localsite"
            $License = Invoke-ZvmRestApi -Uri "/license"

            if ($LocalSite) {
                Section -Style Heading2 'Local Site' {
                    # Collect Local Site information
                    $LocalSiteInfo = [PSCustomObject] @{
                        'Site Name' = $LocalSite.SiteName
                        'Site ID' = $LocalSite.SiteIdentifier
                        'Location' = $LocalSite.Location
                        'Version' = $LocalSite.Version
                        'Platform Type' = $LocalSite.SiteType
                        'Platform Version' = $LocalSite.SiteTypeVersion
                        'IP Address' = $LocalSite.IpAddress
                        'Replication To Self' = if ($LocalSite.IsReplicationToSelfEnabled) {
                            'Enabled'
                        } else {
                            'Disabled'
                        }
                        'Contact Name' = $LocalSite.ContactName
                        'Contact Email' = $LocalSite.ContactEmail
                        'Contact Phone' = $LocalSite.ContactPhone
                        'Bandwidth Throttling (MB/sec)' = Switch ($LocalSite.BandwidthThrottlingInMBs) {
                            -1 { 'Unlimited' }
                            default { $LocalSite.BandwidthThrottlingInMBs }
                        }
                    }
                    # Check InfoLevels, if 2 show individual tables, else show a single summarised table
                    if ($InfoLevel.LocalSite -ge 2) {
                        $TableParams = @{
                            Name = "Local Site - $ZVM"
                            List = $true
                            ColumnWidths = 40, 60
                        }
                        if ($Report.ShowTableCaptions) {
                            $TableParams['Caption'] = "- $($TableParams.Name)"
                        }
                        $LocalSiteInfo | Table @TableParams
                    } else {
                        $TableParams = @{
                            Name = "Local Site - $ZVM"
                            Columns = 'Site Name', 'Platform Type', 'IP Address', 'Version'
                            ColumnWidths = 25, 25, 25, 25
                        }
                        if ($Report.ShowTableCaptions) {
                            $TableParams['Caption'] = "- $($TableParams.Name)"
                        }
                        $LocalSiteInfo | Table @TableParams
                    }

                    # Licensing
                    if ($License) {
                        Write-PScriboMessage "Collecting ZVM license information."
                        Section -Style Heading3 'Licensing' {
                            $LicenseInfo = [PSCustomObject] @{
                                'Site Name' = $License.SiteName
                                'License' = if ($Options.ShowLicense) {
                                    $License.LicenseKey
                                } else {
                                    'License key not displayed'
                                }
                                'License Type' = $License.LicenseType
                                'Expiry Date' = if ($License.ExpiryTime) {
                                    $License.ExpiryTime
                                } else {
                                    'N/A'
                                }
                                'Quantity' = $License.MaxVms
                                'Total VMs Count' = $License.TotalVmsCount
                            }
                            $TableParams = @{
                                Name = "Licensing - $ZVM"
                                List = $true
                                ColumnWidths = 40, 60
                            }
                            if ($Report.ShowTableCaptions) {
                                $TableParams['Caption'] = "- $($TableParams.Name)"
                            }
                            $LicenseInfo | Table @TableParams
                        }
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