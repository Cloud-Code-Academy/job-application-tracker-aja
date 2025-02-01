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
public class TestDataFactory {

    @isTest
    public static Id getProfileId() {
        Profile profile = [SELECT Id FROM Profile WHERE Name = 'System Administrator' LIMIT 1];  
        String profileId = profile.Id; 
        return profileId; 
    }

    public static String createUniqueUsername(){
        String uniqueUsername = 'test' + DateTime.now().getTime() + '@test.com';
        return uniqueUsername;
    }

    public static User createUser(String uniqueUsername, Id profileId){
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
        return testUser;
    }

    public static Account createAccount(){
        Account testAccount = new Account(Name = 'TestAccount');
        insert testAccount;
        return testAccount;
    }

    public static Contact createContact(Id accountIdParam){
        Contact testContact = new Contact(FirstName = 'FirstNameTest', LastName = 'LastNameTest', AccountId = accountIdParam);
        insert testContact;
        return testContact;
    }

    public static Job_Application__c createJobApplication(Id ownerIdParam, Id accountIdParam, Id contactIdParam, Date followUpDateParam){
        Job_Application__c testJob = new Job_Application__c(Name = 'JobApplicationName', OwnerId = ownerIdParam ,Title__c = 'TestJobTitle', Account__c = accountIdParam, Location__c = 'TestCity', PrimaryContact__c = contactIdParam, Follow_up_Date__c = followUpDateParam);
        insert testJob;
        return testJob;
    }

    public static Event createEvent(Id ownerIdParam, Id contactIdParam, Id jobApplicationIdParam, String locationParam){
        Date nextBusinessDay = BusinessDayUtils.getNextBusinessDay();
        System.debug(nextBusinessDay);
        Event testInterviewTomorrow = new Event(OwnerId = ownerIdParam, Subject = 'Interview', WhoId = contactIdParam, WhatId = jobApplicationIdParam, Location = locationParam, StartDateTime = DateTime.newInstance(nextBusinessDay, Time.newInstance(9,0,0,0)), EndDateTime = DateTime.newInstance(nextBusinessDay, Time.newInstance(10,0,0,0)));
        insert testInterviewTomorrow;
        return testInterviewTomorrow;
    }
}