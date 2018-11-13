({
	executiveMovementData : function(component, event, helper) {
        console.log('starting.............');
        var action = component.get("c.executiveMovementData");
        action.setParams({
            "accId": component.get("v.recordId"),
            "draupId": component.get("v.draupId"),
            "type" : component.get("v.type")
        });
        console.log('accid'+component.get("v.recordId"));
        action.setCallback(this, function(a) {
            if (a.getState() === "SUCCESS") {
                console.log('DraupUniverseWrapper-------'+a.getReturnValue());
                var responseVal = a.getReturnValue();
              /*  if(responseVal == null){
                    component.set("v.errorMsg",'No Data found!!');
                    component.set("v.exeMovementList",null);
                }else{*/
                component.set("v.exeMovementList",a.getReturnValue());
            //}
            }else if (a.getState() === "ERROR") {
                $A.log("Errors", a.getError());
            }
        });
        $A.enqueueAction(action);
        
    }

})