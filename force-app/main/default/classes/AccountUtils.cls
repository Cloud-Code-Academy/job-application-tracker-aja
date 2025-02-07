/**
 * @description This class handles business logic for the account object
 * @author Jonathan Lyles
 * @created 2025-01-31
 */
public with sharing class AccountUtils {
    public static Map<Id,Id> createJobApplicationIdToAccountIdMap (Map<Id, String> jobApplicationIdToAccountNameMap){
        /**
         * @description Gets account if it exists, or creates account if it does not
         * @param jobApplicationIdToAccountNameMap
         * @return Map<Id, Id> Id of the job application to Id of the account 
         */
        try{
            // The map that this method will return
            Map<Id, Id> JobApplicationIdToAccountIdMap = new Map<Id, Id>();
            // Create a list of accounts that exist
            List<Account> accList =[SELECT Id FROM Account WHERE Name IN :jobApplicationIdToAccountNameMap.values()];
            // Map Account Names to Ids
            Map<String, Id> accountNameToIdMap = new Map<String, Id>();
            for(Account acc : accList){
                if(acc.Name != null){
                    accountNameToIdMap.put(acc.Name, acc.Id);
                }
            }
            // Create the job application id to EXISTING account Id map
            for(Id jobApplicationId : jobApplicationIdToAccountNameMap.keySet()){
                jobApplicationIdToAccountIdMap.put(jobApplicationId, accountNameToIdMap.get(jobApplicationIdToAccountNameMap.get(jobApplicationId)));
            }
            return JobApplicationIdToAccountIdMap;
        }catch(Exception e){
            return null;
        }
    }
}