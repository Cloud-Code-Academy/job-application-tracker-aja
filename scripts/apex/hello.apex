// Use .apex files to store anonymous Apex.
// You can execute anonymous Apex in VS Code by selecting the
//     apex text and running the command:
//     SFDX: Execute Anonymous Apex with Currently Selected Text
// You can also execute the entire file by running the command:
//     SFDX: Execute Anonymous Apex with Editor Contents

string tempvar = 'Enter_your_name_here';
System.debug('Hello World!');
System.debug('My name is ' + tempvar);


    FindNewJobs fnj = new FindNewJobs();
    System.enqueueJob(fnj);

InterviewReminder interviewReminder = new InterviewReminder();
Database.executeBatch(interviewReminder, 200);

String SalaryAsText = '$110k - $200k';
String regExpression1 = '^\\$([0-9]+)k([\\s]+)-([\\s]+)\\$([0-9]+)k$';
//Pattern pattern1 = Pattern.compile(regExpression1);
//Matcher matcher1 = pattern1.matcher(salaryAsText);
Boolean matches = Pattern.matches(regExpression1,salaryAsText);
//System.debug(matcher1);
System.debug(matches);


String SalaryAsText = '$110k - $200k';
System.debug(SalaryAsText.length());
System.debug(SalaryAsText.indexOf('-'));

HttpRequest request = JobApplicationUtils.getHttpRequest();
System.debug(request);  

