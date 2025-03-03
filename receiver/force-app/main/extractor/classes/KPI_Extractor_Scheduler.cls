/*
*********************************************************************************************************
@Name     KPI_Extractor_Scheduler
@Author   cavirjuyar.mejia.becas@bbva.com
@Date     Created: 25/10/2023
@Group    Global Hub Components
@Description This is the scheduler class that will be programmed to send packages information and status.
*********************************************************************************************************
@Changes
Date              Author                                    Modification
25/10/2023        cavirjuyar.mejia.becas@bbva.com           Class creation.
*********************************************************************************************************
*/
public with sharing class KPI_Extractor_Scheduler implements Schedulable {
    public void execute(SchedulableContext context) {
        System.enqueueJob(new KPI_Extractor_Service());
    }
}