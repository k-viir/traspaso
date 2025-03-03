@isTest
private class KPI_Visits_Charts_test {
    @testSetup
    static void setup() {
        // Create test user
        insertTestUser();

    // Get the current year
    Integer currentYear = Date.today().year();
        // Create test data for eext__Visit_kpi__c
        List<eext__Visit_kpi__c> visitKpis = new List<eext__Visit_kpi__c>();
        for (Integer i = 0; i < 5; i++) {
            visitKpis.add(new eext__Visit_kpi__c(
                eext__Year__c = String.valueOf(currentYear),
                Organization_url__c = 'http://example' + i + '.com',
                Total_groups__c = 100,
                Month_visited_groups__c = 50,
                Month__c = 'January',
                Quarter_visited_groups__c = 150,
                Quarter__c = 'Q1'
            ));
        }
        insert visitKpis;

        // Create test data for Organization__c
        List<Organization__c> orgs = new List<Organization__c>();
        for (Integer i = 0; i < 5; i++) {
            orgs.add(new Organization__c(
                Org_URL__c = 'http://example' + i + '.com',
                Name = 'Organization ' + i,
                Organization_ID__c = '00D570000003yeKEAQ'
            ));
        }
        insert orgs;
    }

    @isTest
    static void testGetYears() {
        Test.startTest();
        List<String> years = KPI_Visits_Charts.getYears();
        Test.stopTest();
        System.assertEquals(1, years.size(), 'Expected 1 years');
    }

    @isTest
    static void testGetMonthValues() {
        Integer currentYear = Date.today().year();
        Test.startTest();
        List<Wrappers.VisitChartWrapper> monthValues = KPI_Visits_Charts.getMonthValues(String.valueOf(currentYear), 'January');
        Test.stopTest();
        System.assertEquals(5, monthValues.size(), 'Expected 1 month values');
    }

    @isTest
    static void testGetQuarterValues() {
        Integer currentYear = Date.today().year();
        Test.startTest();
        List<Wrappers.VisitChartWrapper> quarterValues = KPI_Visits_Charts.getQuarterValues(String.valueOf(currentYear), 'Q1');
        Test.stopTest();
        System.assertEquals(5, quarterValues.size(), 'Expected 1 quarter values');
    }

    @isTest
    static void testGetRecordMonthlyValues() {
        User u = [SELECT Id FROM User WHERE Alias = 'standt' LIMIT 1];
        System.runAs(u) {
            // The following code runs as user 'u'
            Integer currentYear = Date.today().year();
            Organization__c org = [SELECT Id FROM Organization__c LIMIT 1];
            Test.startTest();
            List<Wrappers.VisitChartWrapper> recordMonthlyValues = KPI_Visits_Charts.getRecordMonthlyValues(org.Id);
            Test.stopTest();
            System.assertEquals(1, recordMonthlyValues.size(), 'Expected 1 monthly values');
          }

    }

    @isTest
    static void testGetOrgNaming() {
        User u = [SELECT Id FROM User WHERE Alias = 'standt' LIMIT 1];

        System.runAs(u) {
            Organization__c org = [SELECT Id FROM Organization__c LIMIT 1];
            Test.startTest();
            Boolean extractVisitsKpi = KPI_Visits_Charts.getOrgNaming(org.Id);
            Test.stopTest();
            System.assertEquals(true, extractVisitsKpi, 'Expected Extract_visits_kpi__c to be true');
        }
    }

    @future
    static void insertTestUser() {
        String uniqueUserName = 'standarduser' + DateTime.now().getTime() + '@testorg.com';
        // This code runs as the system user
        User u = new User(Alias = 'standt', Email='standarduser@testorg.com',
        EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
        LocaleSidKey='en_US', ProfileId =  UserInfo.getProfileId(),
        TimeZoneSidKey='America/Los_Angeles',
        UserName=uniqueUserName);
        insert u;

        PermissionSet permissionSet = [select Id, Name from permissionset where Name = 'KPI_administrator' limit 1];
        User currentUser = [SELECT Id FROM User WHERE Id = :u.Id];
        PermissionSetAssignment permissionSetAssignment = new PermissionSetAssignment(AssigneeId = currentUser.Id,PermissionSetId = permissionSet.Id);
        insert permissionSetAssignment;

    }
}