public with sharing class TaxRateHelper {

    // Fetches the tax rate based on the given tax type.
    public static Decimal getTaxRate(String taxType) {
        if (String.isEmpty(taxType)) {
            return 0;
        }

        Tax_Rate__mdt taxRateRecord = [
            SELECT Tax_Rate_Decimal__c
            FROM Tax_Rate__mdt
            WHERE DeveloperName = :taxType
            WITH SECURITY_ENFORCED
            LIMIT 1
        ];
        return taxRateRecord != null ? taxRateRecord.Tax_Rate_Decimal__c : 0;
    }

    // Fetches the federal tax brackets from Custom Metadata Type.
    public static List<Federal_Income_Tax_Bracket__mdt> getFederalTaxBrackets() {
        return [
            SELECT Federal_Income_Tax_Rate__c, Min__c, Max__c
            FROM Federal_Income_Tax_Bracket__mdt
            WITH SECURITY_ENFORCED
            ORDER BY Min__c ASC
        ];
    }
}