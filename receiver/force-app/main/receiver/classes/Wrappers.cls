@SuppressWarnings('PMD.ExcessivePublicCount')
public with sharing class Wrappers {
    public class CustomAggregateResult {
        public String userId;
        public String status;
        public Integer total;
        public String groupId;
    }

    public class VisitWrapper {
        public AccountWrapper vAccount;
        public String cibParent;
    }

    public class AccountWrapper {
        public String ParentId;
        public String Id;
    }

    public class RecordTypeWrapper {
        public String Name;
    }

    public class VisitChartWrapper {
        @AuraEnabled
        public String name;
        @AuraEnabled
        public Integer percentageValue;
        @AuraEnabled
        public Integer monthValue;
        @AuraEnabled
        public Integer quarterValue;
        @AuraEnabled
        public Integer groupsTotal;
        @AuraEnabled
        public Integer year;

        public VisitChartWrapper(String name, Integer percentageValue, Integer monthValue, Integer quarterValue, Integer groupsTotal, Integer year) {
            this.name = name;
            this.percentageValue = percentageValue;
            this.monthValue = monthValue;
            this.quarterValue = quarterValue;
            this.groupsTotal = groupsTotal;
            this.year = year;
        }
    }




}