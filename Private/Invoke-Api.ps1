function Invoke-Api {
<#
.SYNOPSIS
    Invoke-RestMethod wrapper used by PSFalcon
.PARAMETER URI
    Partial URI for Invoke-RestMethod request (matched with $Falcon.host)
.PARAMETER METHOD
    Method for Invoke-RestMethod request
.PARAMETER HEADER
    A hashtable of Invoke-RestMethod header parameters
.PARAMETER BODY
    Body for Invoke-RestMethod request
.PARAMETER FORM
    Form for Invoke-RestMethod request
.PARAMETER OUTFILE
    Outfile destination path for Invoke-RestMethod request
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
            'Form' { $Param['Form'] = $Form } # Unavailable in PowerShell 5.1... New-RtrFile/New-RtrScript
            'Outfile' { $Param['Outfile'] = $Outfile }
        }
        # Add header values from PSFalcon function
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
        Format-Response $Request
    }
}