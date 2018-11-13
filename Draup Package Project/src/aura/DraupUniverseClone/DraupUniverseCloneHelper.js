({
	 draupAuthenticationHelper : function(component, event, helper) {
        var action = component.get("c.queryParametersForAuthentication");
        var queryParameters;
         action.setCallback(this, function(response) {
             var state = response.getState();
             console.log('****State'+state);
             console.log('--------'+response.getReturnValue());
             if (state === "SUCCESS") {
                 console.log('inside draup athuntication helper');
                 queryParameters = response.getReturnValue();
                 console.log('queryParameters***'+queryParameters);
                 //window.open("https://accounts.google.com/signin/v2/identifier?flowName=GlifWebSignIn&flowEntry=ServiceLogin&ClientId="+tempVars,"_self");
                 var loginWindow = window.open(" https://qa-platform.draup.com/draup/authorize?client_id="+queryParameters,"_blank",'height=600,width=500,location=yes,left=500,top=100,resizable=yes,toolbar=no,status=no,menubar=no,scrollbars=1', 1)       
                 var timer = setInterval(function() {   
                     if(loginWindow.closed) {  
                         clearInterval(timer);  
                         window.location.reload(); 
                     }  
                 }, 1);   
             }    
         });
         
         $A.enqueueAction(action);
         
     },
    getRoledexSuggestions : function(component, event, helper) {
        console.log('starting.............');
        console.log('auth'+component.get('v.isLoginAuth'));
        var action = component.get("c.MatchDraup");
        action.setParams({
            "recordId": component.get("v.recordId")
        });
        console.log('accid'+component.get("v.recordId"));
        action.setCallback(this, function(a) {
            if (a.getState() === "SUCCESS") {
                component.set("v.DraupUniverseWrapper", a.getReturnValue());
                console.log('DraupUniverseWrapper-------'+a.getReturnValue());
            }else if (a.getState() === "ERROR") {
                $A.log("Errors", a.getError());
            }
        });
        $A.enqueueAction(action);
        
    },
    onExecutiveChangeHelper : function(component, event, helper) {
        //Gets the checkbox group based on the checkbox id
        var availableRadioButtons = component.find('rowSelectionRadioId');
        var resetRadioValue  = false;
        if (Array.isArray(availableRadioButtons)) {
            //If more than one checkbox available then individually resets each checkbox
            availableRadioButtons.forEach(function(Radio) {
                Radio.set('v.value', resetRadioValue);
                console.log('resetRadioValue-------'+resetRadioValue);
            }); 
        } else {
            //if only one checkbox available then it will be unchecked
            availableRadioButtons.set('v.value', resetRadioValue);
        }
        //mark the current checkbox selection as checked
        event.getSource().set("v.value",true);
        var selectedExecutive = event.getSource().get("v.text");
        component.set('v.accId',selectedExecutive);
        console.log('inside radiochange helper value.............'+selectedExecutive);
        /*var action = component.get("c.insertDraupData");
        action.setParams({
            "executive_id": event.getSource().get("v.text")
        });*/
    },
    currentUserInfo : function(component, event, helper) {
        console.log('inside current user info');  
        var action = component.get("c.fetchUser");
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var storeResponse = response.getReturnValue();
                component.set("v.userInfo", storeResponse);
            }
            console.log('Draup Tokennnnnnnnnnnn'+storeResponse.Draup_Token__c);
            var userToken = component.get("v.userInfo").Draup_Token__c;
            console.log('userToken'+userToken);
            var expiryDate = component.get("v.userInfo").ExpiryDate__c;
			 if((userToken == null) || (userToken != null && expiryDate == new Date().toISOString().slice(0,10) ))
            {
                component.set("v.isLoginDisable", true);
            }
                else {
                    component.set("v.isLoginDisable", false);
                }
        });
        $A.enqueueAction(action);
    },
     displayRelatedExecutiveHelper:function(component, event, helper) {
        console.log('inside Account.............');
        //this.showSpinner(component, true);
        if( component.get('v.accId')==null)
        {
            alert('Please select Company Name');
            return;
        }
        var action1 = component.get("c.insertDraupData");
         action1.setParams({
            "accId":  component.get('v.accId')
        });
          action1.setCallback(this, function(a1) {
            console.log('from acc data');
            if (a1.getState() === "SUCCESS") {
                
              component.set("v.isLinkButtonClick", true);
                //component.set("v.Spinner", true);
               component.set("v.isDataDisplay",false);
                console.log('inside state');
               component.set("v.DraupHeaders", a1.getReturnValue());
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
                component.set("v.DraupHeaders", custs);
                console.log('..value..>'+custs);
 
            }else if (a1.getState() === "ERROR") {
                $A.log("Errors", a1.getError());
            }

        });
        $A.enqueueAction(action1);
 },
    
    lazyLoadTabs: function (cmp, event) {
        var tab = event.getSource();
        switch (tab.get('v.id')) {
            case 'accounts' :
                this.injectComponent('draupApp:myAccountComponent', tab);
                break;
            case 'cases' :
                this.injectComponent('draupApp:myCaseComponent', tab);
                break;
        }
    },
    injectComponent: function (name, target) {
        $A.createComponent(name, {
        }, function (contentComponent, status, error) {
            if (status === "SUCCESS") {
                target.set('v.body', contentComponent);
            } else {
                throw new Error(error);
            }
        });
    },
    
    unlinkUniverseDataHelper:function(component,event,Helper)
    {
        alert('Inside Helper !!');
    	var actionToDelete =  component.get("c.removeUniverseData");
        console.log('Inside unlink fucntion ');
        actionToDelete.setParams({
             "recordId":  component.get('v.recordId'),
            "accId":  component.get('v.accId')
        });
        alert('accId ' + component.get('v.accId'));
        alert('recordId ' + component.get('v.recordId'));
        actionToDelete.setCallback(this, function(response) {
             console.log('Inside callback ');
            var state = response.getState();
            if (state === "SUCCESS") {
                var bResponse = response.getReturnValue();
                alert(' bResponse ' + bResponse);
            }
      	});
         $A.enqueueAction(actionToDelete);
	}
})