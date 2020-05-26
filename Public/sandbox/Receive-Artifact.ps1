function Receive-Artifact {
<#
.SYNOPSIS
    Download IOC packs, PCAP files, and other analysis artifacts
.DESCRIPTION
    Requires falconx-sandbox:read
.PARAMETER ID
    The identifier of an IOC pack, PCAP file, or actor image
.PARAMETER PATH
    Destination path
.PARAMETER NAME
    The name given to your downloaded file
.EXAMPLE
    PS> Receive-CsArtifact -Id <string> -Path <string>
#>
    [CmdletBinding(DefaultParameterSetName='default')]
    [OutputType()]
    param(
        [Parameter(ParameterSetName = 'default', Mandatory = $true)]
        [string] $Id,

        [Parameter(ParameterSetName = 'default', Mandatory = $true)]
        [string] $Path,

        [Parameter(ParameterSetName = 'default')]
        [string] $Name
    )
    process {
        $Param = @{
            Uri    = '/falconx/entities/artifacts/v1?id=' + $Id
            Method = 'get'
            Header = @{
                accept = '*/*'
                'accept-encoding' = 'gzip'
                'content-type' = 'application/json'
            }
            Outfile = $Path
        }
        switch ($PSBoundParameters.Keys) {
            'Name' { $Param.Uri += '&name=' + $Name }
            'Verbose' { $Param['Verbose'] = $true }
            'Debug' { $Param['Debug'] = $true }
        }
        Invoke-Api @Param
    }
}