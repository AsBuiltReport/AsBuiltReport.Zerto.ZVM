function Get-AbrZvmVolume {
    <#
    .SYNOPSIS
    Used by As Built Report to retrieve Zerto ZVM volume information
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
        Write-PScriboMessage "Collecting ZVM volume information."
    }

    process {
        Try {
            $Volumes = Invoke-ZvmRestApi -Uri "/volumes"
            $Volumes = $Volumes | Where-Object {$_.VolumeType -eq 'Protected'} | Sort-Object -Property @{Expression = {$_.VPG.Name}},@{Expression = {$_.Path.Full}}
            if ($Volumes) {
                Section -Style Heading2 'Volumes' {
                    # Collect Volume information
                    $VolumeInfo = foreach ($Volume in $Volumes) {
                        [PSCustomObject] @{
                            'Volume Name' = "$($($Volume.OwningVM.Name)) $("[$($Volume.VolumeIdentifier)]")"
                            'Datastore' = $Volume.Datastore.Name
                            'Volume Type' = $Volume.VolumeType
                            'Protected Volume Location' = $Volume.Path.Full
                            #'Recovery Volume Location' = ''
                            'Provisioned Storage' = "$([math]::Round($Volume.Size.ProvisionedInBytes / 1GB)) GB"
                            'Provisioned Storage (GB)' = [math]::Round($Volume.Size.ProvisionedInBytes / 1GB)
                            'Used Storage' = "$([math]::Round($Volume.Size.UsedInBytes / 1GB)) GB"
                            'Thin Provisioned' = if ($Volume.IsThinProvisioned) {
                                'Yes'
                            } else {
                                'No'
                            }
                            'VPG Name' = $Volume.Vpg.Name
                        }
                    }
                    # Check InfoLevels, if 2 show individual tables, else show a single summarised table
                    if ($InfoLevel.Volume -ge 2) {
                        $VolumeInfo | ForEach-Object {
                            $Volume = $_
                            Section -Style Heading3 $($Volume.'Volume Name') {
                                $TableParams = @{
                                    Name = "Volume $($Volume.'Volume Name') - $ZVM"
                                    List = $true
                                    ColumnWidths = 40, 60
                                }
                                if ($Report.ShowTableCaptions) {
                                    $TableParams['Caption'] = "- $($TableParams.Name)"
                                }
                                $Volume | Table @TableParams
                            }
                        }
                    } else {
                        $TableParams = @{
                            Name = "Volumes - $ZVM"
                            Columns = 'Volume Name','Datastore','Volume Type','Provisioned Storage (GB)','Thin Provisioned','VPG Name'
                            Headers = 'Volume','Datastore','Volume Type','Provisioned (GB)','Thin','VPG'
                            ColumnWidths = 20, 25, 14, 14, 12, 15
                        }
                        if ($Report.ShowTableCaptions) {
                            $TableParams['Caption'] = "- $($TableParams.Name)"
                        }
                        $VolumeInfo | Table @TableParams
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