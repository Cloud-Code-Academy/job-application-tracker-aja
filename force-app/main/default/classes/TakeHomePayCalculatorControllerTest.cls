@IsTest
public with sharing class TakeHomePayCalculatorControllerTest {
    @IsTest
    static void testCalculatePayPeriodDetails() {
        // Set up test input
        Decimal grossSalary = 120000; // Example gross annual salary

        // Fetch pay periods using the helper
        Map<String, Decimal> payPeriods = PayPeriodHelper.getPayPeriods();
        Decimal weeklyPeriodsPerYear = payPeriods.get('Weekly'); // Fetch weekly pay periods

        // Fetch tax rate for Social Security
        Decimal socialSecurityRate = TaxRateHelper.getTaxRate('Social_Security');

        // Call the method under test
        Test.startTest();
        Map<String, Decimal> results = TakeHomePayCalculatorController.calculatePayPeriodDetails(grossSalary);
        Test.stopTest();

        // Validate the results
        System.assert(results != null, 'Results map should not be null');
        System.assert(results.containsKey('Weekly Social Security Tax'), 'Results should contain Weekly Social Security Tax');
        System.assert(results.containsKey('Annual Net Income'), 'Results should contain Annual Net Income');

        // Check specific calculated values
        Decimal expectedWeeklySocialTax = (grossSalary / weeklyPeriodsPerYear) * (socialSecurityRate);
        System.assertEquals(expectedWeeklySocialTax.setScale(2), results.get('Weekly Social Security Tax').setScale(2), 'Weekly Social Security Tax calculation mismatch');
    }

    @IsTest
    static void testCalculateSocialSecurityTax() {
        // Set up test input
        Decimal grossSalary = 5000;

        // Fetch the Social Security tax rate from custom metadata using the helper
        Decimal socialSecurityRate = TaxRateHelper.getTaxRate('Social_Security');

        // Call the method under test
        Test.startTest();
        Decimal socialSecurityTax = TakeHomePayCalculatorController.calculateSocialSecurityTax(grossSalary);
        Test.stopTest();

        // Validate the result
        Decimal expectedTax = grossSalary * (socialSecurityRate);
        System.assertEquals(expectedTax.setScale(2), socialSecurityTax.setScale(2), 'Social Security Tax calculation mismatch');
    }

    @IsTest
    static void testCalculateMedicareTax() {
        // Set up test input
        Decimal grossSalary = 5000;

        // Fetch the Medicare tax rate from custom metadata using the helper
        Decimal medicareRate = TaxRateHelper.getTaxRate('Medicare');

        // Call the method under test
        Test.startTest();
        Decimal medicareTax = TakeHomePayCalculatorController.calculateMedicareTax(grossSalary);
        Test.stopTest();

        // Validate the result
        Decimal expectedTax = grossSalary * (medicareRate);
        System.assertEquals(expectedTax.setScale(2), medicareTax.setScale(2), 'Medicare Tax calculation mismatch');
    }

    @IsTest
    static void testCalculateFederalIncomeTax() {
        // Set up test input
        Decimal grossIncome = 100000;

        // Get federal income tax brackets from custom metadata using the helper
        List<Federal_Income_Tax_Bracket__mdt> brackets = TaxRateHelper.getFederalTaxBrackets();

        // Manually calculate the expected tax based on the brackets
        Decimal expectedTax = 0;

        // Calculate the expected federal tax using bracket logic
        for (Federal_Income_Tax_Bracket__mdt bracket : brackets) {
            if (grossIncome > bracket.Min__c) {
                Decimal taxableIncome = 0;
                if (grossIncome > bracket.Max__c) {
                    taxableIncome = bracket.Max__c - bracket.Min__c;
                } else {
                    taxableIncome = grossIncome - bracket.Min__c;
                }
                expectedTax += taxableIncome * (bracket.Tax_Rate__c / 100);
                if (grossIncome <= bracket.Max__c) {
                    break;
                }
            }
        }

        // Call the method under test
        Test.startTest();
        Decimal federalTax = TakeHomePayCalculatorController.calculateFederalIncomeTax(grossIncome);
        Test.stopTest();

        // Validate the result
        System.assertEquals(expectedTax.setScale(2), federalTax.setScale(2), 'Federal Income Tax calculation mismatch');
    }
}