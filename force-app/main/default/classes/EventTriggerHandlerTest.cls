@isTest
public class EventTriggerHandlerTest {

    @isTest
    static void testNoOverlappingEvents() {
        // Create and insert an existing event
        Event existingEvent = new Event(
            Subject = 'Existing Event',
            StartDateTime = DateTime.now().addDays(1),
            EndDateTime = DateTime.now().addDays(1).addHours(1)
        );
        insert existingEvent;

        // Attempt to create a new overlapping event
        Event newEvent = new Event(
            Subject = 'Overlapping Event',
            StartDateTime = DateTime.now().addDays(1).addMinutes(30),
            EndDateTime = DateTime.now().addDays(1).addHours(1).addMinutes(30)
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
            StartDateTime = DateTime.now().addDays(3).addHours(9),
            EndDateTime = DateTime.now().addDays(3).addHours(10)
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
            StartDateTime = DateTime.now().addDays(3).addHours(9),
            EndDateTime = DateTime.now().addDays(3).addHours(10)
        );
        insert existingEvent;

        // Insert a second event
        Event secondEvent = new Event(
            Subject = 'Second Event',
            StartDateTime = DateTime.now().addDays(3).addHours(11),
            EndDateTime = DateTime.now().addDays(3).addHours(12)
        );
        insert secondEvent;

        // Attempt to update the second event to overlap with the first
        secondEvent.StartDateTime = DateTime.now().addDays(3).addHours(9).addMinutes(30);
        secondEvent.EndDateTime = DateTime.now().addDays(3).addHours(10).addMinutes(30);

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
            StartDateTime = DateTime.now().addDays(3).addHours(9),
            EndDateTime = DateTime.now().addDays(3).addHours(10)
        );
        insert existingEvent;

        // Update the event to a new valid time range
        existingEvent.StartDateTime = DateTime.now().addDays(3).addHours(13);
        existingEvent.EndDateTime = DateTime.now().addDays(3).addHours(14);

        Test.startTest();
        update existingEvent;
        Test.stopTest();

        // Assert no errors occurred
        Event updatedEvent = [SELECT StartDateTime, EndDateTime FROM Event WHERE Id = :existingEvent.Id];
        System.assertEquals(DateTime.now().addDays(3).addHours(13), updatedEvent.StartDateTime);
        System.assertEquals(DateTime.now().addDays(3).addHours(14), updatedEvent.EndDateTime);
    }

    @isTest
    static void testMultipleEventValidations() {
        // Create and insert an existing event
        Event existingEvent = new Event(
            Subject = 'Existing Event',
            StartDateTime = DateTime.now().addDays(2).addHours(9),
            EndDateTime = DateTime.now().addDays(2).addHours(10)
        );
        insert existingEvent;

        // Attempt to create multiple events with various scenarios
        Event overlappingEvent = new Event(
            Subject = 'Overlapping Event',
            StartDateTime = DateTime.now().addDays(2).addHours(9).addMinutes(30),
            EndDateTime = DateTime.now().addDays(2).addHours(10).addMinutes(30)
        );
        Event weekendEvent = new Event(
            Subject = 'Weekend Event',
            StartDateTime = DateTime.newInstance(2025, 1, 26, 10, 0, 0), // Sunday
            EndDateTime = DateTime.newInstance(2025, 1, 26, 11, 0, 0)
        );
        Event validEvent = new Event(
            Subject = 'Valid Event',
            StartDateTime = DateTime.now().addDays(2).addHours(11),
            EndDateTime = DateTime.now().addDays(2).addHours(12)
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

