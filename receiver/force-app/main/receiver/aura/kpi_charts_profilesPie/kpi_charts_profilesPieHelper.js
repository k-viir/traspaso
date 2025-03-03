/* eslint-disable no-unused-expressions */
({
  setChartConfig: function(cmp, evt, helper) {
    let profilesChartData = cmp.get('v.profilesChartData');
    let formattedData = [];
    let blues = [];
    for (let i = 25; i < 100; i += 3) {
      let alpha = i / 100;
      let color = `rgba(0, 0, 255, ${alpha})`;
      blues.push(color);
    }
    let pieColors = [
      'rgba(148, 223, 255, 1)',
      'rgba(132, 218, 255, 1)',
      'rgba(125, 216, 255, 1)',
      'rgba(116, 213, 255, 1)',
      'rgba(107, 210, 255, 1)',
      'rgba(95, 207, 255, 1)',
      'rgba(85, 203, 254, 1)',
      'rgba(72, 198, 252, 1)',
      'rgba(62, 197, 255, 1)',
      'rgba(52, 194, 255, 1)',
      'rgba(35, 189, 255, 1)',
      'rgba(27, 186, 255, 1)',
      'rgba(19, 184, 255, 1)',
      'rgba(10, 181, 255, 1)',
      'rgba(6, 180, 255, 1)',
      'rgba(1, 172, 246, 1)',
      'rgba(0, 164, 235, 1)',
      'rgba(0, 157, 226, 1)',
      'rgba(0, 148, 211, 1)',
      'rgba(0, 139, 199, 1)',
      'rgba(0, 130, 186, 1)',
      'rgba(0, 124, 178, 1)',
      'rgba(0, 117, 167, 1)',
      'rgba(0, 107, 154, 1)',
      'rgba(0, 100, 143, 1)',
      'rgba(0, 91, 131, 1)',
      'rgba(0, 83, 119, 1)',
      'rgba(0, 73, 104, 1)',
    ];
    pieColors.sort(() => Math.random() - 0.5);
    let profileLabels = Object.keys(
      cmp.get('v.profilesChartData').profilesValuesMap
    );
    cmp.set('v.profileLabels', profileLabels);
    profileLabels.forEach((elem) => {
      formattedData.push(profilesChartData.profilesValuesMap[elem]);
    });

    let chartConfiguration = {
      JSON_Setup: {
        enableButton: false,
        config: {
          type: 'pie', // its gonna be a pie
          options: {
            onClick: (event, activeItems, chart) => {
              // in case we want click and go to report function
              let activePoints = chart.getElementsAtEventForMode(
                event,
                'point',
                chart.options
              );
              let firstPoint = activePoints[0];
              if (firstPoint) {
                helper.goToReport(
                  cmp,
                  evt,
                  helper,
                  cmp.get('v.profileLabels')[firstPoint.index]
                );
              }
            },
            responsive: true,
            scales: {
              y: {
                beginAtZero: 'true',
                display: false,
                grid: {
                  display: false,
                },
              },
              x: {
                beginAtZero: 'true',
                display: false,
                grid: {
                  display: false,
                },
              },
            },
            plugins: {
              legend: {
                display: true,
                position: 'bottom',
              },
              title: {
                display: true,
                text:
                  $A.get('$Label.eext.Profile_chart_title') +
                  ' ' +
                  cmp.get('v.filterValue'), // change title as well
              },
              tooltip: {
                callbacks: {
                },
              },
            },
          },
        },
      },
      JSON_Data: {
        labels: profileLabels,
        datasets: [
          {
            label: $A.get('$Label.eext.Total'), // doesnt need a label probably
            data: formattedData, // its a different dataset
            backgroundColor: pieColors, //no colors predefined?
            borderWidth: 2,
            borderRadius: 2,
            borderSkipped: false,
            order: 1,
          },
        ],
        hoverOffset: 40,
      },
    };

    cmp.set('v.chartConfiguration', chartConfiguration);
  },
  goToReport: function(cmp, evt, helper, profileFilter) {
    let navService = cmp.find('navService');
    let reportFilters;

    reportFilters = {
      fv1: cmp.get('v.recordId'),
      fv2: profileFilter, // profile
      fv3: cmp.get('v.filterValue'), // status
    };
    let pageReference = {
      type: 'standard__recordPage',
      attributes: {
        recordId: cmp.get('v.reportId'),
        actionName: 'view',
      },
      state: reportFilters,
    };
    cmp.set('v.pageReference', pageReference);

    navService.navigate(pageReference);
  },
  showErrorToast: function(cmp, evt, helper, message) {
    let toastEvent = $A.get('e.force:showToast');
    toastEvent.setParams({
      title: $A.get('$Label.eext.Error'),
      type: 'error',
      message: message,
    });
    toastEvent.fire();
  },
  refreshChart: function(cmp, event, helper) {
    var appEvent = $A.get('e.chgn:chartRefreshEvent');
    appEvent.setParams({
      ID: cmp.get('v.canvasId'),
    });
    appEvent.fire();
  },
});
