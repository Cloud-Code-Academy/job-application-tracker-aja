@IsTest
public with sharing class TakeHomePayCalculatorControllerTest {

    @IsTest
    static void testCalculatePayPeriodDetailsPositive() {
        Decimal grossSalary = 100000;
        Test.startTest();
        Map<String, Decimal> results = TakeHomePayCalculatorController.calculatePayPeriodDetails(grossSalary);
        Test.stopTest();

        System.assert(results != null, 'Results map should not be null');
        System.assert(results.containsKey('Weekly Social Security Tax'), 'Results should contain Weekly Social Security Tax');
        System.assert(results.containsKey('Annual Net Income'), 'Results should contain Annual Net Income');
    }

    @IsTest
    static void testCalculatePayPeriodDetailsNullSalary() {
        Boolean exceptionThrown = false;
        try {
            Test.startTest();
            TakeHomePayCalculatorController.calculatePayPeriodDetails(null);
            Test.stopTest();
        } catch (AuraHandledException e) {
            exceptionThrown = true;
        }
        Assert.isTrue(exceptionThrown, 'Expected an exception for null salary input but none was thrown.');
    }

    @IsTest
    static void testCalculatePayPeriodDetailsNegativeSalary() {
        Boolean exceptionThrown = false;
        try {
            Test.startTest();
            TakeHomePayCalculatorController.calculatePayPeriodDetails(-5000);
            Test.stopTest();
        } catch (AuraHandledException e) {
            exceptionThrown = true;
        }
        Assert.isTrue(exceptionThrown, 'Expected an exception for negative salary input but none was thrown.');
    }

    @IsTest
    static void testCalculateSocialSecurityTaxPositive() {
        Decimal grossSalary = 50000;
        Test.startTest();
        Decimal socialSecurityTax = TakeHomePayCalculatorController.calculateSocialSecurityTax(grossSalary);
        Test.stopTest();
        System.assert(socialSecurityTax >= 0, 'Social Security Tax should be positive');
    }

    @IsTest
    static void testCalculateSocialSecurityTaxNullSalary() {
        Boolean exceptionThrown = false;
        try {
            Test.startTest();
            TakeHomePayCalculatorController.calculateSocialSecurityTax(null);
            Test.stopTest();
        } catch (AuraHandledException e) {
            exceptionThrown = true;
        }
        Assert.isTrue(exceptionThrown, 'Expected an exception for null salary input but none was thrown.');
    }

    @IsTest
    static void testCalculateSocialSecurityTaxNegativeSalary() {
        Boolean exceptionThrown = false;
        try {
            Test.startTest();
            TakeHomePayCalculatorController.calculateSocialSecurityTax(-10000);
            Test.stopTest();
        } catch (AuraHandledException e) {
            exceptionThrown = true;
        }
        Assert.isTrue(exceptionThrown, 'Expected an exception for negative salary input but none was thrown.');
    }

    @IsTest
    static void testCalculateMedicareTaxPositive() {
        Decimal grossSalary = 60000;
        Test.startTest();
        Decimal medicareTax = TakeHomePayCalculatorController.calculateMedicareTax(grossSalary);
        Test.stopTest();
        System.assert(medicareTax >= 0, 'Medicare Tax should be positive');
    }

    @IsTest
    static void testCalculateMedicareTaxNullSalary() {
        Boolean exceptionThrown = false;
        try {
            Test.startTest();
            TakeHomePayCalculatorController.calculateMedicareTax(null);
            Test.stopTest();
        } catch (AuraHandledException e) {
            exceptionThrown = true;
        }
        Assert.isTrue(exceptionThrown, 'Expected an exception for null salary input but none was thrown.');
    }

    @IsTest
    static void testCalculateMedicareTaxNegativeSalary() {
        Boolean exceptionThrown = false;
        try {
            Test.startTest();
            TakeHomePayCalculatorController.calculateMedicareTax(-7000);
            Test.stopTest();
        } catch (AuraHandledException e) {
            exceptionThrown = true;
        }
        Assert.isTrue(exceptionThrown, 'Expected an exception for negative salary input but none was thrown.');
    }

    @IsTest
    static void testCalculateFederalIncomeTaxPositive() {
        Decimal grossIncome = 120000;
        Test.startTest();
        Decimal federalTax = TakeHomePayCalculatorController.calculateFederalIncomeTax(grossIncome);
        Test.stopTest();
        System.assert(federalTax >= 0, 'Federal tax should be positive');
    }

    @IsTest
    static void testCalculateFederalIncomeTaxNullSalary() {
        Boolean exceptionThrown = false;
        try {
            Test.startTest();
            TakeHomePayCalculatorController.calculateFederalIncomeTax(null);
            Test.stopTest();
        } catch (AuraHandledException e) {
            exceptionThrown = true;
        }
        Assert.isTrue(exceptionThrown, 'Expected an exception for null salary input but none was thrown.');
    }

    @IsTest
    static void testCalculateFederalIncomeTaxNegativeSalary() {
        Boolean exceptionThrown = false;
        try {
            Test.startTest();
            TakeHomePayCalculatorController.calculateFederalIncomeTax(-80000);
            Test.stopTest();
        } catch (AuraHandledException e) {
            exceptionThrown = true;
        }
        Assert.isTrue(exceptionThrown, 'Expected an exception for negative salary input but none was thrown.');
    }
}
