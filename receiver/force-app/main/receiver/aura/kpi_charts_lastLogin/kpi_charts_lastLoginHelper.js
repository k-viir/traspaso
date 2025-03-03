/* eslint-disable no-unused-expressions */
({
  setChartConfig: function(cmp, evt, helper) {
    let chartData = cmp.get('v.chartData');
    let barColors = [
      'rgba(0, 174, 50, 0.8)',
      'rgba(0, 255, 0, 0.34)',
      'rgba(255, 255, 0, 0.34)',
      'rgba(255, 202, 0, 0.59)',
      'rgba(244, 193, 0, 1)',
      'rgba(255, 103, 103, 1)',
      'rgba(255, 30, 30, 1)',
      'rgba(175, 0, 0, 1)',
    ];
    let xLabels = [
      $A.get('$Label.eext.Yesterday'),
      $A.get('$Label.eext.For_3days'),
      $A.get('$Label.eext.For_week'),
      $A.get('$Label.eext.For_2weeks'),
      $A.get('$Label.eext.For_month'),
      $A.get('$Label.eext.For_3months'),
      $A.get('$Label.eext.For_6months'),
      $A.get('$Label.eext.For_year'),
    ];
    const title = (tooltipItems) => {
      let tooltipText = '';
      tooltipItems.forEach(function(tooltipItem) {
        //might parametrize these values...
        switch (tooltipItem.dataIndex) {
          case 0:
            tooltipText =
              $A.get('$Label.eext.Havent_logged') +
              ' ' +
              $A.get('$Label.eext.Yesterday');
            break;
          case 1:
            tooltipText =
              $A.get('$Label.eext.Havent_logged') +
              ' ' +
              $A.get('$Label.eext.For_3days');
            break;
          case 2:
            tooltipText =
              $A.get('$Label.eext.Havent_logged') +
              ' ' +
              $A.get('$Label.eext.For_week');
            break;
          case 3:
            tooltipText =
              $A.get('$Label.eext.Havent_logged') +
              ' ' +
              $A.get('$Label.eext.For_2weeks');
            break;
          case 4:
            tooltipText =
              $A.get('$Label.eext.Havent_logged') +
              ' ' +
              $A.get('$Label.eext.For_month');
            break;
          case 5:
            tooltipText =
              $A.get('$Label.eext.Havent_logged') +
              ' ' +
              $A.get('$Label.eext.For_3months');
            break;
          case 6:
            tooltipText =
              $A.get('$Label.eext.Havent_logged') +
              ' ' +
              $A.get('$Label.eext.For_6months');
            break;
          case 7:
            tooltipText =
              $A.get('$Label.eext.Havent_logged') +
              ' ' +
              $A.get('$Label.eext.For_year');
            break;
        }
      });
      return tooltipText;
    };

    let chartConfiguration = {
      JSON_Setup: {
        config: {
          type: 'bar',
          options: {
            onClick: (event, activeItems, chart) => {
              let activePoints = chart.getElementsAtEventForMode(
                event,
                'x',
                chart.options
              );
              let firstPoint = activePoints[0];
              if (firstPoint) {
                helper.goToReport(
                  cmp,
                  evt,
                  helper,
                  firstPoint.index,
                  firstPoint.datasetIndex
                );
              }
            },
            responsive: true,
            interaction: {
              intersect: false,
              mode: 'index',
            },
            scales: {
              y: {
                beginAtZero: 'true',
                grid: {
                  display: false,
                },
              },
              x: {
                beginAtZero: 'true',
                grid: {
                  display: false,
                },
              },
            },
            plugins: {
              legend: {
                display: false,
              },
              title: {
                display: true,
                text: $A.get('$Label.eext.Havent_logged_title'),
              },
              tooltip: {
                callbacks: {
                  title: title,
                },
              },
            },
          },
        },
      },
      JSON_Data: {
        labels: xLabels,
        datasets: [
          {
            label: $A.get('$Label.eext.Total'),
            data: chartData.lastLoginCountValues,
            backgroundColor: barColors,
            borderWidth: 2,
            borderRadius: 2,
            borderSkipped: false,
            order: 1,
          },
        ],
      },
    };

    cmp.set('v.chartConfiguration', chartConfiguration);
  },
  goToReport: function(cmp, evt, helper, periodIndex) {
    let navService = cmp.find('navService');
    let filterValue = '';
    let referenceDate = new Date(cmp.get('v.referenceDate'));

    switch (periodIndex) {
      case 0:
        referenceDate.setDate(referenceDate.getDate());
        filterValue = referenceDate.toISOString().split('T')[0];
        break;
      case 1:
        referenceDate.setDate(referenceDate.getDate() - 2);
        filterValue = referenceDate.toISOString().split('T')[0];
        break;
      case 2:
        referenceDate.setDate(referenceDate.getDate() - 6);
        filterValue = referenceDate.toISOString().split('T')[0];
        break;
      case 3:
        referenceDate.setDate(referenceDate.getDate() - 13);
        filterValue = referenceDate.toISOString().split('T')[0];
        break;
      case 4:
        referenceDate.setDate(referenceDate.getDate() - 29);
        filterValue = referenceDate.toISOString().split('T')[0];
        break;
      case 5:
        referenceDate.setDate(referenceDate.getDate() - 89);
        filterValue = referenceDate.toISOString().split('T')[0];
        break;
      case 6:
        referenceDate.setDate(referenceDate.getDate() - 179);
        filterValue = referenceDate.toISOString().split('T')[0];
        break;
      default:
        referenceDate.setDate(referenceDate.getDate() - 364);
        filterValue = referenceDate.toISOString().split('T')[0];
    }

    let reportFilters;
    reportFilters = {
      fv0: cmp.get('v.recordId'),
      fv1: filterValue,
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
});
