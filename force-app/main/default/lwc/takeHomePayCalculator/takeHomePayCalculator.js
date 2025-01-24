import { LightningElement, api, wire } from 'lwc';
import { getRecord, getFieldValue } from 'lightning/uiRecordApi';
import getTaxDetails from '@salesforce/apex/TakeHomePayCalculatorController.calculatePayPeriodDetails';
import SALARY_FIELD from '@salesforce/schema/Job_Application__c.Salary__c';

export default class TakeHomePayCalculatorController extends LightningElement {
    @api recordId; // Record ID of the Job_Application__c object
    salary = 0; // Default value for the salary field
    errorMessage = ''; // Error message for negative salary input
    inputError = ''; // Error message for invalid non-numeric input

    // Default values as constants for clarity
    grossIncome = { weekly: 0, biweekly: 0, monthly: 0, annual: 0 };
    taxes = {
        socialSecurity: { weekly: 0, biweekly: 0, monthly: 0, annual: 0 },
        medicare: { weekly: 0, biweekly: 0, monthly: 0, annual: 0 },
        federal: { weekly: 0, biweekly: 0, monthly: 0, annual: 0 }
    };
    totalTaxes = { weekly: 0, biweekly: 0, monthly: 0, annual: 0 };
    netIncome = { weekly: 0, biweekly: 0, monthly: 0, annual: 0 };

    // Fetch record data with error handling
    @wire(getRecord, { recordId: '$recordId', fields: [SALARY_FIELD] })
    wiredJobApplication({ error, data }) {
        if (data) {
            this.salary = getFieldValue(data, SALARY_FIELD) || 0; // Default to 0 if no value

            // Check if the salary from the record is negative and show error
            if (this.salary < 0) {
                this.errorMessage = 'Salary cannot be negative. Please enter a valid amount.';
            } else if (this.salary === 0) {
                this.errorMessage = 'Salary must be greater than 0. Please enter a valid amount.';
            } else {
                this.errorMessage = ''; // Clear error if salary is valid
            }
            this.calculateTaxes();
        } else if (error) {
            this.handleError('Error fetching record', error);
        }
    }

    // Handle salary change and check for negative value, zero or invalid input
    handleSalaryChange(event) {
        const inputSalary = event.target.value;

        // Check if the input contains any non-numeric characters
        if (isNaN(inputSalary) || inputSalary.trim() === '') {
            this.inputError = 'Please enter a valid numeric value for salary.';
            this.salary = 0; // Reset salary if invalid input
            this.resetResults(); // Optionally reset other results
        } else {
            const numericSalary = parseFloat(inputSalary);

            // Check if the salary is negative or zero
            if (numericSalary < 0) {
                this.inputError = 'Salary cannot be negative. Please enter a valid amount.';
                this.salary = 0; // Reset the salary field
                this.resetResults(); // Optionally reset other results
            } else if (numericSalary === 0) {
                this.inputError = 'Salary must be greater than 0. Please enter a valid amount.';
                this.salary = 0; // Reset the salary field
                this.resetResults(); // Optionally reset other results
            } else {
                this.inputError = ''; // Clear the input error message if the value is valid
                this.salary = numericSalary;
                this.calculateTaxes(); // Recalculate taxes with the valid salary
            }
        }
    }

    // Calculate taxes and break down gross income
    calculateTaxes() {
        if (this.salary <= 0) {
            this.resetResults(); // Reset if salary is invalid
            return;
        }

        getTaxDetails({ grossSalary: this.salary })
            .then((result) => {
                // Map result data and format decimals
                this.grossIncome = this.calculateGrossIncome(this.salary);
                this.taxes = this.mapTaxData(result);
                this.totalTaxes = this.mapTotalTaxes(result);
                this.netIncome = this.mapNetIncome(result);
            })
            .catch((error) => {
                this.handleError('Error fetching tax details', error);
            });
    }

    // Utility: Calculate gross income breakdown
    calculateGrossIncome(salary) {
        return {
            weekly: (salary / 52).toFixed(2),
            biweekly: (salary / 26).toFixed(2),
            monthly: (salary / 12).toFixed(2),
            annual: salary.toFixed(2)
        };
    }

    // Utility: Map tax details to structured data
    mapTaxData(result) {
        return {
            socialSecurity: this.mapTaxPeriod(result, 'Social Security Tax'),
            medicare: this.mapTaxPeriod(result, 'Medicare Tax'),
            federal: this.mapTaxPeriod(result, 'Federal Tax')
        };
    }

    // Utility: Map total taxes
    mapTotalTaxes(result) {
        return this.mapTaxPeriod(result, 'Total Taxes');
    }

    // Utility: Map net income
    mapNetIncome(result) {
        return this.mapTaxPeriod(result, 'Net Income');
    }

    // Utility: Map tax details for specific period
    mapTaxPeriod(result, keyPrefix) {
        return {
            weekly: result[`Weekly ${keyPrefix}`],
            biweekly: result[`Biweekly ${keyPrefix}`],
            monthly: result[`Monthly ${keyPrefix}`],
            annual: result[`Annual ${keyPrefix}`]
        };
    }

    // Utility: Reset all data to default
    resetResults() {
        this.grossIncome = this.calculateGrossIncome(0);
        this.taxes = this.mapTaxData({});
        this.totalTaxes = this.mapTotalTaxes({});
        this.netIncome = this.mapNetIncome({});
    }

    // Utility: Handle and log errors
    handleError(message, error) {
        console.error(message, error);
    }
}