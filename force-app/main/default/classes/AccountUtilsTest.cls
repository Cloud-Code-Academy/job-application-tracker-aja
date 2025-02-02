/**
 * @description Test class for AccountUtils
 * Ensures that duplicates accounts are not created.
 * @author Jonathan Lyles
 * @created 2024-01-31
 */


@isTest
public class AccountUtilsTest {
    /**
     * @description Tests success account retrieval
     * Verifies that if an account exists with the same account name that it correctly returns it's Id.
     */
    @isTest
    static void testRetrivingAccount() {
        // Create a test account
        Account acc = new Account(Name = 'Test Account');
        insert acc;
        
        // Test retrieving existing account
        Test.startTest();
        Id accId = AccountUtils.getOrCreateAccount('Test Account');
        Test.stopTest();
        
        // Assert: Verify an Id is retrieved
        System.assertNotEquals(null, accId, 'Account ID should not be null');
        // Assert: Verify the retrieved Id matches the Id of the insert account
        System.assertEquals(acc.Id, accId, 'Should return existing account ID');
    }
    /**
     * @description Tests successful account creation
     */
    @isTest
    static void testCreatingAccount(){
        
        // Test creating a new account
        Test.startTest();
        Id newAccId = AccountUtils.getOrCreateAccount('New Account');
        Test.stopTest();
        
        // Assert: Verify account creation by checking for an Id
        System.assertNotEquals(null, newAccId, 'New Account ID should not be null');
        
        // Assert: Test null input. If no account name is given, no account should be created
        System.assertEquals(null, AccountUtils.getOrCreateAccount(null), 'Should return null for null input');
    }
}