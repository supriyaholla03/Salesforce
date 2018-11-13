@isTest
public class DraupRolodexControllerTest {
       @testSetup
    static void testSetupData(){

         Lead l = new Lead();    
          l.id=  DraupTestUtility.CreateLead();
        Lead l1 = new Lead();
        l1.FirstName ='fname';
        l1.LastName ='lanam';
        l1.Status='Open - Not Contacted';
        l1.company='IBM';
        l1.Draup_Id__c= null;
        insert l1;
        
         clientAuthDetails__c oAuthD = new clientAuthDetails__c();
        oAuthD.Name = 'Auth';
        oAuthD.draupApp__clientId__c= 'dfhaklfahglkajglkjg';
        oAuthD.draupApp__clientSecret__c='agajgkajglkajglajg';
        insert oAuthD;
            DraupEndPoints__c endPointDetails = new DraupEndPoints__c();
            endPointDetails.Name = 'DraupAuth';
        endPointDetails.draupApp__End_Point_Url__c = 'https://qa-platform.draup.com/service/client/token/';
         insert endPointDetails;
        Map<String,ID> profiles = new Map<String,ID>();
        List<Profile> ps = [select id, name from Profile where  name = 'System Administrator'];
        for(Profile p : ps){
            profiles.put(p.name, p.id);
        }
         List<sObject> recToInsert = new List<sObject>();
        DraupEndPoints__c recObj;
                   recObj = new DraupEndPoints__c();
                   recObj.Name = 'RolodexAllDetailsEndPoint';
                   recObj.End_Point_Url__c = 'https://qa-platform.draup.com/service/daas/executives/all_details/?executive_id=';
                   recToInsert.add(recObj);

                   recObj = new DraupEndPoints__c();
                   recObj.Name = 'RolodexSearchEndPoint';
                   recObj.End_Point_Url__c = 'https://qa-platform.draup.com/service/daas/executives/search/?account=';
                   recToInsert.add(recObj);
        insert recToInsert;
        User oUser = new User(alias = 'standt_1', 
                              email='newTestUser@user.com', 
                              profileid = profiles.get('System Administrator'),  
                              emailencodingkey='UTF-8', 
                              lastname='Testing', languagelocalekey='en_US', 
                              localesidkey='en_US', 
                              username='newTestUser@user.com',
                              timezonesidkey='America/Los_Angeles',
                              Draup_Token__c='CoWVA9Kz54KQJOf825YoQaERX609qvvGjjJf3W0r6CLhHvk3lXfp2XGoFt9EIBMicucNqhOApKQwFzQjoBSG87pYxjkOL7AvRKf4XwDtUWNmRWwtrcD6qguda/A+qa5ctK6fgUAI7A42YipdCqKkaQ==');
        insert oUser;
        
         User oUser1 = new User(alias = 'standt_2', 
                              email='newTestUser1@user.com', 
                              profileid = profiles.get('System Administrator'),  
                              emailencodingkey='UTF-8', 
                              lastname='Testing_1', languagelocalekey='en_US', 
                              localesidkey='en_US', 
                              username='newTestUser1@user.com',
                              timezonesidkey='America/Los_Angeles',
                              Draup_Token__c=null);
        insert oUser1;
        
        CryptoKeys__c oCryptoKeys = new CryptoKeys__c();
        oCryptoKeys.Name = 'Key';
        oCryptoKeys.Key__c='ahskljlskjjalsdkjlkdjlksdjlasdss';
        insert oCryptoKeys;
        
              
        List<DraupHeader__c> draupHeaderList = new List<DraupHeader__c>();
        Id recordTypeId = Schema.SObjectType.DraupHeader__c.getRecordTypeInfosByName().get('Overview').getRecordTypeId();
        Id recordTypeId1 = Schema.SObjectType.DraupHeader__c.getRecordTypeInfosByName().get('Experience').getRecordTypeId();
        Id recordTypeId2 = Schema.SObjectType.DraupHeader__c.getRecordTypeInfosByName().get('Draup Psychological Analysis').getRecordTypeId();
        system.debug('l.Id**'+l.Id);
        draupHeaderList.add(new DraupHeader__c(Lead__c=l.Id,Draup_Id__c='1234',RecordTypeId=recordTypeId,Type__c='Rolodex'));
        draupHeaderList.add(new DraupHeader__c(Lead__c=l.Id,Draup_Id__c='1234',RecordTypeId=recordTypeId1,Type__c='Rolodex'));
         draupHeaderList.add(new DraupHeader__c(Lead__c=l.Id,Draup_Id__c='1234',RecordTypeId=recordTypeId2,Type__c='Rolodex'));
        insert draupHeaderList;
        
        DraupChild__c draupChild=new DraupChild__c(DraupHeader__c=draupHeaderList.get(0).id,ExecutiveName__c='Test User',Designation__c='manager');
        DraupChild__c draupChild1=new DraupChild__c(DraupHeader__c=draupHeaderList.get(1).id,ExecutiveName__c='Test User2',Designation__c='manager2');
        DraupChild__c draupChild2=new DraupChild__c(DraupHeader__c=draupHeaderList.get(2).id,ExecutiveName__c='Test User3',Designation__c='manager3');
        insert draupChild;
        System.assertEquals(draupChild.Designation__c,'manager');
        insert draupChild1;
        insert draupChild2;
    }
        
