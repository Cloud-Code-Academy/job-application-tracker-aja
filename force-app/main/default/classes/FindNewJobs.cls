public with sharing class FindNewJobs implements Queueable, Database.AllowsCallouts {
    public void execute(QueueableContext context){
        try{
            Http http = new Http();
            HttpRequest request = new HttpRequest();
            request.setEndpoint('https://jooble.org/api/03c23409-1a24-4fcf-a10d-d05da812186b');
            request.setMethod('POST');
            request.setHeader('Content-Type', 'application/json');

            //Define the JSON payload
            String jsonBody = '{"keywords": "Salesforce, onsite", "location": "Detroit", "salary": 1}';
            request.setBody(jsonBody);

            //Send the request
            HttpResponse response = http.send(request);

            if(response.getStatusCode() == 200){
                //List of job applications that will be added
                List<Job_Application__c> jobApplicationsList = new List<Job_Application__c>();

                //Parse the JSON string into a Map
                Map<String, Object> parsedResponse = (Map<String, Object>) JSON.deserializeUntyped(response.getBody());
                //Get the 'jobs' list from the parsed response
                List<Object> jobs = (List<Object>) parsedResponse.get('jobs');
                
                //Iterate over each job, which is an inner map in the 'jobs' list
                for(Object jobObj : jobs){
                     
                    Map<String, Object> job = (Map<String, Object>) jobObj;

                    Job_Application__c jobApp = new Job_Application__c();
                    jobApp.Name = (String) job.get('title');
                    jobApp.Status__c = 'Saved';
                    //jobApp.Salary__c = Integer.valueOf( job.get('salary') );



                    System.debug(jobObj);



                    

                     
                }
                
                
                
            
            }else{
                System.debug('Failed with status code: ' + response.getStatusCode());
            }
        }catch (Exception e){
                System.debug(e.getMessage());
        }
    }
}