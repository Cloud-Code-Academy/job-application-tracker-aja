public with sharing class BusinessDayUtils {
    public static Date getNextBusinessDay(){
        // Start with tomorrow
        Date nextDay = Date.today().addDays(1);
        // Cast date into DateTime so I can get the day of week
        DateTime mydatetime = DateTime.newInstance(Date.today().addDays(1), Time.newInstance(0, 0, 0, 0));
        String datestr = mydatetime.format('E');
        System.debug(datestr);

        String dayOfWeek = myDateTime.format('E');

        // Check for weekend and adjust as needed
        if(dayOfWeek == 'Sat'){
            System.debug('Day of week is Saturday, put event forward 2 days');
            nextDay = nextDay.addDays(2);
        }else if(dayOfWeek == 'Sun'){
            System.debug('Day of week is Sunday, push event forward 1 day');
            nextDay = nextDay.addDays(1);
        }
        return nextDay;
    }
}