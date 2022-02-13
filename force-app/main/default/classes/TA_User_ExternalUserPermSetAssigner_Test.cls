@isTest
private class TA_User_ExternalUserPermSetAssigner_Test {

    @isTest
    static void testAfterInsert() {
        List<Contact> lstContacts = TestDataFactory.createContacts(1);
        insert lstContacts;
        List<User> lstUsers = TestDataFactory.createExternalUsers(lstContacts);

        Test.startTest();
        Database.SaveResult sr = Database.insert(lstUsers.get(0));
        Test.stopTest();

        System.assert(sr.isSuccess(), 'Insert was not successful');
    }

    @isTest
    static void testAfterInsertBulk() {
        List<Contact> lstContacts = TestDataFactory.createContacts(201);
        insert lstContacts;
        List<User> lstUsers = TestDataFactory.createExternalUsers(lstContacts);

        Test.startTest();
        List<Database.SaveResult> lstSRs = Database.insert(lstUsers, true);
        Test.stopTest();

        System.assert(lstSRs.get(0).isSuccess(), 'Bulk insert was not successful');
    }

}