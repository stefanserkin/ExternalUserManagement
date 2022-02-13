public class FlowExternalUserPasswordReset {

    @InvocableMethod(label='Reset User Password' description='Reset password for a specified user' category='Users')
    public static void resetPassword(List<Request> requestList) {
        ExternalUserUtilities.resetPassword(requestList.get(0).user, requestList.get(0).sendEmail);
    }
    
    public class Request {
        @InvocableVariable(label='User' required=true)
        public User user;
        @InvocableVariable(label='Send Email' required=true)
        public Boolean sendEmail;
    }

}