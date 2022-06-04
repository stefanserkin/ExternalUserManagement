@isTest
private class ExternalUserUtilities_Test {

    private static final String INVALID_PERM_SET_NAME = 'View_Donations';

    @isTest
    static void testResetPassword() {

        List<Contact> lstContacts = TestDataFactory.createContacts(1);
        insert lstContacts;
        Contact ct = lstContacts.get(0);

        User u = ExternalUserUtilities.getUserWithDefaults();
        u.ContactId           = ct.Id;
        u.Username            = ct.Email;
        u.Email               = ct.Email;
        u.FirstName           = ct.FirstName;
        u.LastName            = ct.LastName;
        u.Alias               = ExternalUserUtilities.getAliasFromName(ct.FirstName, ct.LastName);
        u.CommunityNickname   = ExternalUserUtilities.getNicknameFromUsername(ct.Email);
        insert u;

        Test.startTest();
        ExternalUserUtilities.resetPassword(u, false);
        Test.stopTest();

        User refreshedUser = [SELECT Id, LastPasswordChangeDate FROM User WHERE Id = :u.Id LIMIT 1];
        System.assert(
            refreshedUser.LastPasswordChangeDate >= Datetime.now().addDays(-1), 
            'Password was not reset for user'
        );
        
    }

    @isTest
    static void testGetExternalUsers() {
        List<Contact> lstContacts = TestDataFactory.createContacts(10);
        insert lstContacts;
        List<User> lstUsers = TestDataFactory.createExternalUsers(lstContacts);
        insert lstUsers;

        List<User> lstExternalUsers;

        Test.startTest();
        lstExternalUsers = ExternalUserUtilities.getExternalUsers(lstUsers);
        Test.stopTest();

        System.assertEquals(lstUsers.size(), lstExternalUsers.size(), 'External user list size did not match user list');

    }

    @isTest
    static void testGetExternalProfileId() {
        Test.startTest();
        String profileId = ExternalUserUtilities.getExternalProfileId();
        Test.stopTest();
        System.assert(!String.isBlank(profileId), 'Did not receive a profile id');
    }

    @isTest
    static void testGetExternalProfileIdFromCache() {
        String profileId = ExternalUserUtilities.getExternalProfileId();
        Test.startTest();
        String profileIdFromCache = ExternalUserUtilities.getExternalProfileId();
        Test.stopTest();
        System.assertEquals(profileId, profileIdFromCache, 'Second profile id response did not match the first');
    }

    @isTest
    static void testGetDefaultPermissionSetIds() {
        Boolean permSetNotFound = false;

        Test.startTest();
        // Get permission set ids from utilities class
        Set<Id> setPermSetIds = ExternalUserUtilities.getDefaultPermissionSetIds();
        Test.stopTest();

        // Check custom metadata type to verify
        External_Site_Setting__mdt siteSetting = External_Site_Setting__mdt.getInstance('Default');
        List<String> setPermSetNames = siteSetting.Permission_Sets_to_Auto_Assign__c.replaceAll('\\s+', '').split(',');
        List<PermissionSet> lstPermSets = [SELECT Id FROM PermissionSet WHERE Name IN :setPermSetNames LIMIT 10000];
        for (PermissionSet ps : lstPermSets) {
            System.assert(setPermSetIds.contains(ps.Id), 'Expected permission set id not found in result');
        }
    }

    @isTest
    static void testGetDefaultPermissionSetIdsFromCache() {
        // Get permission set ids from utilities class
        Set<Id> setPermSetIds = ExternalUserUtilities.getDefaultPermissionSetIds();

        Test.startTest();
        // Retrieve ids a second time
        Set<Id> setPermSetIdsFromCache = ExternalUserUtilities.getDefaultPermissionSetIds();
        Test.stopTest();

        // Verify results are the same
        System.assertEquals(setPermSetIds.size(), setPermSetIdsFromCache.size(), 
            'Results from cache do not match original results');
    }

    @isTest
    static void testGetDefaultPermissionSetIdsWithInvalidId() {
        // Set test mode and invalid permission set to add
        ExternalUserUtilities.testPermissionSetsMode = true;
        ExternalUserUtilities.testPermissionSetNameToAdd = INVALID_PERM_SET_NAME;

        // Get permission set ids from utilities class
        Test.startTest();
        Set<Id> setPermSetIds = ExternalUserUtilities.getDefaultPermissionSetIds();
        Test.stopTest();

        PermissionSet invalidPermSet = [
            SELECT Id, Name FROM PermissionSet WHERE Name = :INVALID_PERM_SET_NAME LIMIT 1
        ];

        // Verify invalid permission set was returned
        System.assert(setPermSetIds.contains(invalidPermSet.Id), 'Did not find invalid perm set id in results');
    }

    
    @isTest
    static void testGetAliasFromName() {
        String firstName = 'Benny';
        String lastName  = 'Agbayani';

        Test.startTest();
        String alias = ExternalUserUtilities.getAliasFromName(firstName, lastName);
        Test.stopTest();

        System.assert(alias.length() > 0, 'Alias was not set');
    }

    @isTest
    static void testGetNicknameFromUsername() {
        String username = 'bagbayani@metsies.com';

        Test.startTest();
        String nickname = ExternalUserUtilities.getNicknameFromUsername(username);
        Test.stopTest();

        String expectedNickname = username.contains('@') ? username.substring(0, username.indexOf('@')) : username;

        System.assert(nickname.length() > 0, 'Nickname was not set');
        System.assertEquals(expectedNickname, nickname, 'Received unexpected nickname');
    }

    @isTest
    static void testGetUniqueNicknameFromUsername() {
        String username = 'bagbayani@metsies.com';

        Test.startTest();
        String nickname = ExternalUserUtilities.getNicknameFromUsername(username);
        Test.stopTest();

        String standardNickname = ExternalUserUtilities.getUniqueNicknameFromUsername(username);

        System.assert(nickname.length() > 0, 'Nickname was not set');
        System.assertNotEquals(standardNickname, nickname, 'Nickname is not unique');
    }

    @isTest
    static void testGetUserWithDefaults() {
        User u;

        Test.startTest();
        u = ExternalUserUtilities.getUserWithDefaults();
        Test.stopTest();

        String expectedProfileId = ExternalUserUtilities.getExternalProfileId();

        System.assertEquals(expectedProfileId, u.ProfileId, 'Received unexpected profile id');
        System.assertEquals(UserInfo.getLocale(), u.LocaleSidKey, 'Received unexpected locale sid key');
        System.assert(u.IsActive, 'User is not active');

    }

    


}