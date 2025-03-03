/* eslint-disable no-unused-expressions */
({
  doInit: function(cmp, evt, helper) {
    let action = cmp.get('c.getSegmentationChartData');
    let randomNumber = Math.floor(Math.random() * 100000);
    cmp.set('v.canvasId', 'segmentationChart' + randomNumber);

    action.setParams({
      organizationRecordId: cmp.get('v.recordId'),
      filterValue: cmp.get('v.filterValue'),
    });

    action.setCallback(this, function(response) {
      let state = response.getState();
      if (state === 'SUCCESS') {
        cmp.set(
          'v.segmentationChartData',
          JSON.parse(JSON.stringify(response.getReturnValue()))
        );
        helper.setChartConfig(cmp, evt, helper);
        let buttons = cmp.find('filterButtons');
        buttons[0].set('v.disabled', true);
      } else if (state === 'ERROR') {
        let errors = response.getError();
        console.error(JSON.stringify(errors));
        helper.showErrorToast(
          cmp,
          evt,
          helper,
          $A.get('$Label.c.Error_message_data')
        );
      }
    });
    $A.enqueueAction(action);

    let secondAction = cmp.get('c.getReportId');
    secondAction.setParams({ whatReport: 'segmentation' }); // if we want go to functionality change this as well

    secondAction.setCallback(this, function(response) {
      let state = response.getState();
      if (state === 'SUCCESS') {
        cmp.set('v.reportId', response.getReturnValue());
      } else if (state === 'ERROR') {
        let errors = response.getError();
        console.error(JSON.stringify(errors));
        helper.showErrorToast(
          cmp,
          evt,
          helper,
          $A.get('$Label.c.Error_message_report')
        );
      }
    });
    $A.enqueueAction(secondAction);
  },

  handleFilters: function(cmp, evt, helper) {
    var buttonLabel = evt.getSource().get('v.label');
    let action = cmp.get('c.getSegmentationChartData');
    cmp.set('v.filterValue', buttonLabel);
    console.log('buttonLabel', buttonLabel);
    let buttons = cmp.find('filterButtons');
    buttons.forEach((elem) => {
      elem.set('v.disabled', false);
    });
    evt.getSource().set('v.disabled', true);
    action.setParams({
      organizationRecordId: cmp.get('v.recordId'),
      filterValue: cmp.get('v.filterValue'),
    });

    action.setCallback(this, function(response) {
      let state = response.getState();
      if (state === 'SUCCESS') {
        cmp.set(
          'v.segmentationChartData',
          JSON.parse(JSON.stringify(response.getReturnValue()))
        );
        if (
          Object.keys(cmp.get('v.segmentationChartData').segmentationValuesMap)
            .length !== 0
        ) {
          helper.setChartConfig(cmp, evt, helper);
          helper.refreshChart(cmp, evt, helper);
        } else {
          cmp.set('v.chartConfiguration', undefined);
        }
      } else if (state === 'ERROR') {
        let errors = response.getError();
        console.error(JSON.stringify(errors));
        helper.showErrorToast(
          cmp,
          evt,
          helper,
          $A.get('$Label.c.Error_message_data')
        );
      }
    });
    $A.enqueueAction(action);
  },
});