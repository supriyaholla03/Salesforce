({
	doInit : function(component, event, helper) {
		helper.universeGlobalization(component, event, helper);
	},
    Globalization : function(component, event, helper) {
     var radioText = event.getSource().get("v.text");
        component.set("v.type" , radioText);    
		helper.universeGlobalization(component, event, helper);
	}
  /*  handleShowActiveSectionName: function (cmp, event, helper) {
        alert(cmp.find("accordion").get('v.activeSectionName'));
    }*/
})