function Get-AbrZvmDatastore {
    <#
    .SYNOPSIS
    Used by As Built Report to retrieve Zerto ZVM datastore information
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
        Write-PScriboMessage "Collecting ZVM datastore information."
    }

    process {
        Try {
            $Datastores = Invoke-ZvmRestApi -Uri "/datastores"
            $Datastores = $Datastores | Sort-Object DatastoreName
            if ($Datastores) {
                Section -Style Heading2 'Datastores' {
                    # Collect Datastore information
                    $DatastoreInfo = foreach ($Datastore in $Datastores) {
                        [PSCustomObject] @{
                            'Datastore' = $Datastore.DatastoreName
                            'Datastore ID' = $Datastore.DatastoreIdentifier
                            'Status' = $Datastore.Health.Status
                            'Type' = $Datastore.Config.Type
                            'Devices' = ($Datastore.Config.Devices | Sort-Object) -join ', '
                            'Datastore Cluster' = if ($Datastore.Config.OwningDatastoreCluster) {
                                $Datastore.Config.OwningDatastoreCluster
                            } else {
                                '--'
                            }
                            'Total Usage' = "$($Datastore.stats.usage.datastore.ProvisionedInBytes / 1GB) GB"
                            'Capacity' = "$($Datastore.stats.usage.datastore.CapacityInBytes / 1GB) GB"
                            'Number of Protected VMs' = $Datastore.Stats.NumOutgoingVMs
                            'Number of Incoming VMs' = $Datastore.Stats.NumIncomingVMs
                            'Number of VRAs' = $Datastore.Stats.NumVRAs
                        }
                    }
                    # Check InfoLevels, if 2 show individual tables, else show a single summarised table
                    if ($InfoLevel.Datastore -ge 2) {
                        $DatastoreInfo | ForEach-Object {
                            $Datastore = $_
                            Section -Style Heading3 $($Datastore.'Datastore') {
                                $TableParams = @{
                                    Name = "Datastore $($Datastore.'Datastore') - $ZVM"
                                    List = $true
                                    ColumnWidths = 40, 60
                                }
                                if ($Report.ShowTableCaptions) {
                                    $TableParams['Caption'] = "- $($TableParams.Name)"
                                }
                                $Datastore | Table @TableParams
                            }
                        }
                    } else {
                        $TableParams = @{
                            Name = "Datastores - $ZVM"
                            Columns = 'Datastore', 'Status', 'Type', 'Datastore Cluster', 'Number of Protected VMs', 'Number of VRAs'
                            Headers = 'Datastore', 'Status', 'Type', 'Datastore Cluster', '# Protected VMs', '# VRAs'
                            ColumnWidths = 24, 13, 13, 24, 13, 13
                        }
                        if ($Report.ShowTableCaptions) {
                            $TableParams['Caption'] = "- $($TableParams.Name)"
                        }
                        $DatastoreInfo | Table @TableParams
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