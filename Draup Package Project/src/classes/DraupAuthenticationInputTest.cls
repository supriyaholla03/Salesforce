@isTest
private class DraupAuthenticationInputTest {
    @testSetup
    static void testSetupData(){
        clientAuthDetails__c oAuth = new clientAuthDetails__c();
        oAuth.Name = 'Auth';
        oAuth.draupApp__clientId__c= 'dfhaklfahglkajglkjg';
        oAuth.draupApp__clientSecret__c='agajgkajglkajglajg';
        insert oAuth;
        
        clientAuthDetails__c oAuth1 = new clientAuthDetails__c();
        oAuth1.Name = 'Auth';
        oAuth1.draupApp__clientId__c= 'test2';
        oAuth1.draupApp__clientSecret__c='test2';
        oAuth1.draupApp__SuperUserProfile__c= 'System Administrator';
        oAuth1.draupApp__SyncHour__c='2';
        insert oAuth1;
        
        clientAuthDetails__c oAuth3 = new clientAuthDetails__c();
        oAuth3.Name = 'gfgf';
        oAuth3.draupApp__clientId__c= '';
        oAuth3.draupApp__clientSecret__c='';
        oAuth3.draupApp__SuperUserProfile__c= '';
        oAuth3.draupApp__SyncHour__c='';

        insert oAuth3;
        
        
        
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
        
    }
    static testMethod void testAuthentication() {
        system.Test.startTest();
        User oUser = [select id,Draup_Token__c from user where lastname='Testing'];
        clientAuthDetails__c oAuth =clientAuthDetails__c.getValues('Auth');
        system.runas(oUser){
               DraupAuthenticationInput oDraupAuthenticationInput = new DraupAuthenticationInput ();
               oDraupAuthenticationInput.insertClientDetails();
        }        
        system.Test.stopTest();
    }
}