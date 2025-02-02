/**
 * @description This class checks for stale job application records and closes them
 * @author Jonathan Lyles
 * @created 2025-01-31
 */
public with sharing class StaleJobApplicationDailyCleanup implements Database.Batchable<sObject>, Schedulable{
    /**
     * @description Queues the job
     */
    public void execute(SchedulableContext context){
        System.enqueueJob(this);
    }
    /**
     * @description Queries for stale jobs
     * @return Data.QueryLocator A list of stale jobs
     */
    public Database.QueryLocator start(Database.BatchableContext bc){
        String query = 'SELECT Id FROM Job_Application__c WHERE Follow_up_Date__c < N_DAYS_AGO:30 AND (Status__c != \'Closed\' AND Status__c != \'Accepted\')';
        return Database.getQueryLocator(query);
    }
    /**
     * @description Executes the batch job
     */
    public void execute(Database.BatchableContext bc, List<Job_Application__c> scope){
        List<Job_Application__c> jobsToUpdate = new List<Job_Application__c>();
        for(Job_Application__c job : scope){
            job.Status__c = 'Closed';
            job.Notes__c = 'Closed by an automated process';
            jobsToUpdate.add(job);
        }
        update jobsToUpdate;
    }
    /**
     * @description This method executes at the end of the operation.  
     */
    public void finish(Database.BatchableContext bc){
       //To do: send email to user who called method
    }
}