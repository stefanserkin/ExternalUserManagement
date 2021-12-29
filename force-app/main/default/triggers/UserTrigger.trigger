trigger UserTrigger on User (after insert) {
    new UserTriggerHandler().run();
}