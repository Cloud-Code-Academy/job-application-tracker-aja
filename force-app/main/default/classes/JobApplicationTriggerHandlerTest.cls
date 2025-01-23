@isTest
private class JobApplicationTriggerHandlerTest {

    @isTest
    static void testHandlePrimaryContact_NullInput() {
        // Arrange
        JobApplicationTriggerHandler handler = new JobApplicationTriggerHandler();

        // Act
        Test.startTest();
        handler.handlePrimaryContactAssignment(null);
        Test.stopTest();

        // Assert
        // No exceptions should occur, and no DML operations are performed.
        System.assertEquals(0, Limits.getDMLRows(), 'No DML operations should occur for null input.');
    }

    @isTest
    static void testHandlePrimaryContact_EmptyList() {
        // Arrange
        JobApplicationTriggerHandler handler = new JobApplicationTriggerHandler();

        // Act
        Test.startTest();
        handler.handlePrimaryContactAssignment(new List<Job_Application__c>());
        Test.stopTest();

        // Assert
        // No exceptions should occur, and no DML operations are performed.
        System.assertEquals(0, Limits.getDMLRows(), 'No DML operations should occur for an empty list.');
    }

    @isTest
    static void testHandlePrimaryContact_JobApplicationWithRelatedContacts() {
        // Arrange
        Account account = new Account(Name = 'Test Account');
        insert account;

        Contact contact1 = new Contact(FirstName = 'John', LastName = 'Doe', AccountId = account.Id);
        Contact contact2 = new Contact(FirstName = 'Jane', LastName = 'Smith', AccountId = account.Id);
        insert new List<Contact>{ contact1, contact2 };

        Job_Application__c jobApp = new Job_Application__c(Name = 'Job App 1', Account__c = account.Id);
        insert jobApp;

        List<Job_Application__c> jobApps = [SELECT Id, PrimaryContact__c FROM Job_Application__c WHERE Id = :jobApp.Id];

        JobApplicationTriggerHandler handler = new JobApplicationTriggerHandler();

        // Act
        Test.startTest();
        handler.handlePrimaryContactAssignment(jobApps);
        Test.stopTest();

        // Assert
        jobApps = [SELECT PrimaryContact__c FROM Job_Application__c WHERE Id = :jobApp.Id];
        System.assertNotEquals(null, jobApps[0].PrimaryContact__c, 'Primary contact should be assigned.');
        System.assertEquals(contact1.Id, jobApps[0].PrimaryContact__c, 'The first related contact should be assigned as the primary contact.');
    }

    @isTest
    static void testHandlePrimaryContact_JobApplicationWithoutRelatedContacts() {
        // Create an Account
        Account testAccount = new Account(Name = 'Test Account');
        insert testAccount;

        // Create a Job Application with a related Account but no related Contacts
        Job_Application__c jobApp = new Job_Application__c(Name = 'Job App 1', Account__c = testAccount.Id);
        insert jobApp;

        // Retrieve the Job Application, ensuring Account__c is included in the query
        Job_Application__c retrievedJobApp = [SELECT Id, Name, Account__c, PrimaryContact__c FROM Job_Application__c WHERE Id = :jobApp.Id];

        // Call the method
        List<Job_Application__c> jobApplications = new List<Job_Application__c> { retrievedJobApp };
        JobApplicationTriggerHandler handler = new JobApplicationTriggerHandler();
        Test.startTest();
        handler.handlePrimaryContactAssignment(jobApplications);
        Test.stopTest();

        // Verify no Primary Contact is assigned since there are no related Contacts
        retrievedJobApp = [SELECT Id, PrimaryContact__c FROM Job_Application__c WHERE Id = :jobApp.Id];
        System.assertEquals(null, retrievedJobApp.PrimaryContact__c, 'Primary Contact should remain null as there are no related Contacts.');
    }

