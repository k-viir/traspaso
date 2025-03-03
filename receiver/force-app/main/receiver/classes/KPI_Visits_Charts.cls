public with sharing class KPI_Visits_Charts {

    @AuraEnabled
    public static List<String> getYears(){
        try {
            String query = 'Select  eext__Year__c  Years From eext__Visit_kpi__c  Group By eext__Year__c order by eext__Year__c asc';
            List<AggregateResult> years = database.query(String.escapeSingleQuotes(query));
            List<String> yearValues = new List<String>();
            for (AggregateResult eachResult: years) {
                yearValues.add((String) eachResult.get('Years'));
            }
            return yearValues;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled
    public static List<Wrappers.VisitChartWrapper> getMonthValues(String year, String month) {
        try {
            String query = 'Select Organization_url__c, Total_groups__c, Month_visited_groups__c From Visit_kpi__c where Year__c = :year and Month__c = :month  order by Organization_url__c asc';
            Set<String> urls = new Set<String>();
            List<Visit_kpi__c> kpis = database.query(String.escapeSingleQuotes(query));
            Map<String,Wrappers.VisitChartWrapper> values = new Map<String,Wrappers.VisitChartWrapper>();
            for (Visit_kpi__c eachKpi: kpis) {
                values.put(eachKpi.Organization_url__c, new Wrappers.VisitChartWrapper(null, (Integer)(eachKpi.Month_visited_groups__c / eachKpi.Total_groups__c * 100), (Integer) eachKpi.Month_visited_groups__c, null, (Integer) eachKpi.Total_groups__c, null));
            }
            urls = values.keyset();
            String secondQuery = 'Select Name name, Org_URL__c url from Organization__c where Org_URL__c in :urls Group By Name, Org_URL__c';
            List<AggregateResult> orgs = database.query(String.escapeSingleQuotes(secondQuery));
            for (AggregateResult eachResult: orgs) {
                values.get((String) eachResult.get('url')).name = (String) eachResult.get('name');

            }
            return values.values();
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled
    public static List<Wrappers.VisitChartWrapper> getQuarterValues(String year, String quarter) {
        try {
            String query = 'Select Organization_url__c, Total_groups__c, Quarter_visited_groups__c From Visit_kpi__c where Year__c = :year and Quarter__c = :quarter  order by Organization_url__c asc';
            Set<String> urls = new Set<String>();
            List<Visit_kpi__c> kpis = database.query(String.escapeSingleQuotes(query));
            Map<String,Wrappers.VisitChartWrapper> values = new Map<String,Wrappers.VisitChartWrapper>();
            for (Visit_kpi__c eachKpi: kpis) {
                values.put(eachKpi.Organization_url__c, new Wrappers.VisitChartWrapper(null, (Integer)(eachKpi.Quarter_visited_groups__c / eachKpi.Total_groups__c * 100), null, (Integer) eachKpi.Quarter_visited_groups__c, (Integer) eachKpi.Total_groups__c, null));
            }
            urls = values.keyset();
            String secondQuery = 'Select Name name, Org_URL__c url from Organization__c where Org_URL__c in :urls  Group By Name, Org_URL__c';
            List<AggregateResult> orgs = database.query(String.escapeSingleQuotes(secondQuery));
            for (AggregateResult eachResult: orgs) {
                values.get((String) eachResult.get('url')).name = (String) eachResult.get('name');

            }
            return values.values();
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled
    public static List<Wrappers.VisitChartWrapper> getRecordMonthlyValues(String recordId) {
        try {
            Organization__c org = [Select Id, Org_URL__c, Name, Organization_ID__c, CreatedDate From Organization__c where Id = :recordId WITH SECURITY_ENFORCED limit 1];
            String year = String.valueOf(org.CreatedDate.year());
            String orgUrl = org.Org_URL__c;
            String query = 'Select Month__c, Total_groups__c, Month_visited_groups__c From Visit_kpi__c where Month__c != null AND Month_visited_groups__c != null AND Year__c = :year and Organization_url__c = :orgUrl order by CreatedDate asc LIMIT 12';
            List<Visit_kpi__c> kpis = database.query(String.escapeSingleQuotes(query));
            List<Wrappers.VisitChartWrapper> values = new List<Wrappers.VisitChartWrapper>();
            for (Visit_kpi__c eachKpi: kpis) {
                values.add(new Wrappers.VisitChartWrapper(eachKpi.Month__c, (Integer)(eachKpi.Month_visited_groups__c / eachKpi.Total_groups__c * 100), (Integer) eachKpi.Month_visited_groups__c, null, (Integer) eachKpi.Total_groups__c, (Integer) org.CreatedDate.year()));
            }
            return values;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled
    public static Boolean getOrgNaming(String recordId) {
        try {
            // Get the Organization__c record
            Organization__c org = [SELECT Organization_ID__c FROM Organization__c WHERE Id = :recordId WITH SECURITY_ENFORCED LIMIT 1];
            // Get the Org_naming__mdt record
            Org_naming__mdt orgNaming = [SELECT Extract_visits_kpi__c FROM Org_naming__mdt WHERE Org_id__c = :org.Organization_ID__c WITH SECURITY_ENFORCED LIMIT 1];
            return orgNaming.Extract_visits_kpi__c;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
}