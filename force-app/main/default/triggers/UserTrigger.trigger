trigger UserTrigger on User (after insert) {
    UserTriggerHandler.handleTriggerEvent(Trigger.newMap, Trigger.isInsert, Trigger.isAfter);
}