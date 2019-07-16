#Requires -Module GraylogSidecarDsc, xPSDesiredStateConfiguration

<#
    .DESCRIPTION
        This configuration will install the Graylog Sidecar version 1.0.1.
#>
Configuration ARCADE_GraylogSidecarConfiguration_AddGraylogSidecarConfiguration
{
    Import-DscResource -Module 'GraylogSidecarDsc'
    Import-DscResource -Module 'xPSDesiredStateConfiguration'

    Node 'localhost'
    {
        xRemoteFile 'DownloadSetup'
        {
            Uri             = 'https://github.com/Graylog2/collector-sidecar/releases/download/1.0.1/graylog_sidecar_installer_1.0.1-1.exe'
            DestinationPath = "$Env:Temp\graylog_sidecar_installer_1.0.1-1.exe"
        }

        GraylogSidecarDsc 'InstallSidecar'
        {
            IsSingleInstance = 'Yes'
            Ensure           = 'Present'
            SetupPath        = "$Env:Temp\graylog_sidecar_installer_1.0.1-1.exe"
            ServerUrl        = 'https://graylog.contoso.com/'
            ServerApiToken   = 'yb34rs6w9nmd6p5y3x2a4kk6a7n8q9p9w7d5us4de3l2ahg'
            DependsOn        = '[xRemoteFile]DownloadSetup'
        }

        GraylogSidecarConfiguration 'ConfigureSidecar'
        {
            IsSingleInstance = 'Yes'
            Ensure           = 'Present'
            ServerUrl        = 'https://graylog.contoso.com/'
            Credential       = [System.Management.Automation.PSCredential]::new('username', (Protect-String -String 'password'))
            CollectorId      = '5d06f1676ed6471c02a78f4f'
            ConfigurationId  = '5d02c716a4edbf98a35b07fc'
            DependsOn        = '[GraylogSidecarDsc]InstallSidecar'
        }
    }
}
