public with sharing class KPI_Receiver_Scheduler implements Schedulable {
    /*
    *********************************************************
    @Method Name    : execute()
    @author         : cavirjuyar.mejia.tech@bbva.com
    @description    : this method executes periodically to extract visits
                    : data from the external orgs
    @param          : SchedulableContext context. Inherited
    @return         :
    ********************************************************
    */
    public void execute(SchedulableContext context) {
        try {
            // Your logic to extract visits data from the external orgs
            Id batchJobId = Database.executeBatch(new KPI_Receiver_Batch(), 1);
        } catch (Exception e) {
            // Handle the exception
            System.debug('An error occurred: ' + e.getMessage());
        }
    }
}