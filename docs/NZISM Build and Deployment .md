Deploy using az command line





1. Prerequisites:
   - Ensure you have an Azure DevOps project set up.
   - Make sure you have an Azure subscription where you want to deploy the policy initiative.

Create a new Project in the DevOps Org - follow EPAC model - https://techcommunity.microsoft.com/t5/core-infrastructure-and-security/azure-enterprise-policy-as-code-a-new-approach/ba-p/3607843
https://github.com/Azure/enterprise-azure-policy-as-code/blob/main/Docs/index.md

Single Tenant and Centralised Model - Centralized: One centralized team manages all Policy resources in the Azure organization, at all levels (Management Group, Subscription, Resource Group). This is the default setup.

Create a new project in Azure DevOps
Project Name = EPAC
Click Create

Create a new repo
Click on Project Settings and Repositories
Click + Create
Leave type as Git and set name to epacforkrepo
Click Create
Click the Repos link on the left
Click on epacforkrepo in the top dropdown list
Click on the Import button under Import a Repository and copy the URL https://github.com/Azure/enterprise-azure-policy-as-code into the Clone URL field
Click Import






2. Set up Service Connection:
   - Create an Azure Service Connection in Azure DevOps to connect to your Azure subscription. Go to Project Settings -> Service connections -> New service connection -> Azure Resource Manager -> Service Principal (automatic). Provide the required information to create the connection.

3. Create a new YAML pipeline:
   - In your Azure DevOps project, navigate to the Pipelines section and create a new pipeline.
   - Choose the "Starter pipeline" to create a new YAML file for your pipeline.

4. Define the pipeline stages and tasks:
   - In the YAML file, define your pipeline stages. Typically, you'll have stages for build, test, and deploy. For this specific scenario, you'll add a stage to deploy the policy initiative.

   ```yaml
   trigger:
     branches:
       include:
         - main

   pool:
     vmImage: 'ubuntu-latest'

   stages:
     - stage: Build
       jobs:
         - job: BuildJob
           steps:
             # Add steps to build your policy initiative here

     - stage: Test
       jobs:
         - job: TestJob
           steps:
             # Add steps to test your policy initiative here

     - stage: Deploy
       jobs:
         - job: DeployJob
           steps:
             - task: AzurePowerShell@5
               inputs:
                 azureSubscription: '<Your-Azure-Service-Connection>'
                 scriptType: 'InlineScript'
                 inline: |
                   # Add PowerShell script to deploy the policy initiative and assign it here
   ```

5. Write PowerShell script to deploy and assign the policy initiative:
   - Inside the `DeployJob` job, you'll use a PowerShell script to deploy the policy initiative and assign it to your Azure subscription. You can use Azure PowerShell cmdlets to achieve this.

   Here's a sample PowerShell script to deploy an initiative definition and assign it:

   ```powershell
   # Connect to your Azure subscription
   Connect-AzAccount -ServicePrincipal -TenantId "<Your-Tenant-ID>" -ApplicationId "<Your-Service-Principal-AppID>" -CertificateThumbprint "<Your-Service-Principal-CertThumbprint>"

   # Set your target Azure subscription
   Set-AzContext -SubscriptionId "<Your-Subscription-ID>"

   # Define the path to your policy initiative definition file
   $initiativeDefinitionFile = "path/to/your/initiative-definition.json"

   # Deploy the policy initiative definition
   $initiative = New-AzPolicySetDefinition -Name "MyPolicyInitiative" -DisplayName "My Policy Initiative" -PolicyDefinition $initiativeDefinitionFile

   # Assign the policy initiative to the desired scope (e.g., subscription, resource group, etc.)
   New-AzPolicyAssignment -Name "MyPolicyInitiativeAssignment" -DisplayName "My Policy Initiative Assignment" -Scope "/subscriptions/<Your-Subscription-ID>" -PolicySetDefinition $initiative
   ```

6. Replace the placeholders in the PowerShell script with your actual values (e.g., `<Your-Tenant-ID>`, `<Your-Service-Principal-AppID>`, `<Your-Service-Principal-CertThumbprint>`, `<Your-Subscription-ID>`, and the path to the initiative definition file).

7. Commit and push your changes:
   - Save the YAML file and commit it to your repository.
   - Push the changes to trigger the pipeline.

8. Run the pipeline:
   - Go to the Pipelines section in Azure DevOps, and you should see your new pipeline.
   - Manually trigger the pipeline or wait for a trigger (if you have set up an automatic trigger).

The pipeline will execute the build, test, and deployment stages. The deployment stage will use the PowerShell script to deploy the policy initiative and assign it to the specified Azure subscription.