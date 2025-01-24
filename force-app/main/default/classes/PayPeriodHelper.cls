public with sharing class PayPeriodHelper {
   public static Map<String, Decimal> getPayPeriods() {
        Map<String, Decimal> payPeriodMap = new Map<String, Decimal>();
        List<Pay_Period__mdt> payPeriodRecords = [
            SELECT DeveloperName, Periods_Per_Year__c
            FROM Pay_Period__mdt
            WITH SECURITY_ENFORCED
        ];

        for (Pay_Period__mdt record : payPeriodRecords) {
            payPeriodMap.put(record.DeveloperName, record.Periods_Per_Year__c);
        }

        return payPeriodMap;
    }
}