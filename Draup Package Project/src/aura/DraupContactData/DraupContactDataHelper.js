({
    getRoledexSuggestions : function(component, event, helper) {
        console.log('starting.............');
        console.log('auth'+component.get('v.isLoginAuth'));
        this.showSpinner(component, true);
        var action = component.get("c.matchDraup");
        action.setParams({
            "recordId": component.get("v.recordId")
        });
        console.log('ContactId'+component.get("v.recordId"));
        action.setCallback(this, function(a) {
            if (a.getState() === "SUCCESS") {
                var executives = a.getReturnValue();
                component.set("v.DraupExecutiveWrapper", executives);
                console.log('executives***'+executives);
                var isSuperUser = component.get('v.isSuperUser');
                if(!isSuperUser){
                    component.set("v.noDataFlag","slds-show");
                    component.set("v.errorMsg","Draup data not linked to this Contact.");
                }
                else if(executives == null || executives == ''){
                    component.set("v.noDataFlag","slds-show");
                    component.set("v.errorMsg","No matching executive found in Draup");
                }
                console.log('DraupExecutiveWrapper-------'+executives);
                component.set("v.DraupContactWrapper", executives);
               
            }else if (a.getState() === "ERROR") {
                $A.log("Errors", a.getError());
            }
            this.showSpinner(component, false);
        });
        $A.enqueueAction(action);
        
    },
    checkRolodexExecutive : function(component, event, helper) {
        console.log('gdhfgdhf');
        
        var action = component.get("c.getContact");
        action.setParams({
            "recordId": component.get("v.recordId")
        });
        console.log('ContactID*****'+component.get("v.recordId"));
        action.setCallback(this, function(response) {
            if (response.getState() === "SUCCESS") {
                var storeResponse = response.getReturnValue();
                component.set("v.RolodexExecutive", storeResponse);
                var draupId = component.get("v.RolodexExecutive").draupApp__Draup_Id__c;
                component.set('v.draupId',draupId);
                console.log('rolodex executive ID-------'+draupId);
                component.set("v.isLoginDisable", false);
                var draupId = component.get('v.draupId');
                console.log('draupId**-------'+draupId);
                if(draupId == null){
                    console.log('from if');
                    component.set("v.isLinkButtonHide",true);
                    this.checkAccountStatus(component,event,helper);
                   // this.getRoledexSuggestions(component,event,helper);
                    
                }else{
                    console.log('from else');
                    // component.set("v.isLinkButtonHide",false);
                    // component.set("v.isLinkButtonClick",true);
                    component.set("v.executiveId",draupId);
                    this.showLastModDate(component,event,helper);
                    this.displayRelatedExecutiveHelper(component, event, helper);
                }
            }else if (response.getState() === "ERROR") {
                $A.log("Errors", response.getError());
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
        console.log('inside Contact data.............');
       	
        if( component.get('v.executiveId')==null)
        {
            alert('Please select Executive');
            return;
        }
        this.showSpinner(component, true);
        var msg = 'There is no data from Draup linked with this contact\'s Account. \n Please Link Account first and try again';
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            duration:12000,
            "title": "Please Link Accounts",
            "type": 'error',
            "message": msg
        });
        
        var checkAction = component.get("c.checkAccountlinkedStatus");
        checkAction.setParams({
            "recordId":  component.get('v.recordId'),
            "executiveId":  component.get('v.executiveId'),
        });
        checkAction.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") 
            {
                var status = response.getReturnValue();
                console.log('status* ' + status);
                if(status === false)
                {
                    console.log('in side to show toast msg ');
                    this.showSpinner(component, false);
                    toastEvent.fire();
                }
                else
                {                   
                    var action1 = component.get("c.displayDraupData");
                    //var exeId= document.querySelector('input[name="rate"]:checked').value;
                    action1.setParams({
                        "recordId":  component.get('v.recordId'),
                        "executiveId":  component.get('v.executiveId'),
                        "syncCheck" : false
                    });
                    action1.setCallback(this, function(a1) {
                        console.log('from lead data');
                        if (a1.getState() === "SUCCESS") {
                            component.set("v.isLinkButtonClick", true);
                            component.set("v.Spinner", true);
                            component.set("v.isDataDisplay",false);
                            component.set("v.isLinkButtonHide",false);
                            console.log('inside state');
                            var draupDataList = a1.getReturnValue();
                            console.log('DraupHeaders*******'+draupDataList);
                            if(draupDataList == null || draupDataList == ''){
                                component.set("v.noDataFlag","slds-show");
                                component.set("v.errorMsg","Data not linked");
                            }
                            //component.set("v.DraupHeaders", a1.getReturnValue());
                            //console.log('DraupHeaders*******'+a1.getReturnValue());
                         else{
                            var custs = [];
                            var existsImg =false;
                            var conts = a1.getReturnValue();
                            for(var key in conts){
                                var Props = [];
                                if(key=='Overview')
                                {
                                    console.log('indexOv**');
                                    for(var key1 in conts[key][0]){
                                        /*var index = key1.indexOf(":");
                             console.log('index**'+index);
                            var header = key1.substring(0,index);
                             console.log('header**'+header);*/
                                        if(key1=='Image Link'){
                                            component.set("v.imageURL",conts[key][0][key1]);
                                        }
                                        Props.push({value:conts[key][0][key1], key:key1});   
                                    }
                                }
                                if(key=='Draup Psychological Analysis')
                                {
                                    console.log('index**');
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
                                    console.log('indexEx**');
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
                            //debugger;
                            
                            /* if(a1.getReturnValue().Overview[0] !='undefined'){
                    
                var imgUrl = a1.getReturnValue().Overview[0]['Image Link'].split('src=')[1].split('><')[0];
                console.log('--imgUrl--'+imgUrl);
                if(imgUrl != 'null' ){
                   
                 //var result = this.checkimageValidation(imgUrl);   
                 
                 console.log('<<<result>>>'+result);
                 /*this.imageValidation(imgUrl,function(existsImg){
                  if(existsImg == true){
                    component.set("v.isImageURLValid",true);
                   }  
                  });
                  }
                }*/
                            component.set("v.draupId",component.get('v.executiveId')); 
                            component.set("v.DraupHeaders", custs);
                            console.log('..value..>');
                            console.log(custs);
                            this.showLastModDate(component,event,helper);
                            this.showSpinner(component, false); 
                         }
                            
                        }else if (a1.getState() === "ERROR") {
                            $A.log("Errors", a1.getError());
                            this.showSpinner(component, false); 
                        }

                    });
                    $A.enqueueAction(action1);
                }
            }
        });
        $A.enqueueAction(checkAction);
        
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
                //window.open("https://accounts.google.com/signin/v2/identifier?flowName=GlifWebSignIn&flowEntry=ServiceLogin&ClientId="+tempVars,"_self");
                var WindowName = " https://qa-platform.draup.com/draup/authorize?client_id="+queryParameters;
                var loginWindow = window.open(WindowName,"_blank",'height=600,width=600,location=yes,left=500,top=100,resizable=yes,toolbar=no,status=no,menubar=no,scrollbars=1')    ;   
                var check = WindowName.includes('DraupAuthRedirectPage');
                console.log(' WindowName ' + WindowName);
                console.log( 'cheking '+ WindowName.includes('DraupAuthRedirectPage'));
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
        this.showSpinner(component, true);
        var action = component.get("c.fetchUser");
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var storeResponse = response.getReturnValue();
                component.set("v.userInfo", storeResponse);
                console.log('User**');
                 console.log(storeResponse);
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
                    this.checkRolodexExecutive(component,event,helper);
                }
            }else if (response.getState() === "ERROR") {
                $A.log("Errors", response.getError());
            }
            this.showSpinner(component, false);
        });
        $A.enqueueAction(action);
    },
    showSpinner: function(component, isVisible) {
        var spinner = component.find("childSpinner");
        spinner.showSpinner(isVisible);
    },
    unlinkRolodexDataHelper:function(component, event, helper)
    {
        this.showSpinner(component, true);
        var actionToDelete =  component.get("c.removeRolodexData");
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            duration:4000,
            "title": "Sucess",
            "type": 'Success',
            "message": "Contact has been unlinked"
        });
        console.log('Inside unlink fucntion ');
        actionToDelete.setParams({
            "recordId":  component.get('v.recordId'),
            "executiveId":  component.get('v.executiveId')
        });
        actionToDelete.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var bResponse = response.getReturnValue();
                if(bResponse === true)
                {
                    component.set("v.isDataDisplay",true);
                    component.set("v.isLinkButtonClick",false);
                    //this.checkRolodexExecutive(component, event, helper);
                    component.set("v.executiveId",null);
					component.set("v.checkSync",false);
                    this.currentUserInfo(component,event, helper);
                    toastEvent.fire();
                }
                else
                {
                    alert("This record is may be deleted already ");
                    this.showSpinner(component, false); 
                }
            }     
        });
        
        $A.enqueueAction(actionToDelete);
    },
    
    syncRolodexDataHelper :function(component, event, helper){
        
        this.showSpinner(component, true);
        var actionToSync=  component.get("c.syncRolodexData");
        console.log('Inside Sync fucntion -2 ');
        actionToSync.setParams({
            "recordId":  component.get('v.recordId'),
            "executiveId":  component.get('v.executiveId')
        });
        actionToSync.setCallback(this, function(response) {
            console.log('Inside callback -3 ');
            var state = response.getState();
            if (state === "SUCCESS") {
                component.set('v.checkSync',true);
                this.displayRelatedExecutiveHelper(component, event, helper);
            }
            this.showSpinner(component, false);
        });
        
        $A.enqueueAction(actionToSync);
    },
    showLastModDate:function(component,event,helper)
    {
        this.showSpinner(component, true);
        var modDate = component.get("c.getLastModDate");
        console.log('in side Time'); 
        modDate.setParams({
            "executiveId":  component.get('v.executiveId'),
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
    }, imageValidation : function(imgURL,callBack){
        debugger;
        var imageData = new Image();
        imageData.src = imgURL;
        imageData.onload = function(){
            callBack(true);
        };   
        imageData.onerror = function(){
            callBack(false);
        };
        
    },
    
    checkimageValidation :function(url){
        return new Promise(function(resolve, reject) {
            //debugger;
            var timeout =50000;
            var timer, img = new Image();
            img.onerror = img.onabort = function() {
                clearTimeout(timer);
                reject("error");
            };
            img.onload = function() {
                clearTimeout(timer);
                resolve("success");
            };
            timer = setTimeout(function() {
                // reset .src to invalid URL so it stops previous
                // loading, but doens't trigger new load
                img.src = "//!!!!/noexist.jpg";
                reject("timeout");
            }, timeout); 
            img.src = url;
        });  
    },
    
    record : function(url, result) {
        // debugger;
        document.body.innerHTML += "<span class='" + result + "'>" + 
            result + ": " + url + "</span><br>";
    },
    runImage : function(url){
        This.checkimageValidation(url).then(This.record.bind(null, url), This.record.bind(null, url));
    },
    
    checkAccountStatus:function(component,event,helper)
    {
        console.log('chekcing Status... ');
       // var msg = 'There is no data from Draup linked this contact Accounts.Please Link account first and try to link Contact';
        var msg = 'There is no data from Draup linked with this contact\'s Account. \nPlease Link Account first and try again';
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            duration:1000,
            "title": "Please Link Accounts",
            "type": 'error',
            "message": msg
        });
        var checkAction = component.get("c.checkAccountlinkedStatus");
        checkAction.setParams({
            "recordId":  component.get('v.recordId'),
            "executiveId":  component.get('v.executiveId')
        });
        checkAction.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") 
            {
                var status = response.getReturnValue();
                console.log('status ' + status);
                if(status == false)
                {
                    toastEvent.fire();
                    component.set("v.noDataFlag","slds-show");
                    component.set("v.errorMsg","There is no data from Draup linked with this contact\'s Account. \nPlease Link Account first and try again");
                }
                else
                {
                    //this.checkRolodexExecutive(component, event, helper);
                    this.getRoledexSuggestions(component,event,helper);
                    //this.currentUserInfo(component, event, helper);
                }
            }
            this.showSpinner(component, false);
        });
        $A.enqueueAction(checkAction);
    },
    
    createQueryHelper : function(component,event,helper)
    {
        this.showSpinner(component, true);
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            duration:5000,
            "title": "Sucess",
            "type": 'Success',
            "message": "Query Created Successfully"
        });
        var create = component.get("c.createNewQuery");
        console.log('reason ** '+component.get('v.queryReason'))
        create.setParams({
            "queryReason":  component.get('v.queryReason'),
        });
        create.setCallback(this, function(response) {
        var state = response.getState();
        if (state === "SUCCESS") 
        {
            var status = response.getReturnValue();
            console.log('status ' + status);
            if(status == true)
            {
                component.set("v.showCreateQuery",false);
                this.showSpinner(component, false);
                toastEvent.fire();
            }
            else
            {
                this.showSpinner(component, false);
            }
        }
        });
        $A.enqueueAction(create);
    }
})