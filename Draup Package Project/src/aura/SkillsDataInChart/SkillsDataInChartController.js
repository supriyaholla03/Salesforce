({
    
    doInit : function(component,event,helper){
        helper.helperMethod(component);
        
    },
    setChart : function(component,event,helper){
        helper.setupChart(component);
        
    },
    CountryWise : function(component,event,helper){
        if ( component.get("v.showTable")) {
            component.set("v.showTable",false);
        }
        else
        {
                component.set("v.showTable",true);
        }
    
        //helper.setupChart2(component);
        
    },
    addValue : function(component, event, helper) {
        var checkResult = component.get("v.Countries");
        var result = [];
        checkResult.forEach(function(country) {
            if (country.checkbox == true) {
                result.push(country.countryName);
            }
            
        });
         component.set("v.selectedCountries",result);
        console.log(component.get("v.selectedCountries"));
       var country=component.get("v.selectedCountries");
        if(country.length>=1){
         helper.setupChart3(component);
      
        }
        else
            alert('please select ')
     },
   


                
                
            })