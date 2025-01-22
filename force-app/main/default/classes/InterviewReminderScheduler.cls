// Schedulable class to run the InterviewReminder batch
public class InterviewReminderScheduler implements Schedulable {

    // Implement the execute method required by the Schedulable interface
    public void execute(SchedulableContext sc) {
        // Call the batchable class
        InterviewReminder batchJob = new InterviewReminder();
        // Run the batchable with a batch size of 200
        Database.executeBatch(batchJob, 200);
    }
}