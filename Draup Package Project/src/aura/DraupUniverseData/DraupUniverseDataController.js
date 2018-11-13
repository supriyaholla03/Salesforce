({
	
 /*OpenPop : function(component, event, helper){
         var loginWindow = window.open(" https://www.google.co.in/",'height=600,width=500,location=yes,left=500,top=100,resizable=yes,toolbar=no,status=no,menubar=no,scrollbars=1', 1)       
                 var timer = setInterval(function() {   
                     if(loginWindow.closed) {  
                         clearInterval(10000);  
                         window.location.reload(); 
                     }  
                 }, 1);
    },
    openModel: function(component, event, helper) {
      // for Display Model,set the "isOpen" attribute to "true"
      component.set("v.isOpen", true);
   },
 
   closeModel: function(component, event, helper) {
      // for Hide/Close Model,set the "isOpen" attribute to "Fasle"  
      component.set("v.isOpen", false);
   },*/
    doInit : function(component, event, helper) {
      // helper.checkUniverseAccount(component, event, helper);
        var platformUrl = $A.get("$Label.c.Draup_Platform_Url");
        component.set("v.draupPlatformUrl",platformUrl);
       helper.currentUserInfo(component, event, helper);
       //helper.showLastModDate(component,event,helper);
    },
   
   draupAuthentication : function(component, event, helper) {
        console.log('inside draupAuthentication');
        helper.draupAuthenticationHelper(component, event, helper);
    },
     onExecutiveChange : function(component, event, helper)
    {
        console.log('inside onRadioChangeHelper()');
        helper.onExecutiveChangeHelper(component, event, helper);
    },
    displayRelatedUniverseData : function(component, event, helper) { 
        console.log('inside displayRelatedData()');
        helper.displayRelatedUniverseHelper(component, event, helper);
        
    },
   /* ITRadioClick: function(component, event, helper) { 
         var type = event.getSource().get("v.text");
         //component.set("v.storeRadioValue" , type);    
		 helper.ITRadioClick(component, type , helper);
	 },*/
    unlinkUniverseData:function (component, event, helper) {
        helper.unlinkUniverseDataHelper(component, event, helper);
        //helper.verifyContactsHelper(component, event, helper);
    },
    
    syncUniverse : function (component, event, helper) {
        helper.syncUniverseDataHelper(component, event, helper); 
        //helper.displayRelatedUniverseHelper(component,event,helper);         
    },
    closePopuUp : function (component, event, helper) {
 		component.set("v.isContactsDelete",false);
	},
    verifyContacts:function(component, event, helper)
    {
        helper.verifyContactsHelper(component, event, helper);
    }
})