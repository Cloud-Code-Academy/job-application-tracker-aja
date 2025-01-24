/**
 * This class contains unit tests for validating the behavior of Apex classes
 * and triggers.
 *
 * Unit tests are class methods that verify whether a particular piece
 * of code is working properly. Unit test methods take no arguments,
 * commit no data to the database, and are flagged with the testMethod
 * keyword in the method definition.
 *
 * All test methods in an org are executed whenever Apex code is deployed
 * to a production org to confirm correctness, ensure code
 * coverage, and prevent regressions. All Apex classes are
 * required to have at least 75% code coverage in order to be deployed
 * to a production org. In addition, all triggers must have some code coverage.
 * 
 * The @isTest class annotation indicates this class only contains test
 * methods. Classes defined with the @isTest annotation do not count against
 * the org size limit for all Apex scripts.
 *
 * See the Apex Language Reference for more information about Testing and Code Coverage.
 */
@isTest
private class InterviewReminderSynchronousTest {
    @TestSetup
    static void makeData(){
        //profile
        Profile profile = [SELECT Id FROM Profile WHERE Name = 'System Administrator' LIMIT 1];  
        String profileId = profile.Id;   
        System.debug(profileId);
        
        //unique username
        String uniqueUsername = 'test' + DateTime.now().getTime() + '@test.com';
        System.debug(uniqueUsername);

        //user
        User testUser = new User(
            Username = uniqueUsername, 
            Alias = 'test', 
            TimeZoneSidKey = 'America/New_York', 
            LocaleSidKey = 'en_US', 
            ProfileId = profileId, 
            LanguageLocaleKey = 'en_US', 
            EmailEncodingKey = 'UTF-8',
            FirstName = 'test', 
            LastName = 'test', 
            Email = 'test@test.com', 
            isActive = true
        );
        insert testUser;
        System.debug(testUser);
        
        //Create a test account record
        Account testAccount = new Account(Name = 'TestAccount');
        insert testAccount;
        System.debug(testAccount);

        //Create a test contact record and relate it to the test account record
        Contact testContact = new Contact(FirstName = 'FirstNameTest', LastName = 'LastNameTest', AccountId = testAccount.Id);
        insert testContact;
        System.debug(testContact);

        //Create a Job_Application__c record and relate it to the test contact and test account
        Job_Application__c testJob = new Job_Application__c(Name = 'JobApplicationName', OwnerId = testUser.Id ,Title__c = 'TestJobTitle', Account__c = testAccount.Id, Location__c = 'TestCity', PrimaryContact__c = testContact.Id);
        insert testJob;
        System.debug(testJob);

        //Create an interview for tomorrow (positive case)
        Event testInterviewTomorrow = new Event(OwnerId = testUser.Id, Subject = 'Interview', WhoId = testContact.Id, WhatId = testJob.Id, Location = testJob.Location__c, StartDateTime = DateTime.newInstance(Date.today().addDays(1), Time.newInstance(9,0,0,0)), EndDateTime = DateTime.newInstance(Date.today().addDays(1), Time.newInstance(10,0,0,0)));
        insert testInterviewTomorrow;
        System.debug(testInterviewTomorrow);

        
    }

    @isTest
    static void testEmailCount() {
        Test.startTest();
        
        InterviewReminderSynchronous emailReminders = new InterviewReminderSynchronous();
        emailReminders.sendInterviewReminderEmails();

        Integer emailCount = System.Limits.getEmailInvocations();
        System.debug(emailCount);
        
        Test.stopTest();
          
       System.assertEquals(1, emailCount, 'Only one email should be sent' );
       
       EmailMessage emailMessage = [SELECT Id, Subject, RelatedToId, ToAddress 
                                    FROM EmailMessage 
                                    WHERE  RelatedToId IN(
                                        SELECT Id
                                        FROM Job_Application__c
                                        WHERE Name = 'JobApplicationName'
                                    )
                                    LIMIT 1
                                    ];
        System.assertNotEquals(null, emailMessage.Subject, 'Should not be null');
        System.assertEquals('Reminder: Interview Scheduled Tomorrow', emailMessage.Subject, 'Title should be \'Reminder: Interview Scheduled Tomorrow\'');
        System.assertEquals('test@test.com', emailMessage.ToAddress, 'ToAddress is not test@test.com');
       
    }
}