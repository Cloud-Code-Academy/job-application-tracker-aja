public without sharing class InterviewReminder implements Database.Batchable<sObject>{        
    //Step 1: Get events that are scheduled tomorrow and related to job application records       
    public Database.QueryLocator start(Database.BatchableContext bc){
        string query =  'SELECT ' +
                        'Id, ' +
                        'Owner.Email, OwnerId, Owner.FirstName,' +
                        'WhoId,' +
                        'WhatId, Location, StartDateTime, EndDateTime, Type FROM Event WHERE DAY_ONLY(StartDateTime) = NEXT_N_DAYS:2'; 
        return Database.getQueryLocator(query);
    }
    //Step 2: Collect Job Application IDs
    public Set<Id> getJobApplicationIds(List<Event> scope){
         Set<Id> jobApplicationIdset = new Set<Id>();
         for(Event evt : scope){
                 jobApplicationIdSet.add(evt.WhatId);
         }
         return jobApplicationIdSet;
    }
    //Step 3: Map relationship between Job Application and Account Name
    public Map<Id, String> mapJobApplicationsToAccount(Set<Id> jobApplicationIdSet){  
        Map<Id, String> jobApplicationToAccountNameMap = new Map<Id, String>();
        String query =  'SELECT Id, Account__r.Name ' +
                        'FROM Job_Application__c ' +
                        'WHERE Id ' +
                        'IN :jobApplicationIdSet';
        List<Job_Application__c> relatedAccounts = Database.query(query);
        for(Job_Application__c relatedAccount : relatedAccounts){
            jobApplicationToAccountNameMap.put(relatedAccount.Id,relatedAccount.Account__r.Name);
        }
        return jobApplicationToAccountNameMap;
    }
    //Step 4: Prepare emails
    public List<Messaging.SingleEmailMessage> prepareEmails(List<Event> scope, Map<Id, String> jobApplicationToAccountNameMap){
        List<Messaging.SingleEmailMessage> emails = new List<Messaging.SingleEmailMessage>();
        for(Event s : scope){
            if (s.OwnerId != null && s.Owner.Email != null) {
                try{
                    Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
                    email.setToAddresses(new String[] {s.Owner.Email});
                    email.setSubject('Reminder: Interview Scheduled Tomorrow');
                    email.setHtmlBody(
                        '<!DOCTYPE html>' +
                        '<html>' +
                            '<head>' +
                                '<meta charset="UTF-8">' +
                                '<title>Interview Reminder</title>' +
                                '</head>' +
                            '<body>' +
                                '<p>Dear ' + s.Owner.FirstName + ',</p>' +
                                '<p>This is a reminder about your upcoming interview for the ' +
                                '<strong>' + jobApplicationToAccountNameMap.get(s.Id) + '</strong> position at ' +
                                '<strong>' + s.Location + '</strong>.</p>' +
                                '<p><strong>Details:</strong></p>' +
                                '<ul>' +
                                    '<li><strong>Date:</strong> ' + s.StartDateTime.date() + '</li>' +
                                    '<li><strong>Time:</strong> ' + s.StartDateTime.format('hh:mm a') + '</li>' +
                                    '<li><strong>Location:</strong> ' + s.Location + '</li>' +
                                '</ul>' +
                                '<p>Best regards,</p>' +
                                '<p>AJA Recruitment Team</p>' +
                            '</body>' +
                        '</html>'
                    );
                    email.setWhatId(s.WhatId); //Relate the email to job application so that it will appear on the feed of the job application record
                    emails.add(email);
                }catch (Exception e){
                    System.debug(e.getMessage());
                } 
            }
        }
        return emails;
    }
    //Step 5: Send emails
    public void sendInterviewReminderEmails(List<Messaging.SingleEmailMessage> emails){
        if(!emails.isEmpty()){
            Messaging.sendEmail(emails);
        }
    }
    //Execute steps 2 to 6
    public void execute(Database.BatchableContext bc, List<Event> scope){
        try{
            if(!scope.isEmpty()){
                Set<Id> jobApplicationIds = this.getJobApplicationIds(scope); //Step 2
                Map<Id, String> jobApplicationToAccountNameMap = this.mapJobApplicationsToAccount(jobApplicationIds); //Step 3
                List<Messaging.SingleEmailMessage> emailList = this.prepareEmails(scope, jobApplicationToAccountNameMap); //Step 4
                this.sendInterviewReminderEmails(emailList); //Step 5
            }
        }catch (Exception e){
            System.debug(e.getMessage());
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