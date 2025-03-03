({
    doInit: function (cmp, evt, helper) {
        let action = cmp.get("c.getOrgNaming");
        action.setParams({ recordId: cmp.get("v.recordId") });
        action.setCallback(this, function(response) {
            let state = response.getState();
            if (state === "SUCCESS") {
                let result = response.getReturnValue();
                cmp.set("v.extractVisitsKpi", result);
                if(result === true) {
                    helper.getValues(cmp, evt, helper);
                }
            } else {
                console.error("Failed with state: " + state);
            }
        });
        $A.enqueueAction(action);
    }
})