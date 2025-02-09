public with sharing class TakeHomePayCalculatorController {
    @AuraEnabled
public static Map<String, Decimal> calculatePayPeriodDetails(Decimal grossSalary) {
    if (grossSalary == null || grossSalary <= 0) {
        throw new AuraHandledException('Gross salary must be a positive value.');
    }

    // Fetch pay periods from helper
    Map<String, Decimal> payPeriods = PayPeriodHelper.getPayPeriods();

    // Initialize results map 
    Map<String, Decimal> results = new Map<String, Decimal>(); 

    // Store gross income by period
    results.put('Weekly Gross Income', (grossSalary / payPeriods.get('Weekly')).setScale(2));
    results.put('Biweekly Gross Income', (grossSalary / payPeriods.get('Bi_weekly')).setScale(2));
    results.put('Monthly Gross Income', (grossSalary / payPeriods.get('Monthly')).setScale(2));
    results.put('Annual Gross Income', grossSalary.setScale(2));

    // Calculate taxes by period
    Decimal weeklyGross = results.get('Weekly Gross Income');
    Decimal biweeklyGross = results.get('Biweekly Gross Income');
    Decimal monthlyGross = results.get('Monthly Gross Income');

    Decimal weeklySocial = calculateSocialSecurityTax(weeklyGross);
    Decimal biweeklySocial = calculateSocialSecurityTax(biweeklyGross);
    Decimal monthlySocial = calculateSocialSecurityTax(monthlyGross);
    Decimal annualSocial = calculateSocialSecurityTax(grossSalary);

    Decimal weeklyMedicare = calculateMedicareTax(weeklyGross);
    Decimal biweeklyMedicare = calculateMedicareTax(biweeklyGross);
    Decimal monthlyMedicare = calculateMedicareTax(monthlyGross);
    Decimal annualMedicare = calculateMedicareTax(grossSalary);

    Decimal weeklyFederal = calculateFederalIncomeTax(weeklyGross);
    Decimal biweeklyFederal = calculateFederalIncomeTax(biweeklyGross);
    Decimal monthlyFederal = calculateFederalIncomeTax(monthlyGross);
    Decimal annualFederal = calculateFederalIncomeTax(grossSalary);

    // Total taxes by period
    Decimal weeklyTotal = weeklySocial + weeklyMedicare + weeklyFederal;
    Decimal biweeklyTotal = biweeklySocial + biweeklyMedicare + biweeklyFederal;
    Decimal monthlyTotal = monthlySocial + monthlyMedicare + monthlyFederal;
    Decimal annualTotal = annualSocial + annualMedicare + annualFederal;

    // Net income by period
    Decimal weeklyNet = weeklyGross - weeklyTotal;
    Decimal biweeklyNet = biweeklyGross - biweeklyTotal;
    Decimal monthlyNet = monthlyGross - monthlyTotal;
    Decimal annualNet = grossSalary - annualTotal;

    // Populate results map 
    results.put('Weekly Social Security Tax', weeklySocial.setScale(2));
    results.put('Biweekly Social Security Tax', biweeklySocial.setScale(2));
    results.put('Monthly Social Security Tax', monthlySocial.setScale(2));
    results.put('Annual Social Security Tax', annualSocial.setScale(2));

    results.put('Weekly Medicare Tax', weeklyMedicare.setScale(2));
    results.put('Biweekly Medicare Tax', biweeklyMedicare.setScale(2));
    results.put('Monthly Medicare Tax', monthlyMedicare.setScale(2));
    results.put('Annual Medicare Tax', annualMedicare.setScale(2));

    results.put('Weekly Federal Tax', weeklyFederal.setScale(2));
    results.put('Biweekly Federal Tax', biweeklyFederal.setScale(2));
    results.put('Monthly Federal Tax', monthlyFederal.setScale(2));
    results.put('Annual Federal Tax', annualFederal.setScale(2));

    results.put('Weekly Total Taxes', weeklyTotal.setScale(2));
    results.put('Biweekly Total Taxes', biweeklyTotal.setScale(2));
    results.put('Monthly Total Taxes', monthlyTotal.setScale(2));
    results.put('Annual Total Taxes', annualTotal.setScale(2));

    results.put('Weekly Net Income', weeklyNet.setScale(2));
    results.put('Biweekly Net Income', biweeklyNet.setScale(2));
    results.put('Monthly Net Income', monthlyNet.setScale(2));
    results.put('Annual Net Income', annualNet.setScale(2));

    return results;
}


    @AuraEnabled
    public static Decimal calculateSocialSecurityTax(Decimal grossIncome) {
        if (grossIncome == null || grossIncome <= 0) {
            throw new AuraHandledException('Gross salary must be a positive value.');
        }
        Decimal socialSecurityRate = TaxRateHelper.getTaxRate('Social_Security');
        return grossIncome * socialSecurityRate;
    }

    @AuraEnabled
    public static Decimal calculateMedicareTax(Decimal grossIncome) {
        if (grossIncome == null || grossIncome <= 0) {
            throw new AuraHandledException('Gross salary must be a positive value.');
        }
        Decimal medicareRate = TaxRateHelper.getTaxRate('Medicare');
        return grossIncome * medicareRate;
    }

    @AuraEnabled
    public static Decimal calculateFederalIncomeTax(Decimal grossIncome) {
        if (grossIncome == null || grossIncome <= 0) {
            throw new AuraHandledException('Gross salary must be a positive value.');
        }

        List<Federal_Income_Tax_Bracket__mdt> brackets = TaxRateHelper.getFederalTaxBrackets();

        // Iterate through tax brackets to calculate tax
        Decimal federalTax = 0;
        for (Federal_Income_Tax_Bracket__mdt bracket : brackets) {
            if (grossIncome > bracket.Min__c) {
                Decimal taxableIncome = 0;
                if (grossIncome > bracket.Max__c) {
                    taxableIncome = bracket.Max__c - bracket.Min__c;
                } else {
                    taxableIncome = grossIncome - bracket.Min__c;
                }
                federalTax += taxableIncome * (bracket.Federal_Income_Tax_Rate__c);
                if (grossIncome <= bracket.Max__c) {
                    break;
                }
            }
        }

        return federalTax;
    }
}