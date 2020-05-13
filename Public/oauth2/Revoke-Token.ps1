function Revoke-Token {
<#
.SYNOPSIS
    Revoke your current OAuth2 access token before the end of its standard 30-minute lifespan
.EXAMPLE
    PS> Revoke-CsToken
.LINK
https://assets.falcon.crowdstrike.com/support/api/swagger.html#/oauth2/oauth2RevokeToken
#>
    [CmdletBinding()]
    [OutputType()]
    param()
    begin {
        if ($PSVersionTable.PSVersion.Major -ge 7) {
            # Convert and retrieve secret in PowerShell Core
            $Secret = ($Falcon.secret | ConvertFrom-SecureString -AsPlainText)
        } else {
            # Convert and retrieve secret in PowerShell Desktop
            $Secret = ([System.Runtime.InteropServices.Marshal]::PtrToStringAuto(
            [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($Falcon.secret)))
        }
        # Encode credential pair
        $StringPair = [System.Text.Encoding]::ASCII.GetBytes(($Falcon.id + ":" + $Secret))
        $EncodedPair = [System.Convert]::ToBase64String($StringPair)
    }
    process {
        $Param = @{
            Uri    = '/oauth2/revoke'
            Method = 'post'
            Header = @{
                accept        = 'application/json'
                authorization = 'basic ' + $EncodedPair
            }
            Body   = 'token=' + ($Falcon.token -replace 'bearer ', '')
        }
        switch ($PSBoundParameters.Keys) {
            'Verbose' { $Param['Verbose'] = $true }
            'Debug' { $Param['Debug'] = $true }
        }
        $Request = Invoke-Api @Param

        # Remove existing token and expiration time
        if ($Request.status -eq '200 OK') {
            $Falcon.remove('expires')
            $Falcon.remove('token')
        }
    }
    end {
        $Request
    }
}