public with sharing class FindNewJobs implements Queueable, Schedulable, Database.AllowsCallouts {

    public void execute(SchedulableContext context){
        System.enqueueJob(this);
    }


    public void execute(QueueableContext context){
        
        try{
            Http http = new Http();
            //Get the request
            HttpRequest request = JobApplicationUtils.getHttpRequest();
            //Send the request
            HttpResponse response = http.send(request);
            //If success, then parse the response and create Job Application records
            if(response.getStatusCode() == 200){
                List<Object> jobs = JobApplicationUtils.parseResponse(response);
                JobApplicationUtils.createJobApplicationRecords(jobs);
            }else{
                System.debug('Failed with status code: ' + response.getStatusCode());
            }
        }catch (Exception e){
                System.debug(e.getMessage());
        }
    }
}