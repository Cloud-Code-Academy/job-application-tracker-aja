public without sharing class InterviewReminder implements Database.Batchable<sObject>{        

    //Get events scheduled tomorrow       
    public Database.QueryLocator start(Database.BatchableContext bc){
        string query = 'SELECT Id, Owner.Email, OwnerId, Subject, WhoId, WhatId, Location, StartDateTime, EndDateTime, Type FROM Event WHERE DAY_ONLY(StartDateTime) = NEXT_N_DAYS:1'; 
        //AND WhatId IN (SELECT Id FROJob_Application__cM )';
        return Database.getQueryLocator(query);
    }

    //Prepare and process emails
    public void sendInterviewReminderEmails(List<Event> scope){
        System.debug('Scope = ' + scope);
        List<Messaging.SingleEmailMessage> emails = new List<Messaging.SingleEmailMessage>();
        for(Event s : scope){
            System.debug(s.Owner.Email);
           
            if (s.OwnerId != null && s.Owner.Email != null) {
                Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
                email.setToAddresses(new String[] {s.Owner.Email});
                email.setSubject('Reminder: Interview Scheduled Tomorrow');
                email.setPlainTextBody('This is a friendly reminder that an interview is scheduled for tomorrow at ' + s.StartDateTime);
                email.setWhatId(s.WhatId); //Related the email to job application
                emails.add(email);
            }
        }
        if(!emails.isEmpty()){
            System.debug('Emails list is not empty');
            Messaging.sendEmail(emails);
        }
    }

    public void execute(Database.BatchableContext bc, List<Event> scope){
        if(!scope.isEmpty()){
            this.sendInterviewReminderEmails(scope);
        }
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