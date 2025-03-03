@SuppressWarnings('PMD.StdCyclomaticComplexity')
/*
*********************************************************************************************************
@Name     KPI_Receiver_Extension
@Author   cavirjuyar.mejia.tech@bbva.com
@Date     Created: 22/08/2024
@Group    Global Hub Components
@Description This class handles received rest request from extractor package when it comes from batch process
*********************************************************************************************************
@Changes
Date              Author                                    Modification
22/08/2024        cavirjuyar.mejia.tech@bbva.com           Class creation.
*********************************************************************************************************
*/
@RestResource(urlMapping='/KPI_Receiver_Extension/*')
global with sharing class KPI_Receiver_Extension {
    /*
    *********************************************************
    @Method Name    : doPost
    @author         : cavirjuyar.mejia.tech@bbva.com
    @description    : this method is called from target organization periodically to load
                    : kpis data, packages, and login activity when called from batch process
    @param          : String action. Decides which part of the process is being executed
    @param          : String conent. Necessary content for execution, be it information from the org, packages or users
    @param          : String referenceRecordId. Id of the organization record created and taken as reference for the rest of the process
    @return         : result, a string that describes result or the id of the record created
    ********************************************************
    */
    @HttpPost
    global static String doPost(String action, String content, String referenceRecordId) {
        String returnValue;
        if(action == 'init') {
            KPI_Receiver.orgInformation = OrgInfoWrapper.parse(content);
            Boolean alreadyExecuted = false;
            List<Organization__c> orgs = [select Id From Organization__c where Organization_ID__c =: KPI_Receiver.orgInformation.orgId AND Last_connection__c = TODAY AND Status__c = 'Active' WITH SECURITY_ENFORCED];
            alreadyExecuted = orgs.size() > 0 ? true : false;
            if (alreadyExecuted == false) {

            KPI_Receiver.organization = new Organization__c(Name = KPI_Receiver.getOrgName(KPI_Receiver.orgInformation), User__c = KPI_Receiver.orgInformation.user, Organization_ID__c = KPI_Receiver.orgInformation.orgId,
            Org_URL__c = KPI_Receiver.orgInformation.orgUrl, RecordTypeId = KPI_Receiver.orgRecordTypeId);
            KPI_Receiver.organization.Last_connection__c = System.today();
            KPI_Receiver.organization.Status__c = 'Active';
            KPI_Receiver.organization.Status_Detail__c = 'Connection is working as expected';
            KPI_Receiver.organization.Used_licenses__c = KPI_Receiver.orgInformation.usedLicenses;
            KPI_Receiver.organization.Total_licenses__c = KPI_Receiver.orgInformation.totalLicenses;
            insert KPI_Receiver.organization;
            returnValue =  KPI_Receiver.organization.Id;
            }

        } else if(action == 'packages') {
            KPI_Receiver.organization = [SELECT Id, Name FROM Organization__c WHERE Id =: referenceRecordId WITH SECURITY_ENFORCED];
            KPI_Receiver.receivedPackages = PackagesWrapper.parse(content);
            KPI_Receiver.globalPackages = database.query('Select Id, Name, Namespace__c, Package_ID__c From Package__c');
            KPI_Receiver.globalPackagesVersions = database.query('Select Id, Name, Version_number__c, Package__c, Package__r.Name, Package__r.Package_ID__c, Version_differences__c  From Package_version__c');

            KPI_Receiver.getLatestVersions();
            if (KPI_Receiver.versionesMasAltas.size() > 0) {
                KPI_Receiver.processPackagesOptimized();
            }
            returnValue = 'OK';
        } else if(action == 'users') {
            processUsers(action, content, referenceRecordId);
            returnValue = 'OK';
        } else if(action == 'error') {
            Organization__c organization = [SELECT Id, Name, Status__c, Status_Detail__c FROM Organization__c WHERE Id =: referenceRecordId WITH SECURITY_ENFORCED];
            organization.Status__c = 'Error';
            organization.Status_Detail__c = ' error during user data extraction : ' + content;
            SObjectAccessDecision securityDecision = Security.stripInaccessible(AccessType.UPDATABLE, new List<Organization__c>{organization});
            update securityDecision.getRecords();
            returnValue = 'OK';
        }
        return returnValue;
    }

    @future
    public static void processUsers(String action, String content, String referenceRecordId) {
        recurrentProcess(action, content, referenceRecordId);
    }

    public static void recurrentProcess(String action, String content, String referenceRecordId) {
        try {
            KPI_Receiver.organization = [SELECT Id, Name FROM Organization__c WHERE Id =: referenceRecordId WITH SECURITY_ENFORCED FOR UPDATE];
            Map<String, String> contentMap = (Map<String, String>) JSON.deserialize(content, Map<String, String>.class);
            KPI_Receiver.setUsersDetails((String) contentMap.get('licenses'), (String) contentMap.get('loginFrequency'));
            KPI_Receiver.processOrgUsers(contentMap.get('users'));
        } catch (Exception e) {
            recurrentProcess(action, content, referenceRecordId);
        }
    }
}