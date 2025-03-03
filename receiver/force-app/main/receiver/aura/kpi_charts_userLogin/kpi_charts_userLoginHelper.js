/* eslint-disable no-unused-expressions */
({
  setChartConfig: function(cmp, evt, helper) {
    let freqData = cmp.get('v.freqData');
    let barColors = [ 'rgba(39, 178, 245, 0.5)' ];
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
            tooltipText =
              $A.get('$Label.eext.Logins') +
              ' ' +
              $A.get('$Label.eext.Yesterday');
            break;
          case 1:
            tooltipText =
              $A.get('$Label.eext.Logins') +
              ' ' +
              $A.get('$Label.eext.In_3days');
            break;
          case 2:
            tooltipText =
              $A.get('$Label.eext.Logins') +
              ' ' +
              $A.get('$Label.eext.In_week');
            break;
          case 3:
            tooltipText =
              $A.get('$Label.eext.Logins') +
              ' ' +
              $A.get('$Label.eext.In_2weeks');
            break;
          case 4:
            tooltipText =
              $A.get('$Label.eext.Logins') +
              ' ' +
              $A.get('$Label.eext.In_month');
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
                text: $A.get('$Label.eext.Userfreq_chart_title'),
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
            label: 'Total',
            data: freqData.loginFreqValues,
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
