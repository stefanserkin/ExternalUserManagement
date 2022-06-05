public without sharing class FlowExternalUserActivation {

    private static final String NICKNAME_FIELD = 'CommunityNickname';
    private static List<Id> newUserIds;
    private static List<String> lstErrors;
    private static List<String> lstErrorFields;

    @InvocableMethod(label='Activate External User' description='Creates a community user based on External Site Setting custom metadata' category='Users')
    public static List<UserActivationResult> activateUser(List<UserActivationRequest> lstRequests) {

        List<User> lstUsers = new List<User>();
        
        newUserIds = new List<Id>();
        lstErrors = new List<String>();
        lstErrorFields = new List<String>();
        
        for (UserActivationRequest req : lstRequests) {
            lstUsers.add(
                getUserFromRequest( req )
            );
        }

        // Insert users initial attempt
        insertUsers( lstUsers, false );

        // Retry for any errors on duplicate nicknames
        if (!lstErrors.isEmpty() && lstErrorFields.contains(NICKNAME_FIELD)) {
            // Insert users retry = true
            insertUsers( lstUsers, true );
        }

        UserActivationResult result = new UserActivationResult();
        result.lstErrors = lstErrors;
        result.lstNewUserIds = newUserIds;
        result.lstUsers = lstUsers;
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
        public List<Id> lstNewUserIds;
        @InvocableVariable(label='User List')
        public List<User> lstUsers;
        @InvocableVariable(label='Errors')
        public List<String> lstErrors;
    }

    private static User getUserFromRequest(UserActivationRequest req) {
        // Gets user with default required fields populated
        User u = ExternalUserUtilities.getUserWithDefaults();
        // Set unique values from arguments
        u.ContactId           = req.contact.Id;
        u.Username            = req.username;
        u.Email               = req.email;
        u.FirstName           = req.contact.FirstName;
        u.LastName            = req.contact.LastName;
        u.Alias               = ExternalUserUtilities.getAliasFromName(req.contact.FirstName, req.contact.LastName);
        u.CommunityNickname   = ExternalUserUtilities.getNicknameFromUsername(req.username);
        return u;
    }

    private static void insertUsers(
        List<User> lstUsers, 
        Boolean isRetry
    ) {
        lstErrors.clear();
        lstErrorFields.clear();

        List<User> lstUsersToInsert = new List<User>();

        if (isRetry) {
            lstUsersToInsert.addAll(
                getFailedUsersWithUniqueNicknames( lstUsers )
            );
        } else {
            lstUsersToInsert = lstUsers;
        }

        if (!lstUsersToInsert.isEmpty()) {
            List<Database.SaveResult> srList = Database.insert(
                lstUsersToInsert, 
                false
            );
            for (Database.SaveResult sr : srList) {
                if (sr.isSuccess()) {
                    newUserIds.add(sr.getId());
                } else {
                    for (Database.error error : sr.getErrors()) {
                        lstErrors.add(error.getMessage());
                        lstErrorFields.addAll(error.getFields());
                    }
                }
            }
        }
    }

    private static List<User> getFailedUsersWithUniqueNicknames(
        List<User> lstUsers
    ) {
        List<User> lstFailedUsers = new List<User>();
        for (User u : lstUsers) {
            if (u.Id == null) {
                u.CommunityNickname = ExternalUserUtilities.getUniqueNicknameFromUsername(
                    u.Username
                );
                lstFailedUsers.add(u);
            }
        }
        return lstFailedUsers;
    }

}