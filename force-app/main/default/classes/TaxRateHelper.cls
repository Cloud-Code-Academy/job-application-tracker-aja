public with sharing class TaxRateHelper {

    // Fetches the tax rate based on the given tax type.
    public static Decimal getTaxRate(String taxType) {
        if (String.isEmpty(taxType)) {
            System.debug('Invalid tax type provided.');
            return 0;
        }

        try {
            Tax_Rate__mdt taxRateRecord = [
                SELECT Tax_Rate_Decimal__c
                FROM Tax_Rate__mdt
                WHERE DeveloperName = :taxType
                WITH SECURITY_ENFORCED
                LIMIT 1
            ];
            return taxRateRecord != null ? taxRateRecord.Tax_Rate_Decimal__c : 0;
        } catch (QueryException qe) {
            System.debug('QueryException fetching tax rate for: ' + taxType + ', Error: ' + qe.getMessage());
            return 0;
        }
    }

    // Fetches the federal tax brackets from Custom Metadata Type.
    public static List<Federal_Income_Tax_Bracket__mdt> getFederalTaxBrackets() {
        List<Federal_Income_Tax_Bracket__mdt> brackets = new List<Federal_Income_Tax_Bracket__mdt>();

        try {
            brackets = [
                SELECT Federal_Income_Tax_Rate__c, Min__c, Max__c
                FROM Federal_Income_Tax_Bracket__mdt
                WITH SECURITY_ENFORCED
                ORDER BY Min__c ASC
            ];
        } catch (QueryException qe) {
            System.debug('QueryException in getFederalTaxBrackets(): ' + qe.getMessage());
        } 
        return brackets; // Returns empty list if no records exist or if an error occurs
    }
}
