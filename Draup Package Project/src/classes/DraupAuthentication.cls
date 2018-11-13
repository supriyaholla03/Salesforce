/**************************************************************************************************************
*   @author         Persistent Systems
*   @date           18/09/2018
*   @description    This class is used to get user token from client and store it for authorized user
***************************************************************************************************************/

public with sharing class  DraupAuthentication {
    public boolean login{get;set;}  
    public static boolean draupAuthorize{get;set;}
    
    public class PostRequestParam{
        public string client_id;
        public string client_secret;
        public string authorization_code;
        
    }
    /***************************************************************************************************
    * @description   This method get User access token from client by sending required client details
    * @author        Persistent Systems
    * @param       	-
    * @date          18/09/2018
    * @return        String
    ****************************************************************************************************/
    public String getAccessToken()
    {
        try
        {
            String accessToken = '';
            string authCode =ApexPages.currentPage().getParameters().get('authorization_code').escapeHtml4();
            //System.debug('authcode:'+authCode);
            //System.debug('UserInfo.getUserId()' + UserInfo.getUserId());
            //Map<String, Schema.SObjectField> schemaFieldMap = Schema.SObjectType.user.fields.getMap();
            //List<String> fieldList = new List<String>();
            //for(String field :schemaFieldMap.keyset()){
            //    fieldList.add(field);
            //}
            boolean valid = Utility.isAccessible(getUserFieldList(),'User');
            if(!valid){
                return null;
            }
            else{
                String uId = UserInfo.getUserId();
                User userAccessToken = Database.query('Select id, Draup_Token__c from User where id=:uId'); 
                //System.debug('userAccessToken.Draup_Token__c  ' + userAccessToken.Draup_Token__c );
                //System.debug(' authCode ' + authCode);
                if(userAccessToken.Draup_Token__c == null && authCode != ' ')
                {
                    clientAuthDetails__c authDetails = clientAuthDetails__c.getValues('Auth');
                    HttpRequest httpReq = new HttpRequest();
                    PostRequestParam postRequest = new PostRequestParam();
                    postRequest.client_id = authDetails.draupApp__clientId__c;
                    postRequest.client_secret = authDetails.draupApp__clientSecret__c;
                    postRequest.authorization_code = authCode;
                    String jsonstring = JSON.serialize(postRequest); 
                    System.debug('jsonstring'+jsonstring);
                    DraupEndPoints__c auth = DraupEndPoints__c.getValues('DraupAuth');
                    httpReq.setEndpoint(System.Label.Draup_Platform_Url+auth.End_Point_Url__c);
                    httpReq.setMethod('POST');
                    httpReq.setHeader('Content-Type','application/json');
                    httpReq.setHeader('Accept', 'application/json');
                    httpReq.setBody(jsonstring);
                    httpReq.setTimeout(120000);
                    System.debug(' httpReq' +httpReq);
                    http httpObj = new http();
                    httpResponse response = httpObj.send(httpReq);
                    System.debug('response ' + response) ;
                    if(response.getStatusCode() == 201)
                    {
                        System.debug('resbody:' +response.getBody());
                        JSONParser parser = JSON.createParser(response.getBody());
                        System.debug('parser:' +parser);
                        while (parser.nextToken() != null) 
                        {
                            if ((parser.getCurrentToken() == JSONToken.FIELD_NAME))
                            {
                                system.debug('token:'+JSONToken.FIELD_NAME);
                                String fieldName = parser.getText();
                                system.debug('ParserText:'+parser.getText());
                                system.debug('fieldName:'+fieldName);
                                parser.nextToken();
                                if(fieldName == 'token')
                                {
                                    accessToken = parser.getText();
                                    //system.debug('AccessToken:'+accessToken);
                                }
                            }
                        }
                    }
                    if (response.getStatusCode() > 201) {
                        system.debug(' status: ' + response.getStatusCode()+'status: ' + response.getBody() +';' +'request: ' +
                                     httpReq.toString() + 'request headers: ' + httpReq.getHeader('Content-Type') + '; ' +
                                     'request body: ' + httpReq.getBody() );
                    }
                    if(accessToken != '')
                    {
                        //System.debug('s1' + s1);
                        //userAccessToken.Draup_Token__c = s1;
                        userAccessToken.Draup_Token__c = getEncryptedToken(accessToken);
                        userAccessToken.ExpiryDate__c = System.today()+30;
                        //system.debug('ToUpdate in User level AccessToken:'+accessToken);
                        //boolean updateValid = true;// = Utility.isUpdateable(getUserFieldList(),'User');
                        if(Schema.sObjectType.user.fields.Draup_Token__c.isUpdateable() && Schema.sObjectType.user.fields.ExpiryDate__c.isUpdateable() )
                        {
                            Database.update(userAccessToken);
                        }
                        else
                        {
                            return null;
                        }
                        
                        draupAuthorize = true;
                    }
                    
                }
              /*  else {
                    accessToken = getDecryptedToken();
                }*/
            }
        }
        catch(exception ex)
        {
            System.debug('Message **'+ ex.getMessage()+'line number '+ex.getStackTraceString());
            ExceptionHandler.logApexError('DraupAuthentication', 'getAccessToken', String.valueOf(ex.getLineNumber()) , ex.getStackTraceString());
        }
        
        
        return null;
    }
   /* private static String getDecryptedToken()
    {
        // Supriya need to change select statement as per security concern
        try{
            String uId = UserInfo.getUserId();
            User userObj =  Database.query('Select id, Draup_Token__c from User where id=:uId');
            String accessToken = DraupEncryptUtil.getDecryptedValue(userObj.Draup_Token__c);
            return accessToken;
        }catch(exception ex){
            System.debug('Message **'+ ex.getMessage()+'line number '+ex.getStackTraceString());
            ExceptionHandler.logApexError('DraupAuthentication', 'getDecryptedToken', String.valueOf(ex.getLineNumber()) , ex.getStackTraceString());
            return null;
        }
    } */
    
     /***************************************************************************************************
    * @description   Method to Encrypt access token which is recieved from client 
    * @author        Persistent Systems
    * @param       	 User Token 
    * @date          26/09/2018
    * @return        String
    ****************************************************************************************************/
    @TestVisible Private Static String getEncryptedToken(String sToken)
    {
        try{
        String encryptedAccessToken = DraupEncryptUtil.getEncryptedValue(sToken);
        return encryptedAccessToken;
    	}
        catch(exception ex){
            System.debug('Message **'+ ex.getMessage()+'line number '+ex.getStackTraceString());
            ExceptionHandler.logApexError('DraupAuthentication', 'getEncryptedToken', String.valueOf(ex.getLineNumber()) , ex.getStackTraceString());
            return null;
        }
    }
    
     /***************************************************************************************************
    * @description   Method to get Total User object fields.
    * @author        Persistent Systems
    * @param       	 -
    * @date          22/10/2018
    * @return        List<String>
    ****************************************************************************************************/
    public List<String> getUserFieldList()
    {
        try{
        Map<String, Schema.SObjectField> schemaFieldMap = Schema.SObjectType.user.fields.getMap();
        List<String> fieldList = new List<String>();
        for(String field :schemaFieldMap.keyset()){
            fieldList.add(field);
        }
        return fieldList;
        }catch(exception ex){
            System.debug('Message **'+ ex.getMessage()+'line number '+ex.getStackTraceString());
            ExceptionHandler.logApexError('DraupAuthentication', 'getUserFieldList', String.valueOf(ex.getLineNumber()) , ex.getStackTraceString());
            return null;
        }
    }
    
}