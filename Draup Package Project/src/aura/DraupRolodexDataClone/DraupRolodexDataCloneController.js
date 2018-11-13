({
    doInit : function(component, event, helper) {
        helper.getRoledexSuggestions(component, event, helper);
        helper.currentUserInfo(component, event, helper);
        //helper.getLoginRequired(component, event, helper);
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
    draupAuthentication : function(component, event, helper) {
        console.log('inside openActionWindow()');
        helper.draupAuthenticationHelper(component, event, helper);
    },
    unlinkRolodexData : function(component, event, helper) { 
       helper.unlinkRolodexDataHelper(component, event, helper);
    },
    
})