({
    doInit : function(component, event, helper) {
   		var platformUrl = $A.get("$Label.c.Draup_Platform_Url");
        component.set("v.draupPlatformUrl",platformUrl);
        helper.currentUserInfo(component, event, helper);
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
    syncRolodex : function(component, event, helper){
    	helper.syncRolodexDataHelper(component, event, helper);
	},
    imageError: function(component,event,helper){
        debugger;
        console.log('Inside Image Error');
        var errorImage = $A.get('$Resource.noImage');
        component.set("v.imageURL",errorImage);
         //event.target.style.display = 'none';
        //event.target.style.image ="https://draup-dev-ed--c.na57.visual.force.com/resource/1539066326000/noImage";
       // this.src = "https://draup-dev-ed--c.na57.visual.force.com/resource/1539066326000/noImage";
        //alert('noo Image');
    },   
    closePopuUp : function (component, event, helper) {
 		component.set("v.showCreateQuery",false);
	},
    showQueryPopup :function (component, event, helper) {
 		component.set("v.showCreateQuery",true);
	},
    createQuery :function (component, event, helper) {
 		helper.createQueryHelper(component, event, helper);
	}
})