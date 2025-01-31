@isTest
public class EventTriggerHandlerTest {

    @isTest
    static void testNoOverlappingEvents() {
        // Create and insert an existing event
        Event existingEvent = new Event(
            Subject = 'Existing Event',
            StartDateTime = DateTime.newInstance(2025, 1, 31, 10, 0, 0), // Friday
            EndDateTime = DateTime.newInstance(2025, 1, 31, 11, 0, 0)
        );
        insert existingEvent;

        // Attempt to create a new overlapping event
        Event newEvent = new Event(
            Subject = 'Overlapping Event',
            StartDateTime = DateTime.newInstance(2025, 1, 31, 10, 30, 0),
            EndDateTime = DateTime.newInstance(2025, 1, 31, 11, 30, 0)
        );

        Test.startTest();
        try {
            insert newEvent;
            System.assert(false, 'Expected a DMLException due to overlapping events.');
        } catch (DmlException e) {
            System.assert(e.getMessage().contains('This event overlaps with another event.'));
        }
        Test.stopTest();
    }

    @isTest
    static void testNoWeekendScheduling() {
        // Create an event on a weekend (e.g., Saturday)
        Event weekendEvent = new Event(
            Subject = 'Weekend Event',
            StartDateTime = DateTime.newInstance(2025, 1, 25, 10, 0, 0), // Saturday
            EndDateTime = DateTime.newInstance(2025, 1, 25, 11, 0, 0)
        );

        Test.startTest();
        try {
            insert weekendEvent;
            System.assert(false, 'Expected a DMLException due to weekend scheduling.');
        } catch (DmlException e) {
            System.assert(e.getMessage().contains('Events cannot be scheduled on weekends.'));
        }
        Test.stopTest();
    }

    @isTest
    static void testBeforeUpdateNoWeekendScheduling() {
        // Insert a valid event
        Event validEvent = new Event(
            Subject = 'Valid Event',
            StartDateTime = DateTime.newInstance(2025, 1, 22, 10, 0, 0),
            EndDateTime = DateTime.newInstance(2025, 1, 22, 11, 0, 0)
        );
        insert validEvent;

        // Attempt to update the event to a weekend date
        validEvent.StartDateTime = DateTime.newInstance(2025, 1, 25, 10, 0, 0); // Saturday
        validEvent.EndDateTime = DateTime.newInstance(2025, 1, 25, 11, 0, 0);

        Test.startTest();
        try {
            update validEvent;
            System.assert(false, 'Expected a DMLException due to weekend scheduling during update.');
        } catch (DmlException e) {
            System.assert(e.getMessage().contains('Events cannot be scheduled on weekends.'));
        }
        Test.stopTest();
    }

    @isTest
    static void testBeforeUpdateOverlappingEvent() {
        // Insert an existing event
        Event existingEvent = new Event(
            Subject = 'Existing Event',
            StartDateTime = DateTime.newInstance(2025, 1, 31, 9, 0, 0),
            EndDateTime = DateTime.newInstance(2025, 1, 31, 10, 0, 0)
        );
        insert existingEvent;

        // Insert a second event
        Event secondEvent = new Event(
            Subject = 'Second Event',
            StartDateTime = DateTime.newInstance(2025, 1, 31, 11, 0, 0),
            EndDateTime = DateTime.newInstance(2025, 1, 31, 12, 0, 0)
        );
        insert secondEvent;

        // Attempt to update the second event to overlap with the first
        secondEvent.StartDateTime = DateTime.newInstance(2025, 1, 31, 9, 30, 0);
        secondEvent.EndDateTime = DateTime.newInstance(2025, 1, 31, 10, 30, 0);

        Test.startTest();
        try {
            update secondEvent;
            System.assert(false, 'Expected a DMLException due to overlapping events during update.');
        } catch (DmlException e) {
            System.assert(e.getMessage().contains('This event overlaps with another event.'));
        }
        Test.stopTest();
    }

    @isTest
    static void testValidUpdate() {
        // Insert an existing event
        Event existingEvent = new Event(
            Subject = 'Existing Event',
            StartDateTime = DateTime.newInstance(2025, 1, 31, 9, 0, 0),
            EndDateTime = DateTime.newInstance(2025, 1, 31, 10, 0, 0)
        );
        insert existingEvent;

        // Update the event to a new valid time range
        existingEvent.StartDateTime = DateTime.newInstance(2025, 1, 31, 11, 0, 0);
        existingEvent.EndDateTime = DateTime.newInstance(2025, 1, 31, 12, 0, 0);

        Test.startTest();
        update existingEvent;
        Test.stopTest();

        // Assert no errors occurred
        Event updatedEvent = [SELECT StartDateTime, EndDateTime FROM Event WHERE Id = :existingEvent.Id];
        System.assertEquals(DateTime.newInstance(2025, 1, 31, 11, 0, 0), updatedEvent.StartDateTime, 'Start time should be January 31, 2025, 11:00 AM');
        System.assertEquals(DateTime.newInstance(2025, 1, 31, 12, 0, 0), updatedEvent.EndDateTime, 'End time should be January 31, 2025, 12:00 PM');
    }

    @isTest
    static void testMultipleEventValidations() {
        // Create and insert an existing event
        Event existingEvent = new Event(
            Subject = 'Existing Event',
            StartDateTime = DateTime.newInstance(2025, 1, 31, 9, 0, 0),
            EndDateTime = DateTime.newInstance(2025, 1, 31, 10, 0, 0)
        );
        insert existingEvent;

        // Attempt to create multiple events with various scenarios
        Event overlappingEvent = new Event(
            Subject = 'Overlapping Event',
            StartDateTime = DateTime.newInstance(2025, 1, 31, 9, 30, 0),
            EndDateTime = DateTime.newInstance(2025, 1, 31, 10, 30, 0)
        );
        Event weekendEvent = new Event(
            Subject = 'Weekend Event',
            StartDateTime = DateTime.newInstance(2025, 1, 26, 10, 0, 0), // Sunday
            EndDateTime = DateTime.newInstance(2025, 1, 26, 11, 0, 0)
        );
        Event validEvent = new Event(
            Subject = 'Valid Event',
            StartDateTime = DateTime.newInstance(2025, 1, 31, 11, 30, 0),
            EndDateTime = DateTime.newInstance(2025, 1, 31, 12, 30, 0)
        );

        Test.startTest();
        Database.SaveResult[] results = Database.insert(new Event[] { overlappingEvent, weekendEvent, validEvent }, false);
        Test.stopTest();

        // Validate results
        System.assert(!results[0].isSuccess(), 'Overlapping event should fail.');
        System.assert(results[0].getErrors()[0].getMessage().contains('This event overlaps with another event.'));
        System.assert(!results[1].isSuccess(), 'Weekend event should fail.');
        System.assert(results[1].getErrors()[0].getMessage().contains('Events cannot be scheduled on weekends.'));
        System.assert(results[2].isSuccess(), 'Valid event should succeed.');
    }
}

