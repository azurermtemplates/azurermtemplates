Configuration Main
{
  param (
  $MachineName,
  $WebDeployPackagePath = "https://github.com/CawaMS/FileShare/releases/download/releasetag/WebApplication3.zip",
  $UserName,
  $Password,
  $DbServerName,
  $DbName,
  $DbUserName,
  $DbPassword
  )

  Node ($MachineName)
  {

   #script block to download WebPI MSI from the Azure storage blob
    Script DownloadWebPIImage
    {
        GetScript = {
            @{
                Result = "WebPIInstall"
            }
        }
        TestScript = {
            Test-Path "C:\WindowsAzure\wpilauncher.exe"
        }
        SetScript ={
            $source = "http://go.microsoft.com/fwlink/?LinkId=255386"
            $destination = "C:\WindowsAzure\wpilauncher.exe"
            Invoke-WebRequest $source -OutFile $destination
       
        }
    }

    Package WebPi_Installation
        {
            Ensure = "Present"
            Name = "Microsoft Web Platform Installer 5.0"
            Path = "C:\WindowsAzure\wpilauncher.exe"
            ProductId = '4D84C195-86F0-4B34-8FDE-4A17EB41306A'
            Arguments = ''
        }

    Package WebDeploy_Installation
        {
            Ensure = "Present"
            Name = "Microsoft Web Deploy 3.5"
            Path = "$env:ProgramFiles\Microsoft\Web Platform Installer\WebPiCmd-x64.exe"
            ProductId = ''
            Arguments = "/install /products:ASPNET45,ASPNET_REGIIS_NET4,DefaultDocument,DirectoryBrowse,HTTPErrors,HTTPLogging,IISManagementConsole,ISAPIExtensions,ISAPIFilters,ManagementService,NETFramework452,NETFramework4Update402,NetFx4,NetFx4Extended-ASPNET45,NetFxExtensibility45,RequestFiltering,SMO,StaticContent,StaticContentCompression,WASConfigurationAPI,WASProcessModel,WDeploy,WDeployNoSMO  /AcceptEula"
			DependsOn = @("[Package]WebPi_Installation")
        }
	
    # Enable IIS Remote Management  
    Registry EnableRemoteManagement 
    { 
  #    DependsOn = "[WindowsFeature]WebMgmtService" 
      Key = "HKEY_LOCAL_MACHINE\Software\Microsoft\WebManagement\Server" 
      ValueName = "EnableRemoteManagement" 
      ValueData = "1" 
      ValueType = "Dword" 
    } 

    # Start Web Management Server 
    Service WebManagementService 
    { 
      DependsOn = "[Registry]EnableRemoteManagement" 
      Name = "WMSVC" 
      StartupType = "Automatic" 
      State = "Running" 
    }
	

	Script DeployWebPackage
	{
		GetScript = {
            @{
                Result = ""
            }
        }
        TestScript = {
            $false
        }
        SetScript ={

		$WebClient = New-Object -TypeName System.Net.WebClient
		$Destination= "C:\WindowsAzure\WebApplication.zip" 
		#$WebClient.DownloadFile("https://github.com/CawaMS/FileShare/releases/download/releasetag/WebApplication3.zip",$destination)
        $WebClient.DownloadFile($using:WebDeployPackagePath,$destination)
        $ConnectionStringName = "DefaultConnection-Web.config Connection String"
        #$ConnectionString = "Server=tcp:"+"$DbServerName"+".database.windows.net;Database="+"$DbName"+";User ID="+"$DbUserName"+";Password="+"$DbPassword"+";Trusted_Connection=False;Encrypt=True"
        $ConnectionString = "Server=tcp:"+ "$using:DbServerName" + ".database.windows.net,1433;Database=" + "$using:DbName" + ";User ID=" + "$using:DbUserName" + "@$using:DbServerName" + ";Password=" + "$using:DbPassword"+ ";Encrypt=True;TrustServerCertificate=False;Connection Timeout=30;"
        #write-host ("The connection string is: $ConnectionString")
        #write-Output ("The connection string is: $ConnectionString")
        $ConnectionString | Out-File -filepath C:\WindowsAzure\outfile.txt -append -width 200
        $Argument = '-source:package="C:\WindowsAzure\WebApplication.zip"' + ' -dest:auto,ComputerName="localhost",'+"username=$using:UserName" +",password=$using:Password" + ' -setParam:name="' + "$ConnectionStringName" + '"'+',value="' + "$ConnectionString" + '" -verb:sync -allowUntrusted'
		$MSDeployPath = (Get-ChildItem "HKLM:\SOFTWARE\Microsoft\IIS Extensions\MSDeploy" | Select -Last 1).GetValue("InstallPath")
        Start-Process "$MSDeployPath\msdeploy.exe" $Argument -Verb runas
        
        }

	}





    
  }
} 