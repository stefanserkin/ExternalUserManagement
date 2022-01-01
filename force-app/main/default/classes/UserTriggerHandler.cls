public class UserTriggerHandler extends TriggerHandler {

    private Map<Id, User> mapUsersInTrigger;

    public UserTriggerHandler() {
        this.mapUsersInTrigger = (Map<Id, User>) Trigger.newMap;
        // Check for user or profile bypass in Process Switch custom setting
        Process_Switches__c processSwitch = Process_Switches__c.getInstance(UserInfo.getUserId());
        if (processSwitch.Bypass_User__c) {
            TriggerHandler.bypass('UserTriggerHandler');
        }
    }

    public override void afterInsert() {
        // Filter out non-community users before assigning permission sets
        Map<Id, User> mapCommunityUsers = CommunityUserHelper.getCommunityUsersFromMap(mapUsersInTrigger);
        CommunityUserPermissionSetAssigner.assignDefaultPermissionSetsAsync(mapCommunityUsers.keySet());       
    }

}
