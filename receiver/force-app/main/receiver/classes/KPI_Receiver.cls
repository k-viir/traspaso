@SuppressWarnings('PMD.CyclomaticComplexity,PMD.NcssMethodCount,PMD.CognitiveComplexity,PMD.StdCyclomaticComplexity,PMD.AvoidDeeplyNestedIfStmts')
/*
*********************************************************************************************************
@Name     KPI_Receiver
@Author   cavirjuyar.mejia.tech@bbva.com
@Date     Created: 25/10/2023
@Group    Global Hub Components
@Description This class contains the methods to insert/upsert the data received from source org to the
            the custom objects.
*********************************************************************************************************
@Changes
Date              Author                                    Modification
25/10/2023        cavirjuyar.mejia.tech@bbva.com           Class creation.
*********************************************************************************************************
*/
@RestResource(urlMapping='/KPI_Receiver/*')

global without sharing class KPI_Receiver {

    public static List<Organization__c> organizations = new List<Organization__c>();
    public static List<Package__c> globalPackages = new List<Package__c>();
    public static List<Package_version__c> globalPackagesVersions = new List<Package_version__c>();
    public static PackagesWrapper receivedPackages;
    public static OrgInfoWrapper orgInformation;
    public static Organization__c organization;
    public static List<Package_version__c> versionesMasAltas = new List<Package_version__c>();
    public static List<User> orgUsers = new List<User>();
    public static Map<String, Asleep_user__c> userDetailsMap = new Map<String, Asleep_user__c>();
    public static Id orgRecordTypeId;
    public static Date today = DateTime.now().date();

    /*
    *********************************************************
    @Method Name    : upsertReceivedData
    @author         : cavirjuyar.mejia.tech@bbva.com
    @description    : this method is called from target organization periodically to load
                    : kpis data, packages, and login activity
    @param          : String packagesListJson, a serialized list of,
                      installedSubscriberPackage that will be
                      converted into different custom objects
    @param          : String orgInfo. Json that has target organization details
    @param          : String users. Json of a list of object User
    @param          : String licenseAssignments. Json of a list of object PermissionSetLicenseAssign
    @param          : String loginHistory. Json of a list of object LoginHistory
    @return         : result, a string that describes result
    ********************************************************
    */
    @SuppressWarnings('PMD.ExcessiveParameterList')
    @HttpPost
    global static String upsertReceivedData(String packagesListJson, String installationRequests, String orgInfo, String users, String licenseAssignments, String loginHistory) {
        doPost(packagesListJson, orgInfo, users, licenseAssignments, loginHistory);
        return 'Everything OK';
    }

    /*
    *********************************************************
    @Method Name    : doPost
    @author         : cavirjuyar.mejia.tech@bbva.com
    @description    : this method executes all logic neccessary for the process to work, asynchronously
    @param          : String packagesListJson, a serialized list of,
                      installedSubscriberPackage that will be
                      converted into different custom objects
    @param          : String orgInfo. Json that has target organization details
    @param          : String users. Json of a list of object User
    @param          : String licenseAssignments. Json of a list of object PermissionSetLicenseAssign
    @param          : String loginHistory. Json of a list of object LoginHistory
    @return         : void
    ********************************************************
    */
    @SuppressWarnings('PMD.ExcessiveParameterList')
    @future
    public static void  doPost(String packagesListJson, String orgInfo, String users, String licenseAssignments, String loginHistory) {
        //String result = 'Everything OK';
        Boolean alreadyExecuted = false;

        try {
            receivedPackages = PackagesWrapper.parse(packagesListJson);
            orgInformation = OrgInfoWrapper.parse(orgInfo);
            List<Organization__c> orgs = [select Id From Organization__c where Organization_ID__c =: orgInformation.orgId AND Last_connection__c = TODAY AND Status__c = 'Active' WITH SECURITY_ENFORCED];
            alreadyExecuted = orgs.size() > 0 ? true : false;
            if (alreadyExecuted == false) {
                organizations = database.query('Select Id, Name, User__c, Organization_ID__c, Org_URL__c From Organization__c');
                globalPackages = database.query('Select Id, Name, Namespace__c, Package_ID__c From Package__c');
                globalPackagesVersions = database.query('Select Id, Name, Version_number__c, Package__c, Package__r.Name, Package__r.Package_ID__c, Version_differences__c  From Package_version__c');

                getLatestVersions();
                organization = new Organization__c(Name = getOrgName(orgInformation), User__c = orgInformation.user, Organization_ID__c = orgInformation.orgId,
                                                Org_URL__c = orgInformation.orgUrl, RecordTypeId = orgRecordTypeId);
                organization.Last_connection__c = System.today();
                organization.Status__c = 'Active';
                organization.Status_Detail__c = 'Connection is working as expected';
                organization.Used_licenses__c = orgInformation.usedLicenses;
                organization.Total_licenses__c = orgInformation.totalLicenses;
                SObjectAccessDecision securityDecision = Security.stripInaccessible(AccessType.CREATABLE, new List<Organization__c>{organization});

                insert securityDecision.getRecords();
                organization = (Organization__c) securityDecision.getRecords()[0];
                if (versionesMasAltas.size() > 0) {
                    processPackagesOptimized();
                    globalPackages.clear();
                    globalPackagesVersions.clear();
                    versionesMasAltas.clear();
                }
                setUsersDetails(licenseAssignments, loginHistory);
                processOrgUsers(users);
            }

        } catch(Exception e) {
            if (organization != null && organization.Id != null)  {
                organization.Status__c = 'Error';
                organization.Status_Detail__c = ': error ' + e.getMessage() + ':' + e.getStackTraceString();
                SObjectAccessDecision securityDecision = Security.stripInaccessible(AccessType.UPDATABLE, new List<Organization__c>{organization});

                update securityDecision.getRecords();

            }
        }
    }
    /*
    *********************************************************
    @Method Name    : processOrgUsers()
    @author         : cavirjuyar.mejia.tech@bbva.com
    @description    : this method receives a json of a list of users extracted from an org and
                    : processes the data before inserting it
    @param          : String orgUsersJsonList. Json of a list of users from an organization
    @return         : List<InstalledSubscriberPackage> Packages information
    ********************************************************
    */
    public static void processOrgUsers(String orgUsersJsonList){
        orgUsers = (List<User>) JSON.deserialize(orgUsersJsonList, List<User>.class);
        List<Asleep_user__c> currentOrgUsers = new List<Asleep_user__c>();
        Boolean hasDetailMap = false;
        Integer auxCounter;
        User eachOrgUser;
        Integer size = orgUsers.size();
        Integer partialInserts = (Integer) (size / 2000);
        if (Math.mod(size, 2000) == 0) {
            partialInserts--;
        }
        for (Integer i = 0; i <= partialInserts ; i++) {
            auxCounter = 0;
            do {
                eachOrgUser = orgUsers[orgUsers.size() - 1];
                hasDetailMap = userDetailsMap.get(eachOrgUser.Id) != null;
                Asleep_user__c orgUserToInsert = new Asleep_user__c();
                orgUserToInsert.User_organization__c = organization.Id;
                orgUserToInsert.Full_name__c = eachOrgUser.Name;
                orgUserToInsert.Last_login__c = eachOrgUser.LastLoginDate != null ? eachOrgUser.LastLoginDate.date() : null;
                orgUserToInsert.License__c = eachOrgUser.profile.userlicense.masterlabel;
                orgUserToInsert.Profile__c = eachOrgUser.profile.Name;
                orgUserToInsert.BBVA_User__c = eachOrgUser.FederationIdentifier;
                orgUserToInsert.Status__c = eachOrgUser.LastLoginDate != null ? (eachOrgUser.LastLoginDate.date() < DateTime.now().date().addDays(-89) ? 'Asleep' : 'Active') : 'Never logged in';
                orgUserToInsert.Username__c = eachOrgUser.Username;
                orgUserToInsert.Email__c = eachOrgUser.Email;
                orgUserToInsert.Created_on__c = eachOrgUser.CreatedDate.date();
                orgUserToInsert.Time_zone__c = eachOrgUser.TimeZoneSidKey;
                orgUserToInsert.X1_day_login_count__c = hasDetailMap == true ? userDetailsMap.get(eachOrgUser.Id).X1_day_login_count__c : null;
                orgUserToInsert.X3_day_login_count__c = hasDetailMap == true ? userDetailsMap.get(eachOrgUser.Id).X3_day_login_count__c : null;
                orgUserToInsert.X1_week_login_count__c = hasDetailMap == true ? userDetailsMap.get(eachOrgUser.Id).X1_week_login_count__c : null;
                orgUserToInsert.X2_weeks_login_count__c = hasDetailMap == true ? userDetailsMap.get(eachOrgUser.Id).X2_weeks_login_count__c : null;
                orgUserToInsert.X1_month_login_count__c = hasDetailMap == true ? userDetailsMap.get(eachOrgUser.Id).X1_month_login_count__c : null;
                orgUserToInsert.Permission_set_licenses__c = hasDetailMap == true ? userDetailsMap.get(eachOrgUser.Id).Permission_set_licenses__c : null;
                setUserActivity(orgUserToInsert);
                currentOrgUsers.add(orgUserToInsert);
                orgUsers.remove(orgUsers.size() - 1);
                auxCounter++;
            } while (orgUsers.size() > 0 && auxCounter < 2000);
            fillGeographyFields(currentOrgUsers);
            insertOrgUsers(currentOrgUsers);
            currentOrgUsers.clear();
        }
    }

    /*
    *********************************************************
    @Method Name    : setUserActivity()
    @author         : cavirjuyar.mejia.tech@bbva.com
    @description    : this method fills picklist field values for the login
                    : activity depending on login frequency
    @param          : User eachOrgUser. User to fill
    @return         : void
    ********************************************************
    */
    public static void setUserActivity(eext__Asleep_user__c orgUserToInsert) {
        //DAY FILLING
        //filling null freq list
        if ((orgUserToInsert.X1_day_login_count__c == 0 && orgUserToInsert.Last_login__c < today.addDays(-0)) || (orgUserToInsert.X1_day_login_count__c == null && orgUserToInsert.Last_login__c < today.addDays(-0))) {
            orgUserToInsert.X1_day_activity__c = 'No activity';
        }
        //filling low freq list
        if (orgUserToInsert.X1_day_login_count__c == 1) {
            orgUserToInsert.X1_day_activity__c = 'Low activity';
        }
        //filling medium freq list
        if (orgUserToInsert.X1_day_login_count__c >= 2 && orgUserToInsert.X1_day_login_count__c <= 3) {
            orgUserToInsert.X1_day_activity__c = 'Medium activity';
        }
        //filling high freq list
        if (orgUserToInsert.X1_day_login_count__c > 3) {
            orgUserToInsert.X1_day_activity__c = 'High activity';
        }

        //3DAYS FILLING
        //filling null freq list
        if ((orgUserToInsert.X3_day_login_count__c == 0 && orgUserToInsert.Last_login__c < today.addDays(-2)) || (orgUserToInsert.X3_day_login_count__c == null && orgUserToInsert.Last_login__c < today.addDays(-2))) {
            orgUserToInsert.X3_day_activity__c = 'No activity';
        }
        //filling low freq list
        if (orgUserToInsert.X3_day_login_count__c > 0 && orgUserToInsert.X3_day_login_count__c <= 2) {
            orgUserToInsert.x3_day_activity__c = 'Low activity';
        }
        //filling medium freq list
        if (orgUserToInsert.X3_day_login_count__c >= 3 && orgUserToInsert.X3_day_login_count__c <= 5) {
            orgUserToInsert.X3_day_activity__c = 'Medium activity';
        }
        //filling high freq list
        if (orgUserToInsert.X3_day_login_count__c > 5) {
            orgUserToInsert.X3_day_activity__c = 'High activity';
        }

        //1WEEK FILLING
        //filling null freq list
        if ((orgUserToInsert.X1_week_login_count__c == 0 && orgUserToInsert.Last_login__c < today.addDays(-6)) || (orgUserToInsert.X1_week_login_count__c == null && orgUserToInsert.Last_login__c < today.addDays(-6))) {
            orgUserToInsert.X1_week_activity__c = 'No activity';
        }
        //filling low freq list
        if (orgUserToInsert.X1_week_login_count__c > 0 && orgUserToInsert.X1_week_login_count__c <= 4) {
            orgUserToInsert.x1_week_activity__c = 'Low activity';
        }
        //filling medium freq list
        if (orgUserToInsert.X1_week_login_count__c >= 5 && orgUserToInsert.X1_week_login_count__c <= 10) {
            orgUserToInsert.X1_week_activity__c = 'Medium activity';
        }
        //filling high freq list
        if (orgUserToInsert.X1_week_login_count__c > 10) {
            orgUserToInsert.X1_week_activity__c = 'High activity';
        }

        //2WEEK FILLING
        //filling null freq list
        if ((orgUserToInsert.X2_weeks_login_count__c == 0 && orgUserToInsert.Last_login__c < today.addDays(-13)) || (orgUserToInsert.X2_weeks_login_count__c == null && orgUserToInsert.Last_login__c < today.addDays(-13))) {
            orgUserToInsert.X2_week_activity__c = 'No activity';
        }
        //filling low freq list
        if (orgUserToInsert.X2_weeks_login_count__c > 0 && orgUserToInsert.X2_weeks_login_count__c <= 6) {
            orgUserToInsert.x2_week_activity__c = 'Low activity';
        }
        //filling medium freq list
        if (orgUserToInsert.X2_weeks_login_count__c >= 7 && orgUserToInsert.X2_weeks_login_count__c <= 16) {
            orgUserToInsert.X2_week_activity__c = 'Medium activity';
        }
        //filling high freq list
        if (orgUserToInsert.X2_weeks_login_count__c > 16) {
            orgUserToInsert.X2_week_activity__c = 'High activity';
        }

        //1MONTH FILLING
        //filling null freq list
        if ((orgUserToInsert.X1_month_login_count__c == 0 && orgUserToInsert.Last_login__c < today.addDays(-29)) || (orgUserToInsert.X1_month_login_count__c == null && orgUserToInsert.Last_login__c < today.addDays(-29))) {
            orgUserToInsert.X1_month_activity__c = 'No activity';
        }
        //filling low freq list
        if (orgUserToInsert.X1_month_login_count__c > 0 && orgUserToInsert.X1_month_login_count__c <= 9) {
            orgUserToInsert.x1_month_activity__c = 'Low activity';
        }
        //filling medium freq list
        if (orgUserToInsert.X1_month_login_count__c >= 10 && orgUserToInsert.X1_month_login_count__c <= 22) {
            orgUserToInsert.X1_month_activity__c = 'Medium activity';
        }

        //filling high freq list
        if (orgUserToInsert.X1_month_login_count__c > 22) {
            orgUserToInsert.X1_month_activity__c = 'High activity';
        }



    }

    /*
    *********************************************************
    @Method Name    : processPackagesOptimized()
    @author         : cavirjuyar.mejia.tech@bbva.com
    @description    : this method acceses package related static properties set previously and iterates
                    : over them, applying logic for creating resulting custom objects
    @param          : none
    @return         : void
    ********************************************************
    */
    public static void processPackagesOptimized() {
        List<Organization_version__c> organizationVersionsUpsert = new List<Organization_version__c>();

        for (PackagesWrapper.Records receivedPackage: receivedPackages.records) {
            Package_version__c versionPackageGlobal;
            Package__c globalPackage = getPackageGlobal(receivedPackage);
            if (globalPackage != null) {
                versionPackageGlobal = getVersionPackageGlobal(receivedPackage);
            }
            if (versionPackageGlobal != null) {
                Package_version__c latestVersion = searchLatestVersion(versionPackageGlobal);

                if (latestVersion != null) {
                    Organization_version__c nuevaVPP = new Organization_version__c(Name = organization.Name + ' ' + versionPackageGlobal.Name, Installed_organization__c = organization.Id, Package_version__c = versionPackageGlobal.Id, Newest_package_version__c = latestVersion.Id, Version_differences__c = versionPackageGlobal.Version_differences__c );
                    organizationVersionsUpsert.add(nuevaVPP);
                }
            }
        }
        SObjectAccessDecision securityDecision = Security.stripInaccessible(AccessType.CREATABLE, organizationVersionsUpsert);
        insert securityDecision.getRecords();
    }
    /*
    *********************************************************
    @Method Name    : searchLatestVersion()
    @author         : cavirjuyar.mejia.tech@bbva.com
    @description    : this method iterates over Package_version__c objects to find highest version
                    : available of a determined package
    @param          : String versionPackageGlobal. Package version to have as reference when looking for newest
                    : Package version of a certain package
    @return         : Package_version__c newest package version of a package
    ********************************************************
    */

    public static Package_version__c searchLatestVersion(Package_version__c versionPackageGlobal) {
        Integer auxCounter = 0;
        Boolean found = false;
        Package_version__c toReturn;

        while (found == false && auxCounter < versionesMasAltas.size()) {
            if (versionesMasAltas[auxCounter].Package__c == versionPackageGlobal.Package__c) {
                found = true;
                toReturn = versionesMasAltas[auxCounter];
            } else {
                auxCounter++;
            }
        }
        return toReturn;
    }

    /*
    *********************************************************
    @Method Name    : getVersionPackageGlobal()
    @author         : cavirjuyar.mejia.tech@bbva.com
    @description    : this method receives wrapped package version information from an external org and finds
                    : corresponding version in our reference package version records
    @param          : PackagesWrapper.Records receivedPackage. wrapped package version information from an external org
    @return         : Package_version__c corresponding package version
    ********************************************************
    */
    public static Package_version__c getVersionPackageGlobal(PackagesWrapper.Records receivedPackage) {
        String receivedPackageVersion = String.valueOf(receivedPackage.SubscriberPackageVersion.MajorVersion) + '.' + String.valueOf(receivedPackage.SubscriberPackageVersion.MinorVersion);
        Integer auxCounter = 0;
        Boolean found = false;
        Package_version__c returnValue;
        String formattedReceivedPackageId = (String) ((Id) receivedPackage.SubscriberPackageId).to15();

        do {
            if (receivedPackageVersion == globalPackagesVersions[auxCounter].Version_number__c && formattedReceivedPackageId == globalPackagesVersions[auxCounter].Package__r.Package_ID__c) {
                returnValue = globalPackagesVersions[auxCounter];
                found = true;
            } else {
                auxCounter++;
            }

        } while (!found && auxCounter < globalPackagesVersions.size());
        return returnValue;
    }

    /*
    *********************************************************
    @Method Name    : getPackageGlobal()
    @author         : cavirjuyar.mejia.tech@bbva.com
    @description    : this method receives wrapped package version information from an external org and finds
                    : corresponding global package in our reference global package records
    @param          : PackagesWrapper.Records receivedPackage. wrapped package information from an external org
    @return         : Package__c corresponding global package
    ********************************************************
    */

    public static Package__c getPackageGlobal(PackagesWrapper.Records receivedPackage) {
        Integer auxCounter = 0;
        Boolean found = false;
        Package__c returnValue;
        String formattedReceivedPackageId = (String) ((Id) receivedPackage.SubscriberPackageId).to15();

        do {
            if (globalPackages[auxCounter].Package_ID__c == formattedReceivedPackageId) {
                found = true;
                returnValue = globalPackages[auxCounter];
            } else {
                auxCounter++;
            }
        } while (!found && auxCounter < globalPackages.size());

        return returnValue;
    }

    /*
    *********************************************************
    @Method Name    : getLatestVersions()
    @author         : cavirjuyar.mejia.tech@bbva.com
    @description    : method to get the ids of the version receivedPackages
                      that are most up to date
    @param          : none
    @return         : void
    ********************************************************
    */
    public static void getLatestVersions() {
        Package_version__c auxPV;
        Integer auxCounter = 0;
        Boolean found = false;
        List<Package_version__c> auxList = new List<Package_version__c>();
        AggregateResult[] groupedResults = [select  MAX(Version_number__c),Package__r.Name  From Package_version__c WITH SECURITY_ENFORCED group by Package__r.Name];
        for (AggregateResult ar : groupedResults) {
            auxCounter = 0;
            found = false;

            do {
                if (globalPackagesVersions[auxCounter].Package__r.Name == ar.get('Name') && globalPackagesVersions[auxCounter].Version_number__c == ar.get('expr0')) {

                    auxPV = globalPackagesVersions[auxCounter];
                    auxList.add(auxPV);
                    found = true;
                } else {
                    auxCounter++;
                }
            } while (!found && auxCounter < globalPackagesVersions.size());
        }
        versionesMasAltas = auxList;
    }

    @Deprecated
    global static void getLatestVersions(List<Package_version__c> exList) {
        System.debug('depre');
    }
    /*
    *********************************************************
    @Method Name    : gotOrgName()
    @author         : cavirjuyar.mejia.tech@bbva.com
    @description    : this method returns the name of a created Organization__c record depending
                    : on which org it is. if registered known name is used, if not, it uses url info
    @param          : OrgInforWrapper orgInformation. wrapped org information of the external org received data
    @return         : String name of the org
    ********************************************************
    */
    public static String getOrgName(OrgInfoWrapper orgInformation) {
        String returnName = '';
        List<Org_naming__mdt> orgNames = [SELECT Org_name__c, Org_id__c, Org_recordType__c FROM Org_naming__mdt where Org_id__c =:orgInformation.OrgId WITH SECURITY_ENFORCED Limit 1];
        if (orgNames.size() > 0) {
            returnName = orgNames[0].Org_name__c;
            if (orgNames[0].Org_recordType__c != null && Schema.SObjectType.Organization__c.getRecordTypeInfosByName().get(orgNames[0].Org_recordType__c) != null) {
                orgRecordTypeId = Schema.SObjectType.Organization__c.getRecordTypeInfosByName().get(orgNames[0].Org_recordType__c).getRecordTypeId();
            } else {
                orgRecordTypeId = Schema.SObjectType.Organization__c.getRecordTypeInfosByName().get('standard').getRecordTypeId();
            }
        } else {
            returnName = (orgInformation.orgUrl.equalsIgnoreCase('null') ? null : orgInformation.orgUrl.split('https://', 0)[1].split('\\.', 0)[0]);
            orgRecordTypeId = Schema.SObjectType.Organization__c.getRecordTypeInfosByName().get('standard').getRecordTypeId();
        }
        return returnName;
    }

/*
    *********************************************************
    @Method Name    : setUserDetails()
    @author         : cavirjuyar.mejia.tech@bbva.com
    @description    : this methods process user related infomation received from external org and
                    : sets the neccessary values for later use
    @param          : String licenseAssignments. json list of PermissionSetLicenseAssign object extracted
                    : from external org
    @param          : String loginHistory. json list of LoginHistory object extracted from external org
    @return         : void
    ********************************************************
    */
    public static void setUsersDetails(String licenseAssignments, String loginHistory) {
        Map<String, List<Wrappers.CustomAggregateResult>> loginHistoryMap;
        List<PermissionSetLicenseAssign> licensesList = (List<PermissionSetLicenseAssign>) JSON.deserialize(licenseAssignments, List<PermissionSetLicenseAssign>.class);

        try {
            loginHistoryMap = (Map<String, List<Wrappers.CustomAggregateResult>>) JSON.deserialize(loginHistory, Map<String, List<Wrappers.CustomAggregateResult>>.class);
        } catch (Exception e) {
            organization.Status_Detail__c += e.getMessage();
        }
        if (loginHistoryMap != null) {
            for (Wrappers.CustomAggregateResult eachAggregate : loginHistoryMap.get('x1DayLogins')) {
            Asleep_user__c userDetails;
            if (eachAggregate.Status.contains('Success')) {
                if (userDetailsMap.get(eachAggregate.UserId) == null) {
                    userDetails = new Asleep_user__c();
                } else {
                    userDetails = userDetailsMap.get(eachAggregate.UserId);
                }

                userDetails.X1_day_login_count__c = eachAggregate.Total;

                if (userDetailsMap.get(eachAggregate.UserId) == null) {
                    userDetailsMap.put(eachAggregate.UserId, userDetails);
                }
            }
        }

        for (Wrappers.CustomAggregateResult eachAggregate : loginHistoryMap.get('x3DayLogins')) {
            Asleep_user__c userDetails;
            if (eachAggregate.Status.contains('Success')) {
                if (userDetailsMap.get(eachAggregate.UserId) == null) {
                    userDetails = new Asleep_user__c();
                } else {
                    userDetails = userDetailsMap.get(eachAggregate.UserId);
                }

                userDetails.X3_day_login_count__c = eachAggregate.Total;

                if (userDetailsMap.get(eachAggregate.UserId) == null) {
                    userDetailsMap.put(eachAggregate.UserId, userDetails);
                }
            }
        }

        for (Wrappers.CustomAggregateResult eachAggregate : loginHistoryMap.get('x1WeekLogins')) {
            Asleep_user__c userDetails;
            if (eachAggregate.Status.contains('Success')) {
                if (userDetailsMap.get(eachAggregate.UserId) == null) {
                    userDetails = new Asleep_user__c();
                } else {
                    userDetails = userDetailsMap.get(eachAggregate.UserId);
                }

                userDetails.X1_week_login_count__c = eachAggregate.Total;

                if (userDetailsMap.get(eachAggregate.UserId) == null) {
                    userDetailsMap.put(eachAggregate.UserId, userDetails);
                }
            }
        }

        for (Wrappers.CustomAggregateResult eachAggregate : loginHistoryMap.get('x2WeekLogins')) {
            Asleep_user__c userDetails;
            if (eachAggregate.Status.contains('Success')) {
                if (userDetailsMap.get(eachAggregate.UserId) == null) {
                    userDetails = new Asleep_user__c();
                } else {
                    userDetails = userDetailsMap.get(eachAggregate.UserId);
                }

                userDetails.X2_weeks_login_count__c = eachAggregate.Total;

                if (userDetailsMap.get(eachAggregate.UserId) == null) {
                    userDetailsMap.put(eachAggregate.UserId, userDetails);
                }
            }
        }

        for (Wrappers.CustomAggregateResult eachAggregate : loginHistoryMap.get('x1MonthLogins')) {
            Asleep_user__c userDetails;
            if (eachAggregate.Status.contains('Success')) {
                if (userDetailsMap.get(eachAggregate.UserId) == null) {
                    userDetails = new Asleep_user__c();
                } else {
                    userDetails = userDetailsMap.get(eachAggregate.UserId);
                }

                userDetails.X1_month_login_count__c = eachAggregate.Total;

                if (userDetailsMap.get(eachAggregate.UserId) == null) {
                    userDetailsMap.put(eachAggregate.UserId, userDetails);
                }
            }
        }

        }

        for (PermissionSetLicenseAssign eachLicenseAssign : licensesList) {
                Asleep_user__c userDetails;
                if (userDetailsMap.get(eachLicenseAssign.AssigneeId) == null) {
                    userDetails = new Asleep_user__c();
                    userDetails.Permission_set_licenses__c += eachLicenseAssign.PermissionSetLicense.MasterLabel + ', ';
                    userDetailsMap.put(eachLicenseAssign.AssigneeId, userDetails);
                } else {
                    userDetails = userDetailsMap.get(eachLicenseAssign.AssigneeId);
                    userDetails.Permission_set_licenses__c += eachLicenseAssign.PermissionSetLicense.MasterLabel + ', ';
                }
        }
    }

    public static void fillGeographyFields(List<Asleep_user__c> currentOrgUsers) {
        List<String> usernameList = new List<String>();
        List<User_Reference__c> userReferences = new List<User_Reference__c>();
        Map<String, User_Reference__c> refMap = new Map<String, User_Reference__c>();

        for (Asleep_user__c user : currentOrgUsers) {
            if (user.BBVA_User__c != null) {
                usernameList.add(user.BBVA_User__c);
            }
        }

        userReferences = [Select Id, BBVA_User__c, Geography__c, Segmentation__c From User_Reference__c Where BBVA_User__c IN :usernameList  WITH SECURITY_ENFORCED order by BBVA_User__c asc];

        if (userReferences.size() > 0) {
            for (User_Reference__c eachReff: userReferences) {
                refMap.put(eachReff.BBVA_User__c, eachReff);
            }
            for (Asleep_user__c eachUser: (List<Asleep_user__c>) currentOrgUsers) {
                if (refMap.get(eachUser.BBVA_User__c) != null) {
                    eachUser.Geography__c = refMap.get(eachUser.BBVA_User__c).Geography__c;
                    eachUser.Segmentation__c = refMap.get(eachUser.BBVA_User__c).Segmentation__c;
                } else {
                    eachUser.Geography__c = System.Label.Sin_definir;
                    eachUser.Segmentation__c = 'Others';
                }
            }
        }
    }

    public static void insertOrgUsers(List<Asleep_user__c> currentOrgUsers) {
        SObjectAccessDecision securityDecision = Security.stripInaccessible(AccessType.CREATABLE, currentOrgUsers);
        insert securityDecision.getRecords();
    }
}