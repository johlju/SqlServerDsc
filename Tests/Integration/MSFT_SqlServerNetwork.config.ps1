$ConfigurationData = @{
    AllNodes = @(
        @{
            NodeName                    = 'localhost'
            ServerName                  = $env:COMPUTERNAME
            InstanceName                = 'DSCSQL2016'

            PSDscAllowPlainTextPassword = $true

            ProtocolName                = 'Tcp'
            IsEnabled                   = $true
            TcpDynamicPort              = $true
            RestartService              = $true
        }
    )
}

Configuration MSFT_SqlServerNetwork_SetTcpDynamicPort_Config
{
    param
    (
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [System.Management.Automation.PSCredential]
        $SqlInstallCredential
    )

    Import-DscResource -ModuleName 'SqlServerDsc'

    node localhost {
        SqlServerNetwork 'Integration_Test'
        {
            ServerName           = $Node.ServerName
            InstanceName         = $Node.InstanceName
            ProtocolName         = $Node.ProtocolName
            IsEnabled            = $Node.IsEnabled
            TcpDynamicPort       = $Node.TcpDynamicPort

            PsDscRunAsCredential = $SqlInstallCredential
        }
    }
}
