function Invoke-Api {
<#
.SYNOPSIS
    Invoke-WebRequest wrapper used by PSFalcon
.DESCRIPTION
    Takes input from the PSFalcon commands to structure an Invoke-WebRequest, attaches
    an existing OAuth2 token from $Falcon, checks for rate limiting, then sends the
    resulting object to 'Format-Response'
.PARAMETER URI
    Invoke-WebRequest partial Uri (appended to $Falcon.host)
.PARAMETER METHOD
    Invoke-WebRequest Method
.PARAMETER HEADER
    Invoke-WebRequest Header parameter hashtable
.PARAMETER BODY
    Invoke-WebRequest Body
.PARAMETER FORM
    Invoke-WebRequest Form
.PARAMETER OUTFILE
    Outfile destination path for Invoke-WebRequest request
#>
    [CmdletBinding(DefaultParameterSetName = 'default')]
    [OutputType()]
    param(
        [Parameter(ParameterSetName = 'default', Mandatory = $true, Position = 0)]
        [string] $Uri,

        [Parameter(ParameterSetName = 'default', Mandatory = $true, Position = 1)]
        [string] $Method,

        [Parameter(ParameterSetName = 'default', Mandatory = $true, Position = 2)]
        [hashtable] $Header,

        [Parameter(ParameterSetName = 'default')]
        [string] $Body,

        [Parameter(ParameterSetName = 'default')]
        [System.Collections.IDictionary] $Form,

        [Parameter(ParameterSetName = 'default')]
        [string] $Outfile
    )
    begin {
        # If missing or expired, request token
        if ($Uri -ne '/oauth2/token') {
            if ((-not($Falcon.token)) -or (($Falcon.expires) -le (Get-Date).AddSeconds(-5))) {
                Request-CsToken
            }
        }
    }
    process {
        $Param = @{
            Uri    = $Falcon.host + $Uri
            Method = $Method
            Header = @{ }
        }
        switch ($PSBoundParameters.Keys) {
            'Body' { $Param['Body'] = $Body }
            'Form' { $Param['Form'] = $Form } # Unavailable in PowerShell 5.1 (Used by New-RtrFile/New-RtrScript)
            'Outfile' { $Param['Outfile'] = $Outfile }
        }
        # Add header values
        foreach ($Key in $Header.keys) {
            $Param.Header[$Key] = $Header.$Key
        }
        if (($Falcon.token) -and ($Uri -ne '/oauth2/revoke')) {
            # Add OAuth2 bearer token
            $Param.Header['authorization'] = ($Falcon.token)
        }
        if ($Falcon.proxy) {
            # Add proxy
            $Param['Proxy'] = $Falcon.proxy
            $Param['ProxyUseDefaultCredentials'] = $true
        }
        if ($PSVersionTable.PSVersion.Major -lt 6) {
            # UseBasicParsing with PowerShell Desktop
            $Param['UseBasicParsing'] = $true
        }
        # Remove progress bar (for bug with file download speed using Invoke-WebRequest)
        $ProgressPreference = 'SilentlyContinue'

        # Make request
        $Request = try {
            Invoke-WebRequest @Param
        } catch {
            if ($_.ErrorDetails) {
                $_.ErrorDetails
            } else {
                $_.Exception
            }
        }
        # Check for rate limiting and sleep until 'RetryAfter'
        if ($Request.Headers.'X-Ratelimit-RetryAfter') {
            $Wait = (([int] $Request.Headers.'X-Ratelimit-RetryAfter') - ([int] (Get-Date -UFormat %s)) + 1)

            Write-Verbose ('Rate limit exceeded, sleeping ' + [string] $Wait + ' second(s)')

            Start-Sleep -Seconds $Wait
        }
    }
    end {
        # Format output
        if ($Request) { Format-Response $Request }
    }
}