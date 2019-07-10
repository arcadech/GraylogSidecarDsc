#Requires -Module GraylogSidecarDsc

<#
    .DESCRIPTION
        This configuration will remove the Graylog Sidecar installation.
#>
Configuration ARCADE_GraylogSidecar_UninstallGraylogSidecar
{
    Import-DscResource -Module 'GraylogSidecarDsc'

    Node 'localhost'
    {
        GraylogSidecarDsc 'InstallSidecar'
        {
            IsSingleInstance = 'Yes'
            Ensure           = 'Absent'
            SetupPath        = "$Env:Temp\graylog_sidecar_installer_1.0.1-1.exe"
            ServerUrl        = 'https://graylog.contoso.com/api/'
            ServerApiToken   = 'yb34rs6w9nmd6p5y3x2a4kk6a7n8q9p9w7d5us4de3l2ahg'
        }
    }
}
