@isTest
public with sharing class KPI_CalloutMock implements HttpCalloutMock {
    public HTTPResponse respond(HTTPRequest req) {
        HttpResponse response = new HttpResponse();
        String authResponse = '{\"access_token\": \"hidden.hidden\",\"signature\": \"+/I3dolk07Dk=\",\"instance_url\": \"https://bbvacs--compglobal.sandbox.my.salesforce.com\",\"id\": \"https://test.salesforce.com/id/asdf\",\"token_type\": \"Bearer\",\"issued_at\": \"1233\"}';
        String toolingResponse = '{\"size\":2,\"totalSize\":2,\"done\":true,\"queryLocator\":null,\"entityTypeName\":\"InstalledSubscriberPackage\",\"records\":[{\"attributes\":{\"type\":\"InstalledSubscriberPackage\",\"url\":\"/services/data/v58.0/tooling/sobjects/InstalledSubscriberPackage/0A31X000000OQw2SAG\"},\"Id\":\"0A31X000000OQw2SAG\",\"SubscriberPackageId\":\"03306000000shXHAAY\",\"SubscriberPackage\":{\"attributes\":{\"type\":\"SubscriberPackage\",\"url\":\"/services/data/v58.0/tooling/sobjects/SubscriberPackage/03306000000shXHAAY\"},\"NamespacePrefix\":\"kvir\",\"Name\":\"KPI Extractor ConnApp\"},\"SubscriberPackageVersion\":{\"attributes\":{\"type\":\"SubscriberPackageVersion\",\"url\":\"/services/data/v58.0/tooling/sobjects/SubscriberPackageVersion/04t06000000owDPAAY\"},\"Id\":\"04t06000000owDPAAY\",\"Name\":\"alphaOne\",\"MajorVersion\":1,\"MinorVersion\":0,\"PatchVersion\":0,\"BuildNumber\":2}},{\"attributes\":{\"type\":\"InstalledSubscriberPackage\",\"url\":\"/services/data/v58.0/tooling/sobjects/InstalledSubscriberPackage/0A31X000000OPMXSA4\"},\"Id\":\"0A31X000000OPMXSA4\",\"SubscriberPackageId\":\"12345678912345kQAW\",\"SubscriberPackage\":{\"attributes\":{\"type\":\"SubscriberPackage\",\"url\":\"/services/data/v58.0/tooling/sobjects/SubscriberPackage/12345678912345kQAW\"},\"NamespacePrefix\":\"fprd\",\"Name\":\"fprd\"},\"SubscriberPackageVersion\":{\"attributes\":{\"type\":\"SubscriberPackageVersion\",\"url\":\"/services/data/v58.0/tooling/sobjects/SubscriberPackageVersion/04t1v000001YZk3AAG\"},\"Id\":\"04t1v000001YZk3AAG\",\"Name\":\"T-Regex\",\"MajorVersion\":1,\"MinorVersion\":43,\"PatchVersion\":0,\"BuildNumber\":2}}]}';
        String toolingResponseSecond = '{\"size\":2,\"totalSize\":2,\"done\":true,\"queryLocator\":null,\"entityTypeName\":\"PackageInstallRequest\",\"records\":[{\"attributes\":{\"type\":\"PackageInstallRequest\",\"url\":\"/services/data/v58.0/tooling/sobjects/PackageInstallRequest/0Hf1X0000008ACVSA2\"},\"CreatedDate\":\"2024-02-12T17:17:27.000+0000\",\"SubscriberPackageVersionKey\":\"04t06000000ovlk\",\"PackageInstallSource\":null,\"LastModifiedBy\":{\"attributes\":{\"type\":\"User\",\"url\":\"/services/data/v58.0/tooling/sobjects/User/0051X00000FOkjwQAD\"},\"FirstName\":null}},{\"attributes\":{\"type\":\"PackageInstallRequest\",\"url\":\"/services/data/v58.0/tooling/sobjects/PackageInstallRequest/0Hf1X0000008ADnSAM\"},\"CreatedDate\":\"2024-02-15T05:32:02.000+0000\",\"SubscriberPackageVersionKey\":\"04t06000000owDP\",\"PackageInstallSource\":null,\"LastModifiedBy\":{\"attributes\":{\"type\":\"User\",\"url\":\"/services/data/v58.0/tooling/sobjects/User/0051X00000FOkjwQAD\"},\"FirstName\":null}}]}';

        response.setHeader('Content-Type', 'application/json');
        response.setStatusCode(200);

        if (req.getEndpoint().contains('services/oauth2/token')) {
            response.setBody(authResponse);
        }
        if (req.getEndpoint().contains('FROM InstalledSubscriberPackage')) {
            response.setBody(toolingResponse);
        }
        if (req.getEndpoint().contains('FROM PackageInstallRequest')) {
            response.setBody(toolingResponseSecond);
        }
        if (req.getEndpoint().contains('services/apexrest/eext/KPI_Receiver')) {
            response.setBody('Everything OK');
        }
        if (req.getEndpoint().contains('services/apexrest/eext/KPI_Receiver_status')) {
            response.setBody('OKKKKKKKK');
        }
        if (req.getEndpoint().contains('services/apexrest/eext/KPI_Receiver_Extension')) {
            response.setBody('OK');
        }

        return response;
    }
}