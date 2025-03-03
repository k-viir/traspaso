/* eslint-disable no-unused-expressions */
({
  doInit: function(component, event, helper) {
    helper.fetchRecords(component, component.get('v.searchTerm'));
  },
  handleSearchChange: function(component, event, helper) {
    var searchTerm = component.get('v.searchTerm');
    helper.fetchRecords(component, searchTerm);
  },
  navigateToRecord: function(component, event, helper) {
    var recordId = event.currentTarget.dataset.id;
    var navEvt = $A.get('e.force:navigateToSObject');
    navEvt.setParams({
      recordId: recordId,
      slideDevName: 'detail',
    });
    navEvt.fire();
  },
  navigateToFirstRecord: function(component, event, helper) {
    var firstRecordId = component.get('v.firstRecordId');
    if (firstRecordId) {
      var navEvt = $A.get('e.force:navigateToSObject');
      navEvt.setParams({
        recordId: firstRecordId,
        slideDevName: 'detail',
      });
      navEvt.fire();
    } else {
      console.warn('No initial record available.');
    }
  },
});
