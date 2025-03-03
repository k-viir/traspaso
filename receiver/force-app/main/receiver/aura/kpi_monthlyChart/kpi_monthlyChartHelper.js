({
    setChartData : function(cmp, evt, helper) {
        helper.setAverage(cmp, evt, helper);
        let kpiValues = cmp.get('v.kpiValues');
        let chartConfiguration = {
            "JSON_Setup": {
                "config": {
                    "type": "bar",
                    "options": {
                        "scales": {
                            "y": {
                                "min": 0,
                                "ticks": {
                                    "stepSize": 1,
                                    callback: function (value, index, ticks) { return value + '%' }
                                },
                                "grid": {
                                    "display": false
                                }

                            },
                            "x": {
                                "grid": {
                                    "display": false
                                }
                            }
                        },
                        "responsive": true,
                        "plugins": {
                            "tooltip": {
                                "callbacks": {
                                    label: function(context) {
                                        let label =  kpiValues[context.dataIndex].monthValue + ' '+ $A.get('$Label.c.VisitKpi_Visits') + ' / ' + kpiValues[context.dataIndex].groupsTotal + ' ' + $A.get('$Label.c.VisitKpi_Groups');

                                        return label;
                                    }
                                }
                            },
                            "legend": {
                                "display": true,
                                "position": 'bottom',
                                "labels": {
                                    generateLabels: (chart) => {
                                      return chart.data.labels.map(
                                        (label, index) => ({
                                            // get total visits and groups with index, complement with label
                                            text: label + ' ' + kpiValues[index].monthValue + ' '+ $A.get('$Label.c.VisitKpi_Visits') + ' / ' + kpiValues[index].groupsTotal + ' ' + $A.get('$Label.c.VisitKpi_Groups'),
                                            fillStyle: chart.data.datasets[0].backgroundColor[index]
                                        })
                                      )
                                    }
                                }
                            },
                            "title": {
                                "display": true,
                                "text": $A.get('$Label.c.VisitKpi_Monthly'),
                                "font": {
                                    "size": 20,
                                    "weight": "bold"
                                }
                            },
                            "subtitle": {
                                "display": true,
                                "text": $A.get('$Label.c.VisitKpi_Subtitle'),
                                "color": 'rgb(177,177,177)'
                            }
                        }
                    }
                }
            },
            "JSON_Data": {
                "labels": kpiValues.map((elem) => elem.name),
                "datasets": [{
                    "label": '',
                    "data": kpiValues.map((elem) => elem.percentageValue),
                    "backgroundColor": ["#013A63", "#01497C", "#014F86", "#2A6F97", "#2C7DA0", "#468FAF", "#61A5C2", "#89C2D9", "#A9D6E5","#013A63", "#01497C", "#014F86"],
                    "borderWidth": 2,
                    "borderWidth": 2,
                    "borderRadius": 2,
                    "borderSkipped": false,
                    "order": 1
                }
                ]
            }
        }
        cmp.set('v.chartConfiguration', chartConfiguration);

    },
    setAverage : function(cmp, evt, helper) {
        let kpiValues = cmp.get('v.kpiValues');
        let average = 0;
        kpiValues.forEach(elem => {
            average += Math.floor(elem.percentageValue);
        });
        average = Math.floor(average / kpiValues.length);
        cmp.set('v.average', average);
    },
    getValues : function (cmp, evt, helper) {
        let months = [$A.get("$Label.c.VisitKpi_January"), $A.get("$Label.c.VisitKpi_February"), $A.get("$Label.c.VisitKpi_March"), $A.get("$Label.c.VisitKpi_April"), $A.get("$Label.c.VisitKpi_May"), $A.get("$Label.c.VisitKpi_June"), $A.get("$Label.c.VisitKpi_July"), $A.get("$Label.c.VisitKpi_August"), $A.get("$Label.c.VisitKpi_September"), $A.get("$Label.c.VisitKpi_October"), $A.get("$Label.c.VisitKpi_November"), $A.get("$Label.c.VisitKpi_December")];
        let getKpiValues = cmp.get('c.getRecordMonthlyValues');
        getKpiValues.setParams({recordId: cmp.get('v.recordId')});
        getKpiValues.setCallback(this, function(response2) {
            let state2 = response2.getState();
            if (state2 === 'SUCCESS') {
                console.log(response2.getReturnValue());
                let kpiValues = response2.getReturnValue().map((elem) => {
                    if (elem.percentageValue == 0) {
                        elem.percentageValue = 1;
                    }
                    return elem;
                });
                for (let i = 0; i < months.length; i++) {
                    let month = months[i];
                    let found = kpiValues.find(elem => elem.name === month);
                    if (!found) {
                        kpiValues.push({name: month, percentageValue: 0, monthValue: 0, groupsTotal: 0});
                    }
                }//vaya relleno por parte de gpt, mis dieses
                cmp.set('v.kpiValues', kpiValues);

                helper.setChartData(cmp, evt, helper);
            }
        });
        $A.enqueueAction(getKpiValues);
    }

})