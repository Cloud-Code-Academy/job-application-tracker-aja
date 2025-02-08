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
            System.debug('List of accounts that exist, accList: ' + accList);
            Map<String, Id> accountNameToIdMap = new Map<String, Id>();
            for(Account acc : accList){
                if(acc.Name !=  null){
                    accountNameToIdMap.put(acc.Name, acc.Id);
                }
            }
            System.debug('Contents of accountNameToIdMap: ' + accountNameToIdMap);
            System.debug('Size of accountNameToIdMap: ' + accountNameToIdMap.size());
            // List of Accounts to create
            List<Account> newAccounts = new List<Account>();
            for(Id jobApplicationId : jobApplicationIdToAccountNameMap.keyset()){
                if(accountNameToIdMap.containsKey(jobApplicationIdToAccountNameMap.get(jobApplicationId)) == false){
                    Account newAccount = new Account(Name = jobApplicationIdToAccountNameMap.get(jobApplicationId));
                    if(newAccount.Name != null){
                        newAccounts.add(newAccount);
                    }
                }
            }
            // Insert Accounts
            System.debug('newAccounts contents, pre-insert: ' + newAccounts);
            System.debug('newAccounts size, pre-insert: ' + newAccounts.size());
            insert newAccounts;
            System.debug('newAccounts contents, after-insert: ' + newAccounts);
            System.debug('newAccounts size, after-insert: ' + newAccounts.size());
            // How to accountNameToIdMap the account names to account ids for newly inserted accounts
            // Map Id of job application records to account Id
            for(Account newAccount : newAccounts){
                accountNameToIdMap.put(newAccount.Name, newAccount.Id);
                jobApplicationIdToAccountNameMap.put(newAccount.Id, accountNameToIdMap.get(newAccount.Name));
            }
            // Add Id of existing accounts to Id of their job application to the map
            for(Id jobApplicationId : jobApplicationIdToAccountNameMap.keySet()){
                jobApplicationIdToAccountIdMap.put(jobApplicationId, accountNameToIdMap.get(jobApplicationIdToAccountNameMap.get(jobApplicationId)));
            }
            return JobApplicationIdToAccountIdMap;
        }catch(Exception e){
            return null;
        }
    }
}