public with sharing class StaleJobApplicationDailyCleanup implements Database.Batchable<sObject>, Schedulable{
    public void execute(SchedulableContext context){
        System.enqueueJob(this);
    }
    public Database.QueryLocator start(Database.BatchableContext bc){
        String query = 'SELECT Id FROM Job_Application__c WHERE Follow_up_Date__c < N_DAYS_AGO:30 AND (Status__c != \'Closed\' AND Status__c != \'Accepted\')';
        return Database.getQueryLocator(query);
    }

    public void execute(Database.BatchableContext bc, List<Job_Application__c> scope){
        List<Job_Application__c> jobsToUpdate = new List<Job_Application__c>();
        for(Job_Application__c job : scope){
            job.Status__c = 'Closed';
            job.Notes__c = 'Closed by an automated process';
            jobsToUpdate.add(job);
        }
        update jobsToUpdate;
    }

    public void finish(Database.BatchableContext bc){
       //To do: send email to user who called method
    }
}