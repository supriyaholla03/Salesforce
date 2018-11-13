@isTest
public class DraupContactControllerTest {
      @testSetup
    static void testSetupData(){
        
        Account acc = new Account();
        acc.id = DraupTestUtility.CreateAccount();
       
         Contact con = new contact();    
          con.id=  DraupTestUtility.CreateContact();
          con.AccountId = acc.id;
          update con;
        contact con1 = new contact();
        con1.FirstName ='fname';
        con1.LastName ='lanam';
        con1.Draup_Id__c= null;
        
        insert con1;
        
         clientAuthDetails__c oAuthD = new clientAuthDetails__c();
        oAuthD.Name = 'Auth';
        oAuthD.draupApp__clientId__c= 'dfhaklfahglkajglkjg';
        oAuthD.draupApp__clientSecret__c='agajgkajglkajglajg';
        oAuthD.draupApp__SuperUserProfile__c ='System Administrator';
        oAuthD.draupApp__SyncHour__c='24';
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
         CryptoKeys__c oCryptoKeys = new CryptoKeys__c();
        oCryptoKeys.Name = 'Key';
        oCryptoKeys.Key__c='ahskljlskjjalsdkjlkdjlksdjlasdss';
        insert oCryptoKeys;
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
                              Draup_Token__c='tMGWTGUCMM3ae65ic82tmsdmvon4fGUs9U8T4Qrdl+XZZKFzT+6SM8oT5R46cY9ujJ5W0QyuTM1IypVf4QIQguvWqBVVGJEYkjcAjVblnA6kDQrE7i6zUz52rzTa2MEjELEGppSJzHW9QcO4WHawHQ==');
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
        
       
             
        List<DraupHeader__c> draupHeaderList = new List<DraupHeader__c>();
        Id recordTypeId = Schema.SObjectType.DraupHeader__c.getRecordTypeInfosByName().get('Overview').getRecordTypeId();
        Id recordTypeId1 = Schema.SObjectType.DraupHeader__c.getRecordTypeInfosByName().get('Experience').getRecordTypeId();
        Id recordTypeId2 = Schema.SObjectType.DraupHeader__c.getRecordTypeInfosByName().get('Draup Psychological Analysis').getRecordTypeId();
        system.debug('con.Id**'+con.Id);
        draupHeaderList.add(new DraupHeader__c(contact__c=con.Id,Draup_Id__c='1234',RecordTypeId=recordTypeId,Type__c='Rolodex'));
        draupHeaderList.add(new DraupHeader__c(contact__c=con.Id,Draup_Id__c='1234',RecordTypeId=recordTypeId1,Type__c='Rolodex'));
         draupHeaderList.add(new DraupHeader__c(contact__c=con.Id,Draup_Id__c='1234',RecordTypeId=recordTypeId2,Type__c='Rolodex'));
        insert draupHeaderList;
        
