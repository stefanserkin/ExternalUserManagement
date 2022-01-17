@isTest
private class FlowExternalUserActivation_Test {

    @isTest
    static void activateUser() {
        List<Contact> lstContacts = TestDataFactory.createContacts(1);
        insert lstContacts;
        Contact ct = lstContacts.get(0);

        List<FlowExternalUserActivation.UserActivationResult> lstResult;

        Test.startTest();
        FlowExternalUserActivation.UserActivationRequest request;
        request = new FlowExternalUserActivation.UserActivationRequest();
        request.contact  = ct;
        request.email    = ct.Email;
        request.username = ct.Email;
        
        lstResult = FlowExternalUserActivation.activateUser(
            new List<FlowExternalUserActivation.UserActivationRequest>{ request }
        );
        Test.stopTest();

        List<Id> successIds = lstResult.get(0).newUserIds;
        User activatedUser = [SELECT Id, ContactId FROM User WHERE Id IN :successIds LIMIT 1];
        System.assertEquals(ct.Id, activatedUser.ContactId, 'User contactId does not match original contact id');

    }

    @isTest
    static void testDmlException() {
        String invalidUsername = 'invalidusername';

        List<Contact> lstContacts = TestDataFactory.createContacts(1);
        insert lstContacts;
        Contact ct = lstContacts.get(0);

        List<FlowExternalUserActivation.UserActivationResult> lstResult;

        Test.startTest();
        FlowExternalUserActivation.UserActivationRequest request;
        request = new FlowExternalUserActivation.UserActivationRequest();
        request.contact  = ct;
        request.email    = ct.Email;
        request.username = invalidUsername;
        
        lstResult = FlowExternalUserActivation.activateUser(
            new List<FlowExternalUserActivation.UserActivationRequest>{ request }
        );
        Test.stopTest();

        List<String> lstErrors = lstResult.get(0).errors;
        System.assert(lstErrors.get(0).contains('Username'), 
            'Did not receive insert failed dml exception');

    }

}