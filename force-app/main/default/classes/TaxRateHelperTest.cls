@IsTest
public with sharing class TaxRateHelperTest {

    @IsTest
    static void testGetTaxRateSocialSecurity() {
        Test.startTest();
        Decimal taxRate = TaxRateHelper.getTaxRate('Social_Security');
        Test.stopTest();
        System.debug('Fetched Social Security tax rate: ' + taxRate);

        Assert.isTrue(taxRate >= 0, 'Tax rate for Social Security should be a positive number.');
    }

    @IsTest
    static void testGetTaxRateMedicare() {
        Test.startTest();
        Decimal taxRate = TaxRateHelper.getTaxRate('Medicare');
        Test.stopTest();
        System.debug('Fetched Medicare tax rate: ' + taxRate);

        Assert.isTrue(taxRate >= 0, 'Tax rate for Medicare should be a positive number.');
    }

    @IsTest
    static void testGetTaxRateInvalidTax() {
        Test.startTest();
        Decimal taxRate = TaxRateHelper.getTaxRate('Invalid_Tax');
        Test.stopTest();
        System.debug('Attempted to fetch invalid tax type. Returned tax rate: ' + taxRate);

        Assert.isTrue(taxRate == 0, 'Tax rate for an invalid tax type should return 0.');
    }

    @IsTest
    static void testGetTaxRateEmptyTaxType() {
        Test.startTest();
        Decimal taxRate = TaxRateHelper.getTaxRate('');
        Test.stopTest();
        System.debug('Attempted to fetch tax rate with empty tax type. Returned: ' + taxRate);

        Assert.isTrue(taxRate == 0, 'Tax rate for an empty tax type should return 0.');
    }

    @IsTest
    static void testGetTaxRateNullTaxType() {
        Test.startTest();
        Decimal taxRate = TaxRateHelper.getTaxRate(null);
        Test.stopTest();
        System.debug('Attempted to fetch tax rate with null tax type. Returned: ' + taxRate);

        Assert.isTrue(taxRate == 0, 'Tax rate for null tax type should return 0.');
    }

    @IsTest
    static void testGetFederalTaxBrackets() {
        Test.startTest();
        List<Federal_Income_Tax_Bracket__mdt> brackets = TaxRateHelper.getFederalTaxBrackets();
        Test.stopTest();
        System.debug('Fetched federal tax brackets count: ' + brackets.size());

        Assert.isTrue(brackets != null, 'Federal tax brackets list should not be null.');
    }

    @IsTest
    static void testGetTaxRateExceptionHandling() {
        Test.startTest();
        Decimal taxRate = TaxRateHelper.getTaxRate('INVALID_RECORD'); 
        Test.stopTest();
        System.debug('Exception Handling Test: Returned Tax Rate: ' + taxRate);

        Assert.isTrue(taxRate == 0, 'When an exception occurs, tax rate should return 0.');
    }
}
