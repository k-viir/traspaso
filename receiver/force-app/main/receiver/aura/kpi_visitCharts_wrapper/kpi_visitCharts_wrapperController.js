({
    doInit : function(cmp, event, helper) {
        let yearOptions = [];
        let quarterOptions = [{label: $A.get('$Label.c.VisitKpi_Q1'), value: $A.get('$Label.c.VisitKpi_Q1')},{label: $A.get('$Label.c.VisitKpi_Q2'), value: $A.get('$Label.c.VisitKpi_Q2')},{label: $A.get('$Label.c.VisitKpi_Q3'), value: $A.get('$Label.c.VisitKpi_Q3')},{label: $A.get('$Label.c.VisitKpi_Q4'), value: $A.get('$Label.c.VisitKpi_Q4')}];
        let monthOptions = [
            {label: $A.get("$Label.c.VisitKpi_January"), value: $A.get("$Label.c.VisitKpi_January")},
            {label: $A.get("$Label.c.VisitKpi_February"), value: $A.get("$Label.c.VisitKpi_February")},
            {label: $A.get("$Label.c.VisitKpi_March"), value: $A.get("$Label.c.VisitKpi_March")},
            {label: $A.get("$Label.c.VisitKpi_April"), value: $A.get("$Label.c.VisitKpi_April")},
            {label: $A.get("$Label.c.VisitKpi_May"), value: $A.get("$Label.c.VisitKpi_May")},
            {label: $A.get("$Label.c.VisitKpi_June"), value: $A.get("$Label.c.VisitKpi_June")},
            {label: $A.get("$Label.c.VisitKpi_July"), value: $A.get("$Label.c.VisitKpi_July")},
            {label: $A.get("$Label.c.VisitKpi_August"), value: $A.get("$Label.c.VisitKpi_August")},
            {label: $A.get("$Label.c.VisitKpi_September"), value: $A.get("$Label.c.VisitKpi_September")},
            {label: $A.get("$Label.c.VisitKpi_October"), value: $A.get("$Label.c.VisitKpi_October")},
            {label: $A.get("$Label.c.VisitKpi_November"), value: $A.get("$Label.c.VisitKpi_November")},
            {label: $A.get("$Label.c.VisitKpi_December"), value: $A.get("$Label.c.VisitKpi_December")}
        ];
        cmp.set('v.monthOptions', monthOptions);
        cmp.set('v.quarterOptions', quarterOptions);
        cmp.set('v.filteredMonthOptions', monthOptions.slice(0, 3));
        // get real values through apex
        let action = cmp.get('c.getYears');
        action.setCallback(this, function(response) {
            let state = response.getState();
            if (state === 'SUCCESS') {
                console.log(response.getReturnValue());
                response.getReturnValue().forEach(elem => {
                    yearOptions.push({label: elem, value: elem});
                });
                cmp.set('v.yearOptions', yearOptions);
                cmp.set('v.yearValue', yearOptions[0].value);
                cmp.set('v.monthValue', monthOptions[0].value);
                cmp.set('v.quarterValue', quarterOptions[0].value);
            }
        });
        $A.enqueueAction(action);

    },
    updateFilters: function(cmp, evt, helper) {
        // call inner component method that updates values for the charts
        let picklistComponent = evt.getSource();
        let variant = picklistComponent.get('v.name');
        let monthChartCmp;
        let quarterChartCmp;
        let yearPicklistCmp = cmp.find('yearCombo');
        let monthPicklistCmp = cmp.find('monthCombo');
        let quarterPicklistCmp = cmp.find('quarterCombo');

        switch (variant) {
            case 'year':
                monthChartCmp = cmp.find('monthChart');
                quarterChartCmp = cmp.find('quarterChart');
                monthPicklistCmp = cmp.find('monthCombo');
                quarterPicklistCmp = cmp.find('quarterCombo');
                monthChartCmp.updateChart(picklistComponent.get('v.value'), monthPicklistCmp.get('v.value'));
                quarterChartCmp.updateChart(picklistComponent.get('v.value'), quarterPicklistCmp.get('v.value'));
                break;
            case 'quarter':
                quarterChartCmp = cmp.find('quarterChart');
                yearPicklistCmp = cmp.find('yearCombo');
                quarterChartCmp.updateChart(yearPicklistCmp.get('v.value'), picklistComponent.get('v.value'));
                // filter months available based on selected quarter
                let allMonthOptions = cmp.get('v.monthOptions');
                let filteredMonthOptions = [];
                switch (picklistComponent.get('v.value')) {
                    case 'Q1':
                        filteredMonthOptions = allMonthOptions.slice(0, 3);
                        break;
                    case 'Q2':
                        filteredMonthOptions = allMonthOptions.slice(3, 6);
                        break;
                    case 'Q3':
                        filteredMonthOptions = allMonthOptions.slice(6, 9);
                        break;
                    case 'Q4':
                        filteredMonthOptions = allMonthOptions.slice(9, 12);
                        break;
                }
                cmp.set('v.filteredMonthOptions', filteredMonthOptions);
                cmp.set('v.monthValue', filteredMonthOptions[0].value);
                monthChartCmp = cmp.find('monthChart');
                monthChartCmp.updateChart(yearPicklistCmp.get('v.value'), cmp.get('v.monthValue'));
                break;
            case 'month':
                yearPicklistCmp = cmp.find('yearCombo');
                monthChartCmp = cmp.find('monthChart');
                monthChartCmp.updateChart(yearPicklistCmp.get('v.value'), picklistComponent.get('v.value'));
                break;
        }
    }
})