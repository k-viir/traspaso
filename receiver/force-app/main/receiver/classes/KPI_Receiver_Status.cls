@RestResource(urlMapping='/KPI_Receiver_Status/*')
global with sharing class KPI_Receiver_Status {
    public static OrgInfoWrapper wrapper;

    /*
    *********************************************************
    @Method Name    : checkStatus()
    @author         : cavirjuyar.mejia.tech@bbva.com
    @description    : method called when an error occurs on the target org
                    : to create Organization__c record with error details
    @param          : String orgInfo. json that contains target organization data
    @return         : String 'OK'.
    ********************************************************
    */
    @HttpPost
    global static String checkStatus(String orgInfo) {
        String escapedString = orgInfo.replaceAll('(?<="detail":")(.*)(?=","orgId")', (orgInfo.substringBefore('","orgId"').substringAfter('"detail":"').replaceAll('"','')));
        wrapper = OrgInfoWrapper.parse(escapedString);

        if (!wrapper.detail.containsIgnoreCase('Read timed out')) {

            List<Organization__c> organizations = new List<Organization__c>();
            organizations.add(new Organization__c(Name = KPI_Receiver.getOrgName(wrapper), User__c = wrapper.user, Organization_ID__c = wrapper.orgId,
            Org_URL__c = wrapper.orgUrl, Status__c = wrapper.status ? 'Active' : 'Error', Status_Detail__c = wrapper.detail, Last_connection__c = System.today()));
            if (wrapper.detail.containsIgnoreCase('Unexpected error')) {
                organizations[0].Status__c = 'Error';
            }
            SObjectAccessDecision securityDecision = Security.stripInaccessible(AccessType.CREATABLE, organizations);
            insert securityDecision.getRecords();
        }
        return 'OK';
    }

}