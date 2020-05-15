function Submit-HostAction {
<#
.SYNOPSIS
    Take various actions on hosts in your environment
.DESCRIPTION
    Requires hosts:write
.PARAMETER ID
    The host identifiers to target
.PARAMETER ACTION
    contain          : Contains the host, stopping network communications other than to the CrowdStrike
                       cloud and IPs specified in your containment policy.
    lift_containment : Lifts containment on the host, returning network communications to normal.
    hide_host        : Hides a host. After a host is hidden, no detections for that host will be
                       reported via UI or APIs.
    unhide_host      : Restores a hidden host. Detection reporting will resume after the host is restored.
.EXAMPLE
    PS> Submit-CsHostAction -Id host_id_1, host_id_2 -Action contain
    Contains host identifiers 'host_id_1' and 'host_id_2'
.EXAMPLE
    PS> Submit-CsHostAction -Id host_id_1, host_id_2 -Action unhide_host
    Restores hidden host identifiers 'host_id_1' and 'host_id_2'
#>
    [CmdletBinding(DefaultParameterSetName='default')]
    [OutputType()]
    param(
        [Parameter(ParameterSetName = 'default', Mandatory = $true)]
        [array] $Id,

        [Parameter(ParameterSetName = 'default', Mandatory = $true)]
        [ValidateSet('contain', 'hide_host', 'lift_containment', 'unhide_host')]
        [string] $Action
    )
    process {
        $Param = @{
            Uri    = '/devices/entities/devices-actions/v2?action_name=' + $Action
            Method = 'post'
            Header = @{
                accept = 'application/json'
                'content-type' = 'application/json'
            }
            Body   = @{ 'ids' = $Id } | ConvertTo-Json
        }
        switch ($PSBoundParameters.Keys) {
            'Verbose' { $Param['Verbose'] = $true }
            'Debug' { $Param['Debug'] = $true }
        }
        if ($Action -eq 'hide_host' -or 'unhide_host') {
            # Max group size
            $Max = 100

            # Make requests in groups of $Max for 'hide_host' and 'unhide_host'
            for ($i = 0; $i -lt $Id.count; $i += $Max) {
                if ($i -gt 0) {
                    $Progress = @{
                        Activity = $MyInvocation.MyCommand.Name
                        Status = [string] $i + ' of ' + [string] $Id.count
                        PercentComplete = (($i/$Id.count)*100)
                    }
                    Write-Progress @Progress
                }
                $Param.Body = @{ 'ids' = @($Id)[$i..($i + ($Max - 1))] } | ConvertTo-Json

                Invoke-Api @Param
            }
        } else {
            Invoke-Api @Param
        }
    }
}