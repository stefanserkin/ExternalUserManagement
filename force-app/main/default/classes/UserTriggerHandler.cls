public class UserTriggerHandler {
    
    public static void handleTriggerEvent(
        Map<Id, User> mapUsersInTrigger,
        Boolean isInsert,
        Boolean isAfter
    ) {
        if (isInsert && isAfter) {
            ExternalUserService.handleAfterInsert(mapUsersInTrigger);
        }
    }

}
