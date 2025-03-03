@isTest
public with sharing class KPI_Extractor_Test {
    @isTest
    public static void testScheduleClass() {
        Test.setMock(HttpCalloutMock.class, new KPI_CalloutMock());

        // call apex static class to test and pass parameters and save
        Test.startTest();
        KPI_Extractor_Setup.configure();
        List<AsyncApexJob> result = [Select ApexClass.Name From AsyncApexJob Where ApexClass.Name = 'KPI_Extractor_Scheduler' AND Status = 'Queued'];
        Test.stopTest();
        System.assertEquals(true, result.size() > 0, 'process not configured');
    }

    @isTest
    public static void testScheduleClass2() {
        Test.setMock(HttpCalloutMock.class, new KPI_CalloutMock());
        String cronExp = '0 0 23 * * ? *';
        String jobName = 'scheduled packages kpi extraction';

        KPI_Extractor_Scheduler job = new KPI_Extractor_Scheduler();

        Id result = System.schedule(jobName, cronExp, job);

        // call apex static class to test and pass parameters and save
        Test.startTest();
        try {
            KPI_Extractor_Setup.configure();
        } catch (Exception e) {
            system.debug(e.getMessage());
        }
        Test.stopTest();
        System.assertEquals(true, result != null, 'process not configured');

    }

    @isTest
    public static void testMainClass() {
        Test.setMock(HttpCalloutMock.class, new KPI_CalloutMock());
        Test.startTest();
        KPI_Extractor_Service.setConfigMetadata();
        KPI_Extractor_Service.setSelfToken();
        KPI_Extractor_Service.setExternalToken();
        String result = KPI_Extractor_Service.sendStatus('duplicate batch');
        Test.stopTest();

        System.assertEquals('OK', result, 'process not completed');
    }

    @isTest
    public static void testExtension() {
        Test.setMock(HttpCalloutMock.class, new KPI_CalloutMock());
        Test.startTest();
        KPI_Extractor_Service.setConfigMetadata();
        String result = KPI_Extractor_Extension.mainProcess();
        Test.stopTest();

        System.assertEquals('OK', result, 'process not completed');
    }

    @isTest
    public static void testExtensionError() {
        Test.setMock(HttpCalloutMock.class, new KPI_CalloutMock());
        Test.startTest();
        String result = KPI_Extractor_Extension.mainProcess();
        Test.stopTest();

        System.assertEquals('KO', result, 'process not completed');
    }

}