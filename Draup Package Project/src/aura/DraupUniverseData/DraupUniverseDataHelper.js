({
	 draupAuthenticationHelper : function(component, event, helper) {
        var action = component.get("c.queryParametersForAuthentication");
         /*var left = (screen.width/2)-(w/2);
			var top = (screen.height/2)-(h/2);*/
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
                 var loginWindow = window.open(" https://qa-platform.draup.com/draup/authorize?client_id="+queryParameters,"_blank",'height=600,width=600,location=yes,left=400,top=100,location=center,Window Position=center,toolbar=no,status=no,menubar=no,scrollbars=1', 1)       
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
         this.showSpinner(component, true);
        var action = component.get("c.matchDraup");
        action.setParams({
            "recordId": component.get("v.recordId")
        });
        console.log('accid'+component.get("v.recordId"));
        action.setCallback(this, function(a) {
            if (a.getState() === "SUCCESS") {
                var accounts = a.getReturnValue();
                var isSuperUser = component.get('v.isSuperUser');
                component.set("v.DraupUniverseWrapper", accounts);
               if(!isSuperUser){
                    component.set("v.noDataFlag","slds-show");
                    component.set("v.errorMsg","Draup data not linked to this Account");
                   }
                else if(accounts == null || accounts == ''){
                    component.set("v.noDataFlag","slds-show");
                    component.set("v.errorMsg","No matching Account found in Draup");
                  //  this.showSpinner(component, false);
                }
              
            }else if (a.getState() === "ERROR") {
                $A.log("Errors", a.getError());
            }
              this.showSpinner(component, false);
        });
        $A.enqueueAction(action);
        
    },
    checkUniverseAccount : function(component, event, helper) {
        console.log('gdhfgdhf');
        this.showSpinner(component, true);
        var action = component.get("c.getAccount");
        action.setParams({
            "recordId": component.get("v.recordId")
        });
        console.log('accid'+component.get("v.recordId"));
        action.setCallback(this, function(response) {
            if (response.getState() === "SUCCESS") {
                
                var storeResponse = response.getReturnValue();
                component.set("v.universeAccount", storeResponse);
                 var draupId = component.get("v.universeAccount").draupApp__Draup_Id__c;
                component.set('v.draupId',draupId);
                component.set("v.isLoginDisable", false);
                   var draupId = component.get("v.draupId");
                     console.log('draupId**-------'+draupId);
                    if(draupId == null){
                        console.log('from if');
                         component.set("v.isLinkButtonHide",true);
                        this.getRoledexSuggestions(component,event,helper);
                        
                    }else{
                        console.log('from else');
                       // component.set("v.isLinkButtonHide",false);
                       // component.set("v.isLinkButtonClick",true);
                        component.set("v.accId",draupId);
                        this.showLastModDate(component,event,helper);
                        this.displayRelatedUniverseHelper(component, event, helper);
                    }
                
            }
            else if (response.getState() === "ERROR") {
                $A.log("Errors", response.getError());
            }
             //this.showSpinner(component, false);
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
        var selectedExecutiveName = event.getSource().get("v.name");
        component.set('v.accId',selectedExecutive);
        component.set('v.draupAccountName',selectedExecutiveName);
        console.log('inside radiochange helper value.............'+selectedExecutive);
        console.log(' selectedExecutiveName '+ selectedExecutiveName);
        /*var action = component.get("c.insertDraupData");
        action.setParams({
            "executive_id": event.getSource().get("v.text")
        });*/
    },
    currentUserInfo : function(component, event, helper) {
        console.log('inside current user info'); 
        //this.showSpinner(component, true);
        var action = component.get("c.fetchUser");
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var storeResponse = response.getReturnValue();
                component.set("v.userInfo", storeResponse);
             console.log('Draup Tokennnnnnnnnnnn'+storeResponse.draupApp__Draup_Token__c);
            var userProfile = component.get("v.userInfo").Profile.Name;
            console.log('userProfile ' + userProfile );
            var isSuperUser = component.get("v.userInfo").draupApp__isSuperUser__c;
            console.log('isSuperUser ' + userProfile );
            component.set("v.isSuperUser" , isSuperUser);
           
          
            var userToken = component.get("v.userInfo").draupApp__Draup_Token__c;
            console.log('userToken'+userToken);
            var expiryDate = component.get("v.userInfo").draupApp__ExpiryDate__c;
			 if((userToken == null) || (userToken != null && expiryDate == new Date().toISOString().slice(0,10) ))
            {
                component.set("v.isLoginDisable", true);
            }
            else {
                    this.checkUniverseAccount(component, event, helper);
                }
            }else if (response.getState() === "ERROR") {
                $A.log("Errors", response.getError());
            }
           // this.showSpinner(component, false);
        });
        $A.enqueueAction(action);
    },
     displayRelatedUniverseHelper:function(component, event, helper) {
        console.log('inside Account.............');
        console.log('checkSync**'+component.get("v.checkSync"));
        if( component.get('v.accId')==null)
        {
            alert('Please select Company Name');
            return;
        }
        this.showSpinner(component, true);
      
		console.log('drapAcc**'+component.get('v.draupAccountName'));
        var action1 = component.get("c.displayDraupData");
         action1.setParams({
            "recordId":  component.get('v.recordId'),
            "accId":  component.get('v.accId'),
             "checkSync" : component.get('v.checkSync'),
             "draupAccName" : component.get('v.draupAccountName')
        });
         
          action1.setCallback(this, function(a1) {
            console.log('from acc data');
            if (a1.getState() === "SUCCESS") {
                
              component.set("v.isLinkButtonClick", true);
                //component.set("v.Spinner", true);
               component.set("v.isDataDisplay",false);
                component.set("v.isLinkButtonHide",false);
                console.log('inside state');
              // component.set("v.DraupHeaders", a1.getReturnValue());
                var custs = [];
                var conts = a1.getReturnValue();
                for(var key in conts){  
                   // console.log('inside loop');
                     var Props = [];
                     if(key=='Strategic Signals')
                    {
                       		
                            Props.push({value:conts[key], key:key}); 
                        
                    }
                     if(key=='Digital Tech Stack')
                    {
                            Props.push({value:conts[key], key:key}); 
                        
                    }
                    else{
                       for(var key1 in conts[key][0]){
                             Props.push({value:conts[key][0][key1], key:key1});
                        }
                    }
                    custs.push({value:Props, key:key});
                    
                }
                component.set("v.draupId",component.get('v.accId'));
                component.set("v.DraupHeaders", custs);
                this.showLastModDate(component,event,helper);
 
            }else if (a1.getState() === "ERROR") {
                $A.log("Errors", a1.getError());
            }
			this.showSpinner(component, false);
        });
        $A.enqueueAction(action1);
             
 },
    
    unlinkUniverseDataHelper:function(component,event,helper)
    {
        this.showSpinner(component, true);
    	var actionToDelete =  component.get("c.removeUniverseData");
        var msg = 'gg';
        var toastEvent = $A.get("e.force:showToast");
                                toastEvent.setParams({
                                    duration:5000,
                                    "title": "Success",
                                    "type": 'success',
                                    "message": 'Account Unlinked with Draup'
                                });
        console.log('Inside unlink fucntion ');
        actionToDelete.setParams({
             "recordId":  component.get('v.recordId'),
            "accId":  component.get('v.accId')
        });
        actionToDelete.setCallback(this, function(response) {
             console.log('Inside callback ');
            var state = response.getState();
            if (state === "SUCCESS") {
                var bResponse = response.getReturnValue();
                if(bResponse === true)
                {
                    toastEvent.fire();
                    component.set("v.isLinkButtonClick", false);
                    component.set("v.isDataDisplay",true);
                    component.set("v.isContactsDelete",false);
                     component.set('v.accId',null);
                     //supriya - checksync -false other than sync functionality
             		component.set('v.checkSync',false);
                    //this.checkUniverseAccount(component, event, helper);
                    this.currentUserInfo(component,event, helper);
                  
                }
            }else if (a1.getState() === "ERROR") {
                $A.log("Errors", a1.getError());
            }
             
      	});
        
         $A.enqueueAction(actionToDelete);
       
	},
   
    syncUniverseDataHelper :function(component,event,helper)
    {
        this.showSpinner(component, true);
    	var actionToSync=  component.get("c.syncUniverseData");
        console.log('Inside Sync...* ');
        actionToSync.setParams({
             "recordId":  component.get('v.recordId'),
            "accId":  component.get('v.accId'),
            "draupAccName" : component.get('v.draupAccountName')
        });
        actionToSync.setCallback(this, function(response) {
             console.log('Inside  Sync callback ');
            var state = response.getState();
            if (state === "SUCCESS") {
                
                if(response.getReturnValue() == true){
                    component.set("v.checkSync",true);
                    this.displayRelatedUniverseHelper(component,event,helper);  
                    this.showSpinner(component, false);
                }	
            }else if (response.getState() === "ERROR") {
                $A.log("Errors", response.getError());
                this.showSpinner(component, false);
            }
             
      	});
        
         $A.enqueueAction(actionToSync);
    },
    showSpinner: function(component, isVisible) {
        var spinner = component.find("childSpinner");
        spinner.showSpinner(isVisible);
    },
    showLastModDate:function(component,event,helper)
    {
         this.showSpinner(component, true);
    	var modDate = component.get("c.getLastModDate");
        console.log('in side Time'); 
        modDate.setParams({
      		  "accId":  component.get('v.accId'),
             "recordId":  component.get('v.recordId')
         });
          modDate.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") 
            {
                var ldate = response.getReturnValue();
                console.log('date ' + ldate);
                component.set("v.lastModifiedDate",ldate);
            }
               this.showSpinner(component, false);
      	});
         $A.enqueueAction(modDate);
	},
    
    verifyContactsHelper:function(component,event,helper)
    {
     var checkContactStatus = component.get("c.verifyContactExistance");
     checkContactStatus.setParams({
             "recordId":  component.get('v.recordId'),
            "accId":  component.get('v.accId')
        });
     checkContactStatus.setCallback(this, function(response) {
         var state = response.getState();
         if (state === "SUCCESS") 
         {
             var count = response.getReturnValue();
             console.log('checkContactStatus **'+ count );
             if(count>0)
             {   
                component.set("v.contactCount",count);
             	component.set("v.isContactsDelete",true);
             } 
             else
             {
                 component.set("v.isContactsDelete",false);
                 this.unlinkUniverseDataHelper(component,event,helper);
             }
         }
         
     });
        $A.enqueueAction(checkContactStatus);
	}
     
})