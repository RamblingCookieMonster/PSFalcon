function Request-Token {
<#
.SYNOPSIS
    Generate an OAuth2 access token
.PARAMETER ID
    The API client identifier to authenticate your API requests
.PARAMETER SECRET
    The API client secret to authenticate your API requests
.PARAMETER CID
    For MSSP Master CIDs, optionally lock the token to act on behalf of this member CID
.PARAMETER CLOUD
    CrowdStrike destination cloud [default: 'US']
.PARAMETER PROXY
    Web proxy address
.EXAMPLE
    PS> Request-CsToken -Id <string> -Secret <string>
#>
    [CmdletBinding(DefaultParameterSetName = 'default')]
    [OutputType()]
    param(
        [Parameter(ParameterSetName = 'default', Position = 0)]
        [string] $Id,

        [Parameter(ParameterSetName = 'default', Position = 1)]
        [string] $Secret,

        [Parameter(ParameterSetName = 'default')]
        [string] $CID,

        [Parameter(ParameterSetName = 'default')]
        [ValidateSet('EU', 'US', 'US2', 'USGov')]
        [string] $Cloud,

        [Parameter(ParameterSetName = 'default')]
        [string] $Proxy
    )
    begin {
        if (-not($Falcon)) {
            # Create $Falcon
            [System.Collections.Hashtable] $Global:Falcon = @{ }
        }
        # Choose destination cloud
        switch ($Cloud) {
            'EU' { $Falcon['host'] = 'https://api.eu-1.crowdstrike.com' }
            'US2' { $Falcon['host'] = 'https://api.us-2.crowdstrike.com' }
            'USGov' { $Falcon['host'] = 'https://api.laggar.gcw.crowdstrike.com' }
            default { $Falcon['host'] = 'https://api.crowdstrike.com' }
        }
        # Capture input
        switch ($PSBoundParameters.Keys) {
            'Id' { $Falcon['id'] = $Id }
            'Secret' { $Falcon['secret'] = $Secret | ConvertTo-SecureString -AsPlainText -Force }
            'CID' { $Falcon['cid'] = [string] $CID }
            'Proxy' { $Falcon['proxy'] = $Proxy }
        }
        if (-not($Falcon.id)) {
            # Prompt for id
            $Falcon['id'] = Read-Host 'Id'
        }
        if (-not($Falcon.secret)) {
            # Prompt for secret
            $Falcon['secret'] = Read-Host 'Secret' -AsSecureString
        }
        if ((-not($CID)) -and ($Falcon.cid)) {
            # Remove existing member cid
            $Falcon.remove('cid')
        }
        if ((-not($Proxy)) -and ($Falcon.proxy)) {
            # Remove existing proxy
            $Falcon.remove('proxy')
        }
    }
    process {
        $Param = @{
            Uri    = '/oauth2/token'
            Method = 'post'
            Header = @{
                accept = 'application/json'
            }
            Body   = 'client_id=' + [string] $Falcon.id + '&client_secret='
        }
        if ($PSVersionTable.PSVersion.Major -ge 7) {
            # Convert and add secret in PowerShell Core
            $Param.Body += ($Falcon.secret | ConvertFrom-SecureString -AsPlainText)
        } else {
            # Convert and add secret in PowerShell Desktop
            $Param.Body += ([System.Runtime.InteropServices.Marshal]::PtrToStringAuto(
            [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($Falcon.secret)))
        }
        if ($Falcon.cid) {
            # Add member cid
            $Param.Body += '&member_cid=' + [string] $Falcon.cid
        }
        switch ($PSBoundParameters.Keys) {
            'Verbose' { $Param['Verbose'] = $true }
            'Debug' { $Param['Debug'] = $true }
        }
        $Request = Invoke-Api @Param

        if ($Request.access_token) {
            # Save token and expiration to $Falcon
            $Falcon['expires'] = ((Get-Date).addSeconds($Request.expires_in))
            $Falcon['token'] = [string] $Request.token_type + ' ' + [string] $Request.access_token
        } else {
            # Erase $Falcon
            Remove-Variable -Name Falcon -Scope Global

            # Output error
            $Request
        }
    }
}