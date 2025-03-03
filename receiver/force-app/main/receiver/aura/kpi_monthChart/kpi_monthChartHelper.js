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
                                        // context.dataIndex for getting label, probably
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
                                            text: label.split(' ').length > 1 ? label.split(' ')[0] + ' ' + label.split(' ')[1].substring(0,3) + '... ' + kpiValues[index].monthValue + ' '+ $A.get('$Label.c.VisitKpi_Visits') + ' / ' + kpiValues[index].groupsTotal + ' ' + $A.get('$Label.c.VisitKpi_Groups') : label + ' '+ kpiValues[index].monthValue + ' '+ $A.get('$Label.c.VisitKpi_Visits') + ' / ' + kpiValues[index].groupsTotal + ' ' + $A.get('$Label.c.VisitKpi_Groups'),
                                            fillStyle: chart.data.datasets[0].backgroundColor[index]
                                        })
                                      )
                                    }
                                }
                            },
                            "title": {
                                "display": true,
                                "text": cmp.get('v.month') + ' ' + $A.get('$Label.c.VisitKpi_Visits'),
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
                    "backgroundColor": ["#013A63", "#01497C", "#014F86", "#2A6F97", "#2C7DA0", "#468FAF", "#61A5C2", "#89C2D9", "#A9D6E5"],
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
    }
})