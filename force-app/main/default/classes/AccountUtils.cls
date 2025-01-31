public with sharing class AccountUtils {
    public static Id getOrCreateAccount(String accountName){
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