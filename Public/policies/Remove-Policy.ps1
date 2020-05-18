function Remove-Policy {
<#
.SYNOPSIS
    Delete a set of policies by specifying their ids
.DESCRIPTION
    Requires the following, based on type:

    device-control-policies:write
    firewall-management:write
    prevention-policies:write
    sensor-update-policies:write
.PARAMETER ID
    One or more policy ids
.EXAMPLE
    PS> Remove-CsPolicy -Type Prevention -Ids 'policy_id_1', 'policy_id_2'
    Removes prevention policies 'policy_id_1' and 'policy_id_2'
#>
    [CmdletBinding(DefaultParameterSetName='default')]
    [OutputType()]
    param(
        [Parameter(ParameterSetName = 'default', Mandatory = $true)]
        [ValidateSet('DeviceControl', 'Firewall', 'SensorUpdate', 'Prevention')]
        [string] $Type,

        [Parameter(ParameterSetName = 'default', Mandatory = $true)]
        [array] $Id
    )
    begin {
        switch ($Type) {
            'DeviceControl' { $EntityUri = '/policy/entities/device-control/v1?' }
            'Firewall' { $EntityUri = '/policy/entities/firewall/v1?' }
            'SensorUpdate' { $EntityUri = '/policy/entities/sensor-update/v1?' }
            'Prevention' { $EntityUri = '/policy/entities/prevention/v1?' }
        }
    }
    process {
        $Param = @{
            Uri    = $EntityUri
            Method = 'delete'
            Header = @{ 'content-type' = 'application/json' }
        }
        switch ($PSBoundParameters.Keys) {
            'Verbose' { $Param['Verbose'] = $true }
            'Debug' { $Param['Debug'] = $true }
        }
        Split-Array -Uri $Param.Uri -Id $Id | ForEach-Object {
            $Param.Uri = $EntityUri + ($_ -join '&ids=')

            Invoke-Api @Param
        }
    }
}