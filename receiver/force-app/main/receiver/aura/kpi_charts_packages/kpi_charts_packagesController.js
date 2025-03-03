/* eslint-disable no-unused-expressions */
({
  doInit: function(cmp, evt, helper) {
    console.log('inside doInit');
    let action = cmp.get('c.getChartData');
    action.setParams({ targetOrgRecordId: cmp.get('v.recordId') });

    action.setCallback(this, function(response) {
      console.log('inside callback function');
      let state = response.getState();
      if (state === 'SUCCESS') {
        console.log('inside success response');
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
  },
});
