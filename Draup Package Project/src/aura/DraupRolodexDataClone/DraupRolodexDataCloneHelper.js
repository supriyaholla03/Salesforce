({
    getRoledexSuggestions : function(component, event, helper) {
        console.log('starting.............');
        console.log('auth'+component.get('v.isLoginAuth'));
        var action = component.get("c.MatchDraup");
        action.setParams({
            "recordId": component.get("v.recordId")
        });
        console.log('LeadID'+component.get("v.recordId"));
        action.setCallback(this, function(a) {
            if (a.getState() === "SUCCESS") {
                component.set("v.DraupExecutiveWrapper", a.getReturnValue());
                console.log('DraupExecutiveWrapper-------'+a.getReturnValue());
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
        component.set('v.executiveId',selectedExecutive);
        console.log('inside radiochange helper value.............'+selectedExecutive);
        /*var action = component.get("c.insertDraupData");
        action.setParams({
            "executive_id": event.getSource().get("v.text")
        });*/
    },
    displayRelatedExecutiveHelper:function(component, event, helper) {
        console.log('inside LeadData.............');
       // this.showSpinner(component, true);
        if( component.get('v.executiveId')==null)
        {
            alert('Please select Executive');
            return;
        }
        var action = component.get("c.insertRolodexData");
        //var exeId= document.querySelector('input[name="rate"]:checked').value;

         action.setParams({
             "recordId":  component.get('v.recordId'),
            "executiveId":  component.get('v.executiveId')
        });
        var action1 = component.get("c.insertDraupData");
        //var exeId= document.querySelector('input[name="rate"]:checked').value;

         action1.setParams({
            "executive_id":  component.get('v.executiveId')
        });
        action.setCallback(this, function(a) {
            console.log('from lead data insertion');
            if (a.getState() === "SUCCESS") {
                
                
                action1.setCallback(this, function(a1) {
            console.log('from lead data');
            if (a1.getState() === "SUCCESS") {
                
              component.set("v.isLinkButtonClick", true);
                //component.set("v.Spinner", true);
               component.set("v.isDataDisplay",false);
                console.log('inside state');
               component.set("v.DraupHeaders", a1.getReturnValue());
               console.log('DraupHeaders*******'+a1.getReturnValue());
                var custs = [];
                var conts = a1.getReturnValue();
                for(var key in conts){
                     var Props = [];
                    if(key=='Overview')
                    {
                        for(var key1 in conts[key][0]){
                            /*var index = key1.indexOf(":");
                             console.log('index**'+index);
                            var header = key1.substring(0,index);
                             console.log('header**'+header);*/
                             Props.push({value:conts[key][0][key1], key:key1});   
                    	}
                    }
                    if(key=='Draup Psychological Analysis')
                    {
                        for(var key1 in conts[key][0]){
                            /*var index = key1.indexOf(":");
                             console.log('index**'+index);
                            var header = key1.substring(0,index);
                             console.log('header**'+header);*/
                             Props.push({value:conts[key][0][key1], key:key1});   
                    	}
                    }
                    if(key=='Experience')
                    {
                       
                            Props.push({value:conts[key], key:key}); 
                        
                    }
                   /* for(var key1 in conts[key]){
                        /*var index = key1.indexOf(":");
                         console.log('index**'+index);
                        var header = key1.substring(0,index);
                         console.log('header**'+header);
						 Props.push({value:conts[key][key1], key:key1});                          
                        //console.log('$$$$$$$$$$$$'+keyindex);
                        console.log('value**');
                        console.log(conts[key][key1]);
                    }*/
                    custs.push({value:Props, key:key});
                    
                }
                component.set("v.DraupHeaders", custs);
                console.log('..value..>');
                console.log(custs);
               console.log('Custsssssssss');
                
               
            }else if (a1.getState() === "ERROR") {
                $A.log("Errors", a1.getError());
            }
                    
           // this.showSpinner(component, false);

        });
        $A.enqueueAction(action1);
            }
        });
        $A.enqueueAction(action);
    },
    draupAuthenticationHelper : function(component, event, helper) {
        
        var action = component.get("c.queryParametersForAuthentication");
        var queryParameters;
         action.setCallback(this, function(response) {
             var state = response.getState();
             
             console.log('****'+state);
             console.log('--------'+response.getReturnValue());
             if (state === "SUCCESS") {
                 console.log('dysagdui');
                 queryParameters = response.getReturnValue();
                 
                 console.log('TRFGDRGTE'+queryParameters);
                 
                 console.log('uguehdfhesirfhw');
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
                this.getRoledexSuggestions(component,event,helper);
            }
                else {
                    component.set("v.isLoginDisable", false);
                }
        });
        $A.enqueueAction(action);
    },

    showSpinner: function(component, isVisible) {
        var spinner = component.find("childSpinner");
        spinner.showSpinner(isVisible);
    },
    
    unlinkRolodexDataHelper:function(component, event, helper){
        alert("hello there in Helper !");
       
        var actionToDelete =  component.get("c.removeRolodexData");
        console.log('Inside unlink fucntion ');
        actionToDelete.setParams({
             "recordId":  component.get('v.recordId'),
            "executiveId":  component.get('v.executiveId')
        });
        actionToDelete.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var bResponse = response.getReturnValue();
                if(bResponse)
                {
                    alert('Refreshing Page : ');
                    component.set("v.isDataDisplay",true);
                    this.currentUserInfo(component,event, helper);
                }
                else
                {
                    alert("This record is may be deleted already ");
                }
            }
      	});
         
        $A.enqueueAction(actionToDelete);
    }    
})