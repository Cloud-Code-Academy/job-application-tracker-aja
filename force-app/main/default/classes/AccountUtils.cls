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
            Map<Id, Id> jobApplicationIdToAccountIdMap = new Map<Id, Id>();
            // Create a list of accounts that exist
            List<Account> accList =[SELECT Id, Name FROM Account WHERE Name IN :jobApplicationIdToAccountNameMap.values()];
            // Map Account Names to EXISTING Ids
            //System.debug('List of accounts that exist, accList: ' + accList);
            Map<String, Id> accountNameToIdMap = new Map<String, Id>();
            for(Account acc : accList){
                if(acc.Id !=  null){
                    accountNameToIdMap.put(acc.Name, acc.Id);
                }
            }
            // List of Accounts to create
            List<Account> newAccounts = new List<Account>();
            //System.debug('initial contents of newAccounts: ' + newAccounts);
            for(Id jobApplicationId : jobApplicationIdToAccountNameMap.keyset()){
                //System.debug('jobApplicationId: ' + jobApplicationId);
                //System.debug('keyset list: ' + jobApplicationIdToAccountNameMap.keyset());
                //System.debug('accountNameToIdMap ' + accountNameToIdMap);
                if(accountNameToIdMap.containsKey(jobApplicationIdToAccountNameMap.get(jobApplicationId)) == false){
                    Account newAccount = new Account(Name = jobApplicationIdToAccountNameMap.get(jobApplicationId));
                    //System.debug('newAccount: ' + newAccount);
                    if(newAccount.Name != null){
                        newAccounts.add(newAccount);
                        //System.debug('newAccount added');
                    }
                }
            }
            //System.debug('newAccounts after: ' + newAccounts);
            insert newAccounts;
            // Map account name to account Id & Map job application Id to account name
            System.debug('Initial accountNameToIdMap contents: ' + accountNameToIdMap);
            for(Account newAccount : newAccounts){
                accountNameToIdMap.put(newAccount.Name, newAccount.Id);        
            }
            //System.debug('accountNameToIdMap contents: ' + accountNameToIdMap);
            
            // Add Id of existing accounts to Id of their job application to the map
            for(Id jobApplicationId : jobApplicationIdToAccountNameMap.keySet()){
                //get account name
                String accName = jobApplicationIdToAccountNameMap.get(jobApplicationId);
                jobApplicationIdToAccountIdMap.put(jobApplicationId, accountNameToIdMap.get(accName));
            }
            return JobApplicationIdToAccountIdMap;
        }catch(Exception e){
            return null;
        }
    }
}