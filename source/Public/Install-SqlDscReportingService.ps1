<#
    .SYNOPSIS
        Installs SQL Server Reporting Services or Power BI Report Server.

    .DESCRIPTION
        Installs SQL Server Reporting Services or Power BI Report Server using
        the provided setup executable.

    .PARAMETER AcceptLicensingTerms
        Required parameter to be able to run unattended install. By specifying this
        parameter you acknowledge the acceptance of all license terms and notices for
        the specified features, the terms and notices that the setup executable
        normally asks for.

    .PARAMETER MediaPath
        Specifies the path where to find the SQL Server installation media. On this
        path the SQL Server setup executable must be found.

    .PARAMETER ProductKey
        Specifies the product key to use for the installation, e.g. '12345-12345-12345-12345-12345'.
        This parameter is mutually exclusive with the parameter Edition.

    .PARAMETER EditionUpgrade
        Upgrades the edition of the installed product. Requires that either the
        ProductKey or the Edition parameter is also assigned. By default no edition
        upgrade is performed.

    .PARAMETER Edition
        Specifies a free custom edition to use for the installation. This parameter
        is mutually exclusive with the parameter ProductKey.

    .PARAMETER LogPath
        Specifies the file path where to write the log files, e.g. 'C:\Logs\Install.log'.
        By default log files are created under %TEMP%.

    .PARAMETER InstallFolder
        Specifies the folder where to install the product, e.g. 'C:\Program Files\SSRS'.
        By default the product is installed under the default installation folder.

        Reporting Services: %ProgramFiles%\Microsoft SQL Server Reporting Services
        PI Report Server: %ProgramFiles%\Microsoft Power BI Report Server

    .PARAMETER SuppressRestart
        Suppresses the restart of the computer after the installation is finished.
        By default the computer is restarted after the installation is finished.

    .PARAMETER Timeout
        Specifies how long to wait for the setup process to finish. Default value
        is `7200` seconds (2 hours). If the setup process does not finish before
        this time, an exception will be thrown.

    .PARAMETER Force
        If specified the command will not ask for confirmation. Same as if Confirm:$false
        is used.

    .PARAMETER PassThru
        If specified the command will return the setup process exit code.

    .OUTPUTS
        When PassThru is specified the function will return the setup process exit
        code as System.Int32. Otherwise, the function does not generate any output.

    .EXAMPLE
        Install-SqlDscReportingService -AcceptLicensingTerms -MediaPath 'E:\SQLServerReportingServices.exe'

        Installs SQL Server Reporting Services with default settings.

    .EXAMPLE
        Install-SqlDscReportingService -AcceptLicensingTerms -MediaPath 'E:\SQLServerReportingServices.exe' -ProductKey '12345-12345-12345-12345-12345'

        Installs SQL Server Reporting Services using a product key.

    .EXAMPLE
        Install-SqlDscReportingService -AcceptLicensingTerms -MediaPath 'E:\PowerBIReportServer.exe' -Edition 'Evaluation' -InstallFolder 'C:\Program Files\Power BI Report Server'

        Installs Power BI Report Server in evaluation edition to a custom folder.

    .EXAMPLE
        Install-SqlDscReportingService -AcceptLicensingTerms -MediaPath 'E:\SQLServerReportingServices.exe' -ProductKey '12345-12345-12345-12345-12345' -EditionUpgrade -LogPath 'C:\Logs\SSRS_Install.log'

        Installs SQL Server Reporting Services and upgrades the edition using a
        product key. Also specifies a custom log path.

    .EXAMPLE
        $exitCode = Install-SqlDscReportingService -AcceptLicensingTerms -MediaPath 'E:\SQLServerReportingServices.exe' -PassThru

        Installs SQL Server Reporting Services with default settings and returns the setup exit code.
#>
function Install-SqlDscReportingService
{
    [System.Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSShouldProcess', '', Justification = 'Because ShouldProcess is used in Invoke-SetupAction')]
    [CmdletBinding(SupportsShouldProcess = $true, ConfirmImpact = 'High')]
    [OutputType([System.Int32])]
    param
    (
        [Parameter(Mandatory = $true)]
        [System.Management.Automation.SwitchParameter]
        $AcceptLicensingTerms,

        [Parameter(Mandatory = $true)]
        [System.String]
        $MediaPath,

        [Parameter()]
        [System.String]
        $ProductKey,

        [Parameter()]
        [System.Management.Automation.SwitchParameter]
        $EditionUpgrade,

        [Parameter()]
        [ValidateSet('Developer', 'Evaluation', 'ExpressAdvanced')]
        [System.String]
        $Edition,

        [Parameter()]
        [System.String]
        $LogPath,

        [Parameter()]
        [System.String]
        $InstallFolder,

        [Parameter()]
        [System.Management.Automation.SwitchParameter]
        $SuppressRestart,

        [Parameter()]
        [System.UInt32]
        $Timeout = 7200,

        [Parameter()]
        [System.Management.Automation.SwitchParameter]
        $Force,

        [Parameter()]
        [System.Management.Automation.SwitchParameter]
        $PassThru
    )

    $exitCode = Invoke-ReportServerSetupAction -Install @PSBoundParameters

    if ($PassThru.IsPresent)
    {
        return $exitCode
    }
}
