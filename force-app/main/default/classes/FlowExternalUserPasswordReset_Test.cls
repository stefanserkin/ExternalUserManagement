@isTest
private class FlowExternalUserPasswordReset_Test {

    @isTest
    static void resetPassword() {
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
        FlowExternalUserPasswordReset.Request request;
        request = new FlowExternalUserPasswordReset.Request();
        request.user = u;
        request.sendEmail = false;
        
        FlowExternalUserPasswordReset.resetPassword(
            new List<FlowExternalUserPasswordReset.Request>{ request }
        );
        Test.stopTest();

        User refreshedUser = [SELECT Id, LastPasswordChangeDate FROM User WHERE Id = :u.Id LIMIT 1];
        System.assert(
            refreshedUser.LastPasswordChangeDate >= Datetime.now().addDays(-1), 
            'Password was not reset for user'
        );
    }

}