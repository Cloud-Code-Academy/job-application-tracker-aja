/**
 * @description Executes the queueable job to fetch new job postings from an external API
 * @author Jonathan Lyles
 * @created 2025-01-31
 */

public with sharing class FindNewJobsQueueable implements Queueable, Database.AllowsCallouts {
    
    /**
     * @description Executes the queueable job
     */
    public void execute(QueueableContext context) {
        try {
            Http http = new Http();
            
            // Get the HTTP request object from a utility class
            HttpRequest request = JobApplicationUtils.getHttpRequest();
            
            // Send the HTTP request to fetch job postings
            HttpResponse response = http.send(request);
            
            // Check if the request was successful (HTTP 200 OK)
            if(response.getStatusCode() == 200) {
                // Parse the API response into a list of job objects
                List<Object> jobs = JobApplicationUtils.parseResponse(response);
                // Get list of externalIds
                List<String> externalIds = new List<String>();
                if(!jobs.isEmpty()){
                    externalIds = JobApplicationUtils.getExternalJobApplicationIds(jobs);
                }
                System.debug('externalIds: ' + externalIds);

                // Remove duplicates from externalIds
                List<Object> jobsCleaned = new List<Object>();
                if(!externalIds.isEmpty()){
                    externalIds = JobApplicationUtils.removeExternalJobApplicationDuplicateIds(externalIds);
                    // Remove duplicates from List<Object> jobs
                    jobsCleaned = JobApplicationUtils.removeDuplicateObjects(jobs, externalIds);
                }
                System.debug('Count of jobsCleaned: ' + jobsCleaned.size());
                //System.debug('Jobs Cleaned: ' + jobsCleaned);              
                // Create new Job Application records in Salesforce based on the API response
                List<Job_Application__c> jobApplicationsList = new List<Job_Application__c>();
                if(!jobsCleaned.isEmpty()){
                    jobApplicationsList = JobApplicationUtils.createJobApplicationRecords(jobsCleaned);
                }
                System.debug('Count of jobApplications created: ' + jobApplicationsList.size());
                System.debug('Contents of jobApplicationsList: ' + jobApplicationsList);
                // Map job application Id to company name
                Map<Id, String> jobApplicationIdToAccountNameMap = new Map<Id,String>();
                If(!jobApplicationsList.isEmpty()){
                    jobApplicationIdToAccountNameMap = JobApplicationUtils.createJobApplicationIdToCompanyNameMap(jobApplicationsList);
                }
                System.debug('jobApplicationIdToAccountNameMap: ' + jobApplicationIdToAccountNameMap);
                // Map job application Id to company Id
                Map<Id, Id> jobApplicationIdToAccountIdMap = new Map<Id, Id>();
                if(!jobApplicationIdToAccountNameMap.keySet().isEmpty()){               
                    jobApplicationIdToAccountIdMap = AccountUtils.createJobApplicationIdToAccountIdMap(jobApplicationIdToAccountNameMap);
                }
                System.debug('jobApplicationIdToAccountIdMap: ' + jobApplicationIdToAccountIdMap);
                // Insert the Account Id in the Account__c field for Job Application 
                if(!jobApplicationIdToAccountIdMap.keySet().isEmpty()){
                    JobApplicationUtils.insertAccounts(jobApplicationsList, jobApplicationIdToAccountIdMap);
                }
            } else {
                // Log an error message if the request was unsuccessful
                System.debug('Failed with status code: ' + response.getStatusCode());
            }
        } catch (Exception e) {
            // Log any unexpected exceptions to help with debugging
            System.debug(e.getMessage());
            System.debug(e.getLineNumber());
        }
    }
}
