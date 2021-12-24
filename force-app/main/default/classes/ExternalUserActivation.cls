public with sharing class ExternalUserActivation {

    private static External_User_Configuration__mdt userConfig = External_User_Configuration__mdt.getAll().values().get(0);

    @InvocableMethod(label='Activate External User' description='Returns a username for created user' category='Custom User Actions')
    public static List<ActivateUserResult> activateUser(List<ActivateUserRequest> requestList) {

        Set<String> setPermissionSetIds = new Set<String>();
        if (!String.isBlank(userConfig.Permission_Sets_to_Auto_Assign__c)) {
            setPermissionSetIds.addAll(userConfig.Permission_Sets_to_Auto_Assign__c.replaceAll('\\s+','').split(','));
        }

        Profile profile = [SELECT Id FROM Profile WHERE Name LIKE :userConfig.Profile_Name__c LIMIT 1];
        List<PermissionSet> permSetList = [SELECT Id, Name FROM PermissionSet WHERE Name IN :setPermissionSetIds];

        List<User> userList = new List<User>();
        for (ActivateUserRequest req : requestList) {
            // Call external service to get user defaults
            // User u = req.siteName == null ? ExternalUserService.getUserWithDefaults() : ExternalUserService.getUserWithDefaults(req.siteName);
            User u = new User();
            u.ProfileId         = profile.Id;
            u.IsActive          = true;
            u.TimeZoneSidKey    = 'America/New_York';
            U.LocaleSidKey      = 'en_US';
            u.LanguageLocaleKey = 'en_US';
            u.EmailEncodingKey  = 'ISO-8859-1';
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

        List<PermissionSetAssignment> psaList = new List<PermissionSetAssignment>();
        for (User u : userList) {
            for (PermissionSet permSet : permSetList) {
                PermissionSetAssignment psa = new PermissionSetAssignment();
                psa.AssigneeId = u.Id;
                psa.PermissionSetId = permSet.Id;
                psaList.add(psa);
            }    
        }
        if (!psaList.isEmpty()) {
            insert psaList;
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