        DraupChild__c draupChild=new DraupChild__c(DraupHeader__c=draupHeaderList.get(0).id,ExecutiveName__c='Test User',Designation__c='manager');
        DraupChild__c draupChild1=new DraupChild__c(DraupHeader__c=draupHeaderList.get(1).id,ExecutiveName__c='Test User2',Designation__c='manager2');
        DraupChild__c draupChild2=new DraupChild__c(DraupHeader__c=draupHeaderList.get(2).id,ExecutiveName__c='Test User3',Designation__c='manager3');
        insert draupChild;
        insert draupChild1;
        insert draupChild2;
    }
        
    @isTest static void testContactData(){
         system.Test.startTest();
        String matchDraupResponse = '[\n'+
        '{"bio": null,"executive_id": "4676","account": "IBM","location": "Austin, Texas Area, United States","executive_name": "Amir Simon"\n'+
        '}\n';
       String jsonString = '{\n'+
            '"overview": [{  "key_vendors": [" "," "],"subverticals": [ "","" ],"budget_control": "LOW","deal_size_influencce": "LOW","location": "Greater Seattle Area, United States", "business_unit": "King", "image_link": "http://pbs.twimg.com/profile_images/116369133/mugshot_normal.jpg",\n'+
                            '"contact_details": null,"designation": "Senior Director", "opportunity_index": 2.2 } ],\n'+
           '"experiences": [{"end_date": null,"designation": "Vice President Power Software Development","account_name": "IBM","start_date": "2012-04-01"},{"end_date": "2012-04-01","designation": "Director, Power Firware Development","account_name": "International Business Machines","start_date": "2007-09-01"}]\n'+
           '}\n';
           /*+
           '"psychological_analysis": {"personalities":["Resilient","Challenge Driven","Methodical"], "interests": [{"Actor":["Jerry Seinfeld" ]},{"Government Agency":["Seattle Police Dept."]},{"News Media": ["The Seattle Times", "KING 5 News"]  },{"Fun":["The Onion"]}],\n'+
            '"engagement_guidelines": ["Questions pertaining to the product/service are most likely to be associated with its performance, durability, endurance capacity, functional longevity, etc. Hence, it is better to have all pertinent details about these aspects.\r", "Give examples through specific case studies, on how a particular solution can be offered for their precise requirements.\r","Context gives them clarity. Mention various contexts at which your solutions are applicable.\r"]}';
            */
        String draupId = '1234';
        User oUser = [select id,Draup_Token__c from user where lastname='Testing'];
        contact con=[select id,name from contact where FirstName='Amir'];
           system.runas(oUser){
               
           DraupHeader__c dh=[select id,Draup_Id__c,Type__c,LastModifiedDate from DraupHeader__c where Draup_Id__c='1234'  limit 1];
               List<DraupHeader__c> dhl = new List<DraupHeader__c>();

               
           contact con1 = [Select id from contact where Draup_Id__c=null];
           system.Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator(matchDraupResponse,200));
            DraupContactController.MatchDraup(con.Id);
            //system.Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator(matchDraupResponse,200));
            User us = DraupContactController.fetchUser();
               system.assertEquals(us.Name, 'Testing');
            system.Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator(jsonString,200));
           // DraupRolodexController.checkDraupRoledexDataExists(l1.Id,draupId,false);
            //DraupRolodexController.checkDraupRoledexDataExists(l.Id,draupId,false);
            
            DraupContactController.displayDraupData(con.Id,draupId,true);
            //DraupRolodexController.insertRolodexData(l.Id,draupId,dhl);
           // system.Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator(jsonString,200));
             
            DraupContactController.queryParametersForAuthentication();
           // DraupRolodexController.getLastModDate('1234',l.Id);
           // Boolean b=DraupRolodexController.removeRolodexData(l.Id,draupId);
           // DateTime dt = System.today();
            //DraupRolodexController.getDateBasedOnTimezone(dt);
            
            Boolean b = DraupContactController.checkAccountlinkedStatus(con.Id,draupId);
           
           
           system.Test.stopTest();
        }

    }
    
    @isTest static void testMethoddisplayDraupData(){
    
     contact con = new contact();    
      con =  DraupTestUtility.CreateContact('Barclay','221165');
       List<DraupChild__c> childList = DraupTestUtility.createDraupChildList(con);
        system.assertEquals(4, childList.size());
      DraupContactController.displayDraupData(con.Id,con.Draup_Id__c,true);
    }
    
    @isTest static void testMethoddisplayDraupDataWithoutDraup(){
    
     contact con = new contact();  
      con =  DraupTestUtility.CreateContact('Barclay',null);
       List<DraupChild__c> childList = DraupTestUtility.createDraupChildList(con);
        system.assertEquals(4, childList.size());
      DraupContactController.displayDraupData(con.Id,con.Draup_Id__c,true);
    }
    
    @isTest static void testMethodgetLastModDate(){
         system.test.startTest();
         contact con = new contact();    
        con =  DraupTestUtility.CreateContact('Barclay','221168');
        

        LIst<DraupChild__c> drp = DraupTestUtility.createDraupChildList(con);
        system.assertEquals(4, drp.size());
        DraupContactController.getLastModDate('221168',con.Id);
        system.test.stopTest();
    }
    
     @isTest static void testMethodremoveRolodexData(){
        system.test.startTest();
        contact con = new contact();    
        con =  DraupTestUtility.createContact('Barclay','221168');
        

        LIst<DraupChild__c> drp = DraupTestUtility.createDraupChildList(con);
        
       boolean bStatus = DraupContactController.removeRolodexData(con.Id,'221168');
           system.assertEquals(true, bStatus);
         system.test.stopTest();
    }
    
    @isTest static void testMethodSyncRolodexData(){
     Contact con = new Contact();    
    con =  DraupTestUtility.createContact('Barclay','221168');
    boolean b=  DraupContactController.syncRolodexData(con.Id,con.Draup_Id__c);
         System.assertEquals(true,b);
        
    }
    
     @isTest static void testMethodinsertRolodexData(){
        system.test.startTest();
        contact con = new contact();    
        con =  DraupTestUtility.createContact('Barclay','221168');
        

        LIst<DraupChild__c> drp = DraupTestUtility.createDraupChildList(con);
        List<DraupHeader__c> draupHeaderDeleteList = null;
        DraupContactController.insertRolodexData(con.Id,'221168',draupHeaderDeleteList);
        system.assertEquals(4,drp.size());
         system.test.stopTest();
    }

}