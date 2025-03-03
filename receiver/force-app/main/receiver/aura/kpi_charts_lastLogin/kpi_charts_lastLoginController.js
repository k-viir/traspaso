/* eslint-disable no-unused-expressions */
({
  doInit: function(cmp, evt, helper) {
    let action = cmp.get('c.getChartData');
    action.setParams({ organizationRecordId: cmp.get('v.recordId') });

    action.setCallback(this, function(response) {
      let state = response.getState();
      if (state === 'SUCCESS') {
        cmp.set(
          'v.chartData',
          JSON.parse(JSON.stringify(response.getReturnValue()))
        );
        helper.setChartConfig(cmp, evt, helper);
      } else if (state === 'ERROR') {
        let errors = response.getError();
        console.error(JSON.stringify(errors));
        helper.showErrorToast(
          cmp,
          evt,
          helper,
          $A.get('$Label.eext.Error_message_data')
        );
      }
    });
    $A.enqueueAction(action);

    let secondAction = cmp.get('c.getReportId');
    secondAction.setParams({ whatReport: 'lastLogin' });

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
          $A.get('$Label.eext.Error_message_report')
        );
      }
    });
    $A.enqueueAction(secondAction);

    let thirdAction = cmp.get('c.getReferenceDate');
    thirdAction.setParams({ organizationRecordId: cmp.get('v.recordId') });

    thirdAction.setCallback(this, function(response) {
      let state = response.getState();
      if (state === 'SUCCESS') {
        cmp.set(
          'v.referenceDate',
          JSON.parse(JSON.stringify(response.getReturnValue()))
        );
      } else if (state === 'ERROR') {
        let errors = response.getError();
        console.error(JSON.stringify(errors));
        helper.showErrorToast(
          cmp,
          evt,
          helper,
          $A.get('$Label.eext.Error_message_date')
        );
      }
    });
    $A.enqueueAction(thirdAction);
  },
});
