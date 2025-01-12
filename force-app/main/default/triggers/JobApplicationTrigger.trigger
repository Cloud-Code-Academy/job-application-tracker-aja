trigger JobApplicationTrigger on Job_Application__c (after update) {
    new JobApplicationTriggerHandler().run();
}