function Get-Group {
<#
.SYNOPSIS
    Search for host groups in your environment
.DESCRIPTION
    Requires host-group:read
.PARAMETER ID
    Retrieve detailed information about specific host group identifiers
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
.PARAMETER ALL
    Repeat requests until all available results are retrieved
.EXAMPLE
    PS> Get-CsGroup
    Returns host group identifiers
.EXAMPLE
    PS> Get-CsGroup -Detailed
    Returns detailed host group information
.EXAMPLE
    PS> Get-CsGroup -Filter "name:'Example'"
    Returns the identifier for a host group named 'Example'
.EXAMPLE
    PS> Get-CsGroup -Id group_id_1, group_id_2
    Returns detail about host group identifiers 'group_id_1' and 'group_id_2'
#>
    [CmdletBinding(DefaultParameterSetName = 'default')]
    [OutputType()]
    param(
        [Parameter(ParameterSetName = 'id', Mandatory = $true)]
        [array] $Id,

        [Parameter(ParameterSetName = 'default')]
        [string] $Filter,

        [Parameter(ParameterSetName = 'default')]
        [ValidateRange(1, 5000)]
        [int] $Limit,

        [Parameter(ParameterSetName = 'default')]
        [string] $Sort,

        [Parameter(ParameterSetName = 'default')]
        [int] $Offset,

        [Parameter(ParameterSetName = 'default')]
        [switch] $Detailed,

        [Parameter(ParameterSetName = 'default')]
        [switch] $All
    )
    process {
        $LoopParam = @{ }

        $Param = @{
            Uri    = '/devices/queries/host-groups/v1?'
            Method = 'get'
            Header = @{
                'content-type' = 'application/json'
            }
        }
        if ($Detailed) {
            $LoopParam['Detailed'] = $true

            $Param.Uri = '/devices/combined/host-groups/v1?'
        }
        switch ($PSBoundParameters.Keys) {
            'Filter' {
                $Param.Uri += '&filter=' + [System.Web.HTTPUtility]::UrlEncode($Filter)
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
            Invoke-Loop -Command $MyInvocation.MyCommand.Name -Param $LoopParam
        } elseif ($Id) {
            Split-Array -Uri $Param.Uri -Id $Id | ForEach-Object {
                $Param.Uri = '/devices/entities/host-groups/v1?ids=' + ($_ -join '&ids=')

                Invoke-Api @Param
            }
        } else {
            Invoke-Api @Param
        }
    }
}