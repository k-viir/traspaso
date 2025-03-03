public with sharing class KPI_Extractor_Batch implements Database.Batchable<sObject>, Database.AllowsCallouts {
    String referenceRecordId;
    public KPI_Extractor_Batch(String referenceRecordId) {
        this.referenceRecordId = referenceRecordId;
    }

    public Database.QueryLocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator('select id, Name, Username, LastLoginDate, profile.Name, profile.userlicense.masterlabel, FederationIdentifier, email, CreatedDate, TimeZoneSidKey from user where isActive = true WITH SECURITY_ENFORCED order by username');
    }
    @SuppressWarnings('PMD.ApexSuggestUsingNamedCred')
    public void execute(Database.BatchableContext bc, List<sObject> scope) {
        KPI_Extractor_Service.setConfigMetadata();
        KPI_Extractor_Service.setExternalToken();

        Map<String, List<AggregateResult>> loginFrequencyMap = new Map<String, List<AggregateResult>>();
        List<PermissionSetLicenseAssign> licensesAssignment = [SELECT PermissionSetLicense.MasterLabel, AssigneeId, Assignee.Username, Assignee.profile.Name, Assignee.profile.UserLicense.MasterLabel from PermissionSetLicenseAssign Where AssigneeId IN :new Map<Id,SObject>(scope).keyset() WITH SECURITY_ENFORCED];

        List<AggregateResult> x1DayLogins = [Select UserId, Status, count(Id) Total From LoginHistory where UserId IN :new Map<Id,SObject>(scope).keyset() AND LoginTime >= LAST_N_DAYS:0 WITH SECURITY_ENFORCED Group By UserId, Status];
        List<AggregateResult> x3DayLogins = [Select UserId, Status, count(Id) Total From LoginHistory where UserId IN :new Map<Id,SObject>(scope).keyset() AND LoginTime >= LAST_N_DAYS:2 WITH SECURITY_ENFORCED Group By UserId, Status];
        List<AggregateResult> x1WeekLogins = [Select UserId, Status, count(Id) Total From LoginHistory where UserId IN :new Map<Id,SObject>(scope).keyset() AND LoginTime >= LAST_N_DAYS:6 WITH SECURITY_ENFORCED Group By UserId, Status];
        List<AggregateResult> x2WeekLogins = [Select UserId, Status, count(Id) Total From LoginHistory where UserId IN :new Map<Id,SObject>(scope).keyset() AND LoginTime >= LAST_N_DAYS:13 WITH SECURITY_ENFORCED Group By UserId, Status];
        List<AggregateResult> x1MonthLogins = [Select UserId, Status, count(Id) Total From LoginHistory where UserId IN :new Map<Id,SObject>(scope).keyset() AND LoginTime >= LAST_N_DAYS:29 WITH SECURITY_ENFORCED Group By UserId, Status];
        List<AggregateResult> x3MonthLogins = [Select UserId, Status, count(Id) Total From LoginHistory where UserId IN :new Map<Id,SObject>(scope).keyset() AND LoginTime >= LAST_N_DAYS:89 WITH SECURITY_ENFORCED Group By UserId, Status];
        List<AggregateResult> x6MonthLogins = [Select UserId, Status, count(Id) Total From LoginHistory where UserId IN :new Map<Id,SObject>(scope).keyset() AND LoginTime >= LAST_N_DAYS:179 WITH SECURITY_ENFORCED Group By UserId, Status];
        loginFrequencyMap.put('x1DayLogins', x1DayLogins);
        loginFrequencyMap.put('x3DayLogins', x3DayLogins);
        loginFrequencyMap.put('x1WeekLogins', x1WeekLogins);
        loginFrequencyMap.put('x2WeekLogins', x2WeekLogins);
        loginFrequencyMap.put('x1MonthLogins', x1MonthLogins);
        loginFrequencyMap.put('x3MonthLogins', x3MonthLogins);
        loginFrequencyMap.put('x6MonthLogins', x6MonthLogins);

        HttpRequest sendRequest = new HttpRequest();
        system.debug('execute url' + KPI_Extractor_Service.centralUrl);

        sendRequest.setEndpoint(KPI_Extractor_Service.centralUrl + '/services/apexrest/eext/KPI_Receiver_Extension/');
        sendRequest.setHeader('Authorization', 'Bearer ' + KPI_Extractor_Service.externalToken); //NOSONAR
        sendRequest.setHeader('Content-Type','application/json');
        sendRequest.setBody('{"action" : ' + '"users"' + ', "content": ' + JSON.serialize(JSON.serialize(new Map<String, String>{'users' => JSON.serialize(scope), 'licenses' => JSON.serialize(licensesAssignment), 'loginFrequency' => JSON.serialize(loginFrequencyMap)})) + ', "referenceRecordId": ' + referenceRecordId + '}');
        sendRequest.setMethod('POST');
        sendRequest.setTimeout(120000);
        Http http = new Http();
        HTTPResponse sendResponse = http.send(sendRequest);
        system.debug(sendResponse.getBody());
    }

    public void finish(Database.BatchableContext bc) {
        System.debug('KPI_Extractor_Batch finished');
    }
}