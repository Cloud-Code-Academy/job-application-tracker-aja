/**
 * @description This class handles business logic for the account object
 * @author Jonathan Lyles
 * @created 2025-01-31
 */
public with sharing class AccountUtils {
    public static Id getOrCreateAccount(String accountName){
        /**
         * @description Gets account if it exists, or creates account if it does not
         * @param accountName The name of the account to check
         * @return Id The Id of the account that was retrieved or created 
         */

        if(accountName != null){
            Account relatedAccount = new Account();
            try{
                Account getAccount = [SELECT Id FROM Account WHERE Name = :accountName LIMIT 1];
                    if(getAccount != null){
                    relatedAccount = getAccount;
                }
            }catch(Exception e){
                System.debug('Account does not exist');
                Account createAccount = new Account();
                createAccount.Name = accountName;
                insert createAccount;
                relatedAccount = createAccount;            
            }
            return relatedAccount.Id;
        }else{
            return null;
        }
    }
}