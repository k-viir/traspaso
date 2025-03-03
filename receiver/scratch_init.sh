#!/bin/bash


# Skip the Connection_config.alphaMetadata.md-meta.xml, project-scratch.json and .forceignore files from being tracked
git update-index --skip-worktree force-app/main/extractor/customMetadata/Connection_config.alphaMetadata.md-meta.xml
git update-index --skip-worktree config/project-scratch-def.json
git update-index --skip-worktree force-app/main/receiver/customMetadata/Connection_config.alphaMetadata.md-meta.xml
git update-index --skip-worktree .forceignore

# Prompt the user to enter their email
read -p "Enter your email: " email

# Replace placeholder email
sed -i "s/globalhub_components.group@dev.bbva.com/$email/g" config/project-scratch-def.json

read -p "select package, receiver or extractor: " package

while [[ $package != "receiver" && $package != "extractor" ]]; do
    read -p "Invalid package selection. Please select 'receiver' or 'extractor': " package
done
read -p "Enter scratch org name: " scratchName

read -p "Enter client id (found in packaging org connected app): " clientId

while [[ ! $clientId =~ ^[a-zA-Z0-9_]+$ ]]; do
    read -p "Invalid client id. Please enter a valid client id: " clientId
done

read -p "Enter client secret (found in packaging org connected app): " clientSecret

while [[ ! $clientSecret =~ ^[a-zA-Z0-9_]+$ ]]; do
    read -p "Invalid client secret. Please enter a valid client secret: " clientSecret
done


echo "Creating scratch org..."
sfdx force:org:create -f config/project-scratch-def.json -a $scratchName -s -d 30 -w 10



if [[ $package == "extractor" ]]; then
echo "Remove extractor path from .forceignore to enable deployment..."
sed -i "s/force-app\/main\/extractor//g" .forceignore

fi

echo "Installing beta package with dev connected app..."
sfdx force:package:install --package 04t07000000t4DaAAI -u $scratchName -w 10

if [[ $package == "receiver" ]]; then
echo "Installing package chart generator..."
sfdx force:package:install --package 04t5G000003zgYI -u $scratchName -w 10
fi

echo "Updating connection config..."

sed -i "s/clientId_placeholder/$clientId/g" "force-app/main/$package/customMetadata/Connection_config.alphaMetadata.md-meta.xml"
sed -i "s/clientSecret_placeholder/$clientSecret/g" "force-app/main/$package/customMetadata/Connection_config.alphaMetadata.md-meta.xml"

echo "Pushing metadata to scratch org..."
sfdx force:source:deploy -p "force-app/main/$package"  -w 10

if [[ $package == "receiver" ]]; then
sfdx force:source:deploy -p demo/main/default -u $scratchName -w 10

echo "Assign permission set..."
sfdx force:user:permset:assign -n KPI_administrator -u $scratchName

sfdx force:user:permset:assign -n Demo_permission

echo "Inserting records..."
sfdx force:data:bulk:upsert -s eext__Organization__c -f demo/data/Organizations.csv -i eext__ExternalId__c -w 10 -u $scratchName
sfdx force:data:bulk:upsert -s eext__Asleep_user__c -f demo/data/OrgUsers.csv -i Id -w 10 -u $scratchName
sfdx force:data:bulk:upsert -s eext__Package__c -f demo/data/Paquetes.csv -i eext__ExternalId__c -w 10 -u $scratchName
sfdx force:data:bulk:upsert -s eext__Package_version__c -f demo/data/VersionesPaquetes.csv -i eext__ExternalId__c  -w 10 -u $scratchName
sfdx force:data:bulk:upsert -s eext__Organization_version__c -f demo/data/OrgVersions.csv -i id -w 10 -u $scratchName
fi

# remove connected app from force ignore so it can be packaged
echo "Remove Connected app path from .forceignore to enable packaging..."
sed -i "s/\*\*\/KPI_Extractor_ConnApp\.connectedApp-meta\.xml//g" .forceignore

echo "Opening scratch org..."
sfdx force:org:open -u $scratchName

read -rsn1 -p "Press any key to exit..."
exit 0

