/* eslint-disable no-unused-expressions */
({
  setChartConfig: function(cmp, evt, helper) {
    let chartData = cmp.get('v.chartData');
    let barColors = [
      'rgba(0, 255, 0, 0.64)',
      'rgba(0, 255, 0, 0.34)',
      'rgba(255, 255, 0, 0.34)',
      'rgba(255, 202, 0, 0.59)',
      'rgba(244, 193, 0, 1)',
      'rgba(255, 103, 103, 1)',
      'rgba(255, 30, 30, 1)',
      'rgba(175, 0, 0, 1)',
    ];
    let xLabels = [
      '1 day',
      '3 days',
      '1 week',
      '2 weeks',
      '1 month',
      '3 months',
      '6 months',
      '1 year',
    ];
    const footer = (tooltipItems) => {
      let tooltipText = '';
      tooltipItems.forEach(function(tooltipItem) {
        //might parametrize these values...
        switch (tooltipItem.dataIndex) {
          case 0:
            tooltipText =
              chartData.lastLoginCountValues[tooltipItem.dataIndex] +
              ' Users havent logged in yesterday';
            break;
          case 1:
            tooltipText =
              chartData.lastLoginCountValues[tooltipItem.dataIndex] +
              ' Users havent logged in in the last 3 days';
            break;
          case 2:
            tooltipText =
              chartData.lastLoginCountValues[tooltipItem.dataIndex] +
              ' Users havent logged in in the last week';
            break;
          case 3:
            tooltipText =
              chartData.lastLoginCountValues[tooltipItem.dataIndex] +
              ' Users havent logged in in the last 2 weeks';
            break;
          case 4:
            tooltipText =
              chartData.lastLoginCountValues[tooltipItem.dataIndex] +
              ' Users havent logged in in the last month';
            break;
          case 5:
            tooltipText =
              chartData.lastLoginCountValues[tooltipItem.dataIndex] +
              ' Users havent logged in in the last 3 months';
            break;
          case 6:
            tooltipText =
              chartData.lastLoginCountValues[tooltipItem.dataIndex] +
              ' Users havent logged in in the last 6 months';
            break;
          case 7:
            tooltipText =
              chartData.lastLoginCountValues[tooltipItem.dataIndex] +
              ' Users havent logged in in the last year or never logged in';
            break;
        }
      });
      return tooltipText;
    };

    let chartConfiguration = {
      JSON_Setup: {
        enableButton: true,
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
              },
            },
            plugins: {
              legend: {
                display: false,
              },
              title: {
                display: true,
                text: 'Users last login report',
              },
              tooltip: {
                callbacks: {
                  footer: footer,
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
});
