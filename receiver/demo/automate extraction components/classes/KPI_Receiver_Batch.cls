public class KPI_Receiver_Batch implements Database.Batchable<sObject>, Database.AllowsCallouts {


    public KPI_Receiver_Batch() {
    }

    public List<sObject> start(Database.BatchableContext context) {
        List<sObject> orgNamings = [select id, Org_name__c  from eext__Org_naming__mdt where eext__Extract_visits_kpi__c = true ];
        List<String> orgNames = new List<String>();
        for (Org_naming__mdt eachMdt: (List<Org_naming__mdt>)orgNamings) {
            orgNames.add(eachMdt.Org_name__c);
        }
        List<sObject> extractOrgs = [select Org_URL__c from Organization__c where Name IN :orgNames];
        return extractOrgs;
    }

    public void execute(Database.BatchableContext context, List<sObject> scope) {
        HttpRequest externalAuthRequest = new HttpRequest();
        Http restHttp = new Http();
        HttpResponse response;
        String externalAccessToken;
        Map<String, Object> externalAuthResponseMap;
        List<Connection_config__mdt> connectionCredentials;
        connectionCredentials = (List<Connection_config__mdt>) database.query('select Client_id__c, Secret_id__c from Connection_config__mdt where DeveloperName = \'alphaMetadata\' Limit 1');

        String externalAuthBody = 'grant_type=client_credentials'
        + '&client_id=' + EncodingUtil.urlEncode(connectionCredentials[0].Client_id__c, 'UTF-8')
        + '&client_secret=' + EncodingUtil.urlEncode(connectionCredentials[0].Secret_id__c, 'UTF-8');

        externalAuthRequest.setMethod('POST');
        externalAuthRequest.setHeader('Content-Type', 'application/x-www-form-urlencoded');
        externalAuthRequest.setBody(externalAuthBody);

        for (Organization__c eachOrg : (List<Organization__c>)scope) {
            System.debug('auth call for ' + eachOrg.Org_URL__c);
            externalAuthRequest.setEndpoint(eachOrg.Org_URL__c + '/services/oauth2/token');
            response = restHttp.send(externalAuthRequest);
            if (response.getStatusCode() == 200) {
                externalAuthResponseMap = (Map<String, Object>) JSON.deserializeUntyped(response.getBody());
                externalAccessToken = (String) externalAuthResponseMap.get('access_token');
                AsyncOptions queueOptions = new AsyncOptions();
                queueOptions.MaximumQueueableStackDepth = 1000;

                System.enqueueJob(new KPI_Visits_Queueable(eachOrg.Org_URL__c, externalAccessToken, null), queueOptions);
            } else {
                system.debug('error connection: ' + response.getBody());
            }
        }
    }

    public void finish(Database.BatchableContext context) {
        // Implement any post-processing logic here
    }
}
