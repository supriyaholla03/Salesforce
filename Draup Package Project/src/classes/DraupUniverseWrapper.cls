/**************************************************************************************************************
*   @author         Persistent Systems
*   @date           20/09/2018
*   @description    This wrapper class is used to parse Account suggestion list response 
***************************************************************************************************************/
public with sharing class DraupUniverseWrapper {
    
    @AuraEnabled public String account_id;
    @AuraEnabled public String account_name;
    @AuraEnabled public boolean isSelected =false;
    @AuraEnabled public boolean direct_match;
    @AuraEnabled public String lastModDate;
    @AuraEnabled public Map<string,List<Map<string,string>>> draupDetailMap;
    
    public static List<DraupUniverseWrapper> parse(String json) {
        return (List<DraupUniverseWrapper>) System.JSON.deserialize(json, List<DraupUniverseWrapper>.class);
    }
    
}