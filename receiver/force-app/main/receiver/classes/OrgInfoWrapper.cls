public class OrgInfoWrapper {

    public final String orgId;
    public final String orgUrl;
    public final String user;
    public final Boolean status;
    public final String detail;
    public final List<String> dormantUsers;
    public final Integer totalLicenses;
    public final Integer usedLicenses;


    public static OrgInfoWrapper parse(String json) {
        return (OrgInfoWrapper) System.JSON.deserialize(json, OrgInfoWrapper.class);
    }
}