function Get-AbrZvmVra {
    <#
    .SYNOPSIS
    Used by As Built Report to retrieve Zerto ZVM VRA information
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
        Write-PScriboMessage "Collecting ZVM VRA information."
    }

    process {
        Try {
            $Vras = Invoke-ZvmRestApi -Uri "/vras"
            $Vras = $Vras | Sort-Object VraName
            if ($Vras) {
                Section -Style Heading2 'VRAs' {
                    # Collect VRA information
                    $VRAInfo = foreach ($VRA in $VRAs) {
                        [PSCustomObject] @{
                            'VRA Name' = $VRA.VraName
                            'VRA Version' = $VRA.VraVersion
                            'VRA Status' = Switch ($VRA.Status) {
                                0 { 'Installed' }
                                1 { 'Unsupported ESX Version' }
                                2 { 'Not Installed' }
                                3 { 'Installing' }
                                4 { 'Removing' }
                                5 { 'Installation Error' }
                                6 { 'Host Password Changed' }
                                7 { 'Updating IP Settings' }
                                8 { 'During Change Host' }
                                9 { 'Host in Maintenance Mode' }
                                default { 'Unknown' }
                            }
                            'Host Address' = $VRA.HostDisplayName
                            'Host Version' = $VRA.HostVersion
                            'VRA CPU' = $VRA.NumOfCpus
                            'VRA RAM' = "$($VRA.MemoryInGB) GB"
                            'VRA IP Configuration' = $VRA.VraNetworkDataApi.VraIPConfigurationTypeApi
                            'VRA IP Address' = $VRA.VraNetworkDataApi.VraIPAddress
                            'VRA Subnet Mask' = $VRA.VraNetworkDataApi.SubnetMask
                            'VRA Default Gateway' = $VRA.VraNetworkDataApi.DefaultGateway
                            'VRA Group' = $VRA.VraGroup
                            'Datastore' = $VRA.DatastoreName
                            'Datastore Identifier' = $VRA.DatastoreIdentifier
                            'Datastore Cluster' = if ($VRA.DatastoreClusterName) {
                                $VRA.DatastoreClusterName
                            } else {
                                '--'
                            }
                            'Datastore Cluster Identifier' = if ($VRA.DatastoreClusterIdentifier) {
                                $VRA.DatastoreClusterIdentifier
                            } else {
                                '--'
                            }
                            'Network Name' = $VRA.NetworkName
                            'Network Identifier' = $VRA.NetworkIdentifier
                            'Number of Protected VMs' = $VRA.ProtectedCounters.VMs
                            'Number of Protected Volumes' = $VRA.ProtectedCounters.Volumes
                            'Number of Protected VPGs' = $VRA.ProtectedCounters.Vpgs
                            'Number of Recovery VMs' = $VRA.RecoveryCounters.VMs
                            'Number of Recovery Volumes' = $VRA.RecoveryCounters.Volumes
                            'Number of Recovery VPGs' = $VRA.RecoveryCounters.Vpgs
                            #'Progress' = $VRA.Progress
                            #'Self Protected Vpgs' = $VRA.SelfProtectedVpgs
                        }
                    }
                    # Check InfoLevels, if 2 show individual tables, else show a single summarised table
                    if ($InfoLevel.VRA -ge 2) {
                        $VRAInfo | ForEach-Object {
                            $VRA = $_
                            Section -Style Heading3 $($VRA.'VRA Name') {
                                $TableParams = @{
                                    Name = "VRA $($VRA.'VRA Name') - $ZVM"
                                    List = $true
                                    ColumnWidths = 40, 60
                                }
                                if ($Report.ShowTableCaptions) {
                                    $TableParams['Caption'] = "- $($TableParams.Name)"
                                }
                                $VRA | Table @TableParams
                            }
                        }
                    } else {
                        $TableParams = @{
                            Name = "VRAs - $ZVM"
                            Columns = 'VRA Name','VRA IP Address','VRA Version','Host Address','Host Version', 'Number of Protected VPGs', 'Number of Protected VMs'
                            Headers = 'VRA Name','VRA Address','VRA Version','Host Address','Host Version', '# VPGs', '# VMs'
                            ColumnWidths = 22, 16, 10, 22, 10, 10, 10
                        }
                        if ($Report.ShowTableCaptions) {
                            $TableParams['Caption'] = "- $($TableParams.Name)"
                        }
                        $VRAInfo | Table @TableParams
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