public with sharing class KPI_Cleaning_Batch implements Database.Batchable<sObject> {
    String identifier;
    public KPI_Cleaning_Batch(String identifier) {
        this.identifier = identifier;
    }

    public List<sObject> start(Database.BatchableContext context) {
        List<sObject> deleteData = [select id from Aux_data__c where Process_identifier__c = :identifier];
        return deleteData;
    }

    public void execute(Database.BatchableContext context, List<sObject> scope) {
        delete scope;
    }

    public void finish(Database.BatchableContext context) {
        // Implement any post-processing logic here
    }

}