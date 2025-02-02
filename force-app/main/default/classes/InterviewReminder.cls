/**
 * @description Handles logic for sending reminder emails
 * @author Jonathan Lyles
 * @createc 2025-01-31
 */

public without sharing class InterviewReminder implements Database.Batchable<sObject>, Schedulable{        
    
    /**
     * @description      Implement the execute method required by the Schedulable interface
     */
     public void execute(SchedulableContext sc) {
        InterviewReminder batchJob = new InterviewReminder();
        // Run the batchable with a batch size of 200
        Database.executeBatch(batchJob, 200);
        }

    //Bathable Step 1: Get events that are scheduled tomorrow and related to job application records       
    public Database.QueryLocator start(Database.BatchableContext bc){
        
        //Determine the next business day
        Date today = Date.today();
        Date startOfWeek = today.toStartOfWeek();
        Integer dayNumber = startOfWeek.daysBetween(today);
        String nextBusinessDay = 'NEXT_N_DAYS:1';
        
        switch on dayNumber {
            when 0,1,2,3,4 {
                //do nothing
            }
            when 5{
                nextBusinessDay = 'NEXT_N_DAYS:3';
            }
            when 6{
                nextBusinessDay = 'NEXT_N_DAYS:2';
            }
        }

        //Get events scheduled on the next business day
        string query =  'SELECT ' +
                        'Id, ' +
                        'Owner.Email, OwnerId, Owner.FirstName,' +
                        'WhoId,' +
                        'WhatId, Location, StartDateTime, EndDateTime, Type FROM Event WHERE DAY_ONLY(StartDateTime) = ' + nextBusinessDay; 
        return Database.getQueryLocator(query);
    }
    //Batchable Step 2: Collect Job Application IDs
    public Set<Id> getJobApplicationIds(List<Event> scope){
         Set<Id> jobApplicationIdset = new Set<Id>();
         for(Event evt : scope){
                 jobApplicationIdSet.add(evt.WhatId);
         }
         return jobApplicationIdSet;
    }
    //Batchable Step 3: Query values needed to build maps
    public List<Job_Application__c> getJobApplicationList(Set<Id> jobApplicationIdSet){
        String query =  'SELECT Id, Name, Account__r.Name ' +
                        'FROM Job_Application__c ' +
                        'WHERE Id ' +
                        'IN :jobApplicationIdSet';
        List<Job_Application__c> jobAppList = Database.query(query);
        return jobAppList;
    } 
    //Batchable Step 4: Map relationship between Job Application and Account Name
    public Map<Id, String> mapJobApplicationsToAccount(List<Job_Application__c> jobAppList){  
        Map<Id, String> jobApplicationToAccountNameMap = new Map<Id, String>();
        for(Job_Application__c jobApp : jobAppList){
            jobApplicationToAccountNameMap.put(jobApp.Id, jobApp.Account__r.Name);
        }
        return jobApplicationToAccountNameMap;
    }
    //Batchable Step 5: Map Job Application Id to Job Application Name
    public Map<Id, String> mapJobApplicationIdToJobApplicationName(List<Job_Application__c> jobAppList){
        Map<Id, String> jobApplicationIdToJobApplicationNameMap = new Map<Id, String>();
        for(Job_Application__c jobApp : jobAppList){
            jobApplicationIdToJobApplicationNameMap.put(jobApp.Id, jobApp.Name);
        }
        return jobApplicationIdToJobApplicationNameMap;
    }
    //Batchable Step 6: Prepare emails
    public List<Messaging.SingleEmailMessage> prepareEmails(List<Event> scope, Map<Id, String> jobApplicationToAccountNameMap, Map<Id, String> jobApplicationIdToJobApplicationNameMap ){
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
                                '<p>This is a reminder about your upcoming interview for the ' + jobApplicationIdToJobApplicationNameMap.get(s.WhatId) + 
                                ' position at '+
                                '<strong>' + jobApplicationToAccountNameMap.get(s.WhatId) + '</strong>' +
                                '<p><strong>Details:</strong></p>' +
                                '<ul>' +
                                    '<li><strong>Date:</strong> ' + s.StartDateTime.date().format() + '</li>' +
                                    '<li><strong>Time:</strong> ' + s.StartDateTime.format('hh:mm a') + '</li>' +
                                    (s.Location != null ? '<li><strong>Location:</strong> ' + s.Location + '</li>' : '') +
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
    //Batchable Step 7: Send emails
    public void sendInterviewReminderEmails(List<Messaging.SingleEmailMessage> emails){
        if(!emails.isEmpty()){
            List<Messaging.SendEmailResult> emailResults =  Messaging.sendEmail(emails, FALSE);
            for(Messaging.SendEmailResult emailResult : emailResults){
                System.debug(emailResult.isSuccess());
            }
        }
    }
    //Batchable Step 6: Execute steps 2 to 7
    public void execute(Database.BatchableContext bc, List<Event> scope){
        try{
            if(!scope.isEmpty()){
                //Step 2
                System.debug('Scope is not empty');
                Set<Id> jobApplicationIds = this.getJobApplicationIds(scope); 
                System.debug('Job Application Ids: ' + jobApplicationIds);
                //Step 3
                List<Job_Application__c> jobsList = this.getJobApplicationList(jobApplicationIds);
                System.debug('jobsList: ' + jobsList );
                //Step 4
                Map<Id, String> jobApplicationToAccountNameMap = this.mapJobApplicationsToAccount(jobsList); 
                System.debug(jobApplicationToAccountNameMap);
                //Step 5
                Map<Id, String> jobApplicationToJobApplicationNameMap = this.mapJobApplicationIdToJobApplicationName(jobsList);
                System.debug(jobApplicationToJobApplicationNameMap);
                //Step 6
                List<Messaging.SingleEmailMessage> emailList = this.prepareEmails(scope, jobApplicationToAccountNameMap, jobApplicationToJobApplicationNameMap); 
                System.debug(emailList);
                //Step 7
                this.sendInterviewReminderEmails(emailList);
            }
        }catch (Exception e){
            System.debug(e.getMessage());
        }
    }
    //Batchable Step 7: Retrieve job info and send to administrator
    public void finish(Database.BatchableContext bc){
      //send email to job requester with job results
    }
}