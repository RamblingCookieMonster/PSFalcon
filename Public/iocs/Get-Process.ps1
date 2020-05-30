function Get-Process {
<#
.SYNOPSIS
    Retrieve detailed information about process
.DESCRIPTION
    Requires iocs:read
.PARAMETER ID
    Process identifier [format: 'pid:<device_id>:<process_id>']
.EXAMPLE
    PS> Get-CsProcess -Id pid:device_id_1:process_id_1
    Returns summary information about 'process_id_1' on 'device_id_1'
#>
    [CmdletBinding(DefaultParameterSetName='default')]
    [OutputType()]
    param(
        [Parameter(ParameterSetName = 'default', Mandatory = $true)]
        [array] $Id
    )
    process {
        $Param = @{
            Uri    = '/processes/entities/processes/v1'
            Method = 'get'
            Header = @{ 'content-type' = 'application/json' }
        }
        switch ($PSBoundParameters.Keys) {
            'Verbose' { $Param['Verbose'] = $true }
            'Debug' { $Param['Debug'] = $true }
        }
        $Uri = '/processes/entities/processes/v1?ids='

        Split-Array -Uri $Uri -Join '&ids=' -Id $Id | ForEach-Object {
            $Param.Uri = $Uri + ($_ -join '&ids=')

            Invoke-Api @Param
        }
    }
}