({
       showSpinner: function(component,event) {
        var params = event.getParam('arguments');
        var documentProcessSpinner = component.find('documentProcessSpinner');
        var elements = document.getElementsByClassName("siteforceLoadingBalls");
        console.log(elements);
       //  component.set("v.lightningView",false);
        if(params.show) {
            $A.util.removeClass(documentProcessSpinner, 'slds-hide');
            $A.util.addClass(documentProcessSpinner, 'slds-show');
            $A.util.addClass(elements, 'slds-hide');
        } else {
            $A.util.removeClass(documentProcessSpinner, 'slds-show');
            $A.util.addClass(documentProcessSpinner, 'slds-hide');
            $A.util.addClass(elements, 'slds-hide');
        }
    }
})