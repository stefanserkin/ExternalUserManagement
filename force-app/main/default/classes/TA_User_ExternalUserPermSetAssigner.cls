public with sharing class TA_User_ExternalUserPermSetAssigner implements TriggerAction.AfterInsert {

    public void afterInsert(List<User> newList) {
        // Get filtered list of only external users
        List<User> lstExternalUsers = ExternalUserUtilities.getExternalUsers(newList);
        // Assign permission sets asynchronously
        ExternalUserPermSetAssignerQueueable psa = new ExternalUserPermSetAssignerQueueable(lstExternalUsers);
        System.enqueueJob(psa);
    }

}