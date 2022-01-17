public with sharing class ExternalUserPermSetAssignerQueueable implements Queueable {

    public List<User> lstExternalUsers;
    public ExternalUserPermSetAssignerQueueable(List<User> lstExternalUsersPassed) {
        this.lstExternalUsers = lstExternalUsersPassed;
    }

    public void execute(QueueableContext ctx) {
        String jobId = '' + ctx.getJobId();
        System.debug('Begin: executing queueable job: ' + jobId);
        Set<Id> setPermSetIdsToAssign = ExternalUserUtilities.getDefaultPermissionSetIds();
        List<PermissionSetAssignment> lstPSAs = new List<PermissionSetAssignment>();
        for (User u : lstExternalUsers) {
            for (Id permSetId : setPermSetIdsToAssign) {
                lstPSAs.add( new PermissionSetAssignment(AssigneeId = u.Id, PermissionSetId = permSetId) );
            }
        }
        if (!lstPSAs.isEmpty()) {
            try {
                insert lstPSAs;
            } catch (Exception e) {
                System.debug('Error executing the job [' + jobId + ']: ' + e.getMessage());
            } finally {
                System.debug('Completed: execution of queueable job: ' + jobId);
            }
        }
    }

}