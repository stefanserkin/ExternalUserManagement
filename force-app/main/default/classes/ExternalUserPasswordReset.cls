public with sharing class ExternalUserPasswordReset {

    @InvocableMethod(label='Reset User Password' description='Reset password' category='Custom User Actions')
    public static void resetPassword(List<Request> requestList) {
        User user = requestList.get(0).user;
        Boolean sendEmail = requestList.get(0).sendEmail == null ? false : requestList.get(0).sendEmail;
        ExternalUserService.resetPassword(user, sendEmail);
    }
    
    public class Request {
        @InvocableVariable(label='User' required=true)
        public User user;
        @InvocableVariable(label='Send Email')
        public Boolean sendEmail;
    }

}
