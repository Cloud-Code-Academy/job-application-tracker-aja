/**
 * @description This is a helper class with methods needed to create new job application records
 * @author Jonathan Lyles
 * @created 2025-01-31
 */

 /**
  * Execution Flow:
  * Step 1: FindNewJobsSchedulable's execute method calls System.enqueueJob(new FindNewJobsQueueable());
            FindNewJobsQueueable's execute method: Gets HttpRequest()
  * Step 2: FindNewJobsQueueable: Sends HttpRequest
  * Step 3: FindNewJobsQueueable: Receives HttpResponse
  * Step 4: FindNewJobsQueueable: Checks HttpResponse code.
        - If response code is 200:
            * Calls JobApplicationUtils.parseReponse(HttpResponse response)
    Step 5: JobApplicationUtils.parseResponse()
        - Deserializes JSON string
        - Returns List<Object> jobs
  * Step 6: JobApplicationUtils.getExternalJobApplicationId(List<Object> jobs)
        - Returns List<String> externalIds
  * Step 7: JobApplicaitonUtils.removeExternalJobApplicationDuplicateIds(List<String> externalIds)
        - Remove any duplicates and returns the list List<String> externalIds
  * Step 8: JobApplicationUtils.removeDuplicateObjects(List<Object> jobs, List<String> externalsIds)
        - Remove jobs in jobs where its Id is not in externalIds
        - Returns List<Object> jobsCleaned
  * Step 9: JobApplicationUtils.createJobApplicationRecords(List<Object> jobsCleaned)
        - Creates the job application records, which includes parsing the text, salary, etc
        - Call parseSalary() to parse salary.
        - Returns List<Job_Application__c> jobApplicationsList - the records created
  * Step 10: JobApplicationUtils.createJobApplicationIdToCompanyNameMap(List<Job_Application__c> jobApplicationList)
        - Returns Map<Id, String> of Job_Application__c Ids to company name map
  * Step 11: AccountUtils.createJobApplicationIdToAccountIdMap(Map<Id, String> jobApplicationIdToAccountNameMap)
        - For Accounts that exist, add the Ids to the map
        - For Accounts that do not exist, create them, get their Ids, and them to the map
        - Returns Map<Id, Id> - Map of Job Application Id to Account Id
    Step 12: JobApplicationUtils.insertAccounts (List<Job_Application__c> jobApps, Map<Id, Id> jobAppToAccountMap )
        - Updates the Account__c field for the job application records
        - returns void
  */
