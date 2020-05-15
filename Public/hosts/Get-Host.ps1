function Get-Host {
<#
.SYNOPSIS
    Search for hosts in your environment
.DESCRIPTION
    Requires hosts:read
.PARAMETER ID
    Retrieve detailed information for specific host identifiers
.PARAMETER FILTER
    An FQL filter expression used to limit results
.PARAMETER LIMIT
    The maximum number of records to return
.PARAMETER SORT
    A property to use to sort results
.PARAMETER OFFSET
    Offset token/integer to retrieve next result set
.PARAMETER HIDDEN
    Narrow search to 'hidden' hosts
.PARAMETER DETAILED
    Retrieve detailed information
.PARAMETER ALL
    Repeat requests until all available results are retrieved
.EXAMPLE
    PS> Get-CsDevice
    Returns an unfiltered list of host identifiers
.EXAMPLE
    PS> Get-CsDevice -Detailed
    Returns an unfiltered list of detailed host information
.EXAMPLE
    PS> Get-CsDevice -Filter "hostname:'USER-PC'"
    Returns identifiers for hosts with hostname 'USER-PC'
.EXAMPLE
    PS> Get-CsDevice -Id host_id_1, host_id_2
    Returns detail about host identifiers 'host_id_1' and 'host_id_2'
#>
    [CmdletBinding(DefaultParameterSetName = 'default')]
    [OutputType()]
    param(
        [Parameter(ParameterSetName = 'id', Mandatory = $true)]
        [array] $Id,

        [Parameter(ParameterSetName = 'default')]
        [Parameter(ParameterSetName = 'hidden')]
        [string] $Filter,

        [Parameter(ParameterSetName = 'default')]
        [Parameter(ParameterSetName = 'hidden')]
        [ValidateRange(1, 5000)]
        [int] $Limit,

        [Parameter(ParameterSetName = 'default')]
        [Parameter(ParameterSetName = 'hidden')]
        [string] $Sort,

        [Parameter(ParameterSetName = 'default')]
        [Parameter(ParameterSetName = 'hidden')]
        [string] $Offset,

        [Parameter(ParameterSetName = 'hidden')]
        [switch] $Hidden,

        [Parameter(ParameterSetName = 'default')]
        [Parameter(ParameterSetName = 'hidden')]
        [switch] $Detailed,

        [Parameter(ParameterSetName = 'default')]
        [Parameter(ParameterSetName = 'hidden')]
        [switch] $All
    )
    process {
        $LoopParam = @{ }

        $Param = @{
            Uri    = '/devices/queries/devices-scroll/v1?'
            Method = 'get'
            Header = @{
                'content-type' = 'application/json'
            }
        }
        switch ($PSBoundParameters.Keys) {
            'Hidden' {
                $Param.Uri = '/devices/queries/devices-hidden/v1?'
                $LoopParam['Hidden'] = $true
            }
            'Filter' {
                $Param.Uri += '&filter=' + $Filter
                $LoopParam['Filter'] = $Filter
            }
            'Limit' {
                $Param.Uri += '&limit=' + [string] $Limit
                $LoopParam['Limit'] = $Limit
            }
            'Sort' {
                $Param.Uri += '&sort=' + $Sort
                $LoopParam['Sort'] = $Sort
            }
            'Offset' {
                $Param.Uri += '&offset=' + [string] $Offset
            }
            'Verbose' {
                $Param['Verbose'] = $true
                $LoopParam['Verbose'] = $true
            }
            'Debug' {
                $Param['Debug'] = $true
                $LoopParam['Debug'] = $true
            }
        }
        if ($All) {
            if ($Detailed) {
                Invoke-Loop -Command $MyInvocation.MyCommand.Name -Param $LoopParam -Detailed
            } else {
                Invoke-Loop -Command $MyInvocation.MyCommand.Name -Param $LoopParam
            }
        } elseif ($Id) {
            Split-Array -Uri $Param.Uri -Id $Id | ForEach-Object {
                $Param.Uri = '/devices/entities/devices/v1?ids=' + ($_ -join '&ids=')

                Invoke-Api @Param
            }
        } else {
            $Request = Invoke-Api @Param

            if ($Detailed -and $Request.resources) {
                Split-Array -Uri $Param.Uri -Id $Request.resources | ForEach-Object {
                    $Param.Uri = '/devices/entities/devices/v1?ids=' + ($_ -join '&ids=')

                    Invoke-Api @Param
                }
            } else {
                $Request
            }
        }
    }
}
