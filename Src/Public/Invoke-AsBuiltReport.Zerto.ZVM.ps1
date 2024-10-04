function Invoke-AsBuiltReport.Zerto.ZVM {
    <#
    .SYNOPSIS
        PowerShell script to document the configuration of Zerto infrastucture in Word/HTML/Text formats
    .DESCRIPTION
        Documents the configuration of Zerto infrastucture in Word/HTML/Text formats using PScribo.
    .NOTES
        Version:        0.1.0
        Author:         Tim Carman
        Twitter:        @tpcarman
        Github:         tpcarman
        Credits:        Iain Brighton (@iainbrighton) - PScribo module
    .LINK
        https://github.com/AsBuiltReport/AsBuiltReport.Zerto.ZVM
    #>

    param (
        [String[]] $Target,
        [PSCredential] $Credential
    )

    # Import Report Configuration
    $Report = $ReportConfig.Report
    $InfoLevel = $ReportConfig.InfoLevel
    $Options = $ReportConfig.Options
    # Used to set values to TitleCase where required
    $TextInfo = (Get-Culture).TextInfo

    #region foreach $ZVM in $Target
    foreach ($ZVM in $Target) {
        Section -Style Heading1 $ZVM {
            # Site Dashboard
            if ($InfoLevel.Dashboard-gt 0) {
                Get-AbrZvmDashboard
            }

            # Local Site Information
            if ($InfoLevel.LocalSite -gt 0) {
                Get-AbrZvmLocalSite
            }

            # Peer Site Information
            if ($InfoLevel.PeerSite -gt 0) {
                Get-AbrZvmPeerSite
            }

            # VRAs
            if ($InfoLevel.Vra -gt 0) {
                Get-AbrZvmVra
            }

            # Service Profiles
            if ($InfoLevel.ServiceProfile -gt 0) {
                Get-AbrZvmServiceProfile
            }

            # VPGs
            if ($InfoLevel.VPG -gt 0) {
                Get-AbrZvmVpg
            }

            # Protected VMs
            if ($InfoLevel.VM -gt 0) {
                Get-AbrZvmProtectedVM
            }

            # Datastores
            if ($InfoLevel.Datastore -gt 0) {
                Get-AbrZvmDatastore
            }

            # Volumes
            if ($InfoLevel.Volume -gt 0) {
                Get-AbrZvmVolume
            }
        }
    }
    #endregion foreach $ZVM in $Target
}