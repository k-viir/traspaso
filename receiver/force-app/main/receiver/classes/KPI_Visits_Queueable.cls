public with sharing class KPI_Visits_Queueable implements Queueable, Database.AllowsCallouts{
    String queryMore;
    String externalAccessToken;
    String endpoint;
    public KPI_Visits_Queueable(String endpoint, String externalAccessToken, String queryMore) {
        this.queryMore = queryMore;
        this.externalAccessToken = externalAccessToken;
        this.endpoint = endpoint;
    }

    public void execute (QueueableContext context) {
        if (endpoint.contains('bbvacibsales')) {
            System.enqueueJob(new KPI_Visits_Queueable2(endpoint, externalAccessToken, new List<String>{null,null}, null, 0));
            //TODO execute quarter queries
        } else {
            Http restHttp = new Http();
            HttpResponse response;
            HttpRequest queryRequest = new HttpRequest();
            Map<String, Object> bodyMap;
            List<Object> records;
            Map <String, Object> queryMap;

            // query existing record of kpi visits, if not present, create one with total groups, endpoint, month and year
            // Integer queryYear =  Date.today().year();
            // Integer queryMonth = Date.today().month() - 1;
            // if (queryMonth == 0) {
            //     queryMonth = 12;
            //     queryYear = queryYear - 1;
            // }

            Integer queryYear = 2025;
            // Integer queryMonth = 1;
            String queryQuarter = 'Q1';
            String queryQuarterMonths = '(1,2,3)';
            // can change this query depending on quarter value
            List<Visit_kpi__c> kpi = [SELECT Id, Name, eext__Year__c, eext__Month__c, eext__Quarter__c, eext__Month_visited_groups__c, eext__Total_groups__c, eext__Quarter_visited_groups__c, eext__Organization_url__c  from Visit_kpi__c  where Organization_url__c = :endpoint AND eext__Quarter__c = :queryQuarter AND Year__c = :String.valueOf(queryYear) LIMIT 1];
            if (kpi.size() > 0) {
                // can also change this query depending on quarter value
                String visitsQuery = 'SELECT dwp_kitv__account_id__r.Id, dwp_kitv__account_id__r.parentId FROM dwp_kitv__Visit__c WHERE (dwp_kitv__visit_channel__c = \'01\' OR dwp_kitv__visit_location_desc__c != NULL ) AND dwp_kitv__visit_status_type__c IN (\'04\', \'05\', \'06\') AND CALENDAR_MONTH(dwp_kitv__visit_start_date__c) in ' + queryQuarterMonths + ' AND CALENDAR_YEAR(dwp_kitv__visit_start_date__c) = ' + queryYear + ' AND (dwp_kitv__account_id__r.RecordType.Name LIKE \'%group%\' OR dwp_kitv__account_id__r.RecordType.Name LIKE \'%grupo%\' OR dwp_kitv__account_id__r.parent.RecordType.Name LIKE \'%group%\' OR dwp_kitv__account_id__r.parent.RecordType.Name LIKE \'%grupo%\')';

                if (queryMore != null) {
                    queryRequest.setEndpoint(endpoint + queryMore);
                } else {
                    queryRequest.setEndpoint(endpoint + '/services/data/v58.0/query/?q=' + EncodingUtil.urlEncode((String) (visitsQuery), 'UTF-8'));
                }

                queryRequest.setHeader('Content-Type', 'application/json');
                queryRequest.setHeader('Authorization', 'Bearer ' + externalAccessToken);
                queryRequest.setMethod('GET');
                queryRequest.setTimeout(120000);
                response = restHttp.send(queryRequest);
                queryMap = (Map<String,Object>) JSON.deserializeUntyped(response.getBody());
                List<Aux_data__c> visits = new List<Aux_data__c>();

                for (Object eachRecord : (List<Object>) queryMap.get('records')) {
                    Wrappers.VisitWrapper visit = (Wrappers.VisitWrapper) JSON.deserialize(JSON.serialize(eachRecord).replaceAll('dwp_kitv__account_id__r', 'vAccount'), Wrappers.VisitWrapper.class);
                    visits.add(new Aux_data__c(Aux_field_1__c = visit.vAccount.ParentId != null ? visit.vAccount.ParentId : visit.vAccount.Id, Process_identifier__c = 'VisitData-' + endpoint));
                }

                insert visits;

                if (((String) queryMap.get('nextRecordsUrl')) != null) {
                    System.enqueueJob(new KPI_Visits_Queueable(endpoint, externalAccessToken, (String) queryMap.get('nextRecordsUrl')));
                } else {
                    Integer totalVisits = [SELECT Aux_field_1__c from Aux_data__c Where Process_identifier__c = :('VisitData-' + endpoint) Group By Aux_field_1__c].size();
                    kpi[0].Quarter_visited_groups__c = totalVisits;
                    update kpi[0];
                    Database.executeBatch(new KPI_Cleaning_Batch('VisitData-' + endpoint));
                }
            } else {
                // get groups total, insert kpi and call again this queueable
                String groupTotalQuery = 'SELECT count(id) total FROM Account where RecordType.Name like \'%group%\' or recordtype.name like \'%grupo%\' ';
                queryRequest.setEndpoint(endpoint + '/services/data/v58.0/query/?q=' + EncodingUtil.urlEncode((String) (groupTotalQuery), 'UTF-8'));
                queryRequest.setHeader('Content-Type', 'application/json');
                queryRequest.setHeader('Authorization', 'Bearer ' + externalAccessToken);
                queryRequest.setMethod('GET');
                queryRequest.setTimeout(120000);
                response = restHttp.send(queryRequest);
                queryMap = (Map<String,Object>) JSON.deserializeUntyped(response.getBody());
                Wrappers.CustomAggregateResult aggregateResult;
                for (Object eachRecord : (List<Object>) queryMap.get('records')) {
                    aggregateResult = (Wrappers.CustomAggregateResult) JSON.deserialize(JSON.serialize(eachRecord), Wrappers.CustomAggregateResult.class);
                }

                insert new Visit_kpi__c(Total_groups__c = aggregateResult.total, Organization_url__c = endpoint, Year__c = String.valueOf(queryYear), Quarter__c = queryQuarter);

                System.enqueueJob(new KPI_Visits_Queueable(endpoint, externalAccessToken, null));
            }
        }
    }

    public String getMonthLabel(Integer monthValue) {
        String monthLabel;
        switch on monthValue {
            when 1 {
            monthLabel = System.Label.VisitKpi_January;
            }
            when 2 {
            monthLabel = System.Label.VisitKpi_February;
            }
            when 3 {
            monthLabel = System.Label.VisitKpi_March;
            }
            when 4 {
            monthLabel = System.Label.VisitKpi_April;
            }
            when 5 {
            monthLabel = System.Label.VisitKpi_May;
            }
            when 6 {
            monthLabel = System.Label.VisitKpi_June;
            }
            when 7 {
            monthLabel = System.Label.VisitKpi_July;
            }
            when 8 {
            monthLabel = System.Label.VisitKpi_August;
            }
            when 9 {
            monthLabel = System.Label.VisitKpi_September;
            }
            when 10 {
            monthLabel = System.Label.VisitKpi_October;
            }
            when 11 {
            monthLabel = System.Label.VisitKpi_November;
            }
            when 12 {
            monthLabel = System.Label.VisitKpi_December;
            }
        }
        return monthLabel;
    }

}
