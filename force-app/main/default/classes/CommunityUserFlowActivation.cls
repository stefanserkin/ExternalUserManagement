public class CommunityUserFlowActivation {

    @InvocableMethod(label='Activate External User' description='Creates a community user based on External User Configuration custom metadata' category='Custom User Actions')
    public static List<UserActivationResult> activateUser(List<UserActivationRequest> lstRequests) {

        List<User> userList = new List<User>();
        for (UserActivationRequest req : lstRequests) {
            // Gets user with default required fields populated
            User u = CommunityUserHelper.getUserWithDefaults();
            // Set unique values from arguments
            u.ContactId           = req.contact.Id;
            u.Username            = req.username;
            u.Email               = req.email;
            u.FirstName           = req.contact.FirstName;
            u.LastName            = req.contact.LastName;
            u.Alias               = CommunityUserHelper.getAliasFromName(req.contact.FirstName, req.contact.LastName);
            u.CommunityNickname   = CommunityUserHelper.getNicknameFromUsername(req.username);
            userList.add(u);
        }

        List<Id> newUserIds    = new List<Id>();
        List<String> errorList = new List<String>();

        List<Database.SaveResult> srList = Database.insert(userList, false);
        for (Database.SaveResult sr : srList) {
            if (sr.isSuccess()) {
                newUserIds.add(sr.getId());
            } else {
                for (Database.error error : sr.getErrors()) {
                    errorList.add(error.getMessage());
                }
            }
        }

        UserActivationResult result = new UserActivationResult();
        result.errors = errorList;
        result.newUserIds = newUserIds;
        List<UserActivationResult> lstResults = new List<UserActivationResult>();
        lstResults.add(result);
        return lstResults;

    }

    public class UserActivationRequest {
        @InvocableVariable(label='Contact' required=true)
        public Contact contact;
        @InvocableVariable(label='Username' required=true)
        public String username;
        @InvocableVariable(label='Email' required=true)
        public String email;
    }

    public class UserActivationResult {
        @InvocableVariable(label='New Users')
        public List<Id> newUserIds;
        @InvocableVariable(label='Errors')
        public List<String> errors;
    }

}
