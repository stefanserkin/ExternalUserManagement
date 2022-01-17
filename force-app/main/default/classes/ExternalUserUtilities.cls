public without sharing class ExternalUserUtilities {

    // Test variables allow a default permission set to be added for testing
    @TestVisible public static Boolean testPermissionSetsMode = false;
    @TestVisible public static String testPermissionSetNameToAdd;

    // Email encoding key for default user
    private static final String EMAIL_ENCODING_KEY = 'UTF-8';

    // Cache profile id from default user configuration
    private static String externalProfileId;
    private static Boolean externalProfileIdIsSet = false;

    // Cache permission set ids from default user configuration
    private static Set<Id> setPermissionSetIds;
    private static Boolean setPermissionSetIdsIsSet = false;

    // Default site configuration
    private static External_Site_Setting__mdt siteSetting = External_Site_Setting__mdt.getInstance('Default');


    /* *
    * Reset password for user
    * Optionally send reset password to user
    * */

    public static void resetPassword(User user, Boolean sendEmail) {
        System.resetPassword(user.Id, sendEmail);
    }


    /* *
    * Returns only the users with the external profile
    * Profile name is defined in the default External Site Setting
    * */

    public static List<User> getExternalUsers(List<User> lstUsers) {
        String externalProfileId = getExternalProfileId();
        List<User> lstExternalUsers = new List<User>();
        for (User u : lstUsers) {
            if (u.ProfileId == externalProfileId) {
                lstExternalUsers.add(u);
            }
        }
        return lstExternalUsers;
    }


    /* *
    * Caches and returns profile id defined in the default External Site Setting
    * Profile name can be defined in Custom Metadata Type
    * */

    public static String getExternalProfileId() {
        if (externalProfileIdIsSet) {
            return externalProfileId;
        }
        Profile externalProfile = [SELECT Id FROM Profile WHERE Name = :siteSetting.Profile_Name__c LIMIT 1];
        externalProfileId = externalProfile.Id;
        externalProfileIdIsSet = true;
        return externalProfileId;
    }


    /* *
    * Caches and returns a collection of permission set ids defined in the default External User Configuration
    * Permission sets to auto-assign can be defined in Custom Metadata Type
    * */

    public static Set<Id> getDefaultPermissionSetIds() {
        if (setPermissionSetIdsIsSet) {
            return setPermissionSetIds;
        }
        setPermissionSetIds = new Set<Id>();
        List<String> setPermSetNames = siteSetting.Permission_Sets_to_Auto_Assign__c.replaceAll('\\s+', '').split(',');
        // Public static variables allow a default permission set to be added for testing
        if (testPermissionSetsMode && !String.isBlank(testPermissionSetNameToAdd)) {
            setPermSetNames.add(testPermissionSetNameToAdd);
        }
        List<PermissionSet> lstPermSets = [SELECT Id FROM PermissionSet WHERE Name IN :setPermSetNames LIMIT 10000];
        for (PermissionSet permSet : lstPermSets) {
            setPermissionSetIds.add(permSet.Id);
        }
        setPermissionSetIdsIsSet = true;
        return setPermissionSetIds;
    }


    /* *
    * Returns a default User Alias based on a first and last name
    * */

    public static String getAliasFromName(String firstName, String lastName) {
        return firstName.substring(0, 1) + (lastName.length() > 4 ? lastName.substring(0, 4) : lastName);
    }


    /* *
    * Returns a default User Alias, removing the @domain from the username
    * */

    public static String getNicknameFromUsername(String username) {
        return username.contains('@') ? username.substring(0, username.indexOf('@')) : username;
    }


    /* *
    * Returns a user sobject with default required fields populated
    * Defaults: IsActive, ProfileId, TimeZoneSidKey, LocaleSidKey, LanguageLocaleKey, EmailEncodingKey
    * */

    public static User getUserWithDefaults() {
        return new User(
            IsActive          = true, 
            ProfileId         = getExternalProfileId(), 
            TimeZoneSidKey    = UserInfo.getTimeZone().toString(), 
            LocaleSidKey      = UserInfo.getLocale(), 
            LanguageLocaleKey = UserInfo.getLocale(), 
            EmailEncodingKey  = EMAIL_ENCODING_KEY
        );
    }

}