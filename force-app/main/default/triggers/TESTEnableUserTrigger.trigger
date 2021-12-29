trigger TESTEnableUserTrigger on User (after insert) {
    
    List<PermissionSet> lstPermSets = [SELECT Id, Name 
                                         FROM PermissionSet 
                                        WHERE Name IN ('Traction_Rec_Community_User','AG_External_User_Basic_Access','Traction_Pay_User_Access')];
    
    List<PermissionSetAssignment> lstPSAs = new List<PermissionSetAssignment>();
    
    for (User u : Trigger.new) {
        if (u.IsPortalEnabled) {
            for (PermissionSet ps : lstPermSets) {
                PermissionSetAssignment psa = new PermissionSetAssignment();
                psa.AssigneeId = u.Id;
                psa.PermissionSetId = ps.Id;
                lstPSAs.add(psa);
            }
        }
    }

    if (!lstPSAs.isEmpty()) {
        insert lstPSAs;
    }

}