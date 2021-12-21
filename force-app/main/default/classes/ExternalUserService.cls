public with sharing class ExternalUserService {

    private static External_User_Configuration__mdt userConfig = External_User_Configuration__mdt.getAll().values().get(0);
    private static Boolean permSetIdsAreSet = false;
    private static Set<String> setPermSetIds;

    public static void handleNewUsers(Map<Id, User> mapUsers) {
        List<PermissionSetAssignment> lstPSAs = new List<PermissionSetAssignment>();
        Map<Id, User> mapExternalUsers = getExternalUsersFromUserMap(mapUsers);
        Set<String> setIdsToAssign = getAutoAssignedPermissionSetIds();
        // Create permission set assignments
        if (!mapExternalUsers.isEmpty() && !setIdsToAssign.isEmpty()) {
            for (Id key : mapExternalUsers.keySet()) {
                for (String strId : setIdsToAssign) {
                    PermissionSetAssignment psa = new PermissionSetAssignment();
                    psa.AssigneeId = key;
                    psa.PermissionSetId = strId;
                    lstPSAs.add(psa);
                }
            }
        }
        insert lstPSAs;
    }

    private static Map<Id, User> getExternalUsersFromUserMap(Map<Id, User> mapUsers) {
        Map<Id, User> mapExternalUsers = new Map<Id, User>();
        for (User u : mapUsers.values()) {
            if (u.IsPortalEnabled) {
                mapExternalUsers.put(u.Id, u);
            }
        }
        return mapExternalUsers;
    }

    private static Set<String> getAutoAssignedPermissionSetIds() {
        // Return cached results
        if (permSetIdsAreSet) {
            return setPermSetIds;
        } else {
            setPermSetIds = new Set<String>();
        }
        // Return empty list if assignments are blank
        if (String.isBlank(userConfig.Permission_Sets_to_Auto_Assign__c)) {
            setPermSetIds = new Set<String>();
            permSetIdsAreSet = true;
            return setPermSetIds;
        }
        // Query for permission sets based on ps names in mdt record
        String permSetNameString = userConfig.Permission_Sets_to_Auto_Assign__c;
        List<String> lstPermSetNames = permSetNameString.replaceAll('\\s+', '').split(',');
        String query = 'SELECT Id FROM PermissionSet WHERE Name IN (';
        Boolean isFirstItem = true;
        for (String name : lstPermSetNames) {
            if (!isFirstItem) {
                query += ',';
            } else {
                isFirstItem = false;
            }
            query += '\'' + name + '\'';
        }
        query += ')';

        List<PermissionSet> lstQueryResults = Database.query(query);

        for (PermissionSet ps : lstQueryResults) {
            setPermSetIds.add(ps.Id);
        }
        permSetIdsAreSet = true;
        return setPermSetIds;
    }
    
}
