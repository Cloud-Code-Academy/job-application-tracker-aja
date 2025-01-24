public with sharing class InterviewReminderSynchronous {
    
    String query;
    List<Event> events = new List<Event>();

    public InterviewReminderSynchronous() {
        this.query = 'SELECT Id, Owner.Email, OwnerId, Subject, WhoId, WhatId, Location, StartDateTime, EndDateTime, Type FROM Event WHERE DAY_ONLY(StartDateTime) = NEXT_N_DAYS:1'; 
        this.events = Database.query(query);
    }

    public void sendInterviewReminderEmails(){
        List<Messaging.SingleEmailMessage> emails = new List<Messaging.SingleEmailMessage>();
        for(Event s : events){
            System.debug(s.Owner.Email);
           
            if (s.OwnerId != null && s.Owner.Email != null) {
                Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
                email.setToAddresses(new String[] {s.Owner.Email});
                email.setSubject('Reminder: Interview Scheduled Tomorrow');
                email.setPlainTextBody('This is a friendly reminder that an interview is scheduled for tomorrow at ' + s.StartDateTime);
                email.setWhatId(s.WhatId); //WhatId of Event is Job_Application__c Id
                emails.add(email);
            }
        }
        if(!emails.isEmpty()){
            System.debug('Emails list is not empty');
            Messaging.sendEmail(emails);
        }
    }
}