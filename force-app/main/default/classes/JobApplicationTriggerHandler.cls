public with sharing class JobApplicationTriggerHandler extends TriggerHandler {
   
    //Method that handles the logic after an update operation
   public override void afterUpdate() {

        //List to hold job applications where status changes
        List<Job_Application__c> updatedApplications = new List<Job_Application__c>();

        //loop through updated Job Application records to see if Status was changed
        for (SObject sObj : Trigger.new) {
            Job_Application__c application = (Job_Application__c) sObj; // Cast SObject to Job_Application__c
            Job_Application__c oldApplication = (Job_Application__c) Trigger.oldMap.get(application.Id); //Cast Trigger.oldMap values
            if (application.Status__c != oldApplication.Status__c) {
                updatedApplications.add(application);
            }
        }

        //Create Tasks based on new Status
        if (!updatedApplications.isEmpty()) {
            createTasksForStatusChange(updatedApplications);
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

