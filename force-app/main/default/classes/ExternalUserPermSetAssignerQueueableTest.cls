@isTest
private class ExternalUserPermSetAssignerQueueableTest {

    private static final String INVALID_PERM_SET_NAME = 'View_Donations';

    @isTest
    static void testAsyncPermissionSetAssignment() {
        // Create contact and user
        List<Contact> lstContacts = TestDataFactory.createContacts(1);
        insert lstContacts;
        List<User> lstExternalUsers = TestDataFactory.createExternalUsers(lstContacts);

        Test.startTest();
        insert lstExternalUsers;
        Test.stopTest();

        // After all async processing, get permission set assignments for user
        List<PermissionSetAssignment> lstPSAs = [
            SELECT Id, PermissionSetId FROM PermissionSetAssignment WHERE AssigneeId = :lstExternalUsers.get(0).Id
        ];
        Set<Id> setAssignedPermSetIds = new Set<Id>();
        for (PermissionSetAssignment psa : lstPSAs) {
            setAssignedPermSetIds.add(psa.PermissionSetId);
        }

        // Get expected permission set ids for comparison
        Set<Id> setExpectedPermSetIds = ExternalUserUtilities.getDefaultPermissionSetIds();
        
        // Evaluate permission set assignments
        for (Id permSetId : setExpectedPermSetIds) {
            System.assert(setAssignedPermSetIds.contains(permSetId), 
                'Did not find expected permission set id assignment');
        }
    }

    @isTest
    static void testFailedPermSetAssignment() {

        // Set ExternalUserUtilities class to test mode
        ExternalUserUtilities.testPermissionSetsMode = true;
        // Add permission set incompatible with community licenses
        ExternalUserUtilities.testPermissionSetNameToAdd = INVALID_PERM_SET_NAME;

        // Create contact and user
        List<Contact> lstContacts = TestDataFactory.createContacts(1);
        insert lstContacts;
        List<User> lstExternalUsers = TestDataFactory.createExternalUsers(lstContacts);

        // Insert user
        Test.startTest();
        List<Database.SaveResult> lstSRs = Database.insert(lstExternalUsers, false);
        Test.stopTest();

        for (Database.SaveResult sr : lstSRs) {
            System.assert(sr.isSuccess(), 'User was not saved successfully');
        }
        
    }

}