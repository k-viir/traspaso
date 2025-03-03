/*
*********************************************************************************************************
@Name     KPI_Receiver_Extension
@Author   cavirjuyar.mejia.tech@bbva.com
@Date     Created: 22/08/2024
@Group    Global Hub Components
@Description This class handles the extraction process when batch is needed due to massive records extraction
*********************************************************************************************************
@Changes
Date              Author                                    Modification
22/08/2024        cavirjuyar.mejia.tech@bbva.com           Class creation.
*********************************************************************************************************
*/

public with sharing class KPI_Extractor_Extension {
    public static String referenceRecordId;

    /*
    *********************************************************
    @Method Name    : mainProcess
    @author         : cavirjuyar.mejia.tech@bbva.com
    @description    : this main flow to execute, first sets configuration then sends org info, packages info and starts users batch
    @return         : result, a string that describes result
    ********************************************************
    */
    public static String mainProcess() {
        try {
            KPI_Extractor_Service.setSelfToken();
            KPI_Extractor_Service.setExternalToken();
            KPI_Extractor_Service.setOrgInfo();
            sendOrgInfo();
            if (referenceRecordId != null) {
                sendPackagesInfo();
                startUsersBatch();
            }
            return 'OK';
        } catch(Exception e) {
            sendError('Error during main process: ' + e.getMessage() + ', ' + e.getStackTraceString());
            return 'KO';
        }
    }
    /*
    *********************************************************
    @Method Name    : sendOrgInfo
    @author         : cavirjuyar.mejia.tech@bbva.com
    @description    : gathers org info and sends it to the central organization
    @return         : none
    ********************************************************
    */
    public static void sendOrgInfo() {
        String body = '{"action" : ' + '"init"' + ', "content": ' + JSON.serialize(KPI_Extractor_Service.orgInfo) + ', "referenceRecordId": ' + null + '}';
        restCall(body, true);
    }
    /*

    *********************************************************
    @Method Name    : sendPackagesInfo
    @author         : cavirjuyar.mejia.tech@bbva.com
    @description    : gathers packages and sends it to the central organization
    @return         : none
    ********************************************************
    */
    public static void sendPackagesInfo() {
        KPI_Extractor_Service.setPackages();
        String body = '{"action" : ' + '"packages"' + ', "content": ' + JSON.serialize(KPI_Extractor_Service.packagesListJson) + ', "referenceRecordId": ' + referenceRecordId + '}';
        restCall(body, false);
    }

    /*
    *********************************************************
    @Method Name    : sendOrstartUsersBatchgInfo
    @author         : cavirjuyar.mejia.tech@bbva.com
    @description    : initiates batch process to gather and send users info
    @return         : none
    ********************************************************
    */
    public static void startUsersBatch() {
        Database.executeBatch(new KPI_Extractor_Batch(referenceRecordId), 3000);
    }

    /*
    *********************************************************
    @Method Name    : sendError
    @author         : cavirjuyar.mejia.tech@bbva.com
    @params         : errorMessage. The error message description
    @description    : when process fail, it sends error details to the central organization
    @return         : none
    ********************************************************
    */
    public static void sendError(String errorMessage) {
        if (KPI_Extractor_Service.externalToken != null && referenceRecordId != null) {
            String body = '{"action" : ' + '"error"' + ', "content": ' + JSON.serialize(errorMessage) + ', "referenceRecordId": ' + referenceRecordId + '}';
            restCall(body, false);
        }
    }

    /*
    *********************************************************
    @Method Name    : restCall
    @author         : cavirjuyar.mejia.tech@bbva.com
    @description    : method called to simplify callout execution
    @params         : body. The body of the request
    @return         : none
    ********************************************************
    */
    @SuppressWarnings('PMD.ApexSuggestUsingNamedCred')
    public static void restCall (String body, Boolean isInit) {
        HttpRequest sendRequest = new HttpRequest();
        sendRequest.setEndpoint(KPI_Extractor_Service.centralUrl + '/services/apexrest/eext/KPI_Receiver_Extension/');
        sendRequest.setHeader('Authorization', 'Bearer ' + KPI_Extractor_Service.externalToken); //NOSONAR
        sendRequest.setHeader('Content-Type','application/json');
        sendRequest.setBody(body);
        sendRequest.setMethod('POST');
        sendRequest.setTimeout(120000);
        Http http = new Http();
        HttpResponse res = http.send(sendRequest);
        if (isInit && res.getStatusCode() == 200) {
            referenceRecordId = res.getBody();
        }
    }
}