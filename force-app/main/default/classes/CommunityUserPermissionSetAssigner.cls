/* *
* Future method inserts default permission set assignments for a list of ids
* Must be async to avoid conflict with self-registration
* */

public with sharing class CommunityUserPermissionSetAssigner {

    @future
    public static void assignDefaultPermissionSetsAsync(Set<Id> setUserIds) {
        Set<Id> setPermSetIdsToAssign = CommunityUserHelper.getDefaultPermissionSetIds();
        List<PermissionSetAssignment> lstPSAs = new List<PermissionSetAssignment>();
        for (Id userId : setUserIds) {
            for (Id permSetId : setPermSetIdsToAssign) {
                lstPSAs.add( new PermissionSetAssignment(AssigneeId = userId, PermissionSetId = permSetId) );
            }
        }
        if (!lstPSAs.isEmpty()) {
            try {
                insert lstPSAs;
            } catch (Exception e) {
                System.debug(':::: Error assigning permission sets: ' + e.getMessage());
            }
        }
    }

}