    @isTest static void testRolodexData(){
         system.Test.startTest();
        String matchDraupResponse = '[\n'+
        '{"bio": null,"executive_id": "4676","account": "IBM","location": "Austin, Texas Area, United States","executive_name": "Amir Simon"\n'+
        '}\n';
       String jsonString = '{\n'+
            '"overview": [{  "key_vendors": [" "," "],"subverticals": [ "","" ],"budget_control": "LOW","deal_size_influencce": "LOW","location": "Greater Seattle Area, United States", "business_unit": "King", "image_link": "http://pbs.twimg.com/profile_images/116369133/mugshot_normal.jpg",\n'+
                            '"contact_details": null,"designation": "Senior Director", "opportunity_index": 2.2 } ],\n'+
           '"experiences": [{"end_date": null,"designation": "Vice President Power Software Development","account_name": "IBM","start_date": "2012-04-01"},{"end_date": "2012-04-01","designation": "Director, Power Firware Development","account_name": "International Business Machines","start_date": "2007-09-01"}],\n'+
           '"psychological_analysis": {"personalities": ["Persuasive","Adaptable","Resilient"],"interests": [{"Government Agency": ["GendarmerieNationale","Élysée"]},{"Sports Team": ["Peugeot Sport","Olympique Lyonnais"]},{"News Media": ["CNN","Le Figaro"]}],\n'+ 
           '}';
            
        String draupId = '1234';
        User oUser = database.query('select id,Draup_Token__c from user where lastname=\'Testing\'');
        Lead l = database.query('select id,name from Lead where FirstName=\'Amir\'');
        
           system.runas(oUser){
               
           DraupHeader__c dh=database.query('select id,Draup_Id__c,Type__c,LastModifiedDate from DraupHeader__c where Draup_Id__c=\'1234\'  limit 1');
               List<DraupHeader__c> dhl = new List<DraupHeader__c>();
           Lead l1 = database.query('Select id from lead where Draup_Id__c=null');
           system.Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator(matchDraupResponse,200));
            DraupRolodexController.matchDraup(l.Id);
            DraupRolodexController.fetchUser();
            system.Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator(JsonString,200));
            DraupRolodexController.displayDraupData(l.Id,draupId,true);
            DraupRolodexController.queryParametersForAuthentication();
          DraupRolodexController.checkDraupRoledexDataExists(l.Id,draupId,True);
           system.Test.stopTest();
        }

    }
    
    @isTest static void testMethoddisplayDraupData(){
    
     Lead led = new Lead();    
      led =  DraupTestUtility.CreateLead('Barclay','221165');
       List<DraupChild__c> childList = DraupTestUtility.CreateDraupChildList(led);
         system.assertEquals(4, childList.size());
      DraupRolodexController.displayDraupData(led.Id,led.Draup_Id__c,true);
    }
    
    @isTest static void testMethodSyncUniverseData(){
     Lead led = new Lead();    
    led =  DraupTestUtility.CreateLead('Barclay','221165');
    boolean b=  DraupRolodexController.syncRolodexData(led.Id,led.Draup_Id__c);
         System.assertEquals(true,b);
        
    }
    @isTest static void testMethoddisplayDraupDataWithoutDraup(){
     Lead led = new Lead();    
      led =  DraupTestUtility.CreateLead('Barclay',null);
       List<DraupChild__c> childList = DraupTestUtility.CreateDraupChildList(led);
        system.assertEquals(4, childList.size());
      DraupRolodexController.displayDraupData(led.Id,led.Draup_Id__c,true);
    }
    
    @isTest static void testMethodgetLastModDate(){
         system.test.startTest();
         Lead led = new Lead();    
        led =  DraupTestUtility.CreateLead('Barclay','221168');
       LIst<DraupChild__c> drp = DraupTestUtility.CreateDraupChildList(led);
        system.assertEquals(4, drp.size());
        DraupRolodexController.getLastModDate('221168',led.Id);
        system.test.stopTest();
    }
    
     @isTest static void testMethodremoveRolodexData(){
        system.test.startTest();
         Lead led = new Lead();    
        led =  DraupTestUtility.CreateLead('Barclay','221168');
       

        LIst<DraupChild__c> drp = DraupTestUtility.CreateDraupChildList(led);
         system.assertEquals(4, drp.size());
        DraupRolodexController.removeRolodexData(led.Id,'221168');
         system.test.stopTest();
    }
    
     @isTest static void testMethodinsertRolodexData(){
        system.test.startTest();
         Lead led = new Lead();    
        led =  DraupTestUtility.CreateLead('Barclay','221168');
         LIst<DraupChild__c> drp = DraupTestUtility.createDraupChildList(led);
        List<DraupHeader__c> draupHeaderDeleteList = null;
        DraupRolodexController.insertRolodexData(led.Id,'221168',draupHeaderDeleteList);
        system.assertEquals(4,drp.size());
         system.test.stopTest();
    }
    
   /* @isTest static void testMethodOne(){
        
        DraupRolodexController.getUserFieldList();
        DraupRolodexController.getLeadFieldList();
        DraupRolodexController.getDraupChildFieldList();
    }*/
}