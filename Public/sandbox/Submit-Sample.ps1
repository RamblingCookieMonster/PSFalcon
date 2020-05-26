function Submit-Sample {
<#
.SYNOPSIS
    Submit an uploaded file or a URL for sandbox analysis
.DESCRIPTION
    Requires falconx-sandbox:write
.PARAMETER ENVIRONMENT
    Environment to use for analysis
.PARAMETER HASH
    SHA256 hash value for the file submission
.PARAMETER URL
    An HTTP, HTTPS or FTP address
.PARAMETER NAME
    Name of the malware sample, used for file type detection and analysis
.PARAMETER SCRIPT
    Runtime script for sandbox analysis
.PARAMETER COMMAND
    Command line script passed to the submitted file at runtime
.PARAMETER PASSWORD
    Password to use with Adobe Acrobat or Microsoft Office files
.PARAMETER TOR
    Route network traffic via TOR
.PARAMETER DATE
    Set a custom sandbox environment date [format: 'yyyy-MM-dd']
.PARAMETER TIME
    Set a custom sandbox environment time [format: 'HH:mm']
.PARAMETER TAG
    Searchable tag values to append to the resulting sandbox report
.EXAMPLE
    PS> Submit-CsSample
#>
    [CmdletBinding(DefaultParameterSetName='default')]
    [OutputType()]
    param(
        [Parameter(ParameterSetName = 'default', Mandatory = $true)]
        [Parameter(ParameterSetName = 'url', Mandatory = $true)]
        [ValidateSet('Android', 'Ubuntu_16_x64', 'Win7_x86', 'Win7_x64', 'Win10_x64')]
        [string] $Environment,

        [Parameter(ParameterSetName = 'default', Mandatory = $true)]
        [ValidateLength(64,64)]
        [string] $Hash,

        [Parameter(ParameterSetName = 'url', Mandatory = $true)]
        [string] $Url,

        [Parameter(ParameterSetName = 'default')]
        [Parameter(ParameterSetName = 'url')]
        [string] $Name,

        [Parameter(ParameterSetName = 'default')]
        [Parameter(ParameterSetName = 'url')]
        [ValidateSet('default', 'default_maxantievasion', 'default_randomfiles',
        'default_randomtheme', 'default_openie')]
        [string] $Script,

        [Parameter(ParameterSetName = 'default')]
        [Parameter(ParameterSetName = 'url')]
        [ValidateLength(1,2048)]
        [string] $Command,

        [Parameter(ParameterSetName = 'default')]
        [string] $Password,

        [Parameter(ParameterSetName = 'default')]
        [Parameter(ParameterSetName = 'url')]
        [switch] $TOR,

        [Parameter(ParameterSetName = 'default')]
        [Parameter(ParameterSetName = 'url')]
        [string] $Date,

        [Parameter(ParameterSetName = 'default')]
        [Parameter(ParameterSetName = 'url')]
        [string] $Time,

        [Parameter(ParameterSetName = 'default')]
        [Parameter(ParameterSetName = 'url')]
        [array] $Tag
    )
    begin {
        $Body = @{ sandbox = @() }

        switch ($Environment) {
            'Android' { $EnvId = 200 }
            'Ubuntu_16_x64' { $EnvId = 300 }
            'Win7_x86' { $EnvId = 100 }
            'Win7_x64' { $EnvId = 110 }
            'Win10_x64' { $EnvId = 160 }
        }
        $Submission = @{ environment_id = $EnvId }

        switch ($PSBoundParameters.Keys) {
            'Hash' { $Submission['sha256'] = $Hash }
            'Url' { $Submission['url'] = $Url }
            'Name' { $Submission['submit_name'] = $Name }
            'Script' { $Submission['action_script'] = $Script }
            'Password' { $Submission['command_line'] = $Command }
            'TOR' { $Submission['enable_tor'] = $TOR }
            'Date' { $Submission['system_date'] = $Date }
            'Time' { $Submission['system_time'] = $Time }
            'Tag' { $Body['user_tags'] = $Tag }
        }
        $Body.sandbox += $Submission
    }
    process {
        $Param = @{
            Uri    = '/falconx/entities/submissions/v1'
            Method = 'post'
            Header = @{ 'content-type' = 'application/json' }
            Body   = ConvertTo-Json $Body
        }
        switch ($PSBoundParameters.Keys) {
            'Verbose' { $Param['Verbose'] = $true }
            'Debug' { $Param['Debug'] = $true }
        }
        Invoke-Api @Param
    }
}