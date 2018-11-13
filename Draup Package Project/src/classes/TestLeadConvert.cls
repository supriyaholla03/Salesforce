@IsTest (SeeAllData=true) private class TestLeadConvert {
    private static testMethod void trigTest() {
        
        // create a Lead
       Lead lead=new Lead(LastName='Doe',FirstName='John',Company='Test',Status='Inquiry',draupApp__AccDraupId__c='221167',draupApp__Draup_Id__c ='221167');
        insert lead;    
        
        system.test.startTest();
        Database.LeadConvert lc = new database.LeadConvert();
        Account acc=new Account(Name ='Barclays PLC',BillingCity ='San Francisco',BillingCountry = 'US',BillingPostalCode ='94087',BillingState = 'CA');
        insert acc;
        Contact con = new contact(FirstName ='Amir',LastName ='Simon',AccountId=acc.id);
       	insert con;
        lc.setLeadId(lead.id);
        lc.setAccountId(acc.id);
        lc.setContactId(con.id);
        lc.setOwnerId(lead.OwnerId);
        lc.setDoNotCreateOpportunity(false);
        LeadStatus convertStatus = [SELECT Id, MasterLabel FROM LeadStatus WHERE IsConverted=true LIMIT 1];
        lc.setConvertedStatus(convertStatus.MasterLabel);
       // Database.convertLead(lc);
        
        //lc.setConvertedStatus('Converted');

       
        Database.LeadConvertResult lcr = Database.convertLead(lc);
        System.assert(lcr.isSuccess());
        system.test.stopTest();
    }
    
}