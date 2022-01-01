public class CommunityUserFlowPasswordReset {

    @InvocableMethod(label='Reset User Password' description='Reset password' category='Custom User Actions')
    public static void resetPassword(List<Request> requestList) {
        CommunityUserHelper.resetPassword(requestList.get(0).user, requestList.get(0).sendEmail);
    }
    
    public class Request {
        @InvocableVariable(label='User' required=true)
        public User user;
        @InvocableVariable(label='Send Email' required=true)
        public Boolean sendEmail;
    }

}
