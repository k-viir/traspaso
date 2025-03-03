/* eslint-disable no-unused-expressions */
({
  setChartConfig: function(cmp, evt, helper) {
    let freqData = cmp.get('v.freqData');
    let tooltipLabels = [
      $A.get('$Label.eext.Total_logins') +
        ' ' +
        $A.get('$Label.eext.Yesterday'),
      $A.get('$Label.eext.Total_logins') + ' ' + $A.get('$Label.eext.In_3days'),
      $A.get('$Label.eext.Total_logins') + ' ' + $A.get('$Label.eext.In_week'),
      $A.get('$Label.eext.Total_logins') +
        ' ' +
        $A.get('$Label.eext.In_2weeks'),
      $A.get('$Label.eext.Total_logins') + ' ' + $A.get('$Label.eext.In_month'),
    ];
    let afterBodyLabels = [
      '\n' +
        $A.get('$Label.eext.Low_when') +
        ' 1 ' +
        $A.get('$Label.eext.Login') +
        '\n' +
        $A.get('$Label.eext.Medium_when') +
        ' 2 ' +
        $A.get('$Label.eext.Or') +
        ' 3 ' +
        $A.get('$Label.eext.Logins') +
        '\n' +
        $A.get('$Label.eext.High_when') +
        ' 3 ' +
        $A.get('$Label.eext.Logins'),
      '\n' +
        $A.get('$Label.eext.Low_when') +
        ' 1 ' +
        $A.get('$Label.eext.Or') +
        ' 2 ' +
        $A.get('$Label.eext.Logins') +
        '\n' +
        $A.get('$Label.eext.Medium_when') +
        ' 3 ' +
        $A.get('$Label.eext.To') +
        ' 5 ' +
        $A.get('$Label.eext.Logins') +
        '\n' +
        $A.get('$Label.eext.High_when') +
        ' 5 ' +
        $A.get('$Label.eext.Logins'),
      '\n' +
        $A.get('$Label.eext.Low_when') +
        ' 1 ' +
        $A.get('$Label.eext.To') +
        ' 4 ' +
        $A.get('$Label.eext.Logins') +
        '\n' +
        $A.get('$Label.eext.Medium_when') +
        ' 5 ' +
        $A.get('$Label.eext.To') +
        ' 10 ' +
        $A.get('$Label.eext.Logins') +
        '\n' +
        $A.get('$Label.eext.High_when') +
        ' 10 ' +
        $A.get('$Label.eext.Logins'),
      '\n' +
        $A.get('$Label.eext.Low_when') +
        ' 1 ' +
        $A.get('$Label.eext.To') +
        ' 6 ' +
        $A.get('$Label.eext.Logins') +
        '\n' +
        $A.get('$Label.eext.Medium_when') +
        ' 7 ' +
        $A.get('$Label.eext.To') +
        ' 16 ' +
        $A.get('$Label.eext.Logins') +
        '\n' +
        $A.get('$Label.eext.High_when') +
        ' 16 ' +
        $A.get('$Label.eext.Logins'),
      '\n' +
        $A.get('$Label.eext.Low_when') +
        ' 1 ' +
        $A.get('$Label.eext.To') +
        ' 9 ' +
        $A.get('$Label.eext.Logins') +
        '\n' +
        $A.get('$Label.eext.Medium_when') +
        ' 10 ' +
        $A.get('$Label.eext.To') +
        ' 22 ' +
        $A.get('$Label.eext.Logins') +
        '\n' +
        $A.get('$Label.eext.High_when') +
        ' 22 ' +
        $A.get('$Label.eext.Logins'),
    ];
    let xLabels = [
      $A.get('$Label.eext.Yesterday'),
      $A.get('$Label.eext.In_3days'),
      $A.get('$Label.eext.In_week'),
      $A.get('$Label.eext.In_2weeks'),
      $A.get('$Label.eext.In_month'),
    ];
    const title = (tooltipItems) => {
      let tooltipText = '';
      tooltipItems.forEach(function(tooltipItem) {
        switch (tooltipItem.dataIndex) {
          case 0:
            tooltipText = tooltipLabels[0];
            break;
          case 1:
            tooltipText = tooltipLabels[1];
            break;
          case 2:
            tooltipText = tooltipLabels[2];
            break;
          case 3:
            tooltipText = tooltipLabels[3];
            break;
          case 4:
            tooltipText = tooltipLabels[4];
            break;
        }
      });
      return tooltipText;
    };
    const afterBody = (tooltipItems) => {
      let tooltipText = '';
      tooltipItems.forEach(function(tooltipItem) {
        switch (tooltipItem.dataIndex) {
          case 0:
            tooltipText = afterBodyLabels[0];
            break;
          case 1:
            tooltipText = afterBodyLabels[1];
            break;
          case 2:
            tooltipText = afterBodyLabels[2];
            break;
          case 3:
            tooltipText = afterBodyLabels[3];
            break;
          case 4:
            tooltipText = afterBodyLabels[4];
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
                text: $A.get('$Label.eext.Chart_title'),
              },
              tooltip: {
                callbacks: {
                  title: title,
                  afterBody: afterBody,
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
            label: 'No activity',
            data: freqData.nullFreqValues,
            backgroundColor: 'rgba(175, 0, 0, 1)',
            borderWidth: 2,
            borderRadius: 2,
            borderSkipped: false,
            order: 4,
          },
          {
            label: 'Low activity',
            data: freqData.lowFreqValues,
            backgroundColor: 'rgba(202, 59, 0, 0.8)',
            borderWidth: 2,
            borderRadius: 2,
            borderSkipped: false,
            order: 3,
          },
          {
            label: 'Medium activity',
            data: freqData.mediumFreqValues,
            backgroundColor: 'rgba(255, 202, 0, 0.59)',
            borderWidth: 2,
            borderRadius: 2,
            borderSkipped: false,
            order: 2,
          },
          {
            label: 'High activity',
            data: freqData.highFreqValues,
            backgroundColor: 'rgba(0, 174, 50, 0.8)',
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
  goToReport: function(cmp, evt, helper, periodIndex, loginActivityIndex) {
    let navService = cmp.find('navService');
    let filter = '';
    let filterValue = '';

    switch (periodIndex) {
      case 0:
        filter = 'fv1';
        break;
      case 1:
        filter = 'fv2';
        break;
      case 2:
        filter = 'fv3';
        break;
      case 3:
        filter = 'fv4';
        break;
      default:
        filter = 'fv5';
    }

    switch (loginActivityIndex) {
      case 0:
        filterValue = 'No activity';
        break;
      case 1:
        filterValue = 'Low activity';
        break;
      case 2:
        filterValue = 'Medium activity';
        break;
      default:
        filterValue = 'High activity';
    }

    // index is the period (yesterday, 3 days,  1 week...), datasetIndex is the loginActivity (none, low, medium...)
    let reportFilters;
    reportFilters = {
      fv0: cmp.get('v.recordId'),
      [filter]: filterValue,
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
      message: message,
      type: 'error',
    });
    toastEvent.fire();
  },
});
