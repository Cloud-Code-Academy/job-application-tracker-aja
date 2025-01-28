public with sharing class JobApplicationUtils {
    public static HttpRequest getHttpRequest(){
            HttpRequest request = new HttpRequest();
            request.setEndpoint('https://jooble.org/api/03c23409-1a24-4fcf-a10d-d05da812186b');
            request.setMethod('POST');
            request.setHeader('Content-Type', 'application/json');
            //Define the JSON payload
            String jsonBody = '{"keywords": "Salesforce", "location": "", "salary": 1}';
            request.setBody(jsonBody);
            return request;
    }
    public static List<Object> parseResponse(HttpResponse response){
        System.debug('HttpResponse: ' + response);
        //Parse the JSON string into a Map
        Map<String, Object> parsedResponse = (Map<String, Object>) JSON.deserializeUntyped(response.getBody());
        //Get the 'jobs' list from the parsed response
        List<Object> jobs = (List<Object>) parsedResponse.get('jobs');
        System.debug('parsed response: ' + jobs);
        return jobs;
    }
    public static void createJobApplicationRecords(List<Object> jobs){
        //List of job applications that will be added
        List<Job_Application__c> jobApplicationsList = new List<Job_Application__c>();
        //Initialize a counter. Some searches can return thousands of jobs
        Integer count = 0;
        //Iterate over each job, which is an inner map in the 'jobs' list
        for(Object jobObj : jobs){
            if(count >= 5){
                break; //Stop iterating after 5 jobs
            }
            Map<String, Object> job = (Map<String, Object>) jobObj;
            Job_Application__c jobApp = new Job_Application__c();
            jobApp.Name = (String) job.get('title');
            jobApp.Title__c = (String) job.get('title');
            jobApp.Location__c = (String) job.get('location');
            JobApp.Url__c = (String) job.get('link');
            jobApp.Status__c = 'Saved';
            String jobDescription = StringUtils.sanitizeString((String)job.get('snippet'));
            jobApp.description__c = jobDescription.substring(4, jobDescription.length()-4); //removes nbsp which remains at start and end of string
            String salary = (String) job.get('salary');
            if(salary.isNumeric()){
                try{
                    jobApp.salary__c = Decimal.valueOf(salary);
                }catch(Exception e){
                    System.debug(e.getMessage());
                }
            }
            String companyName = (String) job.get('company');
            jobApp.Account__c = AccountUtils.getOrCreateAccount(companyName);
            jobApplicationsList.add(jobApp);
            count++; //increment the counter
        }
        if(!jobApplicationsList.isEmpty()){
            insert jobApplicationsList;
        }
    }
    private static Decimal parseSalary(String salaryAsText){
        List<String> regularExpressions = new List<String>();
        //First pattern example: $109k - $120k
        String regExpression2 = '^\\$([0-9]+)k([\\s]+)-([\\s]+)\\$([0-9]+)k$';
        //Second pattern example: $109k
        String regExpression1 = '^\\$([0-9]+)k';
        //Third pattern example: $50 per hour
        String regExpression3 = 'per\\shour';
        //Fourth pattern example: $50 /hr
        String regExpression4 = '/hr';
        
        List<Pattern> patterns = new List<Pattern>();
        for(String regularExpression : regularExpressions){
            Pattern pattern = Pattern.compile(regularExpression);
            patterns.add(pattern);
        }

        List<Matcher> matchers = new List<Matcher>();
        for(Pattern pattern : patterns){
            Matcher matcher = pattern.matcher(salaryAsText);
            matchers.add(matcher);
        }

        for(Matcher matcher : matchers){
            
        }
        return null;
    }
}