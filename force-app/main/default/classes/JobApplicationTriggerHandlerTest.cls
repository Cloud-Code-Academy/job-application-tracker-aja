//need to fix this  test class still***

@isTest
private class JobApplicationTriggerHandlerTest {

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
            Status__c = 'Saved'
        );
        insert jobApplication;

        // Step 2: Update the record to trigger the logic
        jobApplication.Status__c = 'Applying';
        update jobApplication;

        // Step 3: Query the Tasks created by the trigger logic
        List<Task> createdTasks = [
            SELECT Subject, Priority, Status, WhatId, ActivityDate
            FROM Task
            WHERE WhatId = :jobApplication.Id
        ];

        // Step 4: Validate Results
        // Verify tasks were created
        Assert.areEqual(5, createdTasks.size(), 'The number of tasks created should match the expected count for "Applying" status.');

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
            Status__c = 'Applying'
        );
        insert jobApplication;

        jobApplication.Status__c = 'Applied';
        update jobApplication;

        List<Task> createdTasks = [SELECT Subject FROM Task WHERE WhatId = :jobApplication.Id
        ];

        Assert.areEqual(4, createdTasks.size(), 'The number of tasks created should match the expected count for "Applied" status');
    }

    @isTest
    static void testUpdateToInterviewing() {
        Job_Application__c jobApplication = new Job_Application__c(
            Name = 'Test Job Application',
            Status__c = 'Applied'
        );
        insert jobApplication;

        jobApplication.Status__c = 'Interviewing';
        update jobApplication;

        List<Task> createdTasks = [
            SELECT Subject FROM Task WHERE WhatId = :jobApplication.Id];

            Assert.areEqual(5, createdTasks.size(), 'The number of tasks created should match the expected count for "Interviewing" status');
    }

    @isTest
    static void testUpdateToNegotiating() {
        Job_Application__c jobApplication = new Job_Application__c(
            Name = 'Test Job Application',
            Status__c = 'Interviewing'
        );
        insert jobApplication;

        jobApplication.Status__c = 'Negotiating';
        update jobApplication;

        List<Task> createdTasks = [
            SELECT Subject FROM Task WHERE WhatId = :jobApplication.Id];

            Assert.areEqual(3, createdTasks.size(),'The number of tasks created should match the expected count for "Negotiating" status');
    }

    @isTest
    static void testUpdateToAccepted() {
        Job_Application__c jobApplication = new Job_Application__c(
            Name = 'Test Job Application',
            Status__c = 'Negotiating'
        );
        insert jobApplication;

        jobApplication.Status__c = 'Accepted';
        update jobApplication;

        List<Task> createdTasks = [
            SELECT Subject FROM Task WHERE WhatId = :jobApplication.Id];

            Assert.areEqual(3, createdTasks.size(),'The number of tasks created should match the expected count for "Accepted" status');
    }

    @isTest
    static void testUpdateToClosed() {
        Job_Application__c jobApplication = new Job_Application__c(
            Name = 'Test Job Application',
            Status__c = 'Interviewing'
        );
        insert jobApplication;

        jobApplication.Status__c = 'Closed';
        update jobApplication;

        List<Task> createdTasks = [
            SELECT Subject FROM Task WHERE WhatId = :jobApplication.Id];

            Assert.areEqual(2, createdTasks.size(),'The number of tasks created should match the expected count for "Closed" status');
    }


    @isTest
    static void testAfterUpdateHandlerWithoutStatusChange() {
        // Step 1: Setup Test Data
        // Create a Job Application record with an initial status
        Job_Application__c jobApplication = new Job_Application__c(
            Name = 'Test Job Application',
            Status__c = 'Saved'
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
        Assert.areEqual(0, createdTasks.size(), 'No tasks should be created when status does not change.');
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
