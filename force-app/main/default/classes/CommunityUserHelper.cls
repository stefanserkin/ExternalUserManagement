public without sharing class CommunityUserHelper {

    // Cache profile id from default user configuration
    private static String communityProfileId;
    private static Boolean communityProfileIdIsSet = false;

    // Cache permission set ids from default user configuration
    private static Set<Id> setPermissionSetIds;
    private static Boolean setPermissionSetIdsIsSet = false;

    // Default user configuration
    private static External_User_Configuration__mdt userConfig = 
        External_User_Configuration__mdt.getInstance('Default_Community_User');


    /* *
    * Reset password for user
    * Optionally send reset password to user
    * */

    public static void resetPassword(User user, Boolean sendEmail) {
        System.resetPassword(user.Id, sendEmail);
    }


    /* *
    * Returns only the users with the profile defined in the default External User Configuration
    * Profile name can be defined in Custom Metadata Type
    * */
    
    public static Map<Id, User> getCommunityUsersFromMap(Map<Id, User> mapUsers) {
        Map<Id, User> mapCommunityUsers = new Map<Id, User>();
        String communityProfileId = getCommunityProfileId();
        for (User u : mapUsers.values()) {
            if (u.ProfileId == communityProfileId) {
                mapCommunityUsers.put(u.Id, u);
            }
        }
        return mapCommunityUsers;
    }


    /* *
    * Returns profile id defined in the default External User Configuration
    * Profile name can be defined in Custom Metadata Type
    * */

    public static String getCommunityProfileId() {
        if (communityProfileIdIsSet) {
            return communityProfileId;
        }
        Profile communityProfile = [SELECT Id FROM Profile WHERE Name = :userConfig.Profile_Name__c LIMIT 1];
        communityProfileId = communityProfile.Id;
        communityProfileIdIsSet = true;
        return communityProfileId;
    }


    /* *
    * Returns a collection of permission set ids defined in the default External User Configuration
    * Permission sets to auto-assign can be defined in Custom Metadata Type
    * */

    public static Set<Id> getDefaultPermissionSetIds() {
        if (setPermissionSetIdsIsSet) {
            return setPermissionSetIds;
        }
        setPermissionSetIds = new Set<Id>();
        List<String> setPermSetNames = userConfig.Permission_Sets_to_Auto_Assign__c.replaceAll('\\s+', '').split(',');
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
        return firstName.substring(0, 1) + lastName.substring(0, 4);
    }


    /* *
    * Returns a default User Alias, removing the @domain from the username
    * */

    public static String getNicknameFromUsername(String username) {
        return username.substring(0, username.indexOf('@'));
    }


}
