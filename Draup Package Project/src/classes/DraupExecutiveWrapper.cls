/**************************************************************************************************************
*   @author         Persistent Systems
*   @date           20/09/2018
*   @description    This wrapper class is used to parse executive suggestion list response 
***************************************************************************************************************/
public class DraupExecutiveWrapper implements Comparable {
  
    
    @AuraEnabled public String executive_id;
    @AuraEnabled public String executive_name;
    @AuraEnabled public boolean isSelected =false;
    @AuraEnabled public String account;
    @AuraEnabled public String bio;
    @AuraEnabled public String location;
    public static List<DraupExecutiveWrapper> parse(String json) {
        return (List<DraupExecutiveWrapper>) System.JSON.deserialize(json, List<DraupExecutiveWrapper>.class);
    }
    
    public DraupChild__c draupChild;
   
    public DraupExecutiveWrapper(){
        
    }
     // Constructor
    public DraupExecutiveWrapper(DraupChild__c dc) {
        draupChild = dc;
    }
    // Compare Draup Child based on the order .
    public Integer compareTo(Object compareTo) {
        // Cast argument to OpportunityWrapper
        DraupExecutiveWrapper compareToDc = (DraupExecutiveWrapper)compareTo;
        
        // The return value of 0 indicates that both elements are equal.
        Integer returnValue = 0;
        if (draupChild.expOrder__c > compareToDc.draupChild.expOrder__c) {
            // Set return value to a positive value.
            returnValue = 1;
        } else if (draupChild.expOrder__c < compareToDc.draupChild.expOrder__c) {
            // Set return value to a negative value.
            returnValue = -1;
        }
        
        return returnValue;       
    }
   
}