function Get-UninstallToken {
<#
.SYNOPSIS
    Retrieve an uninstall token
.DESCRIPTION
    Requires sensor-update-policies:write
.PARAMETER ID
    Host identifier
.EXAMPLE
    PS> Get-CsUninstallToken
    Returns the bulk maintenance token
.EXAMPLE
    PS> Get-CsUninstallToken -Id host_id_1
    Returns the uninstall token for 'host_id_1'
#>
    [CmdletBinding(DefaultParameterSetName='default')]
    [OutputType()]
    param(
        [Parameter(ParameterSetName = 'default')]
        [string] $Id
    )
    begin {
        if (-not($Id)) { $Id = 'MAINTENANCE' }

        $Body = @{
            audit_message = ($MyInvocation.MyCommand.Name + ' [PSFalcon]')
            device_id = $Id
        }
    }
    process {
        $Param = @{
            Uri    = '/policy/combined/reveal-uninstall-token/v1'
            Method = 'post'
            Header = @{ 'content-type' = 'application/json' }
            Body   = ConvertTo-Json $Body
        }
        switch ($PSBoundParameters.Keys) {
            'Verbose' { $Param['Verbose'] = $true }
            'Debug' { $Param['Debug'] = $true }
        }
        Invoke-Api @Param
    }
}