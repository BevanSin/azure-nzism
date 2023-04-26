# azure-nzism
Policy Initiative for the NZ ISM Restricted standard as published by the NCSC in New Zealand


# Objectives

Automate the production of the NZISM as much as possible

**Plan**

1. feed in CSV containing list of policies and associated control
2. Metadata? - prob keep in separate pile - need to be able to update that from website
3. Create initative pulling info from metadata, combining into single JSON
4. Process to push updated version to Azure tenant\subscription or MG - document this process for people to use


# Current process

1. Dump Metadata to CSV from main spreadsheet - columns = name, category, displayName, description, url
2. Save CSV to %repo%\csv\controls.csv
3. Run createmetadata.ps1 which generates a controls.json in the json folder
4. Dump policy guid and control ID to be included in the inititative into a CSV - columns = policy, groupname
5. Save CSV to %repo%\csv\policies.csv


# Outstanding features to be developed

Policy Dump
Pull list of all available builtin policies from Azure and store in ??
run policy dump on a schedule or on demand?

Metadata store
Pull from NZISM website (scrape? or dl\parse xml)

Build initaitve
Take CSV input

Errorcheck
Identify when a selected policy in list is deprecated and throw error

