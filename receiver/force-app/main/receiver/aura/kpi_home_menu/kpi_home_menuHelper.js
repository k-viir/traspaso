/* eslint-disable no-unused-expressions */
({
  fetchRecords: function(component, searchTerm) {
    var lpPicklist = component.get('v.lpPicklist');
    var action = component.get('c.getRecords');
    action.setParams({ searchTerm: searchTerm, orgName: lpPicklist });

    action.setCallback(this, function(response) {
      var state = response.getState();
      if (state === 'SUCCESS') {
        var records = response.getReturnValue();
        component.set('v.records', records);
        if (records.length > 0) {
          if (!component.get('v.firstRecordId')) {
            component.set('v.firstRecordId', records[0].Id);
          }
        }
      } else {
        console.error('Error fetching records: ' + response.getError());
      }
    });

    $A.enqueueAction(action);
  },
});
