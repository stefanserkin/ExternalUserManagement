@isTest
private class ExternalUserPermSetAssignerQueueableTest {

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

}