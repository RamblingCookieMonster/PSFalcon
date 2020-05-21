function Build-Module {
<#
.SYNOPSIS
    Uses an OpenAPI Swagger Json file to create basic 'Public' modules
.DESCRIPTION
    Runs out of the 'Private' folder to create basic 'Public' functions that serve
    as a starting point for building a set of PowerShell commands
.PARAMETER PATH
    Path to swagger.json file
#>
    [CmdletBinding(DefaultParameterSetName = 'default')]
    param(
        [Parameter(ParameterSetName = 'default', Mandatory = $true, Position = 0)]
        [ValidateScript({ 
            if (Test-Path $_) {
                $true
            } else {
                throw 'File does not exist.'
            }
        })]
        [string] $Path
    )
    begin {
        # Import swagger.json
        $Json = try {
            Get-Content $Path | ConvertFrom-Json
        } catch {
            Write-Output $_
        }
        # Check localization for proper capitalization with name params
        $Culture = (Get-Culture).TextInfo
    }
    process {
        $Output = foreach ($Uri in $Json.paths.psobject.properties.name) {
            foreach ($Method in $Json.paths.$Uri.psobject.properties.name) {
                foreach ($Endpoint in $Json.paths.$Uri.$Method) {
                    # Create base Endpoint object
                    $Object = @{
                        folder     = $Endpoint.tags[0]
                        synopsis   = $Endpoint.summary
                        parameters = @()
                        reference  = $Endpoint.operationId -replace '[^a-zA-Z0-9]', ''
                        uri        = $Uri
                        method     = $Method
                        headers    = @{ }
                    }
                    @('consumes', 'produces', 'security', 'parameters') | ForEach-Object {
                        if ($Endpoint.$_) {
                            switch ($_) {
                                'consumes' { $Object.headers += @{ accept = $Endpoint.$_ } }
                                'produces' { $Object.headers += @{ 'content-type' = $Endpoint.$_ } }

                                'security' { $Object['security'] = $Endpoint.security }

                                'parameters' { 
                                    foreach ($Parameter in $Endpoint.parameters) {
                                        $ParamObject = @{ }

                                        # Replace 'schema' with swagger definitions as 'format'
                                        ($Parameter | Get-Member -MemberType NoteProperty).name |
                                        ForEach-Object {
                                            if ($_ -eq 'schema') {
                                                $Properties = $Json.definitions.(
                                                    $Parameter.$_.'$ref' -replace '#/definitions/',
                                                    '').properties

                                                # Replace 'items' with defintions schema
                                                foreach ($Property in 
                                                    ($Properties.psobject.properties.value)) {
                                                    if ($Property.items.'$ref') {
                                                        $Property.items = $Json.definitions.(
                                                            $Property.items.'$ref' -replace
                                                            '#/definitions/', '').properties
                                                    }
                                                }
                                                $ParamObject['format'] = $Properties
                                            } else {
                                                $ParamObject[$_] = $Parameter.$_
                                            }
                                        }
                                        $Object.parameters += $ParamObject
                                    }
                                }
                            }
                        }
                    }
                    # Add object to output
                    $Object
                }
            }
        }
        if ($PSBoundParameters.Debug -ne $true) {
            # Create folders
            ($Output.folder | Group-Object).name | ForEach-Object {
                if (-not(Test-Path ($PSScriptRoot + '\..\Public\' + $_))) {
                    New-Item -ItemType Directory -Path ($PSScriptRoot + '\..\Public\' + $_) > $null
                }
            }
            $Output | ForEach-Object {
                if (-not(Test-Path ($PSScriptRoot + '\..\Public\' + $_.folder + '\' +
                $_.reference + '.ps1'))) {
                    # Function name
                    $FunctionName = "function " + $_.reference + " {`n"

                    # Param text
                    $ParamText = "    [CmdletBinding(DefaultParameterSetName= 'default')]`n" +
                    "    [OutputType()]`n" +
                    "    param("

                    # Help text
                    $HelpText = ("<#`n" +
                        ".SYNOPSIS`n" +
                        "    " + $_.synopsis + "`n"
                    )
                    if ($_.security.oauth2) {
                        # Add permissions to description help text
                        $HelpText += ".DESCRIPTION`n    Requires " + $_.security.oauth2 + "`n"
                    }
                    # Start example string for example help text
                    $ExampleString = "PS> " + $_.reference + " "

                    # Process text
                    $ProcessText = "    process {`n" +
                    "        `$LoopParam = @{ }`n`n" +

                    "        `$Param = @{`n" +
                    "            Uri    = '" + $_.Uri + "?'`n" +
                    "            Method = '" + $_.Method + "'`n" +
                    "            Header = @{`n"

                    if ($_.headers.accept) {
                        # Add accept to header
                        $ProcessText += "                accept = '" +
                        [string] $_.headers.accept[0] + "'`n"
                    }
                    if ($_.headers.'content-type') {
                        # Add content-type to header
                        $ProcessText += "                'content-type' = '" +
                        [string] $_.headers.'content-type'[0] +	"'`n"
                    }
                    $ProcessText += "            }`n"

                    foreach ($Item in $_.parameters) {
                        # Correct 'integer' to 'int'
                        if ($Item.type -eq 'integer') {
                            $Item.type = 'int'
                        }
                        # Add parameter help text
                        $HelpText += ".PARAMETER " + ([string] $Item.name).ToUpper() + "`n    "
                        $HelpText += $Item.description + "`n"

                        if ($Item.required -eq $true) {
                            # Add mandatory to params
                            $ParamText += "`n        [Parameter(ParameterSetName = 'default', " +
                            "Mandatory = `$true)]"

                            if ($Item.in -eq 'body') {
                                # Add body parameters to example string
                                # Format $ref body strings here...
                            } else {
                                # Add query parameters to example string
                                $ExampleString += "-" + $Culture.ToTitleCase($Item.name) + " <" +
                                $Item.type + "> "
                            }
                        } else {
                            $ParamText += "`n        [Parameter(ParameterSetName = 'default')]"
                        }
                        # Add param type
                        if ($Item.type) {
                            $ParamText += "`n        [" + $Item.type + "] `$" +
                            $Culture.ToTitleCase($Item.name) + ",`r`n"
                        } else {
                            $ParamText += "`n        `$" + $Culture.ToTitleCase($Item.name) + ",`r`n"
                        }
                        if ($Item.name -eq 'body') {
                            # Add 'body' parameter to process text
                            $ProcessText += "            Body   = ConvertTo-Json `$Body`n"
                        }
                    }
                    # Add all parameter to help text
                    $HelpText += ".PARAMETER ALL`n" +
                    "    Repeat requests until all available results are retrieved`n"

                    # Add all parameter to param text
                    $ParamText += "`n        [Parameter(ParameterSetName = 'default')]`n" +
                    "        [switch] `$All,`r`n"

                    # Add example string, finish help text
                    $HelpText += ".EXAMPLE`n    " + $ExampleString.TrimEnd(" ") + "`n#>`n"

                    # Finish param text
                    $ParamText = $ParamText.TrimEnd(",`r`n") + "`n    )`n"

                    # Add switch statement to process text
                    $ProcessText += "        }`n" +
                    "        switch (`$PSBoundParameters.Keys) {`n"

                    if ($_.parameters | Where-Object in -eq 'query') {
                        # Add 'query' parameters to process text
                        $QueryParams = $_.parameters | Where-Object in -eq 'query'

                        foreach ($Item in $QueryParams) {
                            $ProcessText += "            '" + $Culture.ToTitleCase($Item.name) + "' {`n" +
                            "                `$Param.Uri += '&" + $Item.name + "='"

                            if ($Item.type -eq 'array') {
                                $ProcessText += " + (`$" + $Culture.ToTitleCase($Item.name) +
                                " -join '&" + $Item.name + "=')`n"
                            } else {
                                $ProcessText += " + `$" + $Culture.ToTitleCase($Item.name) + "`n"
                            }
                            $ProcessText += "                `$LoopParam['" + $Culture.ToTitleCase($Item.name) +
                            "'] = `$" + $Culture.ToTitleCase($Item.name) + "`n" + "            }`n"
                        }
                    }
                    # Finish switch statement string for 'Verbose' and 'Debug'
                    $ProcessText += "            'Verbose' {`n" +
                    "                `$Param['Verbose'] = `$true`n" +
                    "                `$LoopParam['Verbose'] = `$true`n" +
                    "            }`n" +
                    "            'Debug' {`n" +
                    "                `$Param['Debug'] = `$true`n" +
                    "                `$LoopParam['Debug'] = `$true`n" +
                    "            }`n" +
                    "        }`n" +
                    "        if (`$All) {`n" +
                    "            Invoke-Loop -Command `$MyInvocation.MyCommand.Name -Param `$LoopParam`n" +
                    "        } else {`n" +
                    "            Invoke-Api @Param`n" +
                    "        }`n" +
                    "    }`n"

                    # Combine strings and finish content text
                    $ContentText = $FunctionName + $HelpText + $ParamText + $ProcessText + "}"

                    # Add content to file
                    New-Item -ItemType File -Path ($PSScriptRoot + '\..\Public\' + $_.folder +
                    '\' + $_.reference + '.ps1') -Value $ContentText > $null
                }
            }
        }
    }
    end {
        # Write output for debug
        if ($PSBoundParameters.Debug -eq $true) {
            $Output
        }
    }
}