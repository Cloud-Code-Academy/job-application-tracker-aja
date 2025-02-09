/**
 * @description Handles logic for sending reminder emails
 * @author Jonathan Lyles
 * @createc 2025-01-31
 */
public without sharing class InterviewReminder implements Database.Batchable<sObject>, Schedulable{        
    /**
     * @description      Implement the execute method required by the Schedulable interface
     * @param SchedulableContext sc
     */
     public void execute(SchedulableContext sc) {
        InterviewReminder batchJob = new InterviewReminder();
        // Run the batchable with a batch size of 200
        Database.executeBatch(batchJob, 200);
        }
    /**
     * @description: Implements the start method required by Database.Batchable interface. Gets events that are scheduled tomorrow and related to job application records 
     * @param Database.BatchableContext bc
     * @return Database.QueryLocator - Results of query (Events scheduled the next business day)
    **/
    public Database.QueryLocator start(Database.BatchableContext bc){
        //Determine the next business day
        Date today = Date.today();
        Date startOfWeek = today.toStartOfWeek();
        Integer dayNumber = startOfWeek.daysBetween(today);
        String nextBusinessDay = 'NEXT_N_DAYS:1';
        
        switch on dayNumber {
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
    /**
     * @description This method takes a list of events that are scheduled for the next business day and returns a set of related job application IDs
     * @param List<Event> scope - List of events scheduled the next business day
     * @return Set<Id> jobApplicationIdSet - Set of Job_Application__c record IDs
     */
    public Set<Id> getJobApplicationIds(List<Event> scope){
         Set<Id> jobApplicationIdset = new Set<Id>();
         for(Event evt : scope){
                 jobApplicationIdSet.add(evt.WhatId);
         }
         return jobApplicationIdSet;
    }
    /**
     * @description This method accepts a list of job application IDs and returns their field values which we need to create maps
     * @param Set<Id> jobApplicationIdSet - which was return from getJobApplicationIds()
     * @return List<Job_Application__c> - List of job application with the following fields: Id, Name, Account__r.Name
     */
    public List<Job_Application__c> getJobApplicationList(Set<Id> jobApplicationIdSet){
        String query =  'SELECT Id, Name, Account__r.Name ' +
                        'FROM Job_Application__c ' +
                        'WHERE Id ' +
                        'IN :jobApplicationIdSet';
        List<Job_Application__c> jobAppList = Database.query(query);
        return jobAppList;
    } 
    /**
     * @description This method accepts the jobAppList returned from getJobAppplicationList() as a parameter and returns a map of job application Id to account name
     * @param List<Job_Application__c> jobAppList
     * @return Map<Id, String> jobApplicationToAccountNameMap
     */
    public Map<Id, String> mapJobApplicationsToAccount(List<Job_Application__c> jobAppList){  
        Map<Id, String> jobApplicationToAccountNameMap = new Map<Id, String>();
        for(Job_Application__c jobApp : jobAppList){
            jobApplicationToAccountNameMap.put(jobApp.Id, jobApp.Account__r.Name);
        }
        return jobApplicationToAccountNameMap;
    }
    /**
     * @description This method accepts the jobAppList returned from getJobApplicationList() as a parameter and returns a map job application id to job application name
     * @param List<Job_Application__c> jobAppList
     * @return Map<Id, String> - jobApplicationIdToJobApplicationNameMap
     */
    public Map<Id, String> mapJobApplicationIdToJobApplicationName(List<Job_Application__c> jobAppList){
        Map<Id, String> jobApplicationIdToJobApplicationNameMap = new Map<Id, String>();
        for(Job_Application__c jobApp : jobAppList){
            jobApplicationIdToJobApplicationNameMap.put(jobApp.Id, jobApp.Name);
        }
        return jobApplicationIdToJobApplicationNameMap;
    }
    /**
     * @description prepares the interview reminder emails
     * @param List<Event> scope - List of interviews on the next business day 
     * @param Map<Id, String> jobApplicationToAccountNameMap - relates the job application to the company name
     * @param Map<Id, String> jobApplicationIdToJobApplicationNameMap - relates the job application id to the job application name
     * @return List<Messaging.SingleEmailMessage> - The list of email to be sent
     */
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
    /**
     * @description This method sends the emails returned from prepareEmails()
     * @param List<Messaging.SingleEmailMessage> - The list of emails prepared and return from prepareEmails()
     */
    public void sendInterviewReminderEmails(List<Messaging.SingleEmailMessage> emails){
        if(!emails.isEmpty()){
            List<Messaging.SendEmailResult> emailResults =  Messaging.sendEmail(emails, FALSE);
            for(Messaging.SendEmailResult emailResult : emailResults){
                System.debug(emailResult.isSuccess());
            }
        }
    }
    /**
     * @description This method runs the required execute method of Database.Batchable interface
     * @param Database.BatchableContext bc
     * @param List<Event> scope
     */
    public void execute(Database.BatchableContext bc, List<Event> scope){
        try{
            if(!scope.isEmpty()){
                Set<Id> jobApplicationIds = this.getJobApplicationIds(scope); 
                List<Job_Application__c> jobsList = this.getJobApplicationList(jobApplicationIds);
                Map<Id, String> jobApplicationToAccountNameMap = this.mapJobApplicationsToAccount(jobsList); 
                Map<Id, String> jobApplicationToJobApplicationNameMap = this.mapJobApplicationIdToJobApplicationName(jobsList);
                List<Messaging.SingleEmailMessage> emailList = this.prepareEmails(scope, jobApplicationToAccountNameMap, jobApplicationToJobApplicationNameMap); 
                this.sendInterviewReminderEmails(emailList);
            }
        }catch (Exception e){
            System.debug(LoggingLevel.ERROR, e.getMessage());
        }
    }
    /**
     * @description This method is required from the Database.Batchable interface
     * @To-Do: Send email to job requester with results of the job
     */
    public void finish(Database.BatchableContext bc){
    }
}