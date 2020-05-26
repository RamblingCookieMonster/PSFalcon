function Send-Sample {
<#
.SYNOPSIS
    Upload a file for sandbox analysis
.DESCRIPTION
    Requires falconx-sandbox:write
.PARAMETER PATH
    The full path to the file to upload
.PARAMETER COMMENT
    A descriptive comment to identify the file for other users
.PARAMETER CONFIDENTIAL
    Defines visibility of this file in Falcon MalQuery [default: true]
.EXAMPLE
    PS> Send-CsSample -Path .\example.exe -Comment 'Example File'
    Uploads '.\example.exe' with the comment 'Example File'
#>
    [CmdletBinding(DefaultParameterSetName='default')]
    [OutputType()]
    param(
        [Parameter(ParameterSetName = 'default', Mandatory = $true)]
        [string] $Path,

        [Parameter(ParameterSetName = 'default')]
        [string] $Comment,

        [Parameter(ParameterSetName = 'default')]
        [boolean] $Confidential
    )
    begin {
        if (-not($Confidential)) { $Confidential = $true }
    }
    process {
        $Param = @{
            Uri    = '/samples/entities/samples/v2?file_name=' + (Split-Path $Path -Leaf) +
            '&is_confidential=' + $Confidential
            Method = 'post'
            Header = @{
                accept = 'application/json'
                'content-type' = 'application/octet-stream'
            }
            Body   = "[ " + (Get-Content $Path) + " ]"
        }
        switch ($PSBoundParameters.Keys) {
            'Comment' { $Param.Uri += '&comment=' + $Comment }
            'Verbose' { $Param['Verbose'] = $true }
            'Debug' { $Param['Debug'] = $true }
        }
        Invoke-Api @Param
    }
}