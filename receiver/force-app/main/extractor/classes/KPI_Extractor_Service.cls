/*
*********************************************************************************************************
@Name     KPI_Extractor_Service
@Author   cavirjuyar.mejia.becas@bbva.com
@Date     Created: 24/10/2023
@Group    Global Hub Components
@Description This class contains the main methods to execute package functionality, retrieve info, send
info and status.
*********************************************************************************************************
@Changes
Date              Author                                    Modification
24/10/2023        cavirjuyar.mejia.becas@bbva.com           Class creation.
*********************************************************************************************************
*/
public without sharing class KPI_Extractor_Service implements Queueable, Database.AllowsCallouts{

    public static String selfToken;
    public static String externalToken;
    public static List<Connection_config__mdt> connectionCredentials;
    public static List<Connection_details__mdt> connectionDetails;
    public static String localUrl;
    public static String centralUrl;
    public static String log;
    public static String packagesListJson;
    public static String orgInfo;
    public static UserLicense licenseInfo;


    /*
    *********************************************************
    @Method Name    : sendKpi()
    @author         : cavirjuyar.mejia.becas@bbva.com
    @description    : this method makes a query to extract information about
                      packages in the org and returns it
    @param          :
    @return         : void
    ***********************.*********************************
    */
    public static void  execute(QueueableContext context) {
        try {
            setConfigMetadata();
            Integer totalRecords =(Integer) database.query('select count(id) total From user where isActive = true')[0].get('total');
            if (totalRecords > 4000) {
                KPI_Extractor_Extension.mainProcess();
            } else {
                setSelfToken();
                if (selfToken != null) {
                    setPackages();
                    if (packagesListJson != null) {
                        sendInfo();
                    }
                } else {
                    sendStatus(null);
                }
            }
        } catch (Exception e) {
            sendStatus(e.getMessage());
        }
    }

    /*
    *********************************************************
    @Method Name    : sendInfo
    @author         : cavirjuyar.mejia.becas@bbva.com
    @description    : This methods executes the callout to send
                      the information of the packages to the
                      central org
    @param          : String packagesListJson, String of the information of the packages
    @return         : void
    ********************************************************
    */
    public static void sendInfo() {

        setExternalToken();
        if (externalToken != null) {
            postKpi();
        } else {
            sendStatus(null);
        }
    }

    /*
    *********************************************************
    @Method Name    : sendStatus
    @author         : cavirjuyar.mejia.becas@bbva.com
    @description    : This method reports the status of the process
    @param          :
    @return         : void
    ********************************************************
    */
    @SuppressWarnings('PMD.CyclomaticComplexity')
    public static String sendStatus(String exceptionMessage) {
        Boolean status = false;
        String resultJson;
        Boolean selfConnection = false;
        Boolean batchProcess = false;
        String detail;
        String orgId;
        List<AsyncApexJob> jobList = new List<AsyncApexJob>();
        jobList = [Select ApexClass.Name From AsyncApexJob Where ApexClass.Name = 'KPI_Extractor_Scheduler' AND Status = 'Queued' WITH SECURITY_ENFORCED];
        selfConnection = setSelfConnection();
        batchProcess = setBatchProcess(jobList.size());
        orgId = [Select Id From Organization WITH SECURITY_ENFORCED Limit 1].Id;

        if (selfConnection == false && batchProcess == false) {
            status = false;
            detail = 'Neither connecting to itself or the batch process is working';
            detail = addExceptionMessage(detail, exceptionMessage);
        } else if (selfConnection == false && batchProcess == true) {
            status = false;
            detail = 'Self connection is not working';
            detail = addExceptionMessage(detail, exceptionMessage);
        } else if (selfConnection == true && batchProcess == true) {
            status = true;
            detail = exceptionMessage == null ? 'Connection is working as expected' : 'Unexpected error: ' + exceptionMessage;
        } else if (selfConnection == true && batchProcess == false) {
            status = false;
            detail = 'Connection is working, but the batch process is not configured';
            detail = addExceptionMessage(detail, exceptionMessage);
        }

    resultJson = '{"status":' + status +',"detail":"' + detail + '","orgId":"' + orgId + '","orgUrl":"' + localUrl + '","user":"' +  connectionDetails[0].Local_user__c  + '"}';
    postStatus(resultJson);
    return 'OK';
    }

    /*
    *********************************************************
    @Method Name    : setSelfConnection()
    @author         : cavirjuyar.mejia.tech@bbva.com
    @description    : method to reduce complexity of sendStatus method
    @param          : none
    @return         : Boolean, value
    ********************************************************
    */
    public static Boolean setSelfConnection() {
        Boolean returnValue = false;
        if (selfToken != null) {
            returnValue = true;
        }
        return returnValue;
    }

    /*
    *********************************************************
    @Method Name    : setBatchProcess()
    @author         : cavirjuyar.mejia.tech@bbva.com
    @description    : method to reduce complexity of sendStatus method
    @param          : Integer, size value
    @return         : Boolean, value
    ********************************************************
    */
    public static Boolean setBatchProcess(Integer jobSize) {
        Boolean returnValue = false;
        if (jobSize >= 1) {
            returnValue = true;
        }
        return returnValue;
    }

    /*
    *********************************************************
    @Method Name    : addExceptionMessage()
    @author         : cavirjuyar.mejia.tech@bbva.com
    @description    : method to reduce complexity of sendStatus method
    @param          : String detail, detail value
    @param          : String exceptionMessage, exception message value
    @return         : String, value
    ********************************************************
    */
    public static String addExceptionMessage(String detail, String exceptionMessage) {
        String modifiedDetail = detail;
        if (exceptionMessage != null) {
            modifiedDetail += ', ' + exceptionMessage;
        }
        return modifiedDetail;
    }

    /*
    *********************************************************
    @Method Name    : setConfigMetadata()
    @author         : cavirjuyar.mejia.tech@bbva.com
    @description    : this method queries custom metadata neccessary for connection to central org
    @param          : none
    @return         : void
    ********************************************************
    */
    public static void setConfigMetadata() {
        localUrl = System.url.getOrgDomainUrl().toExternalForm();
        connectionCredentials = (List<Connection_config__mdt>) database.query('select Client_id__c, Secret_id__c from Connection_config__mdt where DeveloperName = \'alphaMetadata\' Limit 1');
        connectionDetails = (List<Connection_details__mdt>) database.query('select Local_user__c, Endpoint_url__c From Connection_details__mdt where DeveloperName = \'alphaMetadata\' Limit 1');
        centralUrl = connectionDetails[0].Endpoint_url__c;
    }

    /*
    *********************************************************
    @Method Name    : setSelfToken()
    @author         : cavirjuyar.mejia.tech@bbva.com
    @description    : this method makes a rest call to current(self) organization to get authentication response
    @param          : none
    @return         : HttpResponse response of the authentication process
    ********************************************************
    */
    @SuppressWarnings('PMD.ApexSuggestUsingNamedCred')
    public static void setSelfToken() {
        HttpRequest selfAuthRequest = new HttpRequest();
        String selfAuthBody = 'grant_type=client_credentials'
        + '&client_id=' + EncodingUtil.urlEncode(connectionCredentials[0].Client_id__c, 'UTF-8')
        + '&client_secret=' + EncodingUtil.urlEncode(connectionCredentials[0].Secret_id__c, 'UTF-8');

        selfAuthRequest.setEndpoint(localUrl + '/services/oauth2/token');
        selfAuthRequest.setMethod('POST');
        selfAuthRequest.setHeader('Content-Type', 'application/x-www-form-urlencoded');
        selfAuthRequest.setBody(selfAuthBody);

        Http authHttp = new Http();
        HttpResponse selfAuthResponse = authHttp.send(selfAuthRequest);
        if (selfAuthResponse.getStatusCode() == 200) {
            Map<String, Object> jsonResponse = (Map<String, Object>) JSON.deserializeUntyped(selfAuthResponse.getBody());
            selfToken = (String) jsonResponse.get('access_token');
        }
    }

    /*
    *********************************************************
    @Method Name    : setExternalToken()
    @author         : cavirjuyar.mejia.tech@bbva.com
    @description    : this method makes a rest call to external(central) organization to get authentication response
    @param          : none
    @return         : HttpResponse response of the authentication process
    ********************************************************
    */
    @SuppressWarnings('PMD.ApexSuggestUsingNamedCred')
    public static void setExternalToken() {
        HttpRequest externalAuthRequest = new HttpRequest();
        String externalAuthBody = 'grant_type=client_credentials'
        + '&client_id=' + EncodingUtil.urlEncode(connectionCredentials[0].Client_id__c, 'UTF-8')
        + '&client_secret=' + EncodingUtil.urlEncode(connectionCredentials[0].Secret_id__c, 'UTF-8');

        externalAuthRequest.setEndpoint(connectionDetails[0].Endpoint_url__c + '/services/oauth2/token');
        externalAuthRequest.setMethod('POST');
        externalAuthRequest.setHeader('Content-Type', 'application/x-www-form-urlencoded');
        externalAuthRequest.setBody(externalAuthBody);

        Http authHttp = new Http();
        HttpResponse externalAuthResponse = authHttp.send(externalAuthRequest);
        if (externalAuthResponse.getStatusCode() == 200) {
            Map<String, Object> jsonResponse = (Map<String, Object>) JSON.deserializeUntyped(externalAuthResponse.getBody());
            externalToken = (String) jsonResponse.get('access_token');
        }
    }

    /*
    *********************************************************
    @Method Name    : postKpi()
    @author         : cavirjuyar.mejia.tech@bbva.com
    @description    : this method makes the rest call to the external(central org) that post the
                    : extracted information and updates data on central org
    @param          : HttpResponse externalAuthResponse. authentication response from previous process
    @param          : String packagesListJson. json list of installed packages of this org
    @return         : void
    ********************************************************
    */
    @SuppressWarnings('PMD.ApexSuggestUsingNamedCred')
    public static void postKpi() {
        List<User> orgUsers = [select id, Name, Username, LastLoginDate, profile.Name, profile.userlicense.masterlabel, FederationIdentifier, email, CreatedDate, TimeZoneSidKey from user where isActive = true WITH SECURITY_ENFORCED order by username];
        Map<String, List<AggregateResult>> loginFrequencyMap = new Map<String, List<AggregateResult>>();
        //Grouped queries (more efficient)
        List<AggregateResult> x1DayLogins = [Select UserId, Status, count(Id) Total From LoginHistory where UserId IN :new Map<Id,SObject>(orgUsers).keyset() AND LoginTime >= LAST_N_DAYS:0 WITH SECURITY_ENFORCED Group By UserId, Status];
        List<AggregateResult> x3DayLogins = [Select UserId, Status, count(Id) Total From LoginHistory where UserId IN :new Map<Id,SObject>(orgUsers).keyset() AND LoginTime >= LAST_N_DAYS:2 WITH SECURITY_ENFORCED Group By UserId, Status];
        List<AggregateResult> x1WeekLogins = [Select UserId, Status, count(Id) Total From LoginHistory where UserId IN :new Map<Id,SObject>(orgUsers).keyset() AND LoginTime >= LAST_N_DAYS:6 WITH SECURITY_ENFORCED Group By UserId, Status];
        List<AggregateResult> x2WeekLogins = [Select UserId, Status, count(Id) Total From LoginHistory where UserId IN :new Map<Id,SObject>(orgUsers).keyset() AND LoginTime >= LAST_N_DAYS:13 WITH SECURITY_ENFORCED Group By UserId, Status];
        List<AggregateResult> x1MonthLogins = [Select UserId, Status, count(Id) Total From LoginHistory where UserId IN :new Map<Id,SObject>(orgUsers).keyset() AND LoginTime >= LAST_N_DAYS:29 WITH SECURITY_ENFORCED Group By UserId, Status];
        List<AggregateResult> x3MonthLogins = [Select UserId, Status, count(Id) Total From LoginHistory where UserId IN :new Map<Id,SObject>(orgUsers).keyset() AND LoginTime >= LAST_N_DAYS:89 WITH SECURITY_ENFORCED Group By UserId, Status];
        List<AggregateResult> x6MonthLogins = [Select UserId, Status, count(Id) Total From LoginHistory where UserId IN :new Map<Id,SObject>(orgUsers).keyset() AND LoginTime >= LAST_N_DAYS:179 WITH SECURITY_ENFORCED Group By UserId, Status];
        loginFrequencyMap.put('x1DayLogins', x1DayLogins);
        loginFrequencyMap.put('x3DayLogins', x3DayLogins);
        loginFrequencyMap.put('x1WeekLogins', x1WeekLogins);
        loginFrequencyMap.put('x2WeekLogins', x2WeekLogins);
        loginFrequencyMap.put('x1MonthLogins', x1MonthLogins);
        loginFrequencyMap.put('x3MonthLogins', x3MonthLogins);
        loginFrequencyMap.put('x6MonthLogins', x6MonthLogins);
        List<PermissionSetLicenseAssign> licensesAssignment = [SELECT PermissionSetLicense.MasterLabel, AssigneeId, Assignee.Username, Assignee.profile.Name, Assignee.profile.UserLicense.MasterLabel from PermissionSetLicenseAssign Where AssigneeId IN :new Map<Id,SObject>(orgUsers).keyset() WITH SECURITY_ENFORCED];
        setOrgInfo();

        HttpRequest sendRequest = new HttpRequest();

        sendRequest.setEndpoint(centralUrl + '/services/apexrest/eext/KPI_Receiver/');
        sendRequest.setHeader('Authorization', 'Bearer ' + externalToken); //NOSONAR
        sendRequest.setHeader('Content-Type','application/json');
        sendRequest.setBody('{"packagesListJson" : ' + JSON.serialize(packagesListJson) + ', "orgInfo": ' + JSON.serialize(orgInfo) + ', "users": ' + JSON.serialize(JSON.serialize(orgUsers)) + ', "licenseAssignments": ' + JSON.serialize(JSON.serialize(licensesAssignment)) + ', "loginHistory": ' + JSON.serialize(JSON.serialize(loginFrequencyMap)) + '}');
        sendRequest.setMethod('POST');
        sendRequest.setTimeout(120000);
        Http http = new Http();
        HTTPResponse sendResponse = http.send(sendRequest);
        system.debug(sendResponse.getBody());
    }

    /*
    *********************************************************
    @Method Name    : setPackages()
    @author         : cavirjuyar.mejia.tech@bbva.com
    @description    : this method queries installed package related data through tooling api.
    @param          : HttpResponse selfAuthResponse. Authentication data of current(self) org
    @return         : List<HttpResponse> both tooling responses
    ********************************************************
    */
    @SuppressWarnings('PMD.ApexSuggestUsingNamedCred')
    public static void setPackages() {

        HttpRequest packagesRequest = new HttpRequest();
        packagesRequest.setEndpoint(localUrl + '/services/data/v58.0/tooling/query/?q=' + EncodingUtil.urlEncode((String) ('SELECT Id, SubscriberPackageId, SubscriberPackage.NamespacePrefix, SubscriberPackage.Name, SubscriberPackageVersion.Id, SubscriberPackageVersion.Name, SubscriberPackageVersion.MajorVersion, SubscriberPackageVersion.MinorVersion, SubscriberPackageVersion.PatchVersion, SubscriberPackageVersion.BuildNumber FROM InstalledSubscriberPackage ORDER BY SubscriberPackageId'), 'UTF-8'));
        packagesRequest.setHeader('Authorization', 'Bearer ' + selfToken); //NOSONAR
        packagesRequest.setHeader('Content-Type', 'application/json');
        packagesRequest.setMethod('GET');
        Http packagesHttp = new Http();
        HttpResponse packagesResponse = packagesHttp.send(packagesRequest);
        if (packagesResponse.getStatusCode() == 200) {
            packagesListJson = packagesResponse.getBody();
        }
    }

    /*
    *********************************************************
    @Method Name    : postStatus()
    @author         : cavirjuyar.mejia.tech@bbva.com
    @description    : this methods makes a rest call to the external(central) org to post status info when
                    : something fails on this side of the process
    @param          : String resultJson. json information about the org and the different components of the process
    @return         : void
    ********************************************************
    */
    @SuppressWarnings('PMD.ApexSuggestUsingNamedCred')
    public static void postStatus(String resultJson) {

        setExternalToken();
        HttpRequest sendRequest = new HttpRequest();
        sendRequest.setEndpoint(centralUrl + '/services/apexrest/eext/KPI_Receiver_Status/');
        sendRequest.setHeader('Authorization', 'Bearer ' + externalToken); //NOSONAR
        sendRequest.setHeader('Content-Type','application/json');
        sendRequest.setBody('{"orgInfo":' + JSON.serialize(resultJson) + '}');
        sendRequest.setMethod('POST');

        Http http = new Http();
        HTTPResponse sendResponse = http.send(sendRequest);
        system.debug(sendResponse.getBody());
    }

    /*
    *********************************************************
    @Method Name    : setOrgInfo()
    @author         : cavirjuyar.mejia.tech@bbva.com
    @description    : this methods gets and formats information about the org and then set static variable
    @param          : none
    @return         : void
    ********************************************************
    */
    public static void setOrgInfo() {
        licenseInfo = database.query('Select Id, MasterLabel, Status, TotalLicenses, UsedLicenses From userlicense where MasterLabel = \'Salesforce\' Limit 1');
        Organization organizationInfo = database.query('SELECT Id From Organization');
        orgInfo = '{"orgId": "' + organizationInfo.Id + '", "orgUrl": "' + localUrl + '", "user": "' + connectionDetails[0].Local_user__c + '", "usedLicenses": ' + licenseInfo.usedLicenses + ', "totalLicenses": ' + licenseInfo.totalLicenses + '}';
    }
}