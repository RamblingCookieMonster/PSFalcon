function Get-Group {
<#
.SYNOPSIS
    Search for host groups in your environment
.DESCRIPTION
    Requires host-group:read
.PARAMETER ID
    Retrieve detailed information or members for specific host group identifiers
.PARAMETER MEMBERS
    Retrieve identifiers for the members of a host group
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
    Returns an unfiltered list of host group identifiers
.EXAMPLE
    PS> Get-CsGroup -Detailed
    Returns an unfiltered list of detailed host group information
.EXAMPLE
    PS> Get-CsGroup -Id group_id_1 -Members -Detailed
    Returns detailed host information for members of 'group_id_1'
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
        [Parameter(ParameterSetName = 'members', Mandatory = $true)]
        [array] $Id,

        [Parameter(ParameterSetName = 'members', Mandatory = $true)]
        [switch] $Members,

        [Parameter(ParameterSetName = 'default')]
        [Parameter(ParameterSetName = 'members')]
        [string] $Filter,

        [Parameter(ParameterSetName = 'default')]
        [Parameter(ParameterSetName = 'members')]
        [ValidateRange(1, 5000)]
        [int] $Limit,

        [Parameter(ParameterSetName = 'default')]
        [Parameter(ParameterSetName = 'members')]
        [string] $Sort,

        [Parameter(ParameterSetName = 'default')]
        [Parameter(ParameterSetName = 'members')]
        [int] $Offset,

        [Parameter(ParameterSetName = 'default')]
        [Parameter(ParameterSetName = 'members')]
        [switch] $Detailed,

        [Parameter(ParameterSetName = 'default')]
        [Parameter(ParameterSetName = 'members')]
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
        if ($Members) {
            if ($Detailed) {
                $Param.Uri = '/devices/combined/host-group-members/v1?'
            } else {
                $Param.Uri = '/devices/queries/host-group-members/v1?'
            }
            $LoopParam['Members'] = $true
        } elseif ($Detailed) {
            $Param.Uri = '/devices/combined/host-groups/v1?'
        }
        switch ($PSBoundParameters.Keys) {
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
            if ($Members) {
                $BaseUri = $Param.Uri

                $Id | ForEach-Object {
                    $Param.Uri = $BaseUri -replace '/v1\?',('/v1?id=' + [string] $_)

                    if ($Detailed) {
                        Invoke-Loop -Command $MyInvocation.MyCommand.Name -Param $LoopParam -Detailed
                    } else {
                        Invoke-Loop -Command $MyInvocation.MyCommand.Name -Param $LoopParam
                    }
                }
            }
            elseif ($Detailed) {
                Invoke-Loop -Command $MyInvocation.MyCommand.Name -Param $LoopParam -Detailed
            } else {
                Invoke-Loop -Command $MyInvocation.MyCommand.Name -Param $LoopParam
            }
        } elseif ($Members) {
            $BaseUri = $Param.Uri

            $Id | ForEach-Object {
                $Param.Uri = $BaseUri -replace '/v1\?',('/v1?id=' + [string] $_)

                Invoke-Api @Param
            }
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