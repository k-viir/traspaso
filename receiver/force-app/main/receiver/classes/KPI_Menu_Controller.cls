public with sharing class KPI_Menu_Controller {
    @AuraEnabled
    public static List<sObject> getRecords(Date searchTerm, String orgName) {
        String query;
        if (searchTerm == null) {
            // Consulta inicial: los primeros 5 registros ordenados por fecha más reciente
            query = 'SELECT Id, Name, eext__Last_connection__c FROM eext__Organization__c WHERE NAME = :orgName ORDER BY eext__Last_connection__c DESC LIMIT 5';
        } else {
            // Consulta con fecha de búsqueda
            query = 'SELECT Id, Name, eext__Last_connection__c FROM eext__Organization__c WHERE eext__Last_connection__c = :searchTerm AND NAME = :orgName ORDER BY eext__Last_connection__c DESC LIMIT 5';
        }
        return Database.query(query);
    }
}
