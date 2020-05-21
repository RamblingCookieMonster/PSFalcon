function Receive-Rule {
<#
.SYNOPSIS
    Download the latest rule set by type, or specific rule set by id
.DESCRIPTION
    Requires falconx-rules:read
.PARAMETER ID
    Rule set identifier
.PARAMETER FORMAT
    Output archive type [default: zip]
.PARAMETER PATH
    Destination path
.EXAMPLE
    PS> Receive-CsRule -Id rule_id_1 -Path .\rule.zip
    Downloads the rule 'rule_id_1' as .\rule.zip
.EXAMPLE
    PS> Receive-CsRule -Type snort-suricata-master -Format gzip -Path .\rule.gzip
    Downloads the latest rule of type 'snort-suricata-master' as .\rule.gzip
#>
    [CmdletBinding(DefaultParameterSetName='default')]
    [OutputType()]
    param(
        [Parameter(ParameterSetName = 'default', Mandatory = $True)]
        [ValidateSet('snort-suricata-master', 'snort-suricata-update', 'snort-suricata-changelog',
        'yara-master', 'yara-update', 'yara-changelog', 'common-event-format', 'netwitness')]
        [string] $Type,

        [Parameter(ParameterSetName = 'id', Mandatory = $true)]
        [int] $Id,

        [Parameter(ParameterSetName = 'default')]
        [Parameter(ParameterSetName = 'id')]
        [ValidateSet('zip', 'gzip')]
        [string] $Format,

        [Parameter(ParameterSetName = 'default', Mandatory = $true)]
        [Parameter(ParameterSetName = 'id', Mandatory = $true)]
        [string] $Path
    )
    begin {
        if (-not($Format)) { $Format = 'zip' }
    }
    process {
        $Param = @{
            Uri    = '/intel/entities/rules-latest-files/v1?type=' + $Type + '&format=' + $Format
            Method = 'get'
            Header = @{ accept = 'application/' + $Format }
            OutFile = $Path
        }
        switch ($PSBoundParameters.Keys) {
            'Id' { $Param.Uri = '/intel/entities/rules-files/v1?id=' + [string] $Id + '&format=' + $Format }
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