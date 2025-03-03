({
    doInit: function (cmp, evt, helper) {
        let getKpiValues = cmp.get('c.getQuarterValues');
        getKpiValues.setParams({year: cmp.get('v.year'), quarter: cmp.get('v.quarter')});
        getKpiValues.setCallback(this, function(response2) {
            let state2 = response2.getState();
            if (state2 === 'SUCCESS') {
                console.log(response2.getReturnValue());
                cmp.set('v.kpiValues', response2.getReturnValue().map((elem) => {
                    if (elem.percentageValue == 0) {
                        elem.percentageValue = 1;
                    }
                    return elem;
                }));
                helper.setChartData(cmp, evt, helper);
            }
        });
        $A.enqueueAction(getKpiValues);
    },
    updateChart: function(cmp, evt, helper) {
        let params = evt.getParam('arguments');
        if (params) {
            console.log(JSON.stringify(params));
        }
        cmp.set('v.year', params.yearValue);
        cmp.set('v.quarter', params.quarterValue);

        let getKpiValues = cmp.get('c.getQuarterValues');
        getKpiValues.setParams({year: params.yearValue, quarter: params.quarterValue});
        getKpiValues.setCallback(this, function(response2) {
            let state2 = response2.getState();
            if (state2 === 'SUCCESS') {
                console.log(response2.getReturnValue());
                if (response2.getReturnValue().length > 0) {
                    cmp.set('v.kpiValues', response2.getReturnValue().map((elem) => {
                        if (elem.percentageValue == 0) {
                            elem.percentageValue = 1;
                        }
                        return elem;
                    }));
                    helper.setChartData(cmp, evt, helper);
                    let chartRefreshEvent = $A.get('e.chgn:chartRefreshEvent');
                    chartRefreshEvent.setParams({'ID': 'quarterChartCanvas'});
                    chartRefreshEvent.setParams({'Json_Chart': cmp.get('v.chartConfiguration')});
                    chartRefreshEvent.fire();
                } else {
                    cmp.set('v.chartConfiguration', undefined);
                }

            }
        });
        $A.enqueueAction(getKpiValues);
    }
})