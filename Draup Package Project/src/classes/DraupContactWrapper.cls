/**************************************************************************************************************
*   @author         Persistent Systems
*   @date           20/09/2018
*   @description    This wrapper class is used to parse Contact suggestion list response 
***************************************************************************************************************/
public class DraupContactWrapper implements Comparable {
    
    @AuraEnabled public String executive_id;
    @AuraEnabled public String executive_name;
    @AuraEnabled public boolean isSelected =false;
    @AuraEnabled public String account;
    @AuraEnabled public String bio;
    @AuraEnabled public String location;
    public static List<DraupContactWrapper> parse(String json) {
        return (List<DraupContactWrapper>) System.JSON.deserialize(json, List<DraupContactWrapper>.class);
    }
    
    public DraupChild__c draupChild;
   
    public DraupContactWrapper(){
        
    }
     // Constructor
    public DraupContactWrapper(DraupChild__c dc) {
        draupChild = dc;
    }
    // Compare Draup Child based on the order .
    public Integer compareTo(Object compareTo) {
        // Cast argument to OpportunityWrapper
        DraupContactWrapper compareToDc = (DraupContactWrapper)compareTo;
        
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