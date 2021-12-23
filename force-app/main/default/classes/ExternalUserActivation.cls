public with sharing class ExternalUserActivation {

    @InvocableMethod(label='Activate External User' description='Returns a username for created user' category='Custom User Actions')
    public static List<ActivateUserResult> activateUser(List<ActivateUserRequest> requestList) {

        List<User> userList = new List<User>();
        for (ActivateUserRequest req : requestList) {
            // Call external service to get user defaults
            User u = req.siteName == null ? ExternalUserService.getUserWithDefaults(req.siteName) : ExternalUserService.getUserWithDefaults();
            // Set unique values from arguments
            u.ContactId           = req.contactId;
            u.Username            = req.username;
            u.Email               = req.email;
            u.FirstName           = req.firstName;
            u.LastName            = req.lastName;
            u.Alias               = ExternalUserService.getAliasFromName(req.firstName, req.lastName);
            u.Authorized_Sites__c = req.siteName == null ? '' : req.siteName;
            userList.add(u);
        }

        List<Id> newUserIds = new List<Id>();
        List<String> errorList = new List<String>();

        List<Database.SaveResult> srList = Database.insert(userList, true);
        for (Database.SaveResult sr : srList) {
            if (sr.isSuccess()) {
                newUserIds.add(sr.getId());
            } else {
                for (Database.error error : sr.getErrors()) {
                    errorList.add(error.getMessage());
                }
            }
        }

        ActivateUserResult result = new ActivateUserResult();
        result.errors = errorList;
        result.newUserIds = newUserIds;
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
        @InvocableVariable(label='Site Name')
        public String siteName;
    }

    public class ActivateUserResult {
        @InvocableVariable(label='New Users')
        public List<Id> newUserIds;
        @InvocableVariable(label='Errors')
        public List<String> errors;
    }

}
