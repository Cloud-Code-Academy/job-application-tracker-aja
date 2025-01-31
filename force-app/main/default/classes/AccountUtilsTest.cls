@isTest
public class AccountUtilsTest {
    @isTest
    static void testRetrivingAccount() {
        // Create an account
        Account acc = new Account(Name = 'Test Account');
        insert acc;
        
        // Test retrieving existing account
        Test.startTest();
        Id accId = AccountUtils.getOrCreateAccount('Test Account');
        Test.stopTest();
        
        System.assertNotEquals(null, accId, 'Account ID should not be null');
        System.assertEquals(acc.Id, accId, 'Should return existing account ID');
    }
    @isTest
    static void testCreatingAccount(){
        
        // Test creating a new account
        Test.startTest();
        Id newAccId = AccountUtils.getOrCreateAccount('New Account');
        Test.stopTest();
        
        System.assertNotEquals(null, newAccId, 'New Account ID should not be null');
        
        // Test null input
        System.assertEquals(null, AccountUtils.getOrCreateAccount(null), 'Should return null for null input');
    }
}