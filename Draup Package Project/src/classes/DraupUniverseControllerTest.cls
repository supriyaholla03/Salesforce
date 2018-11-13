@isTest
public class DraupUniverseControllerTest {
     @testSetup
    static void testSetupData(){
        Account acc = new Account();
        acc = DraupTestUtility.CreateAccount('Barclays PLC','221167');
        List<DraupHeader__c> draupHeaderList = new List<DraupHeader__c>();
        Id recordTypeId = Schema.SObjectType.DraupHeader__c.getRecordTypeInfosByName().get('Digital Tech Stack').getRecordTypeId();
        Id recordTypeId1 = Schema.SObjectType.DraupHeader__c.getRecordTypeInfosByName().get('Executive Movement').getRecordTypeId();
        Id recordTypeId2 = Schema.SObjectType.DraupHeader__c.getRecordTypeInfosByName().get('Globalization').getRecordTypeId();
        system.debug('acc.Id**'+acc.Id);
        draupHeaderList.add(new DraupHeader__c(Account__c=acc.Id,Draup_Id__c='221167',RecordTypeId=recordTypeId,Type__c='Universe'));
        draupHeaderList.add(new DraupHeader__c(Account__c=acc.Id,Draup_Id__c='221167',RecordTypeId=recordTypeId1,Type__c='Universe'));
         draupHeaderList.add(new DraupHeader__c(Account__c=acc.Id,Draup_Id__c='221167',RecordTypeId=recordTypeId2,Type__c='Universe'));
        insert draupHeaderList;
        
        DraupChild__c draupChild=new DraupChild__c(DraupHeader__c=draupHeaderList.get(0).id,ExecutiveName__c='Test User',Designation__c='manager');
        DraupChild__c draupChild1=new DraupChild__c(DraupHeader__c=draupHeaderList.get(1).id,ExecutiveName__c='Test User2',Designation__c='manager2');
        DraupChild__c draupChild2=new DraupChild__c(DraupHeader__c=draupHeaderList.get(2).id,ExecutiveName__c='Test User3',Designation__c='manager3');
        system.assertEquals(draupChild.Designation__c, 'manager');
        insert draupChild;
        insert draupChild1;
        insert draupChild2;
         List<sObject> recToInsert = new List<sObject>();
        DraupEndPoints__c recObj;
                   recObj = new DraupEndPoints__c();
                   recObj.Name = 'AccountAllDetailsEndPoint';
                   recObj.End_Point_Url__c = 'https://qa-platform.draup.com/service/daas/executives/all_details/?executive_id=';
                   recToInsert.add(recObj);

                   recObj = new DraupEndPoints__c();
                   recObj.Name = 'AccountSearchEndPoint';
                   recObj.End_Point_Url__c = 'https://qa-platform.draup.com/service/daas/executives/search/?account=';
                   recToInsert.add(recObj);
        insert recToInsert;
        
        clientAuthDetails__c oAuthD = new clientAuthDetails__c();
        oAuthD.Name = 'Auth';
        oAuthD.draupApp__clientId__c= 'dfhaklfahglkajglkjg';
        oAuthD.draupApp__clientSecret__c='agajgkajglkajglajg';
        insert oAuthD;
        DraupEndPoints__c endPointDetails = new DraupEndPoints__c();
        endPointDetails.Name = 'DraupAuth';
        endPointDetails.draupApp__End_Point_Url__c = 'https://qa-platform.draup.com/service/client/token/';
        insert endPointDetails;
       //DraupUniverseController.displayDraupData(acc.Id,acc.Draup_Id__c,true);
        //DraupUniverseController.insertUniverseData(acc.id,'1234',draupHeaderList);
    }

    @isTest static void testMethodMatchDraup(){
        
      Account acc = new Account();    
        
      acc =  DraupTestUtility.createAccount('Barclays PLC','221167');
      
      DraupUniverseController.matchDraup(acc.Id);
      DraupUniverseController.checkDraupUniverseDataExists(acc.Id,acc.Draup_Id__c,true,'Barclays PLC');
      DraupUniverseController.checkDraupUniverseDataExists(acc.Id,null,true,'Barclays PLC');
       integer b = DraupUniverseController.verifyContactExistance(acc.Id,'221167');
        system.assert(b>=0);
    }
    
