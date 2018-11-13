public with sharing class DraupTestUtility {
    public static id createAccount(){
        
        Account a = new Account();
        a.Name ='Barclays PLC';
        a.BillingCity ='San Francisco';
        a.BillingCountry = 'US';
        a.BillingPostalCode ='94087';
        a.BillingState = 'CA';
        a.draupApp__Draup_Id__c ='221167';
         a.draupApp__Draup_Account_Name__c ='Persistent';
        Database.Insert(a);
        return a.id;
    }
    public static id createLead(){
        
        Lead l = new lead();
        l.FirstName ='Amir';
        l.LastName ='Simon';
        l.Status='Open - Not Contacted';
        l.company='IBM';
        l.draupApp__Draup_Id__c='28992';
        Database.Insert(l);
        return l.id;
    }
     public static id createContact(){
        
        Contact con = new contact();
        con.FirstName ='Amir';
        con.LastName ='Simon';
        con.draupApp__Draup_Id__c='28992';
        Database.Insert(con);
        return con.id;
    }
    
    public static Lead createLead(String lastname,String draupId){
        
        Lead l = new lead();
        l.FirstName ='Amir';
        l.LastName =lastname;
        l.Status='Open - Not Contacted';
        l.company='IBM';
        l.draupApp__Draup_Id__c=draupId;
        Database.Insert(l);
        return l;
    }
      public static contact createContact(String lastname,String draupId){
        
      Contact con = new contact();
        con.FirstName ='Amir';
        con.LastName =lastname;
        con.draupApp__Draup_Id__c= draupId;
        Database.Insert(con);
        return con;
    }
    
  /* public static DraupChild__c CreateDraupChildWithRecordType(Lead led, string recordType){
        
      DraupHeader__c draupHeader = new DraupHeader__c();
      draupHeader.Lead__c = led.Id;
      draupHeader.Draup_Id__c = led.Draup_Id__c;
      //draupHeader.Name  ='DH-004474';
      Id recordTypeId = Schema.SObjectType.DraupHeader__c.getRecordTypeInfosByName().get(recordType).getRecordTypeId();
      draupHeader.RecordTypeId = recordTypeId;
      draupHeader.Type__c = 'Universe';
      Insert draupHeader;
      
      DraupChild__c draupChild = new DraupChild__c();
      draupChild.CompanyName__c = 'PSA';
      draupChild.DraupHeader__c = draupHeader.id;
      draupChild.Role__c = 'VP Safety & Functional Architecture & Chef de Projet Reorganisation R&D';
      draupChild.date__c = '2017-10-10 - To Present'; 
       draupChild.expOrder__c = 0;
       draupChild.date__c = '2014-10-10 - 2017-10-09'; 
       draupChild.expOrder__c = 1;
      Insert draupChild;
      
      return draupChild;
      
    }*/
    public static List<DraupChild__c> createDraupChildList(contact con){
        
      DraupHeader__c draupHeader = new DraupHeader__c();
      List<DraupHeader__c> headerList = new List<DraupHeader__c>();  
          List<DraupChild__c> childList = new List<DraupChild__c>();  
      //draupHeader.Name  ='DH-004474';
      Id recordTypeId = Schema.SObjectType.DraupHeader__c.getRecordTypeInfosByName().get('Overview').getRecordTypeId();
      Id recordTypeId1 = Schema.SObjectType.DraupHeader__c.getRecordTypeInfosByName().get('Experience').getRecordTypeId();
      Id recordTypeId2 = Schema.SObjectType.DraupHeader__c.getRecordTypeInfosByName().get('Draup Psychological Analysis').getRecordTypeId();
     headerList.add(new DraupHeader__c(RecordTypeId = recordTypeId,Draup_Id__c = con.Draup_Id__c,contact__c = con.Id,Type__c = 'Rolodex'));
     headerList.add(new DraupHeader__c(RecordTypeId = recordTypeId1,Draup_Id__c = con.Draup_Id__c,contact__c = con.Id,Type__c = 'Rolodex'));
     headerList.add(new DraupHeader__c(RecordTypeId = recordTypeId2,Draup_Id__c = con.Draup_Id__c,contact__c = con.Id,Type__c = 'Rolodex'));
    
      Database.Insert(headerList);
      
      DraupChild__c draupChild = new DraupChild__c();
      draupChild.CompanyName__c = 'PSA';
      draupChild.DraupHeader__c = draupHeader.id;
      draupChild.Role__c = 'VP Safety & Functional Architecture & Chef de Projet Reorganisation R&D';
       childList.add(new DraupChild__c(CompanyName__c='PSA',DraupHeader__c = headerList.get(0).id,Role__c='VP Safety & Functional Architecture & Chef de Projet Reorganisation R&D'));
       // childList = new List<DraupChild__c>();  
     childList.add(new DraupChild__c(DraupHeader__c = headerList.get(1).id,date__c = '2017-10-10 - To Present',expOrder__c = 0));
     childList.add(new DraupChild__c(DraupHeader__c = headerList.get(1).id,date__c = '2014-10-10 - 2017-10-09',expOrder__c = 1));
        //childList = new List<DraupChild__c>();  
        childList.add(new DraupChild__c(DraupHeader__c = headerList.get(2).id));
   
      Database.Insert(childList);
      
      return childList;
      
    }
    
    public static List<DraupChild__c> createDraupChildList(Lead led){
        
      DraupHeader__c draupHeader = new DraupHeader__c();
      List<DraupHeader__c> headerList = new List<DraupHeader__c>();  
          List<DraupChild__c> childList = new List<DraupChild__c>();  
      //draupHeader.Name  ='DH-004474';
      Id recordTypeId = Schema.SObjectType.DraupHeader__c.getRecordTypeInfosByName().get('Overview').getRecordTypeId();
      Id recordTypeId1 = Schema.SObjectType.DraupHeader__c.getRecordTypeInfosByName().get('Experience').getRecordTypeId();
      Id recordTypeId2 = Schema.SObjectType.DraupHeader__c.getRecordTypeInfosByName().get('Draup Psychological Analysis').getRecordTypeId();
     headerList.add(new DraupHeader__c(RecordTypeId = recordTypeId,Draup_Id__c = led.Draup_Id__c,Lead__c = led.Id,Type__c = 'Rolodex'));
     headerList.add(new DraupHeader__c(RecordTypeId = recordTypeId1,Draup_Id__c = led.Draup_Id__c,Lead__c = led.Id,Type__c = 'Rolodex'));
     headerList.add(new DraupHeader__c(RecordTypeId = recordTypeId2,Draup_Id__c = led.Draup_Id__c,Lead__c = led.Id,Type__c = 'Rolodex'));
    
      Database.Insert(headerList);
      
      DraupChild__c draupChild = new DraupChild__c();
      draupChild.CompanyName__c = 'PSA';
      draupChild.DraupHeader__c = draupHeader.id;
      draupChild.Role__c = 'VP Safety & Functional Architecture & Chef de Projet Reorganisation R&D';
       childList.add(new DraupChild__c(CompanyName__c='PSA',DraupHeader__c = headerList.get(0).id,Role__c='VP Safety & Functional Architecture & Chef de Projet Reorganisation R&D'));
        //childList = new List<DraupChild__c>();  
     childList.add(new DraupChild__c(DraupHeader__c = headerList.get(1).id,date__c = '2017-10-10 - To Present',expOrder__c = 0));
     childList.add(new DraupChild__c(DraupHeader__c = headerList.get(1).id,date__c = '2014-10-10 - 2017-10-09',expOrder__c = 1));
       // childList = new List<DraupChild__c>();  
        childList.add(new DraupChild__c(DraupHeader__c = headerList.get(2).id));
   
      Database.Insert(childList);
      
      return childList;
      
    }
   /* public static List<DraupChild__c> CreateDraupChildExperienceList(Lead led){
         List<DraupHeader__c> headerList = new List<DraupHeader__c>();  
          List<DraupChild__c> childList = new List<DraupChild__c>();  
        Id recordTypeId = Schema.SObjectType.DraupHeader__c.getRecordTypeInfosByName().get('Experience').getRecordTypeId();
     
         headerList.add(new DraupHeader__c(RecordTypeId = recordTypeId,Draup_Id__c = led.Draup_Id__c,Lead__c = led.Id,Type__c = 'Rolodex'));
   insert headerList;
    childList.add(new DraupChild__c(DraupHeader__c = headerList.get(0).id,date__c = '2017-10-10 - To Present',expOrder__c = 0));
     childList.add(new DraupChild__c(DraupHeader__c = headerList.get(0).id,date__c = '2014-10-10 - 2017-10-09',expOrder__c = 1));
        insert childList;
        return childList;
    }*/
    
      
    public static account createAccount(string name,string draupId){
        
        Account a = new Account();
        a.Name = name;
        a.BillingCity ='San Francisco';
        a.BillingCountry = 'US';
        a.BillingPostalCode ='94087';
        a.BillingState = 'CA';
        a.Draup_Id__c = draupId;
        Database.Insert(a);
        return a;
    }
    
    public static DraupChild__c createDraupChild(Account acc){
        
      DraupHeader__c draupHeader = new DraupHeader__c();
      draupHeader.Account__c = acc.Id;
      draupHeader.Draup_Id__c = acc.Draup_Id__c;
      //draupHeader.Name  ='DH-004474';
      Id recordTypeId = Schema.SObjectType.DraupHeader__c.getRecordTypeInfosByName().get('Overview').getRecordTypeId();
      draupHeader.RecordTypeId = recordTypeId;
      draupHeader.Type__c = 'Universe';
      Database.Insert(draupHeader);
      
      DraupChild__c draupChild = new DraupChild__c();
      draupChild.CompanyName__c = 'PSA';
      draupChild.DraupHeader__c = draupHeader.id;
      draupChild.Role__c = 'VP Safety & Functional Architecture & Chef de Projet Reorganisation R&D';
      
      Database.Insert(draupChild);
      
      return draupChild;
      
    }

    public static DraupChild__c createDraupChildWithRecordType(Account acc, string recordType){
        
      DraupHeader__c draupHeader = new DraupHeader__c();
      draupHeader.Account__c = acc.Id;
      draupHeader.Draup_Id__c = acc.Draup_Id__c;
      //draupHeader.Name  ='DH-004474';
      Id recordTypeId = Schema.SObjectType.DraupHeader__c.getRecordTypeInfosByName().get(recordType).getRecordTypeId();
      draupHeader.RecordTypeId = recordTypeId;
      draupHeader.Type__c = 'Universe';
      Database.Insert(draupHeader);
      
      DraupChild__c draupChild = new DraupChild__c();
      draupChild.CompanyName__c = 'PSA';
      draupChild.DraupHeader__c = draupHeader.id;
      draupChild.ExecutiveName__c='Test User';
      draupChild.Designation__c='manager';
      draupChild.Location__c='Test';
      draupChild.Type__c='Universe';
      draupChild.Role__c = 'VP Safety & Functional Architecture & Chef de Projet Reorganisation R&D';
      
      Database.Insert(draupChild);
      
      system.debug('<<<<<draupHeader>>>>>'+draupHeader);
      
      return draupChild;
      
    }
    
   
    
  
}