/*
*********************************************************************************************************
@Name     KPI_Extractor_Setup
@Author   cavirjuyar.mejia.tech@bbva.com
@Date     Created: 24/10/2023
@Group    Global Hub Components
@Description  Contains the main method to execute through anonymous console to initiate kpi extraction process.
*********************************************************************************************************
@Changes
Date              Author                                    Modification
24/10/2023        cavirjuyar.mejia.becas@bbva.com           Class creation.
*********************************************************************************************************
*/
@SuppressWarnings('PMD.AvoidGlobalModifier')
global with sharing class KPI_Extractor_Setup {

    global static void configure() {
    try {
        String cronExp = '0 0 23 * * ? *';
        String jobName = 'scheduled packages kpi extraction';

        KPI_Extractor_Scheduler job = new KPI_Extractor_Scheduler();
        System.enqueueJob(new KPI_Extractor_Service());
        System.schedule(jobName, cronExp, job);
    } catch (Exception e) {
        KPI_Extractor_Service.setConfigMetadata();
        KPI_Extractor_Service.setSelfToken();
        KPI_Extractor_Service.sendStatus(e.getMessage());
        Throw e;
    }

    }

}