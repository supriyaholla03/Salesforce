({
    universeGlobalization:function(component, type, helper){
        console.log('inside ITRadio Click');
        var action1 = component.get("c.globalizationData");
        action1.setParams({
            "accId": component.get("v.recordId"),
            "draupId": component.get("v.draupId"),
            "type" : component.get("v.type")
        });
        action1.setCallback(this, function(a1) {
            
            console.log('from acc data');
            if (a1.getState() === "SUCCESS") {
                component.set("v.isITRadioClick", true);
                component.set("v.radioData", a1.getReturnValue());
                console.log('DraupHeaders*******'+a1.getReturnValue());
                var custs = [];
                var conts = a1.getReturnValue();
                console.log('conts'+conts);
                for(var key in conts){
                    var Props = [];
                    for(var key1 in conts[key]){
                        
                        Props.push({value:conts[key][key1], key:key1});
                    }
                    custs.push({value:Props, key:key});
                }
                if(conts!=null)
                 component.set("v.radioData", custs);
                else
                  component.set("v.radioData", null);   
               console.log(component.get("v.radioData"));
                /*setTimeout($A.getCallback(
                    () => component.set("v.activeSectionName", '0')
                ),3000);*/
                console.log('..value..>'+custs);
            }else if (a1.getState() === "ERROR") {
                $A.log("Errors", a1.getError());
            }
            
        });
        $A.enqueueAction(action1);
    },
    
    showHideHelper: function(component, auraId, visibility){
        var element = component.find(auraId);
        if(visibility == "show"){
            if($A.util.hasClass(element, "slds-hide")){
                $A.util.removeClass(element, "slds-hide");
                $A.util.addClass(element, "slds-show");
            }else{
                $A.util.addClass(element, "slds-show");
            } 
        }
        if(visibility == "hide"){
            //console.log("inside hide");
            if($A.util.hasClass(element, "slds-show")){
                $A.util.removeClass(element, "slds-show");
                $A.util.addClass(element, "slds-hide");
            }else{
                $A.util.addClass(element, "slds-hide");
            } 
        }
    }
})