public with sharing class StaleJobApplicationDailyCleanup implements Database.Batchable<sObject>{
    public StaleJobApplicationDailyCleanup() {

    }
    public Database.QueryLocator start(Database.BatchableContext bc){
        String query = 'SELECT Id FROM Job_Application__c WHERE Follow_up_Date__c < N_DAYS_AGO:30 AND (Status__c != \'Closed\' AND Status__c != \'Accepted\')';
        return Database.getQueryLocator(query);
    }

    public void execute(Database.BatchableContext bc, List<Job_Application__c> scope){
        delete scope;
    }

    public void finish(Database.BatchableContext bc){
        // Get the ID of the AsyncApexJob representing this batch job
        // from Database.BatchableContext.
        // Query the AsyncApexJob object to retrieve the current job's information.
        AsyncApexJob a = 
            [SELECT Id, Status, NumberOfErrors, JobItemsProcessed,
            TotalJobItems, CreatedBy.Email
            FROM AsyncApexJob WHERE Id = :bc.getJobId()];

        // Send an email to the Apex job's submitter notifying of job completion.
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        String[] toAddresses = new String[] {a.CreatedBy.Email};
        mail.setToAddresses(toAddresses);
        mail.setSubject('Apex Sharing Recalculation ' + a.Status);
        mail.setPlainTextBody
        ('The batch Apex job processed ' + a.TotalJobItems +
        ' batches with '+ a.NumberOfErrors + ' failures.');
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
    }
}