function Get-IOC {
<#
.SYNOPSIS
    Search for custom IOCs and observations of those IOCs in your environment
.DESCRIPTION
    Requires iocs:read
.PARAMETER TYPE
    Type of IOC
.PARAMETER VALUE
    Returns detailed information about a specific IOC
.PARAMETER AFTER
    Filter to IOCs created after this time (RFC-3339)
.PARAMETER BEFORE
    Filter to IOCs created before this time (RFC-3339)
.PARAMETER POLICY
    Filter to a specific policy [default: detect]
.PARAMETER SOURCE
    Filter to a specific IOC source
.PARAMETER SHARE
    Filter to a specific share level [default: red]
.PARAMETER CREATEDBY
    Filter to IOCs created by a specific user
.PARAMETER DELETEDBY
    Filter to IOCs deleted by a specific user
.PARAMETER DELETED
    Include deleted IOCs [default: false]
.PARAMETER COUNT
    Returns an aggregate count of hosts that have observed the IOC
.PARAMETER LIST
    Returns a list of host or process identifiers that have observed the IOC
.PARAMETER ID
    Specific host identifier for listing process identifiers that have observed the IOC
.PARAMETER LIMIT
    The maximum number of records to return when listing host or process identifiers
.PARAMETER OFFSET
    Offset integer to retrieve next result set when listing host or process identifiers
.PARAMETER ALL
    Repeat requests until all available results are retrieved
.EXAMPLE
    PS> Get-CsIOC -All
    Returns all custom IOCs in your environment
.EXAMPLE
    PS> Get-CsIOC -Type sha256 -Value sha_value_1
    Returns all 'sha256' type IOCs in your environment
.EXAMPLE
    PS> Get-CsIOC -Type sha256 -Value sha_value_1 -List Hosts
    Returns a list of all host identifiers that have observed sha256 hash 'sha_value_1'
#>
    [CmdletBinding(DefaultParameterSetName = 'default')]
    [OutputType()]
    param(
        [Parameter(ParameterSetName = 'count', Mandatory = $true)]
        [Parameter(ParameterSetName = 'default')]
        [Parameter(ParameterSetName = 'list', Mandatory = $true)]
        [Parameter(ParameterSetName = 'value', Mandatory = $true)]
        [ValidateSet('domain', 'ipv4', 'ipv6', 'md5', 'sha256')]
        [string] $Type,

        [Parameter(ParameterSetName = 'count', Mandatory = $true)]
        [Parameter(ParameterSetName = 'list', Mandatory = $true)]
        [Parameter(ParameterSetName = 'value', Mandatory = $true)]
        [string] $Value,

        [Parameter(ParameterSetName = 'default')]
        [string] $After,

        [Parameter(ParameterSetName = 'default')]
        [string] $Before,

        [Parameter(ParameterSetName = 'default')]
        [ValidateSet('detect', 'none')]
        [string] $Policy,

        [Parameter(ParameterSetName = 'default')]
        [ValidateLength(1, 200)]
        [string] $Source,

        [Parameter(ParameterSetName = 'default')]
        [ValidateSet('red')]
        [string] $Share,

        [Parameter(ParameterSetName = 'default')]
        [string] $CreatedBy,

        [Parameter(ParameterSetName = 'default')]
        [string] $DeletedBy,

        [Parameter(ParameterSetName = 'default')]
        [boolean] $Deleted,

        [Parameter(ParameterSetName = 'count', Mandatory = $true)]
        [switch] $Count,

        [Parameter(ParameterSetName = 'list', Mandatory = $true)]
        [ValidateSet('Hosts', 'Processes')]
        [string] $List,

        [Parameter(ParameterSetName = 'list')]
        [ValidateLength(32,32)]
        [string] $Id,

        [Parameter(ParameterSetName = 'count')]
        [Parameter(ParameterSetName = 'list')]
        [string] $Limit,

        [Parameter(ParameterSetName = 'count')]
        [Parameter(ParameterSetName = 'list')]
        [string] $Offset,

        [Parameter(ParameterSetName = 'count')]
        [Parameter(ParameterSetName = 'list')]
        [Parameter(ParameterSetName = 'default')]
        [switch] $All
    )
    begin {
        if (($PsCmdlet.ParameterSetName -eq 'default') -and (-not($Policy))) { $Policy = 'detect' }

        if (($List -eq 'Processes') -and (-not($Id))) {
            throw 'Must provide a specific host identifier when returning process results.'
        }
    }
    process {
        $LoopParam = @{ }

        $Param = @{
            Uri    = '/indicators/queries/iocs/v1?'
            Method = 'get'
            Header = @{
                accept = 'application/json'
                'content-type' = 'application/json'
            }
        }
        switch ($PsCmdlet.ParameterSetName) {
            'value' { $Param.Uri = '/indicators/entities/iocs/v1?' }
            'count' { $Param.Uri = '/indicators/aggregates/devices-count/v1?' }
            'list' {
                if ($List -eq 'Processes') {
                    $Param.Uri = '/indicators/queries/processes/v1?'
                } else {
                    $Param.Uri = '/indicators/queries/devices/v1?'
                }
            }
        }
        switch ($PsCmdlet.ParameterSetName) {
            'default' {
                switch ($PSBoundParameters.Keys) {
                    'Type' {
                        $Param.Uri += '&types=' + $Type
                        $LoopParam['Type'] = $Type
                    }
                    'Value' {
                        $Param.Uri += '&values=' + $Value
                        $LoopParam['Value'] = $Value
                    }
                    'After' {
                        $Param.Uri += '&from.expiration_timestamp=' + $After
                        $LoopParam['After'] = $After
                    }
                    'Before' {
                        $Param.Uri += '&to.expiration_timestamp=' + $Before
                        $LoopParam['Before'] = $Before
                    }
                    'Policy' {
                        $Param.Uri += '&policies=' + $Policy
                        $LoopParam['Policy'] = $Policy
                    }
                    'Source' {
                        $Param.Uri += '&sources=' + $Source
                        $LoopParam['Source'] = $Source
                    }
                    'Share' {
                        $Param.Uri += '&share_levels=' + $Share
                        $LoopParam['Share'] = $Share
                    }
                    'CreatedBy' {
                        $Param.Uri += '&created_by=' + $CreatedBy
                        $LoopParam['CreatedBy'] = $CreatedBy
                    }
                    'DeletedBy' {
                        $Param.Uri += '&deleted_by=' + $DeletedBy
                        $LoopParam['DeletedBy'] = $DeletedBy
                    }
                    'Deleted' {
                        $Param.Uri += '&include_deleted=' + $Deleted
                        $LoopParam['Deleted'] = $Deleted
                    }
                }
            }
            default {
                switch ($PSBoundParameters.Keys) {
                    'Type' {
                        $Param.Uri += '&type=' + $Type
                        $LoopParam['Type'] = $Type
                    }
                    'Value' {
                        $Param.Uri += '&value=' + $Value
                        $LoopParam['Value'] = $Value
                    }
                    'Id' {
                        $Param.Uri += '&device_id=' + $Id
                        $LoopParam['Id'] = $Id
                    }
                    'Limit' {
                        $Param.Uri += '&limit=' + [string] $Limit
                        $LoopParam['Limit'] = $Limit
                    }
                    'Offset' {
                        $Param.Uri += '&offset=' + [string] $Offset
                    }
                }
            }
        }
        switch ($PSBoundParameters.Keys) {
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
        } else {
            Invoke-Api @Param
        }
    }
}