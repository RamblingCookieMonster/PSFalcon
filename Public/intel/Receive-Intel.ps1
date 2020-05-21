function Receive-Intel {
<#
.SYNOPSIS
    Download an intelligence report PDF
.DESCRIPTION
    Requires falconx-reports:read
.PARAMETER ID
    Intelligence report identifier
.PARAMETER PATH
    Destination path
.EXAMPLE
    PS> Receive-CsIntel -Id report_id_1 -Path .\report.pdf
    Downloads the intelligence report 'report_id_1' as .\report.pdf
#>
    [CmdletBinding(DefaultParameterSetName='default')]
    [OutputType()]
    param(
        [Parameter(ParameterSetName = 'default', Mandatory = $true)]
        [string] $Id,

        [Parameter(ParameterSetName = 'default', Mandatory = $true)]
        [string] $Path
    )
    process {
        $Param = @{
            Uri    = '/intel/entities/report-files/v1?id=' + $Id
            Method = 'get'
            Header = @{ accept = 'application/pdf' }
            OutFile = $Path
        }
        switch ($PSBoundParameters.Keys) {
            'Verbose' { $Param['Verbose'] = $true }
            'Debug' { $Param['Debug'] = $true }
        }
        Invoke-Api @Param
    }
    end {
        if (Test-Path $Path) {
            Get-ChildItem $Path | Out-Host
        }
    }
}