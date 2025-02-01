public with sharing class FindNewJobsSchedulable implements Schedulable{
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