function Get-Rule {
<#
.SYNOPSIS
    Search for rule identifiers and information
.DESCRIPTION
    Requires falconx-rules:read
.PARAMETER ID
    Retrieve detailed information about specific rule identifiers
.PARAMETER NAME
    Filter by rule name
.PARAMETER TYPE
    Filter by rule type
.PARAMETER DESCRIPTION
    Substring match on description field
.PARAMETER TAG
    Filter by rule tags
.PARAMETER MINCREATED
    Filter results to those created on or after a certain date
.PARAMETER MAXCREATED
    Filter results to those created on or before a certain date
.PARAMETER QUERY
    Perform a generic substring search across all fields
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
    PS> Get-CsRule
    Returns rule identifiers
.EXAMPLE
    PS> Get-CsRule -Detailed
    Returns detailed rule information
.EXAMPLE
    PS> Get-CsRule -Tag intel_feed
    Returns identifiers for rules containing the tag 'intel_feed'
.EXAMPLE
    PS> Get-CsRule -Id rule_id_1, rule_id_2
    Returns detail about rule identifiers 'rule_id_1' and 'rule_id_2'
#>
    [CmdletBinding(DefaultParameterSetName='default')]
    [OutputType()]
    param(
        [Parameter(ParameterSetName = 'id', Mandatory = $true)]
        [array] $Id,

        [Parameter(ParameterSetName = 'default')]
        [array] $Name,

        [Parameter(ParameterSetName = 'default', Mandatory = $true)]
        [ValidateSet('snort-suricata-master', 'snort-suricata-update', 'snort-suricata-changelog',
        'yara-master', 'yara-update', 'yara-changelog', 'common-event-format', 'netwitness')]
        [string] $Type,

        [Parameter(ParameterSetName = 'default')]
        [array] $Description,

        [Parameter(ParameterSetName = 'default')]
        [array] $Tag,

        [Parameter(ParameterSetName = 'default')]
        [string] $MinCreated,

        [Parameter(ParameterSetName = 'default')]
        [string] $MaxCreated,

        [Parameter(ParameterSetName = 'default')]
        [string] $Query,

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
            Uri    = '/intel/queries/rules/v1?type=' + $Type
            Method = 'get'
            Header = @{
                'content-type' = 'application/json'
            }
        }
        switch ($PSBoundParameters.Keys) {
            'Name' {
                $Param.Uri += '&name=' + ($Name -join '&name=')
                $LoopParam['Name'] = $Name
            }
            'Description' {
                $Param.Uri += '&description=' + ($Description -join '&description=')
                $LoopParam['Description'] = $Description
            }
            'Tag' {
                $Param.Uri += '&tags=' + ($Tag -join '&tags=')
                $LoopParam['Tag'] = $Tag
            }
            'MinCreated' {
                $Param.Uri += '&mincreateddate=' + $MinCreated
                $LoopParam['MinCreated'] = $MinCreated
            }
            'MaxCreated' {
                $Param.Uri += '&maxcreateddate=' + $MaxCreated
                $LoopParam['MaxCreated'] = $MaxCreated
            }
            'Query' {
                $Param.Uri += '&q=' + $Query
                $LoopParam['Query'] = $Query
            }
            'Limit' {
                $Param.Uri += '&limit=' + $Limit
                $LoopParam['Limit'] = $Limit
            }
            'Sort' {
                $Param.Uri += '&sort=' + $Sort
                $LoopParam['Sort'] = $Sort
            }
            'Offset' {
                $Param.Uri += '&offset=' + $Offset
                $LoopParam['Offset'] = $Offset
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
                $Param.Uri = '/intel/entities/rules/v1?ids=' + ($_ -join '&ids=')

                Invoke-Api @Param
            }
        } else {
            $Request = Invoke-Api @Param

            if ($Detailed -and $Request.resources) {
                Split-Array -Uri $Param.Uri -Id $Request.resources | ForEach-Object {
                    $Param.Uri = '/intel/entities/rules/v1?ids=' + ($_ -join '&ids=')

                    Invoke-Api @Param
                }
            } else {
                $Request
            }
        }
    }
}