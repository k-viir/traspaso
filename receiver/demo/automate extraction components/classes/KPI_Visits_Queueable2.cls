public with sharing class KPI_Visits_Queueable2 implements Queueable, Database.AllowsCallouts{
    List<String> queryMoreList;
    String externalAccessToken;
    String endpoint;
    String moreGroupsPending;
    Integer totalGroups;
    public KPI_Visits_Queueable2(String endpoint, String externalAccessToken, List<String> queryMoreList, String moreGroupsPending, Integer totalGroups) {
        this.queryMoreList = queryMoreList;
        this.externalAccessToken = externalAccessToken;
        this.endpoint = endpoint;
        this.moreGroupsPending = moreGroupsPending;
        this.totalGroups = totalGroups;
    }

    public void execute (QueueableContext context) {
        Http restHttp = new Http();
        HttpResponse response;
        HttpRequest queryRequest = new HttpRequest();
        Map<String, Object> bodyMap;
        List<Object> records;
        Map <String, Object> queryMap;

        // query existing record of kpi visits, if not present, create one with total groups, endpoint, month and year
        Integer queryYear =  Date.today().year();
        Integer queryMonth = Date.today().month() - 1;
        if (queryMonth == 0) {
            queryMonth = 12;
            queryYear = queryYear - 1;
        }
        List<Visit_kpi__c> kpi = [SELECT Id, Name, eext__Year__c, eext__Month__c, eext__Quarter__c, eext__Month_visited_groups__c, eext__Total_groups__c, eext__Quarter_visited_groups__c, eext__Organization_url__c  from Visit_kpi__c  where Organization_url__c = :endpoint AND Month__c = :getMonthLabel(queryMonth) AND Year__c = :String.valueOf(queryYear) LIMIT 1];

        if (kpi.size() > 0) {
            String childVisitsQuery = 'select dwp_acmh__Parent_Account__c from dwp_acmh__GBL_Account_Relationship__c where dwp_acmh__Child_Account__c in (SELECT dwp_kitv__account_id__c FROM dwp_kitv__Visit__c WHERE (dwp_kitv__visit_channel__c = \'01\' OR dwp_kitv__visit_location_desc__c != NULL ) AND dwp_kitv__visit_status_type__c IN (\'04\', \'05\', \'06\') AND CALENDAR_MONTH(dwp_kitv__visit_start_date__c) = ' + queryMonth + ' AND CALENDAR_YEAR(dwp_kitv__visit_start_date__c) = ' + queryYear + ')';
            String parentVisitsQuery = 'select dwp_acmh__Parent_Account__c from dwp_acmh__GBL_Account_Relationship__c where dwp_acmh__Parent_Account__c in (SELECT dwp_kitv__account_id__c FROM dwp_kitv__Visit__c WHERE (dwp_kitv__visit_channel__c = \'01\' OR dwp_kitv__visit_location_desc__c != NULL ) AND dwp_kitv__visit_status_type__c IN (\'04\', \'05\', \'06\') AND CALENDAR_MONTH(dwp_kitv__visit_start_date__c) = ' + queryMonth + ' AND CALENDAR_YEAR(dwp_kitv__visit_start_date__c) = ' + queryYear + ')';

            if (queryMoreList[0] != null) {
                queryRequest.setEndpoint(endpoint + queryMoreList[0]);
            } else {
                queryRequest.setEndpoint(endpoint + '/services/data/v58.0/query/?q=' + EncodingUtil.urlEncode((String) (childVisitsQuery), 'UTF-8'));
            }
            queryRequest.setHeader('Content-Type', 'application/json');
            queryRequest.setHeader('Authorization', 'Bearer ' + externalAccessToken);
            queryRequest.setMethod('GET');
            queryRequest.setTimeout(120000);
            List<Aux_data__c> visits = new List<Aux_data__c>();

            if (queryMoreList[0] == null || (queryMoreList[0] != null && !queryMoreList[0].contains('stop'))) {
                response = restHttp.send(queryRequest);
                queryMap = (Map<String,Object>) JSON.deserializeUntyped(response.getBody());
                visits = new List<Aux_data__c>();

                for (Object eachRecord : (List<Object>) queryMap.get('records')) {
                    Wrappers.VisitWrapper visit = (Wrappers.VisitWrapper) JSON.deserialize(JSON.serialize(eachRecord).replaceAll('dwp_acmh__Parent_Account__c', 'cibParent'), Wrappers.VisitWrapper.class);
                    visits.add(new Aux_data__c(Aux_field_1__c = visit.cibParent, Process_identifier__c = 'VisitData-' + endpoint));
                }

                if (((String) queryMap.get('nextRecordsUrl')) != null) {
                    queryMoreList[0] = (String) queryMap.get('nextRecordsUrl');
                } else {
                    queryMoreList[0] = 'stop';
                }
            }


            if (queryMoreList[1] != null) {
                queryRequest.setEndpoint(endpoint + queryMoreList[1]);
            } else {
                queryRequest.setEndpoint(endpoint + '/services/data/v58.0/query/?q=' + EncodingUtil.urlEncode((String) (parentVisitsQuery), 'UTF-8'));
            }

            queryRequest.setHeader('Content-Type', 'application/json');
            queryRequest.setHeader('Authorization', 'Bearer ' + externalAccessToken);
            queryRequest.setMethod('GET');
            queryRequest.setTimeout(120000);

            if (queryMoreList[1] == null || (queryMoreList[1] != null && !queryMoreList[1].contains('stop'))) {
                response = restHttp.send(queryRequest);
                queryMap = (Map<String,Object>) JSON.deserializeUntyped(response.getBody());

                for (Object eachRecord : (List<Object>) queryMap.get('records')) {
                    Wrappers.VisitWrapper visit = (Wrappers.VisitWrapper) JSON.deserialize(JSON.serialize(eachRecord).replaceAll('dwp_acmh__Parent_Account__c', 'cibParent'), Wrappers.VisitWrapper.class);
                    visits.add(new Aux_data__c(Aux_field_1__c = visit.cibParent, Process_identifier__c = 'VisitData-' + endpoint));
                }

                if (((String) queryMap.get('nextRecordsUrl')) != null) {
                    queryMoreList[1] = (String) queryMap.get('nextRecordsUrl');
                } else {
                    queryMoreList[1] = 'stop';
                }
            }

            insert visits;

            if ((queryMoreList[0] != null && !queryMoreList[0].contains('stop')) || (queryMoreList[1] != null && !queryMoreList[1].contains('stop'))) {
                System.enqueueJob(new KPI_Visits_Queueable2(endpoint, externalAccessToken, queryMoreList, moreGroupsPending, totalGroups));
            } else {
                Integer totalVisits = [SELECT Aux_field_1__c from Aux_data__c Where Process_identifier__c = :('VisitData-' + endpoint) Group By Aux_field_1__c].size();
                kpi[0].Month_visited_groups__c = totalVisits;
                update kpi[0];
                Database.executeBatch(new KPI_Cleaning_Batch('VisitData-' + endpoint));
            }
        } else {
            String groupTotalQuery;
            if (moreGroupsPending != null) {
                groupTotalQuery = 'SELECT dwp_acmh__Parent_Account__c groupId FROM dwp_acmh__GBL_Account_Relationship__c where dwp_acmh__Parent_Account__c > \'' + moreGroupsPending + '\' group by dwp_acmh__Parent_Account__c order by dwp_acmh__Parent_Account__c asc limit 2000 ';

            } else {
                groupTotalQuery = 'SELECT dwp_acmh__Parent_Account__c groupId FROM dwp_acmh__GBL_Account_Relationship__c group by dwp_acmh__Parent_Account__c order by dwp_acmh__Parent_Account__c asc limit 2000 ';
            }
            queryRequest.setEndpoint(endpoint + '/services/data/v58.0/query/?q=' + EncodingUtil.urlEncode((String) (groupTotalQuery), 'UTF-8'));
            queryRequest.setHeader('Content-Type', 'application/json');
            queryRequest.setHeader('Authorization', 'Bearer ' + externalAccessToken);
            queryRequest.setMethod('GET');
            queryRequest.setTimeout(120000);
            response = restHttp.send(queryRequest);
            queryMap = (Map<String,Object>) JSON.deserializeUntyped(response.getBody());
            Wrappers.CustomAggregateResult aggregateResult;
            records = (List<Object>) queryMap.get('records');
            totalGroups = totalGroups + records.size();
            if (records.size() == 2000) {
                moreGroupsPending = (String) ((Map<String, Object>) records[records.size() - 1]).get('groupId');
                System.enqueueJob(new KPI_Visits_Queueable2(endpoint, externalAccessToken, null, moreGroupsPending, totalGroups));
            } else {
                insert new Visit_kpi__c(Total_groups__c = totalGroups, Organization_url__c = endpoint, Year__c = String.valueOf(queryYear), Month__c = getMonthLabel(queryMonth));
                System.enqueueJob(new KPI_Visits_Queueable2(endpoint, externalAccessToken, new List<String>{null,null}, null, null));
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
