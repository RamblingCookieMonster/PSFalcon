function Get-Installer {
<#
.SYNOPSIS
    Search for sensor installer packages
.DESCRIPTION
    Requires sensor-installers:read
.PARAMETER ID
    Retrieve detailed information for specific installer identifiers
.PARAMETER FILTER
    An FQL filter expression used to limit results
.PARAMETER LIMIT
    The maximum number of records to return
.PARAMETER SORT
    A property to use to sort results
.PARAMETER OFFSET
    Offset integer to retrieve next result set
.PARAMETER DETAILED
    Retrieve detailed information
.EXAMPLE
    PS> Get-CsInstaller
    Lists all available sensor installer packages
.EXAMPLE
    PS> Get-CsInstaller -Filter "platform:'windows'"
    Lists all available sensor installer packages for Windows
#>
    [CmdletBinding(DefaultParameterSetName='default')]
    [OutputType()]
    param(
        [Parameter(ParameterSetName = 'default')]
        [int] $Offset,

        [Parameter(ParameterSetName = 'default')]
        [ValidateRange(1, 500)]
        [int] $Limit,

        [Parameter(ParameterSetName = 'default')]
        [string] $Sort,

        [Parameter(ParameterSetName = 'default')]
        [string] $Filter,

        [Parameter(ParameterSetName = 'default')]
        [switch] $Detailed
    )
    process {
        $Param = @{
            Uri    = '/sensors/queries/installers/v1?'
            Method = 'get'
            Header = @{
                accept = 'application/json'
                'content-type' = 'application/json'
            }
        }
        if ($Detailed) { $Param.Uri = '/sensors/combined/installers/v1?' }

        switch ($PSBoundParameters.Keys) {
            'Offset' { $Param.Uri += '&offset=' + $Offset }
            'Limit' { $Param.Uri += '&limit=' + $Limit }
            'Sort' { $Param.Uri += '&sort=' + $Sort }
            'Filter' { $Param.Uri += '&filter=' + [System.Web.HTTPUtility]::UrlEncode($Filter) }
            'Verbose' { $Param['Verbose'] = $true }
            'Debug' { $Param['Debug'] = $true }
        }
        if ($Id) {
            Split-Array -Uri $Param.Uri -Id $Id | ForEach-Object {
                $Param.Uri = '/sensors/entities/installers/v1?ids=' + ($_ -join '&ids=')

                Invoke-Api @Param
            }
        } else {
            Invoke-Api @Param
        }
    }
}