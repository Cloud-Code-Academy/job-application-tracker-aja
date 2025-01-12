public without sharing class InterviewReminder {        
    public static void sendInterviewReminders() {
            // Query events related to Job_Application__c scheduled for tomorrow
            List<Event> events = [
                SELECT OwnerId, Subject, WhoId, WhatId, Location, StartDateTime, EndDateTime, Type 
                FROM Event 
                WHERE DAY_ONLY(StartDateTime) = NEXT_N_DAYS:1
                AND What.Type = 'Job_Application__c'
            ];
    
            // Prepare emails
            List<Messaging.SingleEmailMessage> emails = new List<Messaging.SingleEmailMessage>();
            for (event e : events) {
                if (e.Owner.Email != null) {
                    Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
                    email.setToAddresses(new String[] {e.Owner.Email});
                    email.setSubject('Reminder: Interview Scheduled Tomorrow');
                    email.setPlainTextBody('This is a friendly reminder that an interview is scheduled for tomorrow.');
                    emails.add(email);
                }
            }
    
            // Send emails
            if (!emails.isEmpty()) {
                Messaging.sendEmail(emails);
            }
        }
    }