@isTest
public with sharing class KPI_Chart_Controller_Test {
    @SuppressWarnings('PMD.AvoidHardcodingId')
    @TestSetup
    static void prepareTest(){
        assignPermissionSet();
        Organization__c newPais = new Organization__c(Name = 'Colombia', Organization_ID__c = 'testOrgId', Last_connection__c = DateTime.now().date().addDays(-20));
        insert newPais;
        Package__c newPackage = new Package__c(Name = 'Product Form', Package_ID__c = '12345678912345k', Namespace__c = 'fprd');
        insert newPackage;
        Package_version__c newVersion = new Package_version__c(Name = 'Product Form 1.43', Version_name__c = 'T-Regex', Version_number__c = '1.43', Package__c = newPackage.Id);
        insert newVersion;
        Organization_version__c orgVersion = new Organization_version__c(Name = 'test orgVer', Package_version__c = newVersion.Id, Newest_package_version__c = newVersion.Id, Installed_organization__c = newPais.Id);
        insert orgVersion;
    }

    @future
    public static void assignPermissionSet() {
        PermissionSet permissionSet = [select Id, Name from permissionset where Name = 'KPI_administrator' limit 1];
        User currentUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];
        PermissionSetAssignment permissionSetAssignment = new PermissionSetAssignment(
            AssigneeId = currentUser.Id,
            PermissionSetId = permissionSet.Id
            );
        insert permissionSetAssignment;
    }

    @isTest
    public static void testMainClass() {
        User u = [select Id from User where Id = :UserInfo.getUserId() limit 1];
        system.runAs(u) {
            Test.startTest();
            AggregateResult[] groupedResults = [select  MAX(Version_number__c),Package__r.Name  From Package_version__c WITH SECURITY_ENFORCED group by Package__r.Name];
            system.debug(' kav: ' + groupedResults);
            KPI_Chart_Controller.ChartData result = KPI_Chart_Controller.getChartData([select Id From Organization__c limit 1].Id);
            Test.stopTest();
            System.assertEquals(true, result != null, 'value should not be null');
        }
    }
}