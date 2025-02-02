/**
 * @description Executes the queueable job to fetch new job postings from an external API
 * @author Jonathan Lyles
 * @created 2025-01-31
 */

public with sharing class FindNewJobsQueuable implements Queueable, Database.AllowsCallouts {
    
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
                
                // Create new Job Application records in Salesforce based on the API response
                JobApplicationUtils.createJobApplicationRecords(jobs);
            } else {
                // Log an error message if the request was unsuccessful
                System.debug('Failed with status code: ' + response.getStatusCode());
            }
        } catch (Exception e) {
            // Log any unexpected exceptions to help with debugging
            System.debug(e.getMessage());
        }
    }
}
