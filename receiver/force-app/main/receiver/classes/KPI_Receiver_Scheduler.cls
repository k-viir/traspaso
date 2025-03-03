public with sharing class KPI_Receiver_Scheduler implements Schedulable {
    /*
    *********************************************************
    @Method Name    : execute()
    @author         : cavirjuyar.mejia.tech@bbva.com
    @description    : this method executes periodically to check if
                    : organizations are still connected
    @param          : SchedulableContext context. Inherited
    @return         :
    ********************************************************
    */
    public void execute(SchedulableContext context) {
        Date lastConnection;
        List<Organization__c> inactiveOrganizations = new List<Organization__c>();
        List<Organization__c> organizationsList = [Select Last_connection__c, Status__c, Status_Detail__c From Organization__c WITH SECURITY_ENFORCED];
        for (Organization__c eachOrganization : organizationsList) {
            lastConnection = eachOrganization.Last_connection__c;
            if ((Math.mod(lastConnection.day(), 15)) >= 15 && lastConnection.month() != system.today().month()) {
                //we have an inactive org
                eachOrganization.Status__c = 'Inactive';
                eachOrganization.Status_Detail__c = 'Organization has been inactive for more time than it was expected, and probably wont connect again';
                inactiveOrganizations.add(eachOrganization);
            }
        }
        SObjectAccessDecision securityDecision = Security.stripInaccessible(AccessType.CREATABLE, inactiveOrganizations);
        insert securityDecision.getRecords();
    }
}