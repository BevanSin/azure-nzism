# Deploy NZISM Restricted policy initiative to Azure
## Initiatve and NZISM Version 3.6

This document covers how to deploy and use the NZ ISM Restricted Policy Initiative.  If you have any feedback or requests please send them to nzism@gcsb.govt.nz or contact bevan.sinclair@microsoft.com

## What is the NZISM Restricted Policy Initiative?

This policy initiative is a selection of builtin Azure policies that match controls in the current version of the NZISM.  It is designed to ensure that your Azure environment is operating at a level conformant with the Restricted level of security as defined in the NZISM.  The usage of this template is consistent with Microsoft recommended practice for Compliance policies in that it is an assessment of the environment against a standard, not as an enforcement of that standard.  To that end, this policy intiative should always be deployed in Audit Only, and any non-compliance should be managed as an internal process to understand why a service is non-compliant, then remediated through design and re-deployment.

Before deploying this initative in a Production subscription or management group in Azure, please ensure that you have tested the impact in a test subscription or management group as per recommended Microsoft practice for policy deployment.

To move to a more scalable and audited patern for managing Azure Policy, utilise a CI/CD pipeline to deploy the policy initiative and manage it as code.  For more details around policy management as code please see the Enterprise Policy As Code documentaion and code repo https://aka.ms/epac

## Prerequisites
To install the NZISM Restricted Policy Initiative you will need:

1. Azure CLI - https://learn.microsoft.com/en-us/cli/azure/
2. Permissions to create and assign policies in your Azure subscription or management group

## Files in this package

Included in this package should be the following files:
1. nzism3.6.definitions.json - definitions file
>The definitions file contains all of the policies and their linked groups and parameters for the NZISM initiative.  The definitions file is used to create the initiative in your subscription or management group.  The definitions file is also used to create the policy assignments for the initiative.
2. nzism3.6.groups.json - groups file
>The groups file contains the details of each control from the NZISM including links to the initative published on the NCSC website.
3. nzism3.6.parameters.json
>The parameters file contains any configurable parameter for each policy in the initiative and the appropriate values for each parameter where it is not covered by the default value.  All of these are set to Audit or have a specific value that mateches the NZISM control requirement.  e.g. Minimum RSA Key size is 3072
4. nzism_deployment.md
>This document
5. deploy-initiative.ps1
>Sample PowerShell script to deploy the initiative to your subscription or management group

## Install using script


## Install using Azure shell



## Documentation links

Azure Policy Recommended Practices - https://techcommunity.microsoft.com/t5/core-infrastructure-and-security/azure-policy-recommended-practices/ba-p/3798024
Enterprise Policy As Code - https://aka.ms/epac
Azure safe deployment practices for Policy - https://learn.microsoft.com/en-us/azure/governance/policy/how-to/policy-safe-deployment-practices