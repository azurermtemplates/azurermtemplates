Configuration Main
{
  param (
  $MachineName,
  $WebDeployPackagePath,
  $userName,
  $password
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
	
	#copy the web deploy package to the target machine if the package is uploaded to a network share, for example, \\myserver\shared\webdeploy.zip
	#File WebDeployCopy
     #   {
      #      Ensure = "Present"  # You can also set Ensure to "Absent"
      #      Type = "File" # Default is "File".
      #      Recurse = $true # Ensure presence of subdirectories, too
      #      SourcePath = $WebDeployPackagePath
      #      DestinationPath = "C:\WindowsAzure\WebApplication3.zip"    
      #  }

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
		$source = $WebDeployPackagePath 
		$destination= "C:\WindowsAzure\WebApplication.zip" 
		$WebClient.DownloadFile($source,$destination)
        $argument = '-source:package="C:\WindowsAzure\WebApplication.zip"' + ' -dest:auto,ComputerName="localhost",'+"username=$userName" +",password=$password"+ " -verb:sync -allowUntrusted"
		Start-Process 'C:\Program Files (x86)\IIS\Microsoft Web Deploy V3\msdeploy.exe' $argument -Verb runas
        }

	}





    
  }
} 