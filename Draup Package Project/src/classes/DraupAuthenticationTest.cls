@isTest
private class DraupAuthenticationTest {
    @testSetup
    static void testSetupData(){
        
        clientAuthDetails__c oAuth = new clientAuthDetails__c();
        oAuth.Name = 'Auth';
        oAuth.draupApp__clientId__c= 'dfhaklfahglkajglkjg';
        oAuth.draupApp__clientSecret__c='agajgkajglkajglajg';
        insert oAuth;
        
        DraupEndPoints__c recObj;
                   recObj = new DraupEndPoints__c();
                   recObj.Name = 'DraupAuth';
                   recObj.End_Point_Url__c = 'https://qa-platform.draup.com/service/client/token/';
  insert recObj;
         /*Draup_Auth__c oAuth = new Draup_Auth__c();
        oAuth.Name = 'Auth';
        oAuth.Client_Id__c = 'LrsbVPInllh2dMoPar0g2rsABVkKkL';
        oAuth.Client_Secret__c='7xyuXDFJFQUpFfLm0HlP4k5MPged2R';
        oAuth.End_Point__c = 'https://qa-platform.draup.com/service/client/token/';
        insert oAuth;*/
        Map<String,ID> profiles = new Map<String,ID>();
        List<Profile> ps = [select id, name from Profile where name = 
                            'Standard User' or name = 'System Administrator'];
        for(Profile p : ps){
            profiles.put(p.name, p.id);
        }
        
        User oUser = new User(alias = 'standt_1', 
                              email='newTestUser@user.com', 
                              profileid = profiles.get('Standard User'),  
                              emailencodingkey='UTF-8', 
                              lastname='Testing', languagelocalekey='en_US', 
                              localesidkey='en_US', 
                              username='newTestUser@user.com',
                              timezonesidkey='America/Los_Angeles',
                              Draup_Token__c='ahskljlskjjalsdkjlkdjlksdjlasdssahskljlskjjalsdkjlkdjlksdjlasdss');
        insert oUser;
        
          User oUser1 = new User(alias = 'standt_2', 
                              email='newTestUser1@user.com', 
                              profileid = profiles.get('Standard User'),  
                              emailencodingkey='UTF-8', 
                              lastname='Testing_1', languagelocalekey='en_US', 
                              localesidkey='en_US', 
                              username='newTestUser1@user.com',
                              timezonesidkey='America/Los_Angeles',
                              Draup_Token__c=null);
        insert oUser1;
        
        CryptoKeys__c oCryptoKeys = new CryptoKeys__c();
        oCryptoKeys.Name = 'Key';
        oCryptoKeys.Key__c='owCTawa3WifoDW4WjIJXLQ==';
        insert oCryptoKeys;
    }
    static testMethod void testAuthentication() {
        system.Test.startTest();
       
        
        ApexPages.currentPage().getParameters().put('authorization_code','afdhkfsdhkafjhaklfhkjk');
        String id = ApexPages.currentPage().getParameters().get('authorization_code');
        system.assertEquals(true,id!=null);
        
        User oUser = [select id,Draup_Token__c from user where lastname='Testing'];
        User oUser1 = [select id,Draup_Token__c from user where lastname='Testing_1'];
        String jsonMsg = '{"token":"7xyuXDFJFQUpFfLm0HlP4k5MPged2R"}';

        system.runas(oUser){

            DraupAuthentication oDraupAuthentication = new DraupAuthentication();
            
            system.Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator(jsonMsg,201));
            //oDraupAuthentication.getAccessToken();
            //HttpResponse res = '{"client_secret":"7xyuXDFJFQUpFfLm0HlP4k5MPged2R","client_id":"LrsbVPInllh2dMoPar0g2rsABVkKkL","authorization_code":"afdhkfsdhkafjhaklfhkjk"}';

        }
        system.runas(oUser1){
           
            DraupAuthentication oDraupAuthentication = new DraupAuthentication();
            oDraupAuthentication.getAccessToken();
            
        } 
        
        system.Test.stopTest();
    }
}