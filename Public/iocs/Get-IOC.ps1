function Get-IOC {
<#
.SYNOPSIS
    Search custom IOCs in your environment
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
.PARAMETER ALL
    Repeat requests until all available results are retrieved
.EXAMPLE
    PS> Get-CsIOC -Type sha256 -All
    Returns all 'sha256' type IOCs in your environment
.EXAMPLE
    PS> Get-CsIOC -Type sha256 -Value sha_value_1
    Returns all 'sha256' type IOCs in your environment
#>
    [CmdletBinding(DefaultParameterSetName='default')]
    [OutputType()]
    param(
        [Parameter(ParameterSetName = 'default', Mandatory = $true)]
        [Parameter(ParameterSetName = 'value', Mandatory = $true)]
        [ValidateSet('domain', 'ipv4', 'ipv6', 'md5', 'sha256')]
        [string] $Type,

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

        [Parameter(ParameterSetName = 'default')]
        [switch] $All
    )
    begin {
        if (-not($Policy)) { $Policy = 'detect' }
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
        if ($Value) { $Param.Uri = '/indicators/entities/iocs/v1?' }

        switch ($PSBoundParameters.Keys) {
            'Type' {
                if ($Value) {
                    $Param.Uri += '&type=' + $Type
                } else {
                    $Param.Uri += '&types=' + $Type
                }
                $LoopParam['Type'] = $Type
            }
            'Value' {
                if ($Value) {
                    $Param.Uri += '&value=' + $Value
                } else {
                    $Param.Uri += '&values=' + $Value
                }
                $LoopParam['Value'] = $Value
            }
            'After' {
                $Param.Uri += '&fromexpirationtimestamp=' + $After
                $LoopParam['After'] = $After
            }
            'Before' {
                $Param.Uri += '&toexpirationtimestamp=' + $Before
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
                $Param.Uri += '&sharelevels=' + $Share
                $LoopParam['Share'] = $Share
            }
            'CreatedBy' {
                $Param.Uri += '&createdby=' + $CreatedBy
                $LoopParam['CreatedBy'] = $CreatedBy
            }
            'DeletedBy' {
                $Param.Uri += '&deletedby=' + $DeletedBy
                $LoopParam['DeletedBy'] = $DeletedBy
            }
            'Deleted' {
                $Param.Uri += '&includedeleted=' + $Deleted
                $LoopParam['Deleted'] = $Deleted
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
        } else {
            Invoke-Api @Param
        }
    }
}