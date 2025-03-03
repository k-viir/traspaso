@SuppressWarnings('PMD.StdCyclomaticComplexity,PMD.CognitiveComplexity,PMD.CyclomaticComplexity,PMD.NcssMethodCount')
/*
*********************************************************************************************************
@Name     KPI_SecondChart
@Author   cavirjuyar.mejia.tech@bbva.com
@Date     Created: 24/10/2023
@Group    Global Hub Components
@Description This class contains the main methods to extract neccessary information for representation in
            chart components.
*********************************************************************************************************
@Changes
Date              Author                                    Modification
24/10/2023        cavirjuyar.mejia.becas@bbva.com           Class creation.
*********************************************************************************************************
*/
public with sharing class KPI_SecondChart {

    /*
    *********************************************************
    @Method Name    : getChartData()
    @author         : cavirjuyar.mejia.tech@bbva.com
    @description    : this method gets and formats neccessary data for painting chart of users
                    : last logins
    @param          : String organizationRecordId. context record Id of Organization__c
    @return         : ChartData wrapped data enabled for aura access
    ********************************************************
    */
    @AuraEnabled
    public static ChartData getChartData(String organizationRecordId){
        try {
            ChartData data = new ChartData();
            List<Asleep_user__c> orgUsers = [Select Id, Last_login__c, CreatedDate From Asleep_user__c where User_Organization__c =:organizationRecordId AND eext__License__c = 'Salesforce' WITH SECURITY_ENFORCED];
            Date referenceDate = orgUsers[0].createdDate.date();
            for (Asleep_user__c eachUser : orgUsers) {
                // 1day
                if (eachUser.Last_login__c < referenceDate) {
                    data.lastLoginCountValues[0]++;
                }
                //3day
                if(eachUser.Last_login__c < referenceDate.addDays(-2)) {
                    data.lastLoginCountValues[1]++;
                }
                //1week
                if(eachUser.Last_login__c < referenceDate.addDays(-6)) {
                    data.lastLoginCountValues[2]++;
                }
                //2weeks
                if(eachUser.Last_login__c < referenceDate.addDays(-13)) {
                    data.lastLoginCountValues[3]++;
                }
                //1month
                if(eachUser.Last_login__c < referenceDate.addDays(-29)) {
                    data.lastLoginCountValues[4]++;
                }
                //3months
                if(eachUser.Last_login__c < referenceDate.addDays(-89)) {
                    data.lastLoginCountValues[5]++;
                }
                //6months
                if(eachUser.Last_login__c < referenceDate.addDays(-179)) {
                    data.lastLoginCountValues[6]++;
                }
                //1year
                if(eachUser.Last_login__c < referenceDate.addDays(-364)) {
                    data.lastLoginCountValues[7]++;
                }
            }
            return data;
        } catch (Exception e) {
            return new ChartData();
        }
    }
    /*
    *********************************************************
    @Method Name    : getFreqChartData()
    @author         : cavirjuyar.mejia.tech@bbva.com
    @description    : this method makes a query to extract information about each org user
                    : login frequency data and formats it to be painted on an aura component
    @param          : String orgUserId. Record of the context orgUser
    @return         : FreqChartData frequency data wrapper for chart
    ********************************************************
    */
    @AuraEnabled
    public static FreqChartData getFreqChartData(String orgUserId) {
        FreqChartData freqData = new FreqChartData();
        Asleep_user__c contextOrgUser = [Select Full_name__c, X1_day_login_count__c, X3_day_login_count__c, X1_week_login_count__c, X2_weeks_login_count__c, X1_month_login_count__c From Asleep_user__c Where Id =:orgUserId WITH SECURITY_ENFORCED];
        freqData.loginFreqValues[0] = (Integer) (contextOrgUser.X1_day_login_count__c != null ? contextOrgUser.X1_day_login_count__c : 0);
        freqData.loginFreqValues[1] = (Integer) (contextOrgUser.X3_day_login_count__c != null ? contextOrgUser.X3_day_login_count__c : 0);
        freqData.loginFreqValues[2] = (Integer) (contextOrgUser.X1_week_login_count__c != null ? contextOrgUser.X1_week_login_count__c : 0);
        freqData.loginFreqValues[3] = (Integer) (contextOrgUser.X2_weeks_login_count__c != null ? contextOrgUser.X2_weeks_login_count__c : 0);
        freqData.loginFreqValues[4] = (Integer) (contextOrgUser.X1_month_login_count__c != null ? contextOrgUser.X1_month_login_count__c : 0);
        return freqData;
    }

    /*
    *********************************************************
    @Method Name    : getOrgFreqChartData()
    @author         : cavirjuyar.mejia.tech@bbva.com
    @description    : this method makes a query to extract information about the organization users
                    : login frequency data and formats it to be painted on an aura component
    @param          : String organizationRecordId. Record of the context organization
    @return         : OrgFreqChartData frequency data wrapper for chart
    ********************************************************
    */
    @AuraEnabled
    public static OrgFreqChartData getOrgFreqChartData(String organizationRecordId) {
        OrgFreqChartData freqData = new OrgFreqChartData();
        List<Asleep_user__c> checkList = [select Id From Asleep_user__c Where User_Organization__c =:organizationRecordId AND X1_day_activity__c != null AND X3_day_activity__c != null AND X1_week_activity__c != null AND X2_week_activity__c != null AND X1_month_activity__c != null WITH SECURITY_ENFORCED limit 1];
        if (checkList.size() > 0) {
            fillData(freqData, organizationRecordId);
        } else {
            fillDataLegacy(freqData, organizationRecordId);
        }
        return freqData;
    }

    /*
    *********************************************************
    @Method Name    : fillDataLegacy()
    @author         : cavirjuyar.mejia.tech@bbva.com
    @description    : legacy process to execute when filling login data
    @param          : OrgFreqChartData freqData, String organizationRecordId
    @return         : void
    ********************************************************
    */
    public static void fillDataLegacy(OrgFreqChartData freqData, String organizationRecordId) {
        List<Asleep_user__c> orgUsers = [Select Full_name__c, X1_day_login_count__c, X3_day_login_count__c, X1_week_login_count__c, X2_weeks_login_count__c, X1_month_login_count__c From Asleep_user__c Where User_organization__c =:organizationRecordId AND eext__License__c = 'Salesforce' WITH SECURITY_ENFORCED];
        for (Asleep_user__c eachUser : orgUsers) {

            if (eachUser.X1_day_login_count__c != null && eachUser.X1_day_login_count__c < 1) {
                freqData.lowFreqValues[0]++;
            }
            if (eachUser.X1_day_login_count__c >= 1 && eachUser.X1_day_login_count__c < 2) {
                freqData.mediumFreqValues[0]++;
            }
            if (eachUser.X1_day_login_count__c >= 2) {
                freqData.highFreqValues[0]++;
            }
            if (eachUser.X3_day_login_count__c != null && eachUser.X3_day_login_count__c <= 1) {
                freqData.lowFreqValues[1]++;
            }
            if (eachUser.X3_day_login_count__c >= 2 && eachUser.X3_day_login_count__c <= 3) {
                freqData.mediumFreqValues[1]++;
            }
            if (eachUser.X3_day_login_count__c > 3) {
                freqData.highFreqValues[1]++;
            }
            if (eachUser.X1_week_login_count__c != null && eachUser.X1_week_login_count__c <= 2) {
                freqData.lowFreqValues[2]++;
            }
            if (eachUser.X1_week_login_count__c >= 3 && eachUser.X1_week_login_count__c <= 5) {
                freqData.mediumFreqValues[2]++;
            }
            if (eachUser.X1_week_login_count__c > 5) {
                freqData.highFreqValues[2]++;
            }
            if (eachUser.X2_weeks_login_count__c != null && eachUser.X2_weeks_login_count__c <= 4) {
                freqData.lowFreqValues[3]++;
            }
            if (eachUser.X2_weeks_login_count__c >= 5 && eachUser.X2_weeks_login_count__c <= 10) {
                freqData.mediumFreqValues[3]++;
            }
            if (eachUser.X2_weeks_login_count__c > 10) {
                freqData.highFreqValues[3]++;
            }
            if (eachUser.X1_month_login_count__c != null && eachUser.X1_month_login_count__c <= 8) {
                freqData.lowFreqValues[4]++;
            }
            if (eachUser.X1_month_login_count__c >= 9 && eachUser.X1_month_login_count__c <= 20) {
                freqData.mediumFreqValues[4]++;
            }
            if (eachUser.X1_month_login_count__c > 20) {
                freqData.highFreqValues[4]++;
            }

        }
    }

    /*
    *********************************************************
    @Method Name    : fillData()
    @author         : cavirjuyar.mejia.tech@bbva.com
    @description    : process to execute when filling login data
    @param          : OrgFreqChartData freqData, String organizationRecordId
    @return         : void
    ********************************************************
    */

    public static void fillData(OrgFreqChartData freqData, String organizationRecordId) {
        List<Asleep_user__c> orgUsers = [Select Full_name__c, X1_day_activity__c, X3_day_activity__c, X1_week_activity__c, X2_week_activity__c, X1_month_activity__c From Asleep_user__c Where User_organization__c =:organizationRecordId AND eext__License__c = 'Salesforce' AND eext__Last_login__c != null WITH SECURITY_ENFORCED];
        for (Asleep_user__c eachUser : orgUsers) {
            //filling null freq list
            if (eachUser.X1_day_activity__c != null && eachUser.X1_day_activity__c.equalsIgnoreCase('No activity')) {
                freqData.nullFreqValues[0]++;
            }

            if (eachUser.X1_day_activity__c != null && eachUser.X1_day_activity__c.equalsIgnoreCase('Low activity')) {
                freqData.lowFreqValues[0]++;
            }
            if (eachUser.X1_day_activity__c != null && eachUser.X1_day_activity__c.equalsIgnoreCase('Medium activity')) {
                freqData.mediumFreqValues[0]++;
            }
            if (eachUser.X1_day_activity__c != null && eachUser.X1_day_activity__c.equalsIgnoreCase('High activity')) {
                freqData.highFreqValues[0]++;
            }//filling null freq list
            if (eachUser.X3_day_activity__c != null && eachUser.X3_day_activity__c.equalsIgnoreCase('No activity')) {
                freqData.nullFreqValues[1]++;
            }

            if (eachUser.X3_day_activity__c != null && eachUser.X3_day_activity__c.equalsIgnoreCase('Low activity')) {
                freqData.lowFreqValues[1]++;
            }
            if (eachUser.X3_day_activity__c != null && eachUser.X3_day_activity__c.equalsIgnoreCase('Medium activity')) {
                freqData.mediumFreqValues[1]++;
            }
            if (eachUser.X3_day_activity__c != null && eachUser.X3_day_activity__c.equalsIgnoreCase('High activity')) {
                freqData.highFreqValues[1]++;
            }//filling null freq list
            if (eachUser.X1_week_activity__c != null && eachUser.X1_week_activity__c.equalsIgnoreCase('No activity')) {
                freqData.nullFreqValues[2]++;
            }

            if (eachUser.X1_week_activity__c != null && eachUser.X1_week_activity__c.equalsIgnoreCase('Low activity')) {
                freqData.lowFreqValues[2]++;
            }
            if (eachUser.X1_week_activity__c != null && eachUser.X1_week_activity__c.equalsIgnoreCase('Medium activity')) {
                freqData.mediumFreqValues[2]++;
            }
            if (eachUser.X1_week_activity__c != null && eachUser.X1_week_activity__c.equalsIgnoreCase('High activity')) {
                freqData.highFreqValues[2]++;
            }//filling null freq list
            if (eachUser.X2_week_activity__c != null && eachUser.X2_week_activity__c.equalsIgnoreCase('No activity')) {
                freqData.nullFreqValues[3]++;
            }

            if (eachUser.X2_week_activity__c != null && eachUser.X2_week_activity__c.equalsIgnoreCase('Low activity')) {
                freqData.lowFreqValues[3]++;
            }
            if (eachUser.X2_week_activity__c != null && eachUser.X2_week_activity__c.equalsIgnoreCase('Medium activity')) {
                freqData.mediumFreqValues[3]++;
            }
            if (eachUser.X2_week_activity__c != null && eachUser.X2_week_activity__c.equalsIgnoreCase('High activity')) {
                freqData.highFreqValues[3]++;
            }//filling null freq list
            if (eachUser.X1_month_activity__c != null && eachUser.X1_month_activity__c.equalsIgnoreCase('No activity')) {
                freqData.nullFreqValues[4]++;
            }

            if (eachUser.X1_month_activity__c != null && eachUser.X1_month_activity__c.equalsIgnoreCase('Low activity')) {
                freqData.lowFreqValues[4]++;
            }
            if (eachUser.X1_month_activity__c != null && eachUser.X1_month_activity__c.equalsIgnoreCase('Medium activity')) {
                freqData.mediumFreqValues[4]++;
            }
            if (eachUser.X1_month_activity__c != null && eachUser.X1_month_activity__c.equalsIgnoreCase('High activity')) {
                freqData.highFreqValues[4]++;
            }
        }
    }

    /*
    *********************************************************
    @Method Name    : getReportId()
    @author         : cavirjuyar.mejia.tech@bbva.com
    @description    : this method retrieves the id of the dynamic report for its use on the
                    : navigation component
    @param          : String whatReport. decides what report to use, users last login or activity
    @return         : String reportId
    ********************************************************
    */
    @AuraEnabled
    public static String getReportId (String whatReport) {
        String reportId;
        try {
            String reportDevName;
            switch on whatReport {
                when 'lastLogin' {
                    reportDevName = 'Users_dynamic_lastLogin0GW';
                }
                when 'loginActivity' {
                    reportDevName = 'Users_dynamic_activity0GW';
                }
                when 'profiles' {
                    reportDevName = 'Users_dynamic_profiles0GW';
                }
                when 'geography' {
                    reportDevName = 'Users_dynamic_geography0GW';
                }
                when 'segmentation' {
                    reportDevName = 'Users_dynamic_segmentation0GW';
                }
            }
            reportId = [Select Id From Report Where DeveloperName =:reportDevName WITH SECURITY_ENFORCED Limit 1].Id;
            return reportId;
        } catch (Exception e) {
            return reportId;
        }
    }
    /*
    *********************************************************
    @Method Name    : getReferenceDate()
    @author         : cavirjuyar.mejia.tech@bbva.com
    @description    : this method retrieves a date that is used to get relative filters on the component
    @param          : String organizationRecordId. Context record Id
    @return         : String referenceDate
    ********************************************************
    */
    @AuraEnabled
    public static Date getReferenceDate(String organizationRecordId) {
        try {
            Date referenceDate = [Select Id, CreatedDate From Organization__c Where Id =:organizationRecordId WITH SECURITY_ENFORCED LIMIT 1].CreatedDate.date();
            return referenceDate;
        } catch (Exception e) {
            return null;
        }
    }

    /*
    *********************************************************
    @Method Name    : getProfilesChartData()
    @author         : cavirjuyar.mejia.tech@bbva.com
    @description    : this method retrieves formatted data to be painted on the profiles chart
    @param          : String organizationRecordId. Context record Id
    @param          : String filterValue. value to filter users by state, asleep, active or never logged in
    @return         : ProfilesChartData wrapper
    ********************************************************
    */
    @AuraEnabled
    public static ProfilesChartData getProfilesChartData(String organizationRecordId, String filterValue) {
        ProfilesChartData returnValue = new ProfilesChartData();
        List<AggregateResult> profilesData = [Select Profile__c, Count(Id) total From Asleep_user__c Where User_organization__c =:organizationRecordId AND Status__c =:filtervalue AND eext__License__c = 'Salesforce' WITH SECURITY_ENFORCED Group By Profile__c Order By Count(Id) DESC];
        for (AggregateResult eachResult : profilesData) {
            returnValue.profilesValuesMap.put((String) eachResult.get('eext__Profile__c'), (Integer) eachResult.get('total'));
        }
        return returnValue;
    }

    /*
    *********************************************************
    @Method Name    : getGeographyChartData()
    @author         : cavirjuyar.mejia.tech@bbva.com
    @description    : this method retrieves formatted data to be painted on the geography chart
    @param          : String organizationRecordId. Context record Id
    @param          : String filterValue. value to filter users by state, asleep, active or never logged in
    @return         : GeographyChartData wrapper
    ********************************************************
    */
    @AuraEnabled
    public static GeographyChartData getGeographyChartData(String organizationRecordId, String filterValue) {
        GeographyChartData returnValue = new GeographyChartData();
        List<AggregateResult> geographyData = [Select Geography__c, Count(Id) total From Asleep_user__c Where User_organization__c =:organizationRecordId AND Status__c =:filtervalue AND eext__License__c = 'Salesforce' WITH SECURITY_ENFORCED Group By Geography__c Order By Count(Id) DESC];
        for (AggregateResult eachResult : geographyData) {
            returnValue.geographyValuesMap.put((String) eachResult.get('eext__Geography__c'), (Integer) eachResult.get('total'));
        }
        return returnValue;
    }

    /*
    *********************************************************
    @Method Name    : getSegmentationChartData()
    @author         : cavirjuyar.mejia.tech@bbva.com
    @description    : this method retrieves formatted data to be painted on the segmentation chart
    @param          : String organizationRecordId. Context record Id
    @param          : String filterValue. value to filter users by state, asleep, active or never logged in
    @return         : SegmentationChartData wrapper
    ********************************************************
    */
    @AuraEnabled
    public static SegmentationChartData getSegmentationChartData(String organizationRecordId, String filterValue) {
        SegmentationChartData returnValue = new SegmentationChartData();
        List<AggregateResult> segmentationData = [Select Segmentation__c, Count(Id) total From Asleep_user__c Where User_organization__c =:organizationRecordId AND Status__c =:filtervalue AND eext__License__c = 'Salesforce' WITH SECURITY_ENFORCED Group By Segmentation__c Order By Count(Id) DESC];
        for (AggregateResult eachResult : segmentationData) {
            returnValue.segmentationValuesMap.put((String) eachResult.get('eext__Segmentation__c'), (Integer) eachResult.get('total'));
        }
        return returnValue;
    }

    @TestVisible
    class ChartData {
        @AuraEnabled
        public List<Integer> lastLoginCountValues = new List<Integer>{0,0,0,0,0,0,0,0};
    }

    @TestVisible
    class FreqChartData {
        @AuraEnabled
        public List<Integer> loginFreqValues = new List<Integer>{0,0,0,0,0};
    }

    @TestVisible
    class OrgFreqChartData {
        @AuraEnabled
        public List<Integer> nullFreqValues = new List<Integer>{0,0,0,0,0};

        @AuraEnabled
        public List<Integer> lowFreqValues = new List<Integer>{0,0,0,0,0};

        @AuraEnabled
        public List<Integer> mediumFreqValues = new List<Integer>{0,0,0,0,0};

        @AuraEnabled
        public List<Integer> highFreqValues = new List<Integer>{0,0,0,0,0};
    }

    @TestVisible
    class ProfilesChartData {
        @AuraEnabled
        public Map<String,Integer> profilesValuesMap = new Map<String,Integer>();
    }

    @TestVisible
    class GeographyChartData {
        @AuraEnabled
        public Map<String,Integer> geographyValuesMap = new Map<String,Integer>();
    }

    @TestVisible
    class SegmentationChartData {
        @AuraEnabled
        public Map<String,Integer> segmentationValuesMap = new Map<String,Integer>();
    }
}