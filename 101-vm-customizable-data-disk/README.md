# Create a Virtual Machine from a Windows Image with Customizable Data Disk

<a href="https://azuredeploy.net/" target="_blank">
    <img src="http://azuredeploy.net/deploybutton.png"/>
</a>

This template allows creates a Windows VM with Customizable Data Disk

In the parameters file:

     "vmDiagnosticsStorageAccountResourceGroup":{ 
         "value" : "diagnosticsResourceGroup" 
     }, 
     "vmDiagnosticsStorageAccountName":{ 
         "value" : "diagnosticsStorageAccount" 
     }, 
         "diskSizeGB" : {
        "value":"50"
    },

the specified diagnostics storage account must be created in the specified diagnostics resource group and the value for the datadisk size in GB can be changed.