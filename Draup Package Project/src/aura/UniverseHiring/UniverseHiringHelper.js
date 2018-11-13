({
	hiringData : function(component, event, helper) {
        console.log('starting.............');

        var action = component.get("c.hiringData");
        action.setParams({
            "accId": component.get("v.recordId"),
            "draupId" : component.get("v.draupId")
        });
        console.log('accid'+component.get("v.recordId"));
        action.setCallback(this, function(a) {
            if (a.getState() === "SUCCESS") {

                console.log('DraupUniverseWrapper-------'+a.getReturnValue());
                component.set("v.hiringList",a.getReturnValue());
            }else if (a.getState() === "ERROR") {
                $A.log("Errors", a.getError());
            }
        });
        $A.enqueueAction(action);
        
    }

})