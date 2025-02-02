/**
 * @description This class allows scheduling FindNewJobsQueueable 
 * @author Jonathan Lyles
 * @created 2025-01-31
 */

public with sharing class FindNewJobsSchedulable implements Schedulable{
    /**
     * @description Executes the scheduled job by enqueuing a FindNewJobsQueueable instance.  
     * This method is triggered by the Salesforce scheduler at a defined interval.  
     * If the SchedulableContext is null (which is unlikely), it still proceeds with enqueuing the job.  
     *
     * @param context The SchedulableContext provided by the scheduler (can be null in rare cases).
     */
    public void execute(SchedulableContext context){
        if (context != null) {
            System.enqueueJob(new FindNewJobsQueueable());
            System.debug('context is not null');
        } else {
            System.debug('SchedulableContext is null, but proceeding with queueable job.');
            System.enqueueJob(new FindNewJobsQueueable());
        }
    }
}