<#
    .SYNOPSIS
        Get the current Graylog Sidecar installation status.

    .PARAMETER IsSingleInstance
        Specifies the resource is a single instance, the value must be 'Yes'.

    .PARAMETER SetupPath
        Path to the setup file.

    .PARAMETER ServerUrl
        Target Graylog server url.

    .PARAMETER ServerApiToken
        Target Graylog API token.
#>
function Get-TargetResource
{
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]
    param
    (
        [Parameter(Mandatory = $true)]
        [ValidateSet('Yes')]
        [System.String]
        $IsSingleInstance,

        [Parameter(Mandatory = $true)]
        [System.String]
        $SetupPath,

        [Parameter(Mandatory = $true)]
        [System.String]
        $ServerUrl,

        [Parameter(Mandatory = $true)]
        [System.String]
        $ServerApiToken
    )

    Write-Verbose 'Get Graylog Sidecar resource'

    $setupProperties = Get-ItemProperty -Path $SetupPath -ErrorAction Stop

    # Get the versions of the setup file and the installed components. This is
    # required to detect, if the Sidecar must be updated.
    $setupVersion = $setupProperties.VersionInfo.ProductVersion
    $version      = Get-GraylogSidecarVersion

    # Get the sidecar configuration
    $config = Get-GraylogSidecarConfigFile

    # Set ensure to present if the Sidecar is installed, even if the version
    # does not match.
    $ensure = 'Present'
    if ([System.String]::IsNullOrEmpty($version))
    {
        $ensure = 'Absent'
    }

    $returnValue = @{
        IsSingleInstance       = $IsSingleInstance
        Ensure                 = $ensure
        SetupPath              = $SetupPath
        SetupVersion           = $setupVersion
        Version                = $version
        ServerUrl              = $config.ServerUrl
        ServerApiToken         = $config.ServerApiToken
        NodeName               = $config.NodeName
    }

    return $returnValue
}

<#
    .SYNOPSIS
        Install or uninstall Graylog Sidecar.

    .PARAMETER IsSingleInstance
        Specifies the resource is a single instance, the value must be 'Yes'.

    .PARAMETER Ensure
        Specified if the client should be added or removed.

    .PARAMETER SetupPath
        Path to the setup file.

    .PARAMETER ServerUrl
        Target Graylog server url.

    .PARAMETER ServerApiToken
        Target Graylog API token.

    .PARAMETER NodeName
        The sidecar node name to identify the installation. Matches the hostname
        by default.
#>
function Set-TargetResource
{
    [CmdletBinding(SupportsShouldProcess = $true)]
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSShouldProcess', '')]
    param
    (
        [Parameter(Mandatory = $true)]
        [ValidateSet('Yes')]
        [System.String]
        $IsSingleInstance,

        [Parameter(Mandatory = $false)]
        [ValidateSet('Present', 'Absent')]
        [System.String]
        $Ensure = 'Present',

        [Parameter(Mandatory = $true)]
        [System.String]
        $SetupPath,

        [Parameter(Mandatory = $true)]
        [System.String]
        $ServerUrl,

        [Parameter(Mandatory = $true)]
        [System.String]
        $ServerApiToken,

        [Parameter(Mandatory = $false)]
        [System.String]
        $NodeName = $Env:ComputerName.ToLower()
    )

    Write-Verbose 'Set Graylog Sidecar resource'

    $getTargetResourceSplat = @{
        IsSingleInstance = $IsSingleInstance
        SetupPath        = $SetupPath
        ServerUrl        = $ServerUrl
        ServerApiToken   = $ServerApiToken
    }

    $currentState = Get-TargetResource @getTargetResourceSplat

    # Uninstall the application if it's not needed anymore
    if ($Ensure -eq 'Absent' -and $currentState.Ensure -eq 'Present')
    {
        Uninstall-GraylogSidecar

        # Update the state after the removal
        $currentState = Get-TargetResource @getTargetResourceSplat
    }

    # Install the application, if it's not presend or needs an update
    if ($Ensure -eq 'Present' -and ($currentState.Ensure -eq 'Absent' -or $currentState.SetupVersion -ne $currentState.Version))
    {
        Install-GraylogSidecar -SetupPath $SetupPath -ServerUrl $ServerUrl -ServerApiToken $ServerApiToken

        # Update the state after the installation
        $currentState = Get-TargetResource @getTargetResourceSplat
    }

    # Update the configuration, if it does not match
    if ($Ensure -eq 'Present' -and $currentState.NodeName -ne $NodeName)
    {
        Set-GraylogSidecarConfigFile -NodeName $NodeName
    }

    # Update the configuration, if it does not match
    if ($Ensure -eq 'Present' -and $currentState.ServerUrl -ne $ServerUrl)
    {
        Set-GraylogSidecarConfigFile -ServerUrl $ServerUrl
    }

    # Update the configuration, if it does not match
    if ($Ensure -eq 'Present' -and $currentState.ServerApiToken -ne $ServerApiToken)
    {
        Set-GraylogSidecarConfigFile -ServerApiToken $ServerApiToken
    }

    # Wait 10 seconds to give the Graylog Sidecar the chance to register itself
    # on the graylog server, so that at the end of the configuration, the
    # sidecar is already available on the Graylog server and ready to be
    # configured e.g. by the GraylogSidecarConfiguration resource.
    Start-Sleep -Seconds 10
}

<#
    .SYNOPSIS
        Install or uninstall Graylog Sidecar.

    .PARAMETER IsSingleInstance
        Specifies the resource is a single instance, the value must be 'Yes'.

    .PARAMETER Ensure
        Specified if the client should be added or removed.

    .PARAMETER SetupPath
        Path to the setup file.

    .PARAMETER ServerUrl
        Target Graylog server url.

    .PARAMETER ServerApiToken
        Target Graylog API token.

    .PARAMETER NodeName
        The sidecar node name to identify the installation. Matches the hostname
        by default.
#>
function Test-TargetResource
{
    [CmdletBinding()]
    [OutputType([System.Boolean])]
    param
    (
        [Parameter(Mandatory = $true)]
        [ValidateSet('Yes')]
        [System.String]
        $IsSingleInstance,

        [Parameter(Mandatory = $false)]
        [ValidateSet('Present', 'Absent')]
        [System.String]
        $Ensure = 'Present',

        [Parameter(Mandatory = $true)]
        [System.String]
        $SetupPath,

        [Parameter(Mandatory = $true)]
        [System.String]
        $ServerUrl,

        [Parameter(Mandatory = $true)]
        [System.String]
        $ServerApiToken,

        [Parameter(Mandatory = $false)]
        [System.String]
        $NodeName = $Env:ComputerName.ToLower()
    )

    Write-Verbose 'Test Graylog Sidecar resource'

    $currentState = Get-TargetResource -IsSingleInstance $IsSingleInstance -SetupPath $SetupPath -ServerUrl $ServerUrl -ServerApiToken $ServerApiToken

    if ($Ensure -eq 'Present')
    {
        return $currentState.Ensure -eq $Ensure -and
               $currentState.SetupVersion -eq $currentState.Version -and
               $currentState.ServerUrl -eq $ServerUrl -and
               $currentState.ServerApiToken -eq $ServerApiToken -and
               $currentState.NodeName -eq $NodeName
    }

    if ($Ensure -eq 'Absent')
    {
        return $currentState.Ensure -eq $Ensure
    }
}
