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

        List<Id> successIds = lstResult.get(0).lstNewUserIds;
        User activatedUser = [SELECT Id, ContactId FROM User WHERE Id IN :successIds LIMIT 1];
        System.assertEquals(
            ct.Id, 
            activatedUser.ContactId, 
            'User contactId does not match original contact id'
        );

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

        List<String> lstErrors = lstResult.get(0).lstErrors;
        System.assert(
            lstErrors.get(0).contains('Username'), 
            'Did not receive insert failed dml exception'
        );

    }

    @isTest
    static void testRetryOnDuplicateNicknameError() {

        List<FlowExternalUserActivation.UserActivationResult> lstResult;
        lstResult = new List<FlowExternalUserActivation.UserActivationResult>();

        List<Contact> lstContacts = TestDataFactory.createContacts(2);
        insert lstContacts;

        // Enable first user
        Contact ct1 = lstContacts.get(0);
        ct1.Email = 'duplicate@gmail.com';
        FlowExternalUserActivation.UserActivationRequest request1;
        request1 = new FlowExternalUserActivation.UserActivationRequest();
        request1.contact  = ct1;
        request1.email    = ct1.Email;
        request1.username = ct1.Email;
        lstResult.addAll(
            FlowExternalUserActivation.activateUser(
                new List<FlowExternalUserActivation.UserActivationRequest>{ request1 }
            )
        );

        // Enable second user with the same nickname, different domain
        Contact ct2 = lstContacts.get(1);
        ct2.Email = 'duplicate@yahoo.com';

        Test.startTest();
        FlowExternalUserActivation.UserActivationRequest request2;
        request2 = new FlowExternalUserActivation.UserActivationRequest();
        request2.contact  = ct2;
        request2.email    = ct2.Email;
        request2.username = ct2.Email;
        
        lstResult.addAll(
            FlowExternalUserActivation.activateUser(
                new List<FlowExternalUserActivation.UserActivationRequest>{ request2 }
            )
        );
        Test.stopTest();

        Set<Id> successIds = new Set<Id>();
        for (FlowExternalUserActivation.UserActivationResult res : lstResult) {
            successIds.addAll(res.lstNewUserIds);
        }

        List<User> lstActivatedUsers = [SELECT Id, ContactId, CommunityNickname FROM User WHERE Id IN :successIds];

        System.assertNotEquals(
            lstActivatedUsers.get(0).CommunityNickname, 
            lstActivatedUsers.get(1).CommunityNickname,
            'Nicknames should be unique'
        );
    }


}