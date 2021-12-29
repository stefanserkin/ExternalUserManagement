public class ExternalUserService {
    /*
    private static Map<String, External_User_Configuration__mdt> mapUserConfigsBySite;
    private static Boolean userConfigMapIsSet = false;

    private static Map<String, Id> mapProfileIdsBySiteName;
    private static Boolean profileIdMapIsSet = false;

    private static Map<String, Set<String>> mapPermSetIdsBySiteName;
    private static Boolean permSetIdMapIsSet = false;


    public static void handleAfterInsert(Map<Id, User> mapUsers) {
        List<PermissionSetAssignment> lstPSAs = new List<PermissionSetAssignment>();
        Map<Id, User> mapExternalUsers = getExternalUsersFromUserMap(mapUsers);
        if (!mapExternalUsers.isEmpty()) {
            createPSAsForUsers(mapExternalUsers);
        }
    }

    public static void createPSAsForUsers(Map<Id, User> mapExternalUsers) {
        if (!permSetIdMapIsSet) {
            setPermissionSetIdMap();
        }
        Set<Id> userIds = new Set<Id>();
        for (User u : mapExternalUsers.values()) {
            userIds.add(u.Id);
        }
        futureInsertPermissionSetAssignments(userIds);
    }

    @future
    private static void futureInsertPermissionSetAssignments(Set<Id> userIds) {
        if (!permSetIdMapIsSet) {
            setPermissionSetIdMap();
        }

        List<PermissionSetAssignment> lstPSAs = new List<PermissionSetAssignment>();
        List<User> lstUsers = [SELECT Id, ProfileId, Authorized_Sites__c FROM User WHERE Id IN :userIds];

        for (User u : lstUsers) {
            Set<String> authSites = new Set<String>();
            if (!String.isBlank(u.Authorized_Sites__c)) {
                authSites.addAll(u.Authorized_Sites__c.split(','));
            } else {
                authSites.add(getDefaultUserConfig().Site_Name__c);
            }
            Set<String> permSetsToAssign = new Set<String>();
            for (String authSite : authSites) {
                permSetsToAssign.addAll(mapPermSetIdsBySiteName.get(authSite));
            }
            for (String permSetId : permSetsToAssign) {
                PermissionSetAssignment psa = new PermissionSetAssignment();
                psa.AssigneeId = u.Id;
                psa.PermissionSetId = permSetId;
                lstPSAs.add(psa);
            }
        }        

        if (!lstPSAs.isEmpty()) {
            insert lstPSAs;
        }
    }

    private static void setPermissionSetIdMap() {
        if (permSetIdMapIsSet) {
            return;
        } else {
            mapPermSetIdsBySiteName = new Map<String, Set<String>>();
        }
        if (!userConfigMapIsSet) {
            setUserConfigMap();
        }
        Set<String> permSetIds = new Set<String>();
        for (External_User_Configuration__mdt userConfig : mapUserConfigsBySite.values()) {
            permSetIds.addAll(
                userConfig.Permission_Sets_to_Auto_Assign__c.replaceAll('\\s+','').split(',')
            );
        }
        List<PermissionSet> lstPermSets = [SELECT Id, Name FROM PermissionSet WHERE Name IN :permSetIds LIMIT 10000];
        for (External_User_Configuration__mdt userConfig : mapUserConfigsBySite.values()) {
            Set<String> configPermSetIds = new Set<String>();
            for (PermissionSet permSet : lstPermSets) {
                if (userConfig.Permission_Sets_to_Auto_Assign__c.contains(permSet.Name)) {
                    configPermSetIds.add(permSet.Id);
                }
            }
            mapPermSetIdsBySiteName.put(userConfig.Site_Name__c, configPermSetIds);
        }
        permSetIdMapIsSet = true;
    }


    public static User getUserWithDefaults() {
        String siteName = getDefaultUserConfig().Site_Name__c;
        return generateUser(siteName);
    }

    public static User getUserWithDefaults(String siteName) {
        return generateUser(siteName);
    }

    public static void resetPassword(User user, Boolean sendEmail) {
        System.resetPassword(user.Id, sendEmail);
    }

    public static String getAliasFromName(String firstName, String lastName) {
        return firstName.substring(0, 1) + lastName.substring(0, 4);
    }

    private static Map<Id, User> getExternalUsersFromUserMap(Map<Id, User> mapUsers) {
        Map<Id, User> mapExternalUsers = new Map<Id, User>();
        for (User u : mapUsers.values()) {
            if (u.IsPortalEnabled) {
                mapExternalUsers.put(u.Id, u);
            }
        }
        return mapExternalUsers;
    }

    private static External_User_Configuration__mdt getUserConfig(String siteName) {
        if (!userConfigMapIsSet) {
            setUserConfigMap();
        }
        return mapUserConfigsBySite.get(siteName);
    }

    private static External_User_Configuration__mdt getDefaultUserConfig() {
        if (!userConfigMapIsSet) {
            setUserConfigMap();
        }
        External_User_Configuration__mdt defaultConfig = new External_User_Configuration__mdt();
        for (External_User_Configuration__mdt userConfig : mapUserConfigsBySite.values()) {
            if (userConfig.Default__c) {
                defaultConfig = userConfig;
                break;
            }
        }
        return defaultConfig;
    }

    private static void setUserConfigMap() {
        if (userConfigMapIsSet) {
            return;
        }
        mapUserConfigsBySite = new Map<String, External_User_Configuration__mdt>();
        List<External_User_Configuration__mdt> lstUserConfigs = External_User_Configuration__mdt.getAll().values();
        for (External_User_Configuration__mdt userConfig : lstUserConfigs) {
            mapUserConfigsBySite.put(userConfig.Site_Name__c, userConfig);
        }
        userConfigMapIsSet = true;
    }

    public static Id getProfileIdBySiteName(String siteName) {
        if (!profileIdMapIsSet) {
            setProfileIdMap();
        }
        return mapProfileIdsBySiteName.get(siteName);
    }

    public static Id getDefaultProfileId() {
        if (!profileIdMapIsSet) {
            setProfileIdMap();
        }
        Id profileId;
        for (External_User_Configuration__mdt userConfig : mapUserConfigsBySite.values()) {
            if (userConfig.Default__c) {
                profileId = mapProfileIdsBySiteName.get(userConfig.Site_Name__c);
                break;
            }
        }
        return profileId;
    }

    private static void setProfileIdMap() {
        if (profileIdMapIsSet) {
            return;
        } else {
            mapProfileIdsBySiteName = new Map<String, Id>();
        }
        if (!userConfigMapIsSet) {
            setUserConfigMap();
        }
        Set<String> profileNames = new Set<String>();
        for (External_User_Configuration__mdt userConfig : mapUserConfigsBySite.values()) {
            profileNames.add(userConfig.Profile_Name__c);
        }
        List<Profile> lstProfiles = [SELECT Id, Name FROM Profile WHERE Name IN :profileNames LIMIT 10000];
        for (External_User_Configuration__mdt userConfig : mapUserConfigsBySite.values()) {
            for (Profile prof : lstProfiles) {
                if (prof.Name == userConfig.Profile_Name__c) {
                    mapProfileIdsBySiteName.put(userConfig.Site_Name__c, prof.Id);
                }
            }    
        }
        profileIdMapIsSet = true;
    }

    private static User generateUser(String siteName) {
        User u = new User();
        u.ProfileId         = getProfileIdBySiteName(siteName);
        u.IsActive          = true;
        u.TimeZoneSidKey    = 'America/New_York';
        U.LocaleSidKey      = 'en_US';
        u.LanguageLocaleKey = 'en_US';
        u.EmailEncodingKey  = 'ISO-8859-1';
        return u;
    }
*/
}
