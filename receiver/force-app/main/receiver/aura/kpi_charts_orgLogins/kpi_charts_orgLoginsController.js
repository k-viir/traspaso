/* eslint-disable no-unused-expressions */
({
  doInit: function(cmp, evt, helper) {
    let action = cmp.get('c.getOrgFreqChartData');
    action.setParams({ organizationRecordId: cmp.get('v.recordId') });

    action.setCallback(this, function(response) {
      let state = response.getState();
      if (state === 'SUCCESS') {
        cmp.set(
          'v.freqData',
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
    secondAction.setParams({ whatReport: 'loginActivity' });

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
  },
});
