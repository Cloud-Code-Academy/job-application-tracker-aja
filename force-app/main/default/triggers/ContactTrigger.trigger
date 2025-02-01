trigger ContactTrigger on Contact (after insert, after update) {
    new ContactTriggerHandler().run();
}