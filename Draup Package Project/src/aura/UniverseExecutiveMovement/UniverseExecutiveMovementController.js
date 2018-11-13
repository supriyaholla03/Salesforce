({
    doInit : function(component, event, helper) {
        //document.getElementById("Exits").checked=true;
        // component.find("Exits").getElement().checked = true;
        helper.executiveMovementData(component, event, helper);
    },
    specificMovement : function(component, event, helper) {
        var movementType = event.getSource().get("v.text");
        component.set("v.type",movementType);
        helper.executiveMovementData(component, event, helper);
    }
})