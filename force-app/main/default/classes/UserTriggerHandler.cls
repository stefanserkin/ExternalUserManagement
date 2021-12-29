public class UserTriggerHandler extends TriggerHandler {

    private Map<Id, User> mapUsersInTrigger;

    public UserTriggerHandler() {
        this.mapUsersInTrigger = (Map<Id, User>) Trigger.newMap;
    }

    public override void afterInsert() {
        // filter out non-community users
        Map<Id, User> mapCommunityUsers = CommunityUserHelper.getCommunityUsersFromMap(mapUsersInTrigger);
        Set<Id> setCommunityUserIds = new Set<Id>();
        for (Id key : mapCommunityUsers.keySet()) {
            setCommunityUserIds.add(key);
        }
        // assign permission sets
        assignDefaultPermissionSetsAsync(setCommunityUserIds);
    }


    /* *
    * Future method inserts default permission set assignments for a list of ids
    * Must be async to avoid conflict with self-registration
    * */

    @future
    private static void assignDefaultPermissionSetsAsync(Set<Id> setUserIds) {
        Set<Id> setPermSetIdsToAssign = CommunityUserHelper.getDefaultPermissionSetIds();
        List<PermissionSetAssignment> lstPSAs = new List<PermissionSetAssignment>();
        for (Id userId : setUserIds) {
            for (Id permSetId : setPermSetIdsToAssign) {
                lstPSAs.add( new PermissionSetAssignment(AssigneeId = userId, PermissionSetId = permSetId) );
            }
        }
        if (!lstPSAs.isEmpty()) {
            insert lstPSAs;
        }
    }

}