public with sharing class JobApplicationUtils {
    /**
     * @description Creates and returns the HttpRequest object
     * @return HttpRequest
     */
    public static HttpRequest getHttpRequest(){
            HttpRequest request = new HttpRequest();
            request.setEndpoint('https://jooble.org/api/03c23409-1a24-4fcf-a10d-d05da812186b');
            request.setMethod('POST');
            request.setHeader('Content-Type', 'application/json');
            //Define the JSON payload
            String jsonBody = '{"keywords": "Salesforce, Administrator, Developer", "location": "", "salary": 1}';
            request.setBody(jsonBody);
            return request;
    }
    /**
     * @description Parses the response into a list of jobs
     * @param HttpResponse
     * @return List<Object>
     */
    public static List<Object> parseResponse(HttpResponse response){
        System.debug('response: ' + response.getBody());
        //Parse the JSON string into a Map
        Map<String, Object> parsedResponse = (Map<String, Object>) JSON.deserializeUntyped(response.getBody());
        //Get the 'jobs' list from the parsed response
        List<Object> jobs = (List<Object>) parsedResponse.get('jobs');
        System.debug('Size of jobs ' + jobs.size());
        return jobs;
    }
    /**
     * @description This method builds a list of external IDs that will be used to check for duplicates
     * @param List<Object>jobs
     * @return List<String>
     */
    public static List<String> getExternalJobApplicationIds(List<Object> jobs){
        List<String> externalIds = new List<String>();
        //Build a list of each job's external Id. To be used later to prevent duplicate records
            for(Object jobObj : jobs){
                Map<String, Object> job = (Map<String, Object>) jobObj;
                String externalId = String.valueOf(job.get('id'));
                externalIds.add(externalId);
        }
        System.debug('Size of externalIds: ' + externalIds.size());
        return externalIds;
    }
    /**
     * @description This method removes job applications from the list where the external Id is already in the database
     * @param List<String>
     * @return List<String>
     */
    public static List<String> removeExternalJobApplicationDuplicateIds(List<String> externalIds){
        //Check to see which records already exist
        List<Job_Application__c> duplicateRecords = [SELECT job_id__c FROM Job_Application__c WHERE job_id__c IN :externalIds];
        System.debug('Duplicate records: ' + duplicateRecords);
        //Create a list of duplicate external Ids
        List<String> duplicateExternalIds = new List<String>();
        for(Job_Application__c duplicateRecord : duplicateRecords){
            duplicateExternalIds.add(duplicateRecord.job_id__c);
        }
        System.debug('Size of duplicateExternalIds: ' + duplicateExternalIds.size());
        //Remove duplicateExternalIds from externalIds
        for(String duplicateExternalId : duplicateExternalIds){
            if(externalIds.contains(duplicateExternalId)){
                Integer indexInList = externalIds.indexOf(duplicateExternalId);
                externalIds.remove(indexInList);
            }
        }
        System.debug('Size of externalIds with duplicates removed: ' + externalIds.size());
        System.debug('Contents of externalIds: ' + externalIds);
        return externalIds;
    }
    /**
     * @description Removes jobs already in the database from List<Object> jobs
     * @param List<Object> jobs
     * @param List<String> externalIds
     * @return List<Object> jobsCleaned 
     */
    public static List<Object> removeDuplicateObjects(List<Object> jobs, List<String> externalIds){
        List<Object> jobsCleaned = new List<Object>();
        for(Object jobObj : jobs){
            Map<String, Object> job = (Map<String, Object>) jobObj;
            String externalId = String.valueOf(job.get('id'));
            if(externalIds.contains(externalId)){
                jobsCleaned.add(jobObj);
            }
        }
        return jobsCleaned;
    }
    /**
     * @description Creates job application records
     * @param List<Object> jobs The list of jobs returned from parseResponse()
     */
    public static List<Job_Application__c> createJobApplicationRecords(List<Object> jobsCleaned){
        //List of job applications that will be added
        List<Job_Application__c> jobApplicationsList = new List<Job_Application__c>();

        //Iterate over each job, which is an inner map in the 'jobs' list
        for(Object jobObj : jobsCleaned){
            
            Map<String, Object> job = (Map<String, Object>) jobObj;
            Job_Application__c jobApp = new Job_Application__c();

            //Abbreviate the job application name if over 80 characters
            String jobApplicationName = (String) job.get('title');
            jobApplicationName = jobApplicationName.abbreviate(80);
            jobApp.Name = jobApplicationName;

            jobApp.Title__c = (String) job.get('title');
            jobApp.Location__c = (String) job.get('location');
            JobApp.Url__c = (String) job.get('link');
            jobApp.Status__c = 'Saved';
            //Hidden field
            jobApp.CompanyNameFromHttpResponse__c = (String) job.get('company');

             // Clean Job Description Snippet of HTML tags and entities and set jobApp job description field
            String rawSnippet = (String) job.get('snippet');

            // Remove HTML tags
            String cleanedSnippet = rawSnippet.replaceAll('<.*?>', ' ');

            // Replace common HTML entities with spaces
            cleanedSnippet = cleanedSnippet.replaceAll('&amp;', ' ');
            cleanedSnippet = cleanedSnippet.replaceAll('&nbsp;', ' ');
            cleanedSnippet = cleanedSnippet.replaceAll('&lt;', ' ');
            cleanedSnippet = cleanedSnippet.replaceAll('&gt;', ' ');

            // Normalize spaces
            cleanedSnippet = cleanedSnippet.normalizeSpace();

            // Set the cleaned description
            jobApp.Description__c = cleanedSnippet;

            String salary = (String) job.get('salary');            
            Decimal parsedSalary = JobApplicationUtils.parseSalary(salary);
            jobApp.Salary__c = parsedSalary;
            jobApp.job_id__c = String.valueOf(job.get('id'));
            jobApplicationsList.add(jobApp);
            
        }
        if(!jobApplicationsList.isEmpty()){
            insert jobApplicationsList;
        }
        return jobApplicationsList;
    }
       /**
     * @description Creates a map of the job application id and their company names
     * @param List<Job_Application__c> List of inserted job application records
     * @return Map<Id, String>
     */
    public static Map<Id, String> createJobApplicationIdToCompanyNameMap(List<Job_Application__c> jobApplicationList){
        Map<Id, String> jobApplicationToCompanyNameMap = new Map<Id, String>();
        for(Job_Application__c jobApplication : jobApplicationList){
            try{
                if(jobApplication.CompanyNameFromHttpResponse__c != null){
                    jobApplicationToCompanyNameMap.put(jobApplication.Id, jobApplication.CompanyNameFromHttpResponse__c);
                }else{
                    jobApplicationToCompanyNameMap.put(jobApplication.Id, null);
                }
            }catch (Exception e) {
                jobApplicationToCompanyNameMap.put(jobApplication.Id, null);
            }
        }
        return JobApplicationToCompanyNameMap;
    }
    /**
     * @description Converts the salary string returned from the API call into a numeric value representing annual salary
     * @param salaryAsText The salary returned in the JSON response
     * @return Decimal The salary as a numeric value representing the annual salary of the job application
     */
    @testVisible private static Decimal parseSalary(String salaryAsText){

        //System.debug('Salary as text: ' + salaryAsText);
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
                //System.debug('Matches first pattern');
                Integer stringLength = salaryAsText.length();
                Integer indexOfDash = salaryAsText.indexOf('-');
                String highBoundSalaryAsText = salaryAsText.right(stringLength - indexOfDash);
                highBoundSalaryAsText = highBoundSalaryAsText.replace('-',''); 
                highBoundSalaryAsText = highBoundSalaryAsText.replace('$','');
                highBoundSalaryAsText = highBoundSalaryAsText.replace('k','000');
                highBoundSalaryAsText = highBoundSalaryAsText.trim();
                //System.debug(highBoundSalaryAsText);
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
                //System.debug('Matches third pattern, i.e. $50 - $60 per hour, or $50-$60 per hour');
                String rawSalary = salaryAsText;
                //Get index of dash (-)
                Integer dashIndex = rawSalary.indexOf('-');
                //Remove everything before the dash
                rawSalary = rawSalary.subString(dashIndex + 1);
                rawSalary = rawSalary.replace('$','');
                rawSalary = rawSalary.replace('per hour','');            
                rawSalary = rawSalary.trim();
                Decimal hourlyRate = Decimal.valueOf(rawSalary);  
                decimalReturnValue = hourlyRate * 2080; //40 hours by 52 weeks
                

            }else if(matches4 == true){
                //Matches fourth pattern example: $50 per hour. Reduce to an integer and calculate yearly salary
                //System.debug('Matches fourth pattern');
                String rawSalary = (String) salaryAsText;
                rawSalary = rawSalary.replace('$','');
                rawSalary = rawSalary.replace('per hour','');
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

    /**
     * @description This class updates Account__c field on each job application record
     * @param Map<Id, Id> Represents the map of job application id to their related account id
     * @return void 
     */

     public static void insertAccounts (List<Job_Application__c> jobApps, Map<Id, Id> jobAppToAccountMap ){
        List<Job_Application__c> jobAppsToUpdate = new List<Job_Application__c>();
        for(Job_Application__c jobApp : jobApps){
            jobApp.Account__c = jobAppToAccountMap.get(jobApp.Id);
            jobAppsToUpdate.add(jobApp);
        }
        update jobAppsToUpdate;
    }
}