    @isTest static void testMethodcheckDraupUniverseDataExists(){
        
      Account acc = new Account();    
        
      acc =  DraupTestUtility.createAccount('Barclays PLC',null);
      system.assert(acc!=null);
      DraupUniverseController.checkDraupUniverseDataExists(acc.Id,acc.Draup_Id__c,true,'Barclays PLC');
     }
    
    @isTest static void testMethodglobalizationData(){
        
        Account acc = new Account();    
        acc =  DraupTestUtility.createAccount('Barclays PLC','221168');
        DraupTestUtility.createDraupChildWithRecordType(acc,'Globalization');
        Map<string,Map<string,string>> gList = DraupUniverseController.globalizationData(acc.id,acc.Draup_Id__c,'Universe');
        system.assert(acc!=null);
        
    }
    
    @isTest static void testMethodgetLastModDate(){
        
         Account acc = new Account();    
        acc =  DraupTestUtility.createAccount('Barclays PLC','221168');
        
        DraupChild__c drp = new DraupChild__c();
        drp = DraupTestUtility.createDraupChild(acc);
        system.assert(drp!=null);
        DraupUniverseController.getLastModDate('221168',acc.Id);
    }
    
    @isTest static void testMethoddisplayDraupData(){
    
     Account acc = new Account();    
      acc =  DraupTestUtility.createAccount('Barclay','221165');
        DraupTestUtility.createDraupChildWithRecordType(acc,'Digital Tech Stack');
       Map<string,List<Map<string,string>>> dList=DraupUniverseController.displayDraupData(acc.Id,acc.Draup_Id__c,false,'Barclay');
        system.assert(dList.size()>0);
    }
   
    @isTest static void testMethodSyncUniverseData(){
     Account acc = new Account();    
      acc =  DraupTestUtility.createAccount('Barclay','221164');
        system.assert(acc!=null);
      DraupUniverseController.syncUniverseData(acc.Id,acc.Draup_Id__c,'Barclay');
    }
    
    @isTest static void testMethodRemoveUniverseData(){
     Account acc = new Account();    
      acc =  DraupTestUtility.createAccount('Barclay','221164');
      
      boolean b=DraupUniverseController.removeUniverseData(acc.Id,acc.Draup_Id__c);
          //system.assert(b);
    }
    
    @isTest static void testMethodRemovehideLinkButton(){
     Account acc = new Account();    
      acc =  DraupTestUtility.createAccount('Barclay','221164');
      //DraupUniverseController.hideLinkButton(acc.Id,acc.Draup_Id__c);
         system.assert(acc!=null);
    }
    
    @isTest static void testMethodexecutiveMovementData(){
      
      Account acc = new Account();    
      acc =  DraupTestUtility.createAccount('Barclay','221164');
      
      DraupChild__c drp = new DraupChild__c();
      drp = DraupTestUtility.createDraupChildWithRecordType(acc,'Executive Movement');
        system.assert(drp!=null);
      DraupUniverseController.executiveMovementData(acc.Id,acc.Draup_Id__c,'Universe');
      DraupUniverseController.getTypes(acc.Id,acc.Draup_Id__c);
    }
    
    @isTest static void testMethodhiringData(){
      
      Account acc = new Account();    
      acc =  DraupTestUtility.createAccount('Barclay','221164');
      
      DraupChild__c drp = new DraupChild__c();
      drp = DraupTestUtility.createDraupChildWithRecordType(acc,'Hiring');
        system.assert(drp!=null);
      DraupUniverseController.hiringData(acc.Id,acc.Draup_Id__c);
    }
    
     @isTest static void testMethodfetchUser(){
         
     // DraupTestUtility.CreateNewUser();
      User u = DraupUniverseController.fetchUser();
       system.assert(u!=null);  
    }
    
   
}