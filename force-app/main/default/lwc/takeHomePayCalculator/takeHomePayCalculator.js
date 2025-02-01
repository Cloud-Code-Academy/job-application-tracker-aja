import { LightningElement, api, wire } from 'lwc';
import { getRecord, getFieldValue } from 'lightning/uiRecordApi';
import getTaxDetails from '@salesforce/apex/TakeHomePayCalculatorController.calculatePayPeriodDetails';
import SALARY_FIELD from '@salesforce/schema/Job_Application__c.Salary__c';

export default class TakeHomePayCalculator extends LightningElement {
    @api recordId;
    salary = 0;
    errorMessage = '';
    inputError = '';

    grossIncome = this.initIncomeObject();
    taxes = this.initTaxObject();
    totalTaxes = this.initIncomeObject();
    netIncome = this.initIncomeObject();

    @wire(getRecord, { recordId: '$recordId', fields: [SALARY_FIELD] })
    wiredJobApplication({ error, data }) {
        if (data) {
            this.salary = getFieldValue(data, SALARY_FIELD) || 0;
            this.validateSalary();
        } else if (error) {
            this.handleError('Error fetching record', error);
        }
    }

    handleSalaryChange(event) {
        const inputSalary = event.target.value;
        const numericSalary = parseFloat(inputSalary);

        if (!inputSalary || isNaN(numericSalary) || numericSalary <= 0) {
            this.inputError = 'Please enter a valid numeric value greater than 0.';
            this.resetResults();
            return;
        }

        this.salary = numericSalary;
        this.inputError = '';
        this.validateSalary();
    }

    validateSalary() {
        if (this.salary <= 0) {
            this.errorMessage = 'Salary must be greater than 0.';
            this.resetResults();
        } else {
            this.errorMessage = '';
            this.calculateTaxes();
        }
    }

    async calculateTaxes() {
        if (!this.salary || isNaN(this.salary) || this.salary <= 0) {
            this.resetResults();
            return;
        }

        try {
            const result = await getTaxDetails({ grossSalary: this.salary });
            if (result) {
                this.grossIncome = this.mapTaxPeriod(result, 'Gross Income');
                this.taxes = {
                    socialSecurity: this.mapTaxPeriod(result, 'Social Security Tax'),
                    medicare: this.mapTaxPeriod(result, 'Medicare Tax'),
                    federal: this.mapTaxPeriod(result, 'Federal Tax')
                };
                this.totalTaxes = this.mapTaxPeriod(result, 'Total Taxes');
                this.netIncome = this.mapTaxPeriod(result, 'Net Income');
            }
        } catch (error) {
            this.handleError('Error fetching tax details', error);
        }
    }

    mapTaxPeriod(result, taxCategory) {
        return {
            weekly: result[`Weekly ${taxCategory}`] || 0,
            biweekly: result[`Biweekly ${taxCategory}`] || 0,
            monthly: result[`Monthly ${taxCategory}`] || 0,
            annual: result[`Annual ${taxCategory}`] || 0
        };
    }

    resetResults() {
        this.grossIncome = this.initIncomeObject();
        this.taxes = this.initTaxObject();
        this.totalTaxes = this.initIncomeObject();
        this.netIncome = this.initIncomeObject();
    }

    initIncomeObject() {
        return { weekly: 0, biweekly: 0, monthly: 0, annual: 0 };
    }

    initTaxObject() {
        return {
            socialSecurity: this.initIncomeObject(),
            medicare: this.initIncomeObject(),
            federal: this.initIncomeObject()
        };
    }

    handleError(message, error) {
        console.error(message, error);
        this.errorMessage = message;
    }
}