    @isTest
    static void testHandlePrimaryContact_MixedJobApplications() {
        // Arrange
        Account account1 = new Account(Name = 'Account 1');
        Account account2 = new Account(Name = 'Account 2');
        insert new List<Account>{ account1, account2 };

        Contact contact1 = new Contact(FirstName = 'John', LastName = 'Doe', AccountId = account1.Id);
        Contact contact2 = new Contact(FirstName = 'Jane', LastName = 'Smith', AccountId = account2.Id);
        insert new List<Contact>{ contact1, contact2 };

        Job_Application__c jobApp1 = new Job_Application__c(Name = 'Job App 1', Account__c = account1.Id);
        Job_Application__c jobApp2 = new Job_Application__c(Name = 'Job App 2', Account__c = account2.Id);
        Job_Application__c jobApp3 = new Job_Application__c(Name = 'Job App 3');
        insert new List<Job_Application__c>{ jobApp1, jobApp2, jobApp3 };

        List<Job_Application__c> jobApps = [SELECT Id, PrimaryContact__c, Account__c FROM Job_Application__c];

        JobApplicationTriggerHandler handler = new JobApplicationTriggerHandler();

        // Act
        Test.startTest();
        handler.handlePrimaryContactAssignment(jobApps);
        Test.stopTest();

        // Assert
        jobApps = [SELECT PrimaryContact__c, Account__c FROM Job_Application__c];

        System.assertNotEquals(null, jobApps[0].PrimaryContact__c, 'Job App 1 should have a primary contact.');
        System.assertEquals(contact1.Id, jobApps[0].PrimaryContact__c, 'Job App 1 should be assigned the first contact from Account 1.');

        System.assertNotEquals(null, jobApps[1].PrimaryContact__c, 'Job App 2 should have a primary contact.');
        System.assertEquals(contact2.Id, jobApps[1].PrimaryContact__c, 'Job App 2 should be assigned the first contact from Account 2.');

        System.assertEquals(null, jobApps[2].PrimaryContact__c, 'Job App 3 should not have a primary contact as it has no related contacts or accounts.');
    }

@isTest
static void testJobApplicationCreationWithSavedStatus() {
    // Step 1: Setup Test Data
    Job_Application__c jobApplication = new Job_Application__c(
        Name = 'New Job Application for Saved Status',
        Status__c = 'Saved'
    );
    insert jobApplication;

    // Step 2: Query Tasks Created by Trigger Logic
    List<Task> createdTasks = [
        SELECT Subject FROM Task WHERE WhatId = :jobApplication.Id
    ];

    // Step 3: Validate Results
    Assert.areEqual(3, createdTasks.size(), 'The number of tasks created should match the expected count for "Saved" status');

    // Verify task details
    Map<String, Task> tasksBySubject = new Map<String, Task>();
    for (Task t : createdTasks) {
        tasksBySubject.put(t.Subject, t);
    }

    System.assert(tasksBySubject.containsKey('Check if the job description aligns with your interests and values'), 
        'Task for checking if job aligns with your values should be created.');
    System.assert(tasksBySubject.containsKey('Review the highlighted skills to see if the role is a good fit'), 
        'Task for reviewing the highlighted skills should be created.');
    System.assert(tasksBySubject.containsKey('Research the company or role and mark your excitement level'), 
        'Task for researching company and marking excitement level should be created.');
}

    @isTest
    static void testAfterUpdateHandlerWithStatusChange() {
        // Step 1: Setup Test Data
        // Create a Job Application record with an initial status
        Job_Application__c jobApplication = new Job_Application__c(
            Name = 'Test Job Application',
            Status__c = 'Saved' // 3 tasks created
        );
        insert jobApplication;

        // Step 2: Update the record to trigger the logic
        jobApplication.Status__c = 'Applying';
        update jobApplication; // 5 tasks created

        // Step 3: Query the Tasks created by the trigger logic
        List<Task> createdTasks = [
            SELECT Subject, Priority, Status, WhatId, ActivityDate
            FROM Task
            WHERE WhatId = :jobApplication.Id
        ];

        // Step 4: Validate Results
        // Verify tasks were created
        Assert.areEqual(8, createdTasks.size(), 'The number of tasks created should match the expected count for "Applying" status.');

        // Verify task details
        Map<String, Task> tasksBySubject = new Map<String, Task>();
        for (Task t : createdTasks) {
            tasksBySubject.put(t.Subject, t);
        }

        System.assert(tasksBySubject.containsKey('Find and research someone who works at the company and add them as a contact'),
            'Task for researching someone should be created.');
        System.assert(tasksBySubject.containsKey('Set up an informational interview to learn more about the role/company'),
            'Task for setting up an informational interview should be created.');
        System.assert(tasksBySubject.containsKey('Identify potential referrals to help get your application on the top of the pile'),
            'Task for identifying referrals should be created.');
        System.assert(tasksBySubject.containsKey('Customize your work achievements using the job description keywords'),
            'Task for customizing work achievements should be created.'); // copy this last part to other classes
    }

    @isTest
    static void testUpdateToApplied () {
        Job_Application__c jobApplication = new Job_Application__c(
            Name = 'Test Job Application',
            Status__c = 'Applying' // 5 tasks created
        );
        insert jobApplication;

        jobApplication.Status__c = 'Applied';

        update jobApplication; // 4 more tasks created

        List<Task> createdTasks = [SELECT Subject FROM Task WHERE WhatId = :jobApplication.Id
        ];
        Assert.areEqual(9, createdTasks.size(), 'The number of tasks created should match the expected count for "Applied" status');
    }

    @isTest
    static void testUpdateToInterviewing() {
        Job_Application__c jobApplication = new Job_Application__c(
            Name = 'Test Job Application',
            Status__c = 'Applied' //4 tasks created
        );
        insert jobApplication;

        jobApplication.Status__c = 'Interviewing';

        update jobApplication; //5 more tasks created

        List<Task> createdTasks = [
            SELECT Subject FROM Task WHERE WhatId = :jobApplication.Id];

            Assert.areEqual(9, createdTasks.size(), 'The number of tasks created should match the expected count for "Interviewing" status');

    }

    @isTest
    static void testUpdateToNegotiating() {
        Job_Application__c jobApplication = new Job_Application__c(
            Name = 'Test Job Application',

            Status__c = 'Interviewing' //5 tasks created
        );
        insert jobApplication;

        jobApplication.Status__c = 'Negotiating';

        update jobApplication; //3 more tasks created

        List<Task> createdTasks = [
            SELECT Subject FROM Task WHERE WhatId = :jobApplication.Id];

            Assert.areEqual(8, createdTasks.size(),'The number of tasks created should match the expected count for "Negotiating" status');

    }

    @isTest
    static void testUpdateToAccepted() {
        Job_Application__c jobApplication = new Job_Application__c(
            Name = 'Test Job Application',
            Status__c = 'Negotiating' //3 tasks created

        );
        insert jobApplication;

        jobApplication.Status__c = 'Accepted';

        update jobApplication; // 3 more tasks created

        List<Task> createdTasks = [
            SELECT Subject FROM Task WHERE WhatId = :jobApplication.Id];


            Assert.areEqual(6, createdTasks.size(),'The number of tasks created should match the expected count for "Accepted" status');
    }

    @isTest
    static void testUpdateToClosed() {
        Job_Application__c jobApplication = new Job_Application__c(
            Name = 'Test Job Application',

            Status__c = 'Interviewing' //5 tasks created
        );
        insert jobApplication;

        jobApplication.Status__c = 'Closed';//2 more tasks created

        update jobApplication;

        List<Task> createdTasks = [
            SELECT Subject FROM Task WHERE WhatId = :jobApplication.Id];

            Assert.areEqual(7, createdTasks.size(),'The number of tasks created should match the expected count for "Closed" status');

    }


    @isTest
    static void testAfterUpdateHandlerWithoutStatusChange() {
        // Step 1: Setup Test Data
        // Create a Job Application record with an initial status
        Job_Application__c jobApplication = new Job_Application__c(
            Name = 'Test Job Application',

            Status__c = 'Saved' //3 tasks created

        );
        insert jobApplication;

        // Step 2: Update the record without changing the Status__c field
        jobApplication.Name = 'Updated Name';
        update jobApplication;

        // Step 3: Query Tasks (No tasks should be created)
        List<Task> createdTasks = [
            SELECT Id FROM Task
            WHERE WhatId = :jobApplication.Id
        ];

        // Step 4: Validate Results
        Assert.areEqual(3, createdTasks.size(), 'No new tasks should be created when status does not change.');

    }

    @isTest
    static void testHandlerBypass() { 
        /* bypass method comes from the trigger handler framework  and can be useful for scenarios like bulk imports 
        or updates where an admin may want to bypass some of the trigger logic. Best practice is to include a test method for the bypass method */
        // Step 1: Bypass the handler
        TriggerHandler.bypass('JobApplicationTriggerHandler');

        // Step 2: Setup Test Data
        Job_Application__c jobApplication = new Job_Application__c(
            Name = 'Test Job Application',
            Status__c = 'Saved'
        );
        insert jobApplication;

        // Update the record
        jobApplication.Status__c = 'Applying';
        update jobApplication;

        // Step 3: Query Tasks (No tasks should be created because the handler was bypassed)
        List<Task> createdTasks = [
            SELECT Id FROM Task
            WHERE WhatId = :jobApplication.Id
        ];

        // Step 4: Validate Results
        Assert.areEqual(0, createdTasks.size(), 'No tasks should be created when the handler is bypassed.');

        // Clear the bypass
        TriggerHandler.clearAllBypasses();
    }
}