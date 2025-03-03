/* eslint-disable no-unused-expressions */
({
  setChartConfig: function(cmp, evt, helper) {
    let chartData = cmp.get('v.chartData');
    let pointStyles = [];
    let pointColors = [];
    chartData.installedVersions.forEach((elem, index) => {
      if (elem === chartData.latestVersions[index]) {
        pointStyles.push('circle');
        pointColors.push('rgba(15, 13, 186, 0.69)');
      } else {
        pointStyles.push('circle');
        pointColors.push('rgba(255, 0, 0, 0.90)');
      }
    });

    const footer = (tooltipItems) => {
      let tooltipText;
      tooltipItems.forEach(function(tooltipItem) {
        if (chartData.differences[tooltipItem.dataIndex]) {
          tooltipText = 'Differences \n';
          let eachLineList =
            chartData.differences[tooltipItem.dataIndex].split(/\r\n|\r|\n/);
          for (let i = 0; i < 10; i++) {
            if (eachLineList[i]) {
              tooltipText += eachLineList[i] + '\n';
            }
          }
          if (eachLineList[10]) {
            tooltipText += $A.get('$Label.eext.Full_text');
          }
        } else {
          tooltipText = $A.get('$Label.eext.Up2date');
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
                text: $A.get('$Label.eext.Packages_chart_title'),
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
        labels: chartData.packageNames,
        datasets: [
          {
            label: 'Version pais',
            data: chartData.installedVersions,
            borderColor: 'rgba(39, 178, 245, 0.5)',
            backgroundColor: 'rgba(39, 178, 245, 0.5)',
            borderWidth: 2,
            borderRadius: 2,
            borderSkipped: false,
            order: 2,
          },
          {
            label: 'Ultima version',
            data: chartData.latestVersions,
            borderColor: 'rgba(15, 13, 186, 0.69)',
            backgroundColor: pointColors,
            pointStyle: pointStyles,
            borderWidth: 5,
            borderRadius: 5,
            pointRadius: 5,
            borderSkipped: false,
            type: 'line',
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
