# Desktop Integration Testing Experiment

## About
This repo is an experiment in automating the deployment of a VM onto Azure. Specifically, the deployment:
1. Installs a Windows 10 Enterprise image.
2. Binds a public IP address for the VM with fully qualified domain name.
3. Sets up a storage account to install the VM.
4. Configures a network security group that allows incoming connections on ports `3389` and `5985` for clients to connect via Remote Desktop or Powershell Remoting.
5. Runs the `Enable-PSRemoting.ps1` script to configure Powershell Remoting/WinRM on the VM.

## How It Works
The deployment involves a few pieces. First, the deployment of the VM is encapsulated in `azuredeploy.json`, which is an Azure Resource Management template (ARM). An ARM template describes all the resources that will be installed (i.e., VM, network security group, etc.) in a declarative manner. See Microsoft's [Azure Quickstart Templates](https://github.com/Azure/azure-quickstart-templates) for real world examples. Additionally, ARM templates allow parameters, with default values set in an optional parameters file (`azuredeploy.parameters.json`). The declarative model is unreadable once a template becomes non-trivial, so we recommend going to [Azure Resource Visualizer](http://armviz.io/#/) to see a graphical representation of your templates.

Second, Powershell Remoting is enabled on the VM. To do so, the `Enable-PSRemoting.ps1` script is run on the VM after it is installed as part of the deployment template. Powershell Remoting will enable clients to start Powershell sessions on the VM. This makes integration testing as part of a continuous build system possible.

Finally, the `New-AzureVMDeployment.ps1` script does the heavy lifting.

## Running the Deployment Script

### Prerequisites
* An Azure account with administrator rights is required.
* We recommend using [Visual Studio Code](https://code.visualstudio.com/) with the [Powershell extension](https://github.com/PowerShell/vscode-powershell) installed for fast and lightweight development and debugging.
* Install the Azure Powershell module. Go to the [Azure Downloads](https://azure.microsoft.com/en-us/downloads/) page. The installer should be under the "Command-line tools" section.

### Script Parameters
`New-AzureVMDeployment.ps1` has some mandatory parameters:
* `-UserName` is the username of an Azure account. It needs to have admin rights.
* `-PasswordFilePath` is the path to a file that has your Azure account password stored as an encrypted standard string. See the *Setting up a password file* section for instructions.
* `-SubscriptionId` is the subscription ID assigned to the Azure account.
* `-ResourceGroupName` can be thought of as the name of the deployment.

**This script must be run with administrator rights!**

### Creating a password file
The deployment script logs into Azure. To ensure security, the script expects the password of the Azure account to be stored in a file as an encrypted standard string.

To create a password file, start a Powershell session and run:
```powershell
Read-Host "Enter Password" -AsSecureString |  ConvertFrom-SecureString | Out-File "<path to file here>"
```
Replace `<path to file here>` with the desired file location