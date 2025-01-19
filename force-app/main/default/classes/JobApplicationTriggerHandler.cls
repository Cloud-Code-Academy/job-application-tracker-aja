public with sharing class JobApplicationTriggerHandler extends TriggerHandler {
   
    public override void beforeInsert() {
        handlePrimaryContactAssignment (Trigger.new);
    }

    public override void beforeUpdate() {
        handlePrimaryContactAssignment(Trigger.new);
    }
    
    //Override afterInsert to handle insert logic
    public override void afterInsert() {
        afterInsertOrUpdate();
    }

    // Override afterUpdate to handle update logic
    public override void afterUpdate() {
        afterInsertOrUpdate();
    }

    public void handlePrimaryContactAssignment(List<Job_Application__c> jobApplications) {
        if (jobApplications == null || jobApplications.isEmpty()) {
            return; // No applications to process
        }
    
        // Collect related Job Application and Account IDs
        Set<Id> jobApplicationIds = new Set<Id>();
        Set<Id> accountIds = new Set<Id>();
        for (Job_Application__c jobApp : jobApplications) {
            if (jobApp.PrimaryContact__c == null) {
                if (jobApp.Id != null) {
                    jobApplicationIds.add(jobApp.Id);
                }
                if (jobApp.Account__c != null) {
                    accountIds.add(jobApp.Account__c);
                }
            }
        }
    
        // Return early if no relevant records
        if (jobApplicationIds.isEmpty() && accountIds.isEmpty()) {
            return;
        }
    
        // Fetch related Contacts
        Map<Id, List<Contact>> relatedContactsMap = new Map<Id, List<Contact>>();
        for (Contact contact : [
            SELECT Id, Job_Application__c, AccountId
            FROM Contact
            WHERE Job_Application__c IN :jobApplicationIds OR AccountId IN :accountIds
        ]) {
            Id relatedId = contact.Job_Application__c != null ? contact.Job_Application__c : contact.AccountId;
            if (!relatedContactsMap.containsKey(relatedId)) {
                relatedContactsMap.put(relatedId, new List<Contact>());
            }
            relatedContactsMap.get(relatedId).add(contact);
        }
    
        // Assign Primary Contacts
        for (Job_Application__c jobApp : jobApplications) {
            if (jobApp.PrimaryContact__c == null) {
                if (relatedContactsMap.containsKey(jobApp.Id) && !relatedContactsMap.get(jobApp.Id).isEmpty()) {
                    jobApp.PrimaryContact__c = relatedContactsMap.get(jobApp.Id)[0].Id;
                } else if (jobApp.Account__c != null && relatedContactsMap.containsKey(jobApp.Account__c)
                         && !relatedContactsMap.get(jobApp.Account__c).isEmpty()) {
                    jobApp.PrimaryContact__c = relatedContactsMap.get(jobApp.Account__c)[0].Id;
                }
            }
        }
    }
    
    
    //Method that handles the logic for after insert and after update
   public void afterInsertOrUpdate() {

        //List to hold job applications where status changes
        List<Job_Application__c> processedApplications = new List<Job_Application__c>();

        // Determine whether it's an insert or update
        if(Trigger.isInsert) {
            //For inserts, add all new records to the list
            processedApplications.addAll((List<Job_Application__c>) Trigger.new);
        } else if (Trigger.isUpdate) {
            //For updates, compare Status__c field and add to the list if changed
            for (Job_Application__c application : (List<Job_Application__c>) Trigger.new) {
                Job_Application__c oldApplication = (Job_Application__c) Trigger.oldMap.get(application.Id); //Cast trigger.oldMap values
                if (application.Status__c != oldApplication.Status__c) {
                    processedApplications.add(application);
                }
            }
        }

        //Create Tasks based on new Status
        if (!processedApplications.isEmpty()) {
            createTasksForStatusChange(processedApplications);
        }
    }

    //Method to create tasks based on Status changes
    private void createTasksForStatusChange (List<Job_Application__c> applications) { 
        List<Task> tasksToInsert = new List<Task>();

        for (Job_Application__c application : applications) {
            List<Task> tasksForStatus = getTasksByStatus(application.Status__c, application.Id); 
            tasksToInsert.addAll(tasksForStatus);
        }

        if (!tasksToInsert.isEmpty()) {
            insert tasksToInsert;
        }
    }

    //Method to get tasks for a given status
    private List<Task> getTasksByStatus(String status, Id whatId) { // need to make sure the whatId links to the applicationId
        List<Task> tasks = new List<Task>();

        switch on status {
            when 'Saved' {
                tasks.add(new Task(Subject = 'Check if the job description aligns with your interests and values', 
                    Priority = 'High', Status = 'Not Started', WhatId = whatId, ActivityDate = Date.today().addDays(3)));
                tasks.add(new Task(Subject = 'Review the highlighted skills to see if the role is a good fit', 
                    Priority = 'High', Status = 'Not Started', WhatId = whatId, ActivityDate = Date.today().addDays(3)));
                tasks.add(new Task(Subject = 'Research the company or role and mark your excitement level', 
                    Priority = 'Normal', Status = 'Not Started', WhatId = whatId, ActivityDate = Date.today().addDays(4)));
            }
            when 'Applying' {
                tasks.add(new Task(Subject = 'Find and research someone who works at the company and add them as a contact', 
                    Priority = 'High', Status = 'Not Started', WhatId = whatId, ActivityDate = Date.today().addDays(2)));
                tasks.add(new Task(Subject = 'Set up an informational interview to learn more about the role/company', 
                    Priority = 'Normal', Status = 'Not Started', WhatId = whatId, ActivityDate = Date.today().addDays(7)));
                tasks.add(new Task(Subject = 'Identify potential referrals to help get your application on the top of the pile', 
                    Priority = 'Normal', Status = 'Not Started', WhatId = whatId, ActivityDate = Date.today().addDays(5)));
                tasks.add(new Task(Subject = 'Customize your work achievements using the job description keywords', 
                    Priority = 'Normal', Status = 'Not Started', WhatId = whatId, ActivityDate = Date.today().addDays(4)));
                tasks.add(new Task(Subject = 'Submit your application on the company website if possible', 
                    Priority = 'High', Status = 'Not Started', WhatId = whatId, ActivityDate = Date.today().addDays(3)));
            }
            when 'Applied' {
                tasks.add(new Task(Subject = 'Reach out to the hiring manager or recruiter', 
                    Priority = 'Normal', Status = 'Not Started', WhatId = whatId, ActivityDate = Date.today().addDays(4)));
                tasks.add(new Task(Subject = 'Follow up on your application via email weekly', 
                    Priority = 'Normal', Status = 'Not Started', WhatId = whatId, ActivityDate = Date.today().addDays(7)));
                tasks.add(new Task(Subject = 'Continue identifying and saving similar job opportunities', 
                    Priority = 'Normal', Status = 'Not Started', WhatId = whatId, ActivityDate = Date.today().addDays(5)));
                tasks.add(new Task(Subject = 'Set up weekly networking calls to explore similar companies/roles', 
                    Priority = 'Normal', Status = 'Not Started', WhatId = whatId, ActivityDate = Date.today().addDays(7)));
            }
            when 'Interviewing' {
                tasks.add(new Task(Subject = 'Prepare your blurb or “tell me about yourself” response', 
                    Priority = 'High', Status = 'Not Started', WhatId = whatId, ActivityDate = Date.today().addDays(3)));
                tasks.add(new Task(Subject = 'Practice answering behavioral interview questions', 
                    Priority = 'High', Status = 'Not Started', WhatId = whatId, ActivityDate = Date.today().addDays(4)));
                tasks.add(new Task(Subject = 'Research the company and your interviewers', 
                    Priority = 'High', Status = 'Not Started', WhatId = whatId, ActivityDate = Date.today().addDays(4)));
                tasks.add(new Task(Subject = 'Set up your virtual interview space and test your tech', 
                    Priority = 'Normal', Status = 'Not Started', WhatId = whatId, ActivityDate = Date.today().addDays(5)));
                tasks.add(new Task(Subject = 'Send thank you emails within 24 hours', 
                    Priority = 'High', Status = 'Not Started', WhatId = whatId, ActivityDate = Date.today().addDays(7)));
            }
            when 'Negotiating' {
                tasks.add(new Task(Subject = 'Research your market value and know your numbers', 
                    Priority = 'High', Status = 'Not Started', WhatId = whatId, ActivityDate = Date.today().addDays(2)));
                tasks.add(new Task(Subject = 'Prepare your negotiation scripts', 
                    Priority = 'High', Status = 'Not Started', WhatId = whatId, ActivityDate = Date.today().addDays(3)));
                tasks.add(new Task(Subject = 'Evaluate your offer and decline or accept', 
                    Priority = 'High', Status = 'Not Started', WhatId = whatId, ActivityDate = Date.today().addDays(7)));
            }
            when 'Accepted' {
                tasks.add(new Task(Subject = 'Plan your resignation if applicable', 
                    Priority = 'High', Status = 'Not Started', WhatId = whatId, ActivityDate = Date.today().addDays(3)));
                tasks.add(new Task(Subject = 'Take some time to relax and recharge', 
                    Priority = 'Normal', Status = 'Not Started', WhatId = whatId, ActivityDate = Date.today().addDays(7)));
                tasks.add(new Task(Subject = 'Prepare for your first day of onboarding', 
                    Priority = 'Normal', Status = 'Not Started', WhatId = whatId, ActivityDate = Date.today().addDays(10)));
            }
            when 'Closed' {
                tasks.add(new Task(Subject = 'Send a follow-up email thanking the interviewer and asking for feedback', 
                    Priority = 'Normal', Status = 'Not Started', WhatId = whatId, ActivityDate = Date.today().addDays(3)));
                tasks.add(new Task(Subject = 'Review your notes and reflect on areas of improvement', 
                    Priority = 'Normal', Status = 'Not Started', WhatId = whatId, ActivityDate = Date.today().addDays(3)));
            }
        }

        return tasks;

    }
}

