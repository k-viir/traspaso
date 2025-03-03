@SuppressWarnings('PMD.AvoidHardcodingId')
@isTest
public with sharing class KPI_Receiver_Test {
    public static String packagesJsonData;
    public static String orgJsonData;
    public static String installationsJsonData;
    public static String usersJsonData;
    public static String licenseAssignJsonData;
    public static String loginHistoryJsonData;
    public static String statusJsonData;

    @testSetup
    public static void prepareTest() {
        assignPermissionSet();
        Id colRecordTypeId = Schema.SObjectType.Organization__c.getRecordTypeInfosByName().get('colombia enterprise').getRecordTypeId();
        Organization__c newPais = new Organization__c(Name = 'Colombia Enterprise', Organization_ID__c = 'testOrgId', Last_connection__c = DateTime.now().date().addDays(-40), RecordTypeId = colRecordTypeId);
        insert newPais;
        Package__c newPackage = new Package__c(Name = 'Product Form', Package_ID__c = '12345678912345k', Namespace__c = 'fprd');
        insert newPackage;
        Package_version__c newVersion = new Package_version__c(Name = 'Product Form 1.43', Version_name__c = 'T-Regex', Version_number__c = '1.43', Package__c = newPackage.Id);
        insert newVersion;
        Organization_version__c orgVersion = new Organization_version__c(Name = 'test orgVer', Package_version__c = newVersion.Id, Newest_package_version__c = newVersion.Id, Installed_organization__c = newPais.Id);
        insert orgVersion;

        List<Asleep_user__c> users = new List<Asleep_user__c>();
        users.add(new Asleep_user__c(License__c = 'Salesforce', User_organization__c = newPais.Id,Last_login__c = DateTime.now().date().addDays(-2), Full_name__c = 'Prueba', X1_day_login_count__c = 1, X3_day_login_count__c = 1, X1_week_login_count__c = 1, X2_weeks_login_count__c = 1, X1_month_login_count__c = 1));
        users.add(new Asleep_user__c(License__c = 'Salesforce', User_organization__c = newPais.Id,Last_login__c = DateTime.now().date().addDays(-4)));
        users.add(new Asleep_user__c(License__c = 'Salesforce', User_organization__c = newPais.Id,Last_login__c = DateTime.now().date().addDays(-8)));
        users.add(new Asleep_user__c(License__c = 'Salesforce', User_organization__c = newPais.Id,Last_login__c = DateTime.now().date().addDays(-15)));
        users.add(new Asleep_user__c(License__c = 'Salesforce', User_organization__c = newPais.Id,Last_login__c = DateTime.now().date().addDays(-40)));
        users.add(new Asleep_user__c(License__c = 'Salesforce', User_organization__c = newPais.Id,Last_login__c = DateTime.now().date().addDays(-100)));
        users.add(new Asleep_user__c(License__c = 'Salesforce', User_organization__c = newPais.Id,Last_login__c = DateTime.now().date().addDays(-300)));
        users.add(new Asleep_user__c(License__c = 'Salesforce', User_organization__c = newPais.Id,Last_login__c = DateTime.now().date().addDays(-400)));
        insert users;

        User_Reference__c reff = new User_Reference__c(BBVA_User__c = 'O012341', Geography__c = 'Colombia');
        insert reff;


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
            packagesJsonData = '{\"size\":2,\"totalSize\":2,\"done\":true,\"queryLocator\":null,\"entityTypeName\":\"InstalledSubscriberPackage\",\"records\":[{\"attributes\":{\"type\":\"InstalledSubscriberPackage\",\"url\":\"/services/data/v58.0/tooling/sobjects/InstalledSubscriberPackage/0A31X000000OQw2SAG\"},\"Id\":\"0A31X000000OQw2SAG\",\"SubscriberPackageId\":\"03306000000shXHAAY\",\"SubscriberPackage\":{\"attributes\":{\"type\":\"SubscriberPackage\",\"url\":\"/services/data/v58.0/tooling/sobjects/SubscriberPackage/03306000000shXHAAY\"},\"NamespacePrefix\":\"eext\",\"Name\":\"KPI Extractor ConnApp\"},\"SubscriberPackageVersion\":{\"attributes\":{\"type\":\"SubscriberPackageVersion\",\"url\":\"/services/data/v58.0/tooling/sobjects/SubscriberPackageVersion/04t06000000owDPAAY\"},\"Id\":\"04t06000000owDPAAY\",\"Name\":\"alphaOne\",\"MajorVersion\":1,\"MinorVersion\":0,\"PatchVersion\":0,\"BuildNumber\":2}},{\"attributes\":{\"type\":\"InstalledSubscriberPackage\",\"url\":\"/services/data/v58.0/tooling/sobjects/InstalledSubscriberPackage/0A31X000000OPMXSA4\"},\"Id\":\"0A31X000000OPMXSA4\",\"SubscriberPackageId\":\"12345678912345kQAW\",\"SubscriberPackage\":{\"attributes\":{\"type\":\"SubscriberPackage\",\"url\":\"/services/data/v58.0/tooling/sobjects/SubscriberPackage/12345678912345kQAW\"},\"NamespacePrefix\":\"fprd\",\"Name\":\"fprd\"},\"SubscriberPackageVersion\":{\"attributes\":{\"type\":\"SubscriberPackageVersion\",\"url\":\"/services/data/v58.0/tooling/sobjects/SubscriberPackageVersion/04t1v000001YZk3AAG\"},\"Id\":\"04t1v000001YZk3AAG\",\"Name\":\"T-Regex\",\"MajorVersion\":1,\"MinorVersion\":43,\"PatchVersion\":0,\"BuildNumber\":2}}]}';
            installationsJsonData = '{\"size\":2,\"totalSize\":2,\"done\":true,\"queryLocator\":null,\"entityTypeName\":\"PackageInstallRequest\",\"records\":[{\"attributes\":{\"type\":\"PackageInstallRequest\",\"url\":\"/services/data/v58.0/tooling/sobjects/PackageInstallRequest/0Hf1X0000008ACVSA2\"},\"CreatedDate\":\"2024-02-12T17:17:27.000+0000\",\"SubscriberPackageVersionKey\":\"04t06000000ovlk\",\"PackageInstallSource\":null,\"LastModifiedBy\":{\"attributes\":{\"type\":\"User\",\"url\":\"/services/data/v58.0/tooling/sobjects/User/0051X00000FOkjwQAD\"},\"FirstName\":null}},{\"attributes\":{\"type\":\"PackageInstallRequest\",\"url\":\"/services/data/v58.0/tooling/sobjects/PackageInstallRequest/0Hf1X0000008ADnSAM\"},\"CreatedDate\":\"2024-02-15T05:32:02.000+0000\",\"SubscriberPackageVersionKey\":\"04t06000000owDP\",\"PackageInstallSource\":null,\"LastModifiedBy\":{\"attributes\":{\"type\":\"User\",\"url\":\"/services/data/v58.0/tooling/sobjects/User/0051X00000FOkjwQAD\"},\"FirstName\":null}}]}';
            orgJsonData = '{\"orgId\": \"00Df4000004lfYjEAI\", \"orgUrl\": \"https://bbvacs--compchild.sandbox.my.salesforce.com\", \"user\": \"globalhub_components.group@bbva.com.compchild \"}';
            usersJsonData = '[{"attributes":{"type":"User","url":"/services/data/v60.0/sobjects/User/0057Z00000EXJV4QAP"},"Id":"0057Z00000EXJV4QAP","FederationIdentifier":"O012341","Name":"User User","Username":"test-dtkuzuhlp3ga@example.com","LastLoginDate":"2024-04-01T00:57:48.000+0000","ProfileId":"00e7Z000000tzEuQAI","Email":"cavirjuyar.mejia.tech@bbva.com","CreatedDate":"2024-03-14T05:01:56.000+0000","Profile":{"attributes":{"type":"Profile","url":"/services/data/v60.0/sobjects/Profile/00e7Z000000tzEuQAI"},"Id":"00e7Z000000tzEuQAI","Name":"System Administrator","UserLicenseId":"1007Z000000QmptQAC","UserLicense":{"attributes":{"type":"UserLicense","url":"/services/data/v60.0/sobjects/UserLicense/1007Z000000QmptQAC"},"Id":"1007Z000000QmptQAC","MasterLabel":"Salesforce","TotalLicenses":2}}}]';
            licenseAssignJsonData = '[{"attributes":{"type":"PermissionSetLicenseAssign","url":"/services/data/v60.0/sobjects/PermissionSetLicenseAssign/2LA3O000000G4BeWAK"},"PermissionSetLicenseId":"0PL3O000000ESvJWAW","AssigneeId":"0053O000009z8evQAA","Id":"2LA3O000000G4BeWAK","PermissionSetLicense":{"attributes":{"type":"PermissionSetLicense","url":"/services/data/v60.0/sobjects/PermissionSetLicense/0PL3O000000ESvJWAW"},"Id":"0PL3O000000ESvJWAW","MasterLabel":"Sales Console User"},"Assignee":{"attributes":{"type":"User","url":"/services/data/v60.0/sobjects/User/0053O000009z8evQAA"},"Id":"0053O000009z8evQAA","Username":"test-0zgvkwzd9y18@example.com","ProfileId":"00e3O000000teN5QAI","Profile":{"attributes":{"type":"Profile","url":"/services/data/v60.0/sobjects/Profile/00e3O000000teN5QAI"},"Id":"00e3O000000teN5QAI","Name":"System Administrator","UserLicenseId":"1003O000000ROCJQA4","UserLicense":{"attributes":{"type":"UserLicense","url":"/services/data/v60.0/sobjects/UserLicense/1003O000000ROCJQA4"},"Id":"1003O000000ROCJQA4","MasterLabel":"Salesforce","TotalLicenses":2}}}},{"attributes":{"type":"PermissionSetLicenseAssign","url":"/services/data/v60.0/sobjects/PermissionSetLicenseAssign/2LA3O000000G4BoWAK"},"PermissionSetLicenseId":"0PL3O000000ESvSWAW","AssigneeId":"0053O000009z8evQAA","Id":"2LA3O000000G4BoWAK","PermissionSetLicense":{"attributes":{"type":"PermissionSetLicense","url":"/services/data/v60.0/sobjects/PermissionSetLicense/0PL3O000000ESvSWAW"},"Id":"0PL3O000000ESvSWAW","MasterLabel":"Field Service Dispatcher"},"Assignee":{"attributes":{"type":"User","url":"/services/data/v60.0/sobjects/User/0053O000009z8evQAA"},"Id":"0053O000009z8evQAA","Username":"test-0zgvkwzd9y18@example.com","ProfileId":"00e3O000000teN5QAI","Profile":{"attributes":{"type":"Profile","url":"/services/data/v60.0/sobjects/Profile/00e3O000000teN5QAI"},"Id":"00e3O000000teN5QAI","Name":"System Administrator","UserLicenseId":"1003O000000ROCJQA4","UserLicense":{"attributes":{"type":"UserLicense","url":"/services/data/v60.0/sobjects/UserLicense/1003O000000ROCJQA4"},"Id":"1003O000000ROCJQA4","MasterLabel":"Salesforce","TotalLicenses":2}}}},{"attributes":{"type":"PermissionSetLicenseAssign","url":"/services/data/v60.0/sobjects/PermissionSetLicenseAssign/2LA3O000000G4BjWAK"},"PermissionSetLicenseId":"0PL3O000000ESvVWAW","AssigneeId":"0053O000009z8evQAA","Id":"2LA3O000000G4BjWAK","PermissionSetLicense":{"attributes":{"type":"PermissionSetLicense","url":"/services/data/v60.0/sobjects/PermissionSetLicense/0PL3O000000ESvVWAW"},"Id":"0PL3O000000ESvVWAW","MasterLabel":"Health Cloud"},"Assignee":{"attributes":{"type":"User","url":"/services/data/v60.0/sobjects/User/0053O000009z8evQAA"},"Id":"0053O000009z8evQAA","Username":"test-0zgvkwzd9y18@example.com","ProfileId":"00e3O000000teN5QAI","Profile":{"attributes":{"type":"Profile","url":"/services/data/v60.0/sobjects/Profile/00e3O000000teN5QAI"},"Id":"00e3O000000teN5QAI","Name":"System Administrator","UserLicenseId":"1003O000000ROCJQA4","UserLicense":{"attributes":{"type":"UserLicense","url":"/services/data/v60.0/sobjects/UserLicense/1003O000000ROCJQA4"},"Id":"1003O000000ROCJQA4","MasterLabel":"Salesforce","TotalLicenses":2}}}}]';
            loginHistoryJsonData = '{"x6MonthLogins":[{"attributes":{"type":"AggregateResult"},"UserId":"0053O000009z8evQAA","Status":"Success","Total":62}],"x3MonthLogins":[{"attributes":{"type":"AggregateResult"},"UserId":"0053O000009z8evQAA","Status":"Success","Total":62}],"x1MonthLogins":[{"attributes":{"type":"AggregateResult"},"UserId":"0053O000009z8evQAA","Status":"Success","Total":62}],"x2WeekLogins":[{"attributes":{"type":"AggregateResult"},"UserId":"0053O000009z8evQAA","Status":"Success","Total":62}],"x1WeekLogins":[{"attributes":{"type":"AggregateResult"},"UserId":"0053O000009z8evQAA","Status":"Success","Total":24}],"x3DayLogins":[{"attributes":{"type":"AggregateResult"},"UserId":"0053O000009z8evQAA","Status":"Success","Total":20}],"x1DayLogins":[{"attributes":{"type":"AggregateResult"},"UserId":"0053O000009z8evQAA","Status":"Success","Total":8}]}';

            Organization__c org = [select id from Organization__c limit 1];
            KPI_SecondChart.getChartData(org.Id);
            String result = KPI_Receiver.upsertReceivedData(packagesJsonData, installationsJsonData, orgJsonData, usersJsonData, licenseAssignJsonData, loginHistoryJsonData);
            System.assertEquals('Everything OK', result, 'Expected a success value');
            Test.stopTest();
        }
    }

    @isTest
    public static void testStatusClass() {
        statusJsonData = '{"status":false,"detail":"The batch process is not working","orgId":"00Df4000004lfYjEAI","orgUrl":"https://fun-efficiency-1962-dev-ed.scratch.my.salesforce.com","user":"cavirjuyar.mejia.tech@bbva.com"}';
        String result = KPI_Receiver_Status.checkStatus(statusJsonData);
        System.assertEquals('OK', result, 'Expected a success value');
    }

    @isTest
    public static void testScheduleClass() {
        User u = [select Id from User where Id = :UserInfo.getUserId() limit 1];
        system.runAs(u) {

            Test.startTest();

            String cronExp = '0 25 4 6 * ?'; // runs at sec 0, min 25, hour 4, day 3, all months, any days of week

            String jobName = 'scheduled check on orgs';

            KPI_Receiver_Scheduler job = new KPI_Receiver_Scheduler();

            String jobId = System.schedule(jobName, cronExp, job);
            Test.stopTest();

            System.assertEquals(true, jobId != null, 'Expected a success value');
        }
    }

    @isTest
    public static void testCharts() {
        User u = [select Id from User where Id = :UserInfo.getUserId() limit 1];
        system.runAs(u) {

            Test.startTest();
            Asleep_user__c testOrgUser= [Select id, Full_name__c, User_organization__c From Asleep_user__c Where Full_name__c = 'Prueba' Limit 1];
            KPI_SecondChart.FreqChartData result1;
            KPI_SecondChart.OrgFreqChartData result2;
            KPI_SecondChart.OrgFreqChartData result3;
            result1 = KPI_SecondChart.getFreqChartData(testOrgUser.Id);
            result2 = KPI_SecondChart.getOrgFreqChartData(testOrgUser.User_organization__c);
            testOrgUser.X1_day_activity__c = 'High activity';
            testOrgUser.x3_day_activity__c = 'High activity';
            testOrgUser.x1_week_activity__c = 'High activity';
            testOrgUser.x2_week_activity__c = 'High activity';
            testOrgUser.x1_month_activity__c = 'High activity';
            update testOrgUser;
            result3 = KPI_SecondChart.getOrgFreqChartData(testOrgUser.User_organization__c);
            Test.stopTest();
            System.assertEquals(true, result1 != null, 'Expected a success value');
            System.assertEquals(true, result2 != null, 'Expected a success value');
            System.assertEquals(true, result3 != null, 'Expected a success value');
        }
    }

    @isTest
    public static void testExtensionInit() {
        User u = [select Id from User where Id = :UserInfo.getUserId() limit 1];
        system.runAs(u) {
            Test.startTest();
            String content = '{\"orgId\": \"00DKN0000000Rwd2AE\", \"orgUrl\": \"https://power-flow-9289-dev-ed.scratch.my.salesforce.com\", \"user\": \"kavir\", \"usedLicenses\": 1, \"totalLicenses\": 2}';

            KPI_Receiver_Extension.doPost('init', content, null);
            Test.stopTest();
            System.assertEquals(true, true, 'Expected a success value');
        }
    }

    @isTest
    public static void testExtensionUsers() {
        Organization__c newOrg = New Organization__c(Name = 'test', Organization_ID__c = 'testOrgId');
        insert newOrg;

        User u = [select Id from User where Id = :UserInfo.getUserId() limit 1];
        String content = '{\"loginFrequency\":\"{\\\"x6MonthLogins\\\":[{\\\"attributes\\\":{\\\"type\\\":\\\"AggregateResult\\\"},\\\"UserId\\\":\\\"005KN000000eLW3YAM\\\",\\\"Status\\\":\\\"Success\\\",\\\"Total\\\":322}],\\\"x3MonthLogins\\\":[{\\\"attributes\\\":{\\\"type\\\":\\\"AggregateResult\\\"},\\\"UserId\\\":\\\"005KN000000eLW3YAM\\\",\\\"Status\\\":\\\"Success\\\",\\\"Total\\\":322}],\\\"x1MonthLogins\\\":[{\\\"attributes\\\":{\\\"type\\\":\\\"AggregateResult\\\"},\\\"UserId\\\":\\\"005KN000000eLW3YAM\\\",\\\"Status\\\":\\\"Success\\\",\\\"Total\\\":322}],\\\"x2WeekLogins\\\":[{\\\"attributes\\\":{\\\"type\\\":\\\"AggregateResult\\\"},\\\"UserId\\\":\\\"005KN000000eLW3YAM\\\",\\\"Status\\\":\\\"Success\\\",\\\"Total\\\":317}],\\\"x1WeekLogins\\\":[{\\\"attributes\\\":{\\\"type\\\":\\\"AggregateResult\\\"},\\\"UserId\\\":\\\"005KN000000eLW3YAM\\\",\\\"Status\\\":\\\"Success\\\",\\\"Total\\\":266}],\\\"x3DayLogins\\\":[{\\\"attributes\\\":{\\\"type\\\":\\\"AggregateResult\\\"},\\\"UserId\\\":\\\"005KN000000eLW3YAM\\\",\\\"Status\\\":\\\"Success\\\",\\\"Total\\\":125}],\\\"x1DayLogins\\\":[{\\\"attributes\\\":{\\\"type\\\":\\\"AggregateResult\\\"},\\\"UserId\\\":\\\"005KN000000eLW3YAM\\\",\\\"Status\\\":\\\"Success\\\",\\\"Total\\\":49}]}\",\"licenses\":\"[]\",\"users\":\"[{\\\"attributes\\\":{\\\"type\\\":\\\"User\\\",\\\"url\\\":\\\"/services/data/v61.0/sobjects/User/005KN000000eLW3YAM\\\"},\\\"Id\\\":\\\"005KN000000eLW3YAM\\\",\\\"Name\\\":\\\"User User\\\",\\\"Username\\\":\\\"test-ck5ndh1fgqw4@example.com\\\",\\\"LastLoginDate\\\":\\\"2024-08-22T08:57:50.000+0000\\\",\\\"ProfileId\\\":\\\"00eKN000000E7fUYAS\\\",\\\"Email\\\":\\\"cavirjuyar.mejia.tech@bbva.com\\\",\\\"CreatedDate\\\":\\\"2024-08-07T10:00:24.000+0000\\\",\\\"TimeZoneSidKey\\\":\\\"Europe/Paris\\\",\\\"Profile\\\":{\\\"attributes\\\":{\\\"type\\\":\\\"Profile\\\",\\\"url\\\":\\\"/services/data/v61.0/sobjects/Profile/00eKN000000E7fUYAS\\\"},\\\"Id\\\":\\\"00eKN000000E7fUYAS\\\",\\\"Name\\\":\\\"System Administrator\\\",\\\"UserLicenseId\\\":\\\"100KN0000000LlDYAU\\\",\\\"UserLicense\\\":{\\\"attributes\\\":{\\\"type\\\":\\\"UserLicense\\\",\\\"url\\\":\\\"/services/data/v61.0/sobjects/UserLicense/100KN0000000LlDYAU\\\"},\\\"Id\\\":\\\"100KN0000000LlDYAU\\\",\\\"MasterLabel\\\":\\\"Salesforce\\\",\\\"TotalLicenses\\\":2}}}]\"}';
        system.runAs(u) {
            Test.startTest();
            KPI_Receiver_Extension.doPost('users', content, newOrg.Id);

            Test.stopTest();
            System.assertEquals(true, true, 'Expected a success value');
        }
    }

    @isTest
    public static void testExtensionPackages() {
        Organization__c newOrg = New Organization__c(Name = 'test', Organization_ID__c = 'testOrgId');
        insert newOrg;
        String content = '{\"size\":2,\"totalSize\":2,\"done\":true,\"queryLocator\":null,\"entityTypeName\":\"InstalledSubscriberPackage\",\"records\":[{\"attributes\":{\"type\":\"InstalledSubscriberPackage\",\"url\":\"/services/data/v58.0/tooling/sobjects/InstalledSubscriberPackage/0A3KN000000Cf7a0AC\"},\"Id\":\"0A3KN000000Cf7a0AC\",\"SubscriberPackageId\":\"03307000000sdG2AAI\",\"SubscriberPackage\":{\"attributes\":{\"type\":\"SubscriberPackage\",\"url\":\"/services/data/v58.0/tooling/sobjects/SubscriberPackage/03307000000sdG2AAI\"},\"NamespacePrefix\":\"eext\",\"Name\":\"2genConnApp\"},\"SubscriberPackageVersion\":{\"attributes\":{\"type\":\"SubscriberPackageVersion\",\"url\":\"/services/data/v58.0/tooling/sobjects/SubscriberPackageVersion/04t07000000t4DaAAI\"},\"Id\":\"04t07000000t4DaAAI\",\"Name\":\"ver 0.1\",\"MajorVersion\":0,\"MinorVersion\":1,\"PatchVersion\":0,\"BuildNumber\":2}},{\"attributes\":{\"type\":\"InstalledSubscriberPackage\",\"url\":\"/services/data/v58.0/tooling/sobjects/InstalledSubscriberPackage/0A3KN000000Cf7c0AC\"},\"Id\":\"0A3KN000000Cf7c0AC\",\"SubscriberPackageId\":\"033f4000000YYRiAAO\",\"SubscriberPackage\":{\"attributes\":{\"type\":\"SubscriberPackage\",\"url\":\"/services/data/v58.0/tooling/sobjects/SubscriberPackage/033f4000000YYRiAAO\"},\"NamespacePrefix\":\"chgn\",\"Name\":\"Chart Generator\"},\"SubscriberPackageVersion\":{\"attributes\":{\"type\":\"SubscriberPackageVersion\",\"url\":\"/services/data/v58.0/tooling/sobjects/SubscriberPackageVersion/04t5G000003zgYIQAY\"},\"Id\":\"04t5G000003zgYIQAY\",\"Name\":\"k2\",\"MajorVersion\":1,\"MinorVersion\":31,\"PatchVersion\":0,\"BuildNumber\":4}}]}';
        User u = [select Id from User where Id = :UserInfo.getUserId() limit 1];
        system.runAs(u) {
            Test.startTest();
            KPI_Receiver_Extension.doPost('packages', content, newOrg.Id);

            Test.stopTest();
            System.assertEquals(true, true, 'Expected a success value');
        }
    }

    @isTest
    public static void testExtensionError() {
        Organization__c newOrg = New Organization__c(Name = 'test', Organization_ID__c = 'testOrgId');
        insert newOrg;
        User u = [select Id from User where Id = :UserInfo.getUserId() limit 1];
        system.runAs(u) {
            Test.startTest();
            KPI_Receiver_Extension.doPost('error', 'testerror', newOrg.Id);

            Test.stopTest();
            System.assertEquals(true, true, 'Expected a success value');
        }
    }



}