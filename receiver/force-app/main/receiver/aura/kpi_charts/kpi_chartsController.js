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
      } else {
        //TODO KAV
        //show error toast
      }
    });
    $A.enqueueAction(action);
  },
});
