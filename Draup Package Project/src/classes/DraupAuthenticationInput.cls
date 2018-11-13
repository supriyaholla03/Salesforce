/**************************************************************************************************************
*   @author         Persistent Systems
*   @date           28/10/2018
*   @description    This class is used for Stroring and displaying client details entered by user in vf page
***************************************************************************************************************/
public with sharing class DraupAuthenticationInput {
    public string clientId{get;set;}
    public string clientSecret{get;set;}
    public string superUserProfiles {get;set;}
    public Boolean status{get;set;}
    public Boolean authExists{get;set;}
    public Integer selectedSyncHour{get;set;}
    
/*************************************************************************************************************
* @description Constructor to display user details if already stored in custom setting
* @author      Persistent Systems
* @param       -
* @date        28/10/2018
* @return      None
**************************************************************************************************************/

    public DraupAuthenticationInput()
    {   
        try{
            clientAuthDetails__c clntAuthDetails = clientAuthDetails__c.getValues('Auth');
        System.debug(' clntAuthDetails '+ clntAuthDetails);
         //LIst<clientAuthDetails__c> lClntAuth = [Select id,name,clientId__c,clientSecret__c from clientAuthDetails__c where Name ='Auth' limit 1];
      
        if(clntAuthDetails != null/* && clntAuthDetails.draupApp__clientId__c != null && clntAuthDetails.draupApp__clientSecret__c != null*/) 
        {
            authExists = true;
            clientId = (clntAuthDetails.draupApp__clientId__c != null) ?clntAuthDetails.draupApp__clientId__c : null;
            clientSecret = (clntAuthDetails.draupApp__clientSecret__c != null)?clntAuthDetails.draupApp__clientSecret__c: null ;
            superUserProfiles = (clntAuthDetails.draupApp__SuperUserProfile__c !=null)?clntAuthDetails.draupApp__SuperUserProfile__c:null;
            selectedSyncHour = (clntAuthDetails.draupApp__SyncHour__c !=null)?Integer.valueof(clntAuthDetails.draupApp__SyncHour__c):null;
        }
        }
        catch(exception ex)
            {
                System.debug('Message '+ ex.getMessage()+'line number '+ex.getLineNumber());
                 ExceptionHandler.logApexError('DraupAuthenticationInput', 'DraupAuthenticationInput', String.valueOf(ex.getLineNumber()) , ex.getStackTraceString());
            }
        
    }
    
/*************************************************************************************************************
* @description Method to insert or Update Client details enterd by User
* @author      Persistent Systems
* @param       -
* @date        28/10/2018
* @return      None
**************************************************************************************************************/
    public void insertClientDetails()
    {
        System.debug(' status '+ status);
        System.debug('clientId ' + clientId);
        System.debug(' clientSecret ' + clientSecret);
        try{
        LIst<clientAuthDetails__c> lClntAuth = [Select id,name from clientAuthDetails__c where Name ='Auth' limit 1];
         clientAuthDetails__c oClntAuth = new clientAuthDetails__c();
        if(lClntAuth != null && lClntAuth.size()>0 ) 
        {
            oClntAuth.id=lClntAuth.get(0).id;
            oClntAuth.draupApp__clientId__c = clientId.trim();
            oClntAuth.draupApp__clientSecret__c=clientSecret.trim();
            oClntAuth.draupApp__SuperUserProfile__c = superUserProfiles.trim();
            oClntAuth.draupApp__SyncHour__c = String.valueOf(selectedSyncHour);
            update oClntAuth;
            status = true;
        }    
        else 
        {
            oClntAuth.Name = 'Auth';
            oClntAuth.draupApp__clientId__c = clientId;
            oClntAuth.draupApp__clientSecret__c=clientSecret;
            oClntAuth.draupApp__SuperUserProfile__c = superUserProfiles.trim();
            oClntAuth.draupApp__SyncHour__c = String.valueOf(selectedSyncHour);
            insert oClntAuth; 
            status = true;
        }
        }
        catch(Exception ex)
        {
            ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.Error, ex.getMessage());
            ApexPages.addMessage(msg);
             System.debug('Message '+ ex.getMessage()+'line number '+ex.getLineNumber());
            ExceptionHandler.logApexError('DraupAuthenticationInput', 'insertClientDetails', String.valueOf(ex.getLineNumber()) , ex.getStackTraceString());
        }
    }
    /*public List<SelectOption> getHours()
    {
        List<SelectOption> options = new List<SelectOption>();
        for(Integer i=1;i<=24;i++)
            {
                  String value = String.valueOf(i);
                  options.add(new SelectOption(value ,value ));
            }
            return options;
    }*/

}