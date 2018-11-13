({
	doInit : function(component, event, helper) {
    	console.log('starting.............');
        var action = component.get("c.returnDraupData");
        action.setParams({
           "leadID": component.get("v.recordId")
        });
        console.log('leadID'+component.get("v.recordId"));
        action.setCallback(this, function(a) {
             if (a.getState() === "SUCCESS") {
            component.set("v.DraupHeaders", a.getReturnValue());
                 console.log('DraupHeaders*******'+a.getReturnValue());
             }else if (a.getState() === "ERROR") {
                $A.log("Errors", a.getError());
            }
        });
        $A.enqueueAction(action);
    }
})