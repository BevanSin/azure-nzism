# azure-nzism
Policy Initiative for the NZ ISM Restricted standard as published by the NCSC in New Zealand

# Objectives
Automate the production of the NZISM as much as possible


# Current process

1. Dump Controls (Metadata) to CSV from main spreadsheet - columns = name, category, displayName, description, url
2. Save CSV to %repo%\csv\controls.csv
3. Edit the CSV to replace comma with | due to commas in the description fields
4. Dump the params from current NZISM Policy Initiative to %repo%\csv\params.csv using the columns ParameterName|Type|DisplayName|Description|AllowedValues|DefaultValue  Ensure | separator used instead of comma.
5. Dump the policies selected for this version from the main Spreadsheet to %repo%\csv\policies.csv using the columns policyDefinitionId,groupNames,parameters
6. Add the parameters in using the names of the parameter in the parameters column of the policies.csv - i.e. cee51871-e572-4576-855c-047c820360f0,17.2.24.C.01.,minimumRSAKeySize-cee51871-e572-4576-855c-047c820360f0
7. Delete the copy of allpolicies.json if it exists to ensure latest copy of policies cached when script is run
8. Run the create-initiative.ps1 script from the repo - 

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

