public class TESTUserPasswordService {
    
    @InvocableMethod(label='Reset User Password' description='Reset password' category='Custom User Actions')
    public static void resetPassword(List<Request> requestList) {
        User user = requestList.get(0).user;
        Boolean sendEmail = requestList.get(0).sendEmail;
        System.resetPassword(user.Id, sendEmail);
    }
    
    public class Request {
        @InvocableVariable(label='User')
        public User user;
        @InvocableVariable(label='Send Email')
        public Boolean sendEmail;
    }

}