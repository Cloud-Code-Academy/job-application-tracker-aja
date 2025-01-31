public with sharing class ContactTriggerHandler extends TriggerHandler {

    public override void afterInsert() {
        assignPrimaryContactFromContacts(Trigger.new);
    }

    public override void afterUpdate() {
        assignPrimaryContactFromContacts(Trigger.new);
    }

    public void assignPrimaryContactFromContacts(List<Contact> contacts) {
        //Step 1: Collect Job Application IDs from related Contacts
        Set<Id> jobApplicationIds = new Set<Id>();
        for (Contact contact : contacts) {
            if (contact.Job_Application__c != null) {
                jobApplicationIds.add(contact.Job_Application__c);
            }
        }
        if (jobApplicationIds.isEmpty()) {
            return; //no related job applications to process
        }

        //Step 2: Query job applications with their primary contact
        Map<Id, Job_Application__c> jobApplicationMap = new Map<Id, Job_Application__c>();
        for (Job_Application__c jobApp : [SELECT Id, PrimaryContact__c FROM Job_Application__c WHERE Id IN :jobApplicationIds]) {
            jobApplicationMap.put(jobApp.Id, jobApp);
        }

        //Step 3: Query related contacts for their job applications
        Map<Id, List<Contact>> jobApplicationContactsMap = new Map<Id, List<Contact>>();
        for (Contact relatedContact : [SELECT Id, Job_Application__c FROM Contact WHERE Job_Application__c IN :jobApplicationIds]) {
            Id jobAppId = relatedContact.Job_Application__c;
            if (!jobApplicationContactsMap.containsKey(jobAppId)) {
                jobApplicationContactsMap.put(jobAppId, new List<Contact>()); //Add the jobAppId to the Map
            }
            jobApplicationContactsMap.get(jobAppId).add(relatedContact); //Add the relatedContactsList associatedf to the jobAppId
        }

        //Step 4: Assign primary contacts for each Job Application
        List<Job_Application__c> jobApplicationsToUpdate = new List<Job_Application__c>();
        for (Id jobAppId : jobApplicationContactsMap.keySet()) {
            List<Contact> relatedContacts = jobApplicationContactsMap.get(jobAppId);
            Job_Application__c jobApp = jobApplicationMap.get(jobAppId);

            if(jobApp != null && jobApp.PrimaryContact__c == null && !relatedContacts.isEmpty()) {
                //Assign the first contact as the primary contact if no Primary Contact already
                jobApplicationsToUpdate.add(new Job_Application__c(Id = jobAppId, PrimaryContact__c = relatedContacts[0].Id)); 
            }
        }

        //Step 5: Update the Job Applications
        if (!jobApplicationsToUpdate.isEmpty()) {
            update jobApplicationsToUpdate;
        }
    }
}