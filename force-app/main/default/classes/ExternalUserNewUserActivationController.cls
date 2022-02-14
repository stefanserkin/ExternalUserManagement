public with sharing class ExternalUserNewUserActivationController {

    public Id contactId{ get; set; }
    
    public String getProfileName() {
        String profileName = '';
        List<User> lstUsersFromContact = [SELECT Profile.Name FROM User WHERE ContactId = :contactId LIMIT 1];
        if (!lstUsersFromContact.isEmpty()) {
            profileName = lstUsersFromContact[0].Profile.Name;
        }
        return profileName;
    }
    
}