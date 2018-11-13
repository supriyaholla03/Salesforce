@isTest
private class ConvertedDraupAccountTest {
  @isTest static void testMethodInsertDraupData(){
       List<sObject> recToInsert = new List<sObject>();
        DraupEndPoints__c recObj;
                   recObj = new DraupEndPoints__c();
                   recObj.Name = 'RolodexAllDetailsEndPoint';
                   recObj.End_Point_Url__c = 'https://qa-platform.draup.com/service/daas/executives/all_details/?executive_id=';
                   recToInsert.add(recObj);

                   recObj = new DraupEndPoints__c();
                   recObj.Name = 'AccountAllDetailsEndPoint';
                   recObj.End_Point_Url__c = 'https://qa-platform.draup.com/service/daas/executives/all_details/?executive_id=';
                   recToInsert.add(recObj);
      insert recToInsert;
      
     Account acc = new Account();    
      acc =  DraupTestUtility.createAccount('Barclay','221165');
      Contact con = new Contact();    
      con =  DraupTestUtility.createContact('Barclay','221165');
        DraupTestUtility.createDraupChildWithRecordType(acc,'Digital Tech Stack');
     // DraupTestUtility.createCustomSettingForSyncHour();
       ConvertedDraupAccount.insertUniverseData(acc.Id,acc.draupApp__Draup_Id__c);
      ConvertedDraupAccount.insertRolodexData(con.Id,con.draupApp__Draup_Id__c);
        system.assert(acc!=null);
    }
}