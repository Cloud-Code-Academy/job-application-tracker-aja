global class InterviewReminderScheduler implements Schedulable {
    global void execute(SchedulableContext sc) {
        InterviewReminder.sendInterviewReminders();
    }
}