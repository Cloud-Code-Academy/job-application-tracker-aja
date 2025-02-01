trigger EventTrigger on Event (before insert, before update) {
    new EventTriggerHandler().run();
}