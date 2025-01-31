public with sharing class JobApplicationUtils {
    public static HttpRequest getHttpRequest(){
            HttpRequest request = new HttpRequest();
            request.setEndpoint('https://jooble.org/api/03c23409-1a24-4fcf-a10d-d05da812186b');
            request.setMethod('POST');
            request.setHeader('Content-Type', 'application/json');
            //Define the JSON payload
            String jsonBody = '{"keywords": "Salesforce, Administrator, Business Analyst", "location": "", "salary": 1}';
            request.setBody(jsonBody);
            return request;
    }
    public static List<Object> parseResponse(HttpResponse response){
        //Parse the JSON string into a Map
        Map<String, Object> parsedResponse = (Map<String, Object>) JSON.deserializeUntyped(response.getBody());
        //Get the 'jobs' list from the parsed response
        List<Object> jobs = (List<Object>) parsedResponse.get('jobs');
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
            Decimal parsedSalary = JobApplicationUtils.parseSalary(salary);
            jobApp.Salary__c = parsedSalary;



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
        System.debug('Salary as text: ' + salaryAsText);
        Decimal decimalReturnValue;
        
        //First pattern example: $109k - $120k, or $109k-$120k
        String regExpression1 = '^\\$([0-9]+)k([\\s]*)-([\\s]*)\\$([0-9]+)k$';
        Boolean matches1 = Pattern.matches(regExpression1,salaryAsText);
        
        //Second pattern example: $109k
        String regExpression2 = '^\\$([0-9]+)k';
        Boolean matches2 = Pattern.matches(regExpression2,salaryAsText);

        //Third pattern example: $50 - $60 per hour, or $50-$60 per hour
        String regExpression3 = '\\$([0-9]+)([\\s]*)-([\\s]*)\\$([0-9]+)([\\s]+)per hour';
        Boolean matches3 = Pattern.matches(regExpression3,salaryAsText);
        
        //Fourth pattern example: $50 - $60 per hour, or $50-60 per hour
        String regExpression4 = '\\$([0-9]+)([\\s]*)per hour';
        Boolean matches4 = Pattern.matches(regExpression4,salaryAsText);
        
        try{
            if(matches1 == true){
                //Matches first pattern example: $109k - $120k. Take the high bound and transform into an integer
                System.debug('Matches first pattern');
                Integer stringLength = salaryAsText.length();
                Integer indexOfDash = salaryAsText.indexOf('-');
                String highBoundSalaryAsText = salaryAsText.right(stringLength - indexOfDash);
                highBoundSalaryAsText = highBoundSalaryAsText.replace('-',''); 
                highBoundSalaryAsText = highBoundSalaryAsText.replace('$','');
                highBoundSalaryAsText = highBoundSalaryAsText.replace('k','000');
                highBoundSalaryAsText = highBoundSalaryAsText.trim();
                System.debug(highBoundSalaryAsText);
                decimalReturnValue = Decimal.valueOf(highBoundSalaryAsText);
            }else if(matches2 == true){
                //Matches second pattern example: $109k
                Integer stringLength = salaryAsText.length();
                String rawSalary = salaryAsText.replace('$','');
                rawSalary = rawSalary.replace('k','000');
                rawSalary = rawSalary.trim();
                decimalReturnValue = Decimal.valueOf(rawSalary);

            }else if(matches3 == true){
                //Matches third pattern example: $50 - 60 per hour, or $50-$60 per hour. Reduce to an integer then calculate yearly salary
                System.debug('Matches third pattern, i.e. $50 - $60 per hour, or $50-$60 per hour');
                String rawSalary = salaryAsText;
                System.debug('Raw Salary #1: ' + rawSalary);
                //Get index of dash (-)
                Integer dashIndex = rawSalary.indexOf('-');
                System.debug('Dash Index: ' + dashIndex);
                //Remove everything before the dash
                rawSalary = rawSalary.subString(dashIndex + 1);
                System.debug('First half removed: ' + rawSalary);
                rawSalary = rawSalary.replace('$','');
                System.debug('$ removed: ' + rawSalary);
                rawSalary = rawSalary.replace('per hour','');
                System.debug('per hour removed: ' + rawSalary);
                rawSalary = rawSalary.trim();
                System.debug('After Trim(): ' + rawSalary);
                Decimal hourlyRate = Decimal.valueOf(rawSalary);  
                decimalReturnValue = hourlyRate * 2080; //40 hours by 52 weeks
                System.debug(decimalReturnValue);

            }else if(matches4 == true){
                //Matches fourth pattern example: $50 per hour. Reduce to an integer and calculate yearly salary
                System.debug('Matches fourth pattern');
                String rawSalary = salaryAsText;
                rawSalary = rawSalary.replace('$','');
                rawSalary = rawSalary.replace('/hr','');
                rawSalary = rawSalary.trim();
                Decimal hourlyRate = Decimal.valueOf(rawSalary);
                decimalReturnValue = hourlyRate * 2080; //40 hours by 52 weeks

            }else{
                //Does not match any known pattern
                decimalReturnValue = null;
            }
        }catch(Exception e){
            decimalReturnValue = null;
        }

        return decimalReturnValue;
    }
}