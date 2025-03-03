@SuppressWarnings('PMD.ExcessivePublicCount')
public class PackagesWrapper {

    public final Integer size;
    public final Integer totalSize;
    public final Boolean done;
    public final Object queryLocator;
    public final String entityTypeName;
    public final List<Records> records;

    public class SubscriberPackage_Z {
        public Attributes attributes;
        public Object namespacePrefix;
        public String name;
    }

    public class Attributes {
        public String type;
        public String url;
    }

    public class SubscriberPackage {
        public Attributes attributes;
        public String namespacePrefix;
        public String name;
    }

    public class SubscriberPackageVersion {
        public Attributes attributes;
        public String id;
        public String name;
        public Integer majorVersion;
        public Integer minorVersion;
        public Integer patchVersion;
        public Integer buildNumber;
    }

    public class Records {
        public Attributes attributes;
        public String id;
        public String subscriberPackageId;
        public SubscriberPackage subscriberPackage;
        public SubscriberPackageVersion subscriberPackageVersion;
    }


    public static PackagesWrapper parse(String json) {
        return (PackagesWrapper) System.JSON.deserialize(json, PackagesWrapper.class);
    }
}