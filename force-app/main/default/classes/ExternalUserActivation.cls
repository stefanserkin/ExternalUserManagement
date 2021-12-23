public with sharing class ExternalUserActivation {

    @InvocableMethod(label='Activate External User' description='Returns a username for created user' category='Custom User Actions')
    public static List<ActivateUserResult> activateUser(List<ActivateUserRequest> request) {
        Id contactId     = request.get(0).contactId;
        String username  = request.get(0).username;
        String email     = request.get(0).email;
        String firstName = request.get(0).firstName;
        String lastName  = request.get(0).lastName;

        // CALL EXTERNAL USER SERVICE TO GET USER DEFAULTS
        User u = ExternalUserService.getUserWithDefaults();
        // SET CONTACT SPECIFIC VALUES
        u.ContactId = contactId;
        u.Username  = username;
        u.Email     = email;
        u.FirstName = firstName;
        u.LastName  = lastName;
        u.Alias     = ExternalUserService.getAliasFromName(firstName, lastName);
        // INSERT USER - CAPTURE SUCCESS
        Database.SaveResult sr = Database.insert(u);

        ActivateUserResult result = new ActivateUserResult();
        result.isSuccess = sr.isSuccess();
        List<ActivateUserResult> resultList = new List<ActivateUserResult>();
        resultList.add(result);
        return resultList;
    }
    
    public class ActivateUserRequest {
        @InvocableVariable(label='Contact ID' required=true)
        public Id contactId;
        @InvocableVariable(label='Username' required=true)
        public String username;
        @InvocableVariable(label='Email' required=true)
        public String email;
        @InvocableVariable(label='First Name' required=true)
        public String firstName;
        @InvocableVariable(label='Last Name' required=true)
        public String lastName;
    }

    public class ActivateUserResult {
        @InvocableVariable(label='Activation Successful')
        public Boolean isSuccess;
    }

}
