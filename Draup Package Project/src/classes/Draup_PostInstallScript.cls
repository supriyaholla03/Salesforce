/**************************************************************************************************************
*   @author         Persistent Systems
*   @date           22/10/2018
*   @description    This class is used for installing custom setting during package installation in the Org.
***************************************************************************************************************/

global class Draup_PostInstallScript implements InstallHandler{     
    
    /*************************************************************************************************************
* @description InstallHandler Interface method - to create CustomSetting records during package installation.
* @author      Persistent Systems
* @param       InitialContext
* @date        22/10/2018
* @return      void
**************************************************************************************************************/
    global void onInstall(InstallContext context) {
        
        // To insert custom setting records in to Draup custom setting object.
        insertCustomSettingRecords();
    } 
    
    /*************************************************************************
* @description   Method to delete and create the custom setting records.
* @author        Persistent Systems
* @date          25/10/2018
* @return        String
**************************************************************************/
    public static string insertCustomSettingRecords() {
        
        try{
            // List to hold the custom setting records to be inserted.
            List<sObject> recToInsert = new List<sObject>();
            List<sObject> recToDelete = new List<sObject>();
            boolean keyExists = false;
            List<String> inpVals = new List<String>();
            // checking for already exists custom setting records and deleting the same
            List<Sobject> recKeys = [select id from CryptoKeys__c];   
            List<Sobject> recAuth = [select id from clientAuthDetails__c];
            List<Sobject> recEndpoints = [select id from DraupEndPoints__c];
            if(recKeys !=null && recKeys.size()>0){
                keyExists = true;
                system.debug('Key exists');
            }
           // recToDelete.addAll(recKeys);
            if(recAuth !=null)
            recToDelete.addAll(recAuth);
            if(recEndpoints !=null)
            recToDelete.addAll(recEndpoints);
            // TO delete existing custom setting records
            if(recToDelete.size()>0)
            delete recToDelete;
            
            Blob key = Crypto.generateAesKey(128);
            // Inserting custom setting CryptoKeys__c for key requred for encryption and decryption
            if(Schema.sObjectType.CryptoKeys__c.fields.Name.isCreateable() &&
                Schema.sObjectType.CryptoKeys__c.isCreateable() && !keyExists){
                   CryptoKeys__c recObj;
                   recObj = new CryptoKeys__c();
                   recObj.Name = 'Key';
                   recObj.draupApp__Key__c = (EncodingUtil.base64Encode(key)).trim();
                   recToInsert.add(recObj);                   
               }
            
            if(Schema.sObjectType.clientAuthDetails__c.fields.Name.isCreateable() &&
              Schema.sObjectType.clientAuthDetails__c.isCreateable()){
                   
                   recToInsert.add(new clientAuthDetails__c(Name='Auth',draupApp__clientId__c='',draupApp__clientSecret__c='',draupApp__SuperUserProfile__c='System Administrator'));     
                   }
            /* Start Inserting records of Draup endpoints */
            if(Schema.sObjectType.DraupEndPoints__c.fields.Name.isCreateable() &&
              Schema.sObjectType.DraupEndPoints__c.isCreateable()){
                   
                   DraupEndPoints__c recObj;
                   recObj = new DraupEndPoints__c();
                   recObj.Name = 'AccountAllDetailsEndPoint';
                   recObj.draupApp__End_Point_Url__c = '/service/daas/accounts/all_details/?account_id=';
                   recToInsert.add(recObj);
               }
             if(Schema.sObjectType.DraupEndPoints__c.fields.Name.isCreateable() &&
               Schema.sObjectType.DraupEndPoints__c.isCreateable()){
                   DraupEndPoints__c recObj;
                   recObj = new DraupEndPoints__c();
                   recObj.Name = 'AccountSearchEndPoint';
                   recObj.draupApp__End_Point_Url__c = '/service/daas/accounts/search/?name=';
                   recToInsert.add(recObj);
               }
            if(Schema.sObjectType.DraupEndPoints__c.fields.Name.isCreateable() &&
               Schema.sObjectType.DraupEndPoints__c.isCreateable()){
                       DraupEndPoints__c recObj;
                       recObj = new DraupEndPoints__c();
                       recObj.Name = 'RolodexAllDetailsEndPoint';
                       recObj.draupApp__End_Point_Url__c = '/service/daas/executives/all_details/?executive_id=';
                       recToInsert.add(recObj);
               }
            if(Schema.sObjectType.DraupEndPoints__c.fields.Name.isCreateable() &&
                Schema.sObjectType.DraupEndPoints__c.isCreateable()){
                   DraupEndPoints__c recObj;
                   recObj = new DraupEndPoints__c();
                   recObj.Name = 'RolodexSearchEndPoint';
                   recObj.draupApp__End_Point_Url__c = '/service/daas/executives/search/?account=';
                   recToInsert.add(recObj);
               }
            if(Schema.sObjectType.DraupEndPoints__c.fields.Name.isCreateable() &&
               Schema.sObjectType.DraupEndPoints__c.isCreateable()){
                   DraupEndPoints__c recObj;
                   recObj = new DraupEndPoints__c();
                   recObj.Name = 'DraupAuth';
                   recObj.draupApp__End_Point_Url__c = '/service/client/token/';
                   recToInsert.add(recObj);
               }
            /* End Inserting records of Draup endpoints */
            insert recToInsert;                   
            return 'success';   
            
        }catch(exception e){
            // Log the Exception Message in Error Log Object.
            String exceptionBody = 'Message : ' + e.getMessage() + '<br/>Line no : ' + e.getLineNumber() + '<br/>StackTraceString ' + e.getStackTraceString() 
                + '<br/>Cause:' + e.getCause();
           ExceptionHandler.logApexError('Draup_PostInstallScript', 'insertCustomSettingRecords', String.valueOf(e.getLineNumber()), e.getStackTraceString());
           return e.getMessage();
        }
    }
}