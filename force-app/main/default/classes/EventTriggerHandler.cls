public with sharing class EventTriggerHandler extends TriggerHandler {

    public override void beforeInsert() {
        validateEvents(Trigger.new);
    }
    public override void beforeUpdate() {
        validateEvents(Trigger.new);
    }

    public void validateEvents(List<Event> events) {
        Set<Id> eventIds = new Set<Id>();
        List<Event> allEvents = [SELECT Id, StartDateTime, EndDateTime FROM Event WHERE Id != null];

       for (Event e : events) {
            /*//Skip null StartDateTime of EndDateTime - might not need this because start and end time cannot be null in Salesforce
            if (e.StartDateTime == null || e.EndDateTime == null) {
                continue;
            }*/

            //Ensure no weekend scheduling
            if (e.StartDateTime.format('E') == 'Sat' || e.StartDateTime.format('E') == 'Sun')  {
                e.addError('Events cannot be scheduled on weekends.');
                continue;
            }

            //Check for overlapping times - calls isOverlapping Utility method below
            for (Event existing : allEvents) {
                if (isOverlapping(e, existing)) {
                    e.addError('This event overlaps with another event.');
                    break;
                }
            }
        }
    }

    //Utility method to check if two events overlap
    public Boolean isOverlapping(Event newEvent, Event existingEvent) {
        Long newStart = newEvent.StartDateTime.getTime();
        Long newEnd = newEvent.EndDateTime.getTime();
        Long existingStart = existingEvent.StartDateTime.getTime();
        Long existingEnd = existingEvent.EndDateTime.getTime();

        //newEnd <= existingStart - Checks if the end time of the new interval is less than or equal to the start time of the existing interval. 
        //If true, then the new interval ends before or exactly when the existing interval starts, meaning no overlap
        //newStart >= existingEnd - Checks if the start timne of the new interval is greater than or equal to the end time of the existing interval.
        //If true, then the new interval starts after or exactly when the existing interval ends, again meaning no overlap
        return !(newEnd <= existingStart || newStart >= existingEnd);
        //If either of the above conditions is true, then there is no overlap between the two intervals.
        //If either condition is true = there is no overlap and result = false
        //If neither condition is true, it means there is an overlap, and the result will be true

    }

}



