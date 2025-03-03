public with sharing class KPI_Chart_Controller {
    /*
    *********************************************************
    @Method Name    : getChartData()
    @author         : cavirjuyar.mejia.tech@bbva.com
    @description    : gets and process the data neccesary for creating
                      wanted chart
    @param          : targetOrgRecordId, a String that represents the
                      context record id of the Organization__c object
    @return         : ChartData, inner class enabled for aura
    ********************************************************
    */
    @AuraEnabled
    public static ChartData getChartData(String targetOrgRecordId){
        try {
            List<Organization_version__c> targetOrgVersions = [Select Id, Package_version__r.Version_differences__c, Installed_organization__c, Package_version__r.Version_number__c, Package_version__r.Package__r.Name, Newest_package_version__r.Version_number__c  From Organization_version__c where Installed_organization__c =:targetOrgRecordId WITH SECURITY_ENFORCED];
            ChartData returnChartData = new ChartData();

            for (Organization_version__c eachVpp : targetOrgVersions) {
                returnChartData.packageNames.add(eachVpp.Package_version__r.Package__r.Name);
                returnChartData.installedVersions.add(eachVpp.Package_version__r.Version_number__c);
                returnChartData.latestVersions.add(eachVpp.Newest_package_version__r.Version_number__c );
                returnChartData.differences.add(eachVpp.Package_version__r.Version_differences__c != null ? eachVpp.Package_version__r.Version_differences__c : '');
            }
            return returnChartData;
        } catch (Exception e) {
            return null;
        }
    }

    /*
    *********************************************************
    @Class Name     : ChartData
    @author         : cavirjuyar.mejia.tech@bbva.com
    @description    : wrapper to pass information to aura component
    @property       : List<String> packagesNames. Name of each package,
                      represented on x axis of the chart
    @property       : List<String> installedVersions. In the chart,
                      represents the installed packages dataset
    @property       : List<String> latestVersions. In the chart,
                      represents the latest available package versions
                      dataset
    @property       : List<String> differences. In the chart,
                      represents the features and bugfixes differences
                      of each package
    ********************************************************
    */
    @TestVisible
    class ChartData {
    @AuraEnabled
    public List<String> packageNames = new List<String>();
    @AuraEnabled
    public List<String> installedVersions = new List<String>();
    @AuraEnabled
    public List<String> latestVersions = new List<String>();
    @AuraEnabled
    public List<String> differences  = new List<String>();
    }
}