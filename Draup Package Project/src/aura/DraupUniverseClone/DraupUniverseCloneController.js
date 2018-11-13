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
        helper.getRoledexSuggestions(component, event, helper);
        helper.currentUserInfo(component, event, helper);
        //helper.getLoginRequired(component, event, helper);
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
    displayRelatedExecutiveData : function(component, event, helper) { 
        console.log('inside displayRelatedData()');
        helper.displayRelatedExecutiveHelper(component, event, helper);
        
    },
    handleSelect : function(component, event, helper){
        console.log('from selected');
         var selected = component.get("v.key");
        component.find("tabs").set("v.selectedTabId",selected);
        
        
    },
    handleActive: function (cmp, event, helper) {
        helper.lazyLoadTabs(cmp, event);
    } ,
    unlinkUniverseData:function (component, event, helper) {
        alert('inside Controller ');
        helper.unlinkUniverseDataHelper(component, event, helper);
    }  
 
  
})