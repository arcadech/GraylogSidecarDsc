<#
    .SYNOPSIS
        Get the current sidecar configuration.

    .DESCRIPTION
        Read the configuration file sidecar.yml and parse the relevant values
        ServerUrl, ServerApiToken and NodeName. It will return a custom object
        with the three properties.

    .EXAMPLE
        PS C:\> Get-GraylogSidecarConfigFile
        Get the current sidecar configuration.
#>
function Get-GraylogSidecarConfigFile
{
    [CmdletBinding()]
    [OutputType([System.String])]
    param ()

    $path = 'C:\Program Files\Graylog\sidecar\sidecar.yml'

    $result = [PSCustomObject] @{
        ServerUrl      = ''
        ServerApiToken = ''
        NodeName       = ''
    }

    # Extract the configuration values
    $config = Get-Content -Path $path -Raw -ErrorAction 'SilentlyContinue'
    if ($config -match 'server_url: "(?<ServerUrl>.*)"')
    {
        $result.ServerUrl = $Matches.ServerUrl
    }
    if ($config -match 'server_api_token: "(?<ServerApiToken>.*)"')
    {
        $result.ServerApiToken = $Matches.ServerApiToken
    }
    if ($config -match 'node_name: "(?<NodeName>.*)"')
    {
        $result.NodeName = $Matches.NodeName
    }

    Write-Output $result
}
