/**************************************************************************************************************
*   @author         Persistent Systems
*   @date           17/10/2018
*   @description    This class is used for future callout to insert universe and rolodex data in SF custom objects 
***************************************************************************************************************/
public with sharing class ConvertedDraupAccount {
    /*************************************************************************
* @description   Method to insert universe draup data
* @author        Persistent Systems
* @date          17/10/2018
* @parameter     String recordId,String draupId
* @return        void
**************************************************************************/
    @future(callout=true)
    public static void insertUniverseData(String recordId,String draupId)
    {
        String endpoint;
        system.debug('draupId after'+draupId);
        Account acc =getAccount(recordId);
        DraupEndPoints__c accountAllDetailsEndPoint = DraupEndPoints__c.getValues('AccountAllDetailsEndPoint');
        System.debug(' Label.RolodexSearchEndPoint **' + accountAllDetailsEndPoint);
        endpoint = System.Label.Draup_Platform_Url+accountAllDetailsEndPoint.End_Point_Url__c+draupId;
        acc.Draup_Id__c = draupId;
      
        try{
            HttpRequest httpReq = new HttpRequest();
            httpReq.setEndpoint(endpoint);
            httpReq.setMethod('GET');
            httpReq.setHeader('Accept', 'application/json');
            String userAccessToken = getDecryptedToken();
            httpReq.setHeader('Authorization', 'Bearer '+userAccessToken);
            httpReq.setHeader('Cache-Control', 'no-cache');
            httpReq.setHeader('Content-Type', 'application/json');
            httpReq.setTimeout(120000);
            
            http httpObj = new http();
            
            httpResponse response;
            string result ;
            Integer statusCode ;
            
            if(!System.Test.isRunningTest()){
                response = httpObj.send(httpReq);
                result = response.getBody();
                statusCode = response.getStatusCode();
                System.debug('response :: '+response);
            }else{
                statusCode = 200;
                result = '{\n'+
                    '"techstack": {"IT Service Management (ITSM)": ["Nagios","Webpack"],"Operations Management": ["Microsoft Dynamics GP"]},\n'+
                    '"overview": {"rnd_spend_growth": 2.67,"rnd_spend": 13037,"total_it_workforce": 58790,"total_rnd_workforce": 35390,"headquarters": "Greater Seattle Area, United States","opportunity_index": 4.47024888234089},\n'+
                    '"hiring": {"Coventry, United Kingdom": {"titles": {"AI Programmer": 1,"Senior UI/UX Engineer": 1},"skills": {"hardware": 1,"qa": 1}},\n'+
                    '"Beijing Area, China": {"titles": {"Graphic Designer": 1,"Senior Software Engineer": 6},"skills": {"iot": 1,"bigdata": 1}}},\n'+
                    '"executive_movement": [{"title": "Chief Technology Officer","executive_name": "Sven Oftedal","flux_date": "2018-08-30T12:00:00", "flux_type": "EXIT"},\n'+
                    '{"title": "Executive Vice President, Windows and Devices Group","executive_name": "Terry Myerson","flux_date": "2018-08-30T12:00:00","flux_type": "EXIT"},\n'+
                    '{"title": "Studio Head, The Initiative","executive_name": "Darrell Gallagher","flux_date": "2018-04-15T12:00:00","flux_type": "HIRED"}],\n'+
                    '"outsourcing": {"locations": [ "Greater Seattle Area, United States","Hyderabad Area, India","Beijing Area, China","Bengaluru Area, India","National Capital Region, India","Chennai Area, India","Pune Area, India"],\n'+
                    '"vendors": ["Accenture","HCL"],\n'+
                    '"subverticals": ["Software Testing","UI/UX Design"]\n'+
                    '},\n'+
                    '"globalization": {"R&D": \n'+
                    '[{"vendors": ["Accenture","Adisys Corporation"],"location_class": "Headquarter","headcount": 21000, "site_class": "R&D","subverticals": ["Cloud Engineering","Big Data Engineering"],"location": "Greater Seattle Area, United States","country": "United States of America"},\n'+
                    '{ "vendors": ["Accenture","Capgemini"],"location_class": "Satellite","headcount": 1650, "site_class": "R&D","subverticals": [ "Cloud Engineering","Big Data Engineering"],"location": "Hyderabad Area, India","country": "India"}],\n'+
                    '"IT": [\n'+
                    '{"vendors": ["Accenture","Capgemini"], "location_class": null,"headcount": 2205,"site_class": "IT","subverticals": ["Information Technology"],"location": "Hyderabad Area, India","country": "India"}\n'+
                    ']\n'+
                    '}\n,'+
                    '"startegic_signals": [{\n'+
                    '"news_title": "Biogen, Microsoft gain; PriceSmart, Silicon Motion fall","news_url": "https://www.washingtonpost.com/business/biogen-microsoft-gain-pricesmart-silicon-motion-fall/2018/07/06/c5ce02ba-815c-11e8-b3b5-b61896f90919_story.html","signal_type": "Financial and Market Activity","date_captured": "2018-07-06T00:00:00"\n'+
                    '}\n'+
                    ']\n'+
                    '}\n';
            }
            
            if(statusCode == 200)
            {
                List<DraupHeader__c> draupHeaderList = new List<DraupHeader__c>();
                Map<Id,List<DraupChild__c>> draupHeaderChildMap = DraupAccountResponseParser.parseJsonResponseForAccount(result,draupHeaderList,recordId,draupId);
                  if(draupHeaderChildMap!=null && draupHeaderChildMap.size() > 0 ){
                    system.debug('draupHeaderList::'+draupHeaderList.size());
                    Database.insert(draupHeaderList);
                    Map<Id,Id> draupHeaderResMap = new Map<Id,Id>();
                    for (DraupHeader__c dh : draupHeaderList)
                    {
                        draupHeaderResMap.put(dh.RecordTypeId,dh.Id);
                    }
                    system.debug('draupHeaderResMap::'+draupHeaderResMap);
                    List<DraupChild__c> draupChildFinalList = new List<DraupChild__c>();
                    
                    for(Id recordTypeId : draupHeaderChildMap.keyset()){
                        for (DraupChild__c dc : draupHeaderChildMap.get(recordTypeId))
                        {
                            system.debug('dc id::'+recordTypeId+'::'+draupHeaderResMap.get(recordTypeId));
                            dc.DraupHeader__c=draupHeaderResMap.get(recordTypeId);
                            draupChildFinalList.add(dc);
                        }
                        
                    }
                    system.debug('draupChildList::'+draupChildFinalList.size());
                    if(draupChildFinalList.size() > 0){
                        Database.insert(draupChildFinalList);
                    }
                    Database.update(acc);
                }
            }
            else{
                system.debug('Bad Response'+response.getbody());
            }
            
        }catch(exception ex)
        {
            System.debug('Message '+ ex.getMessage()+'line number '+ex.getLineNumber());
        }
    }
    
/*************************************************************************
* @description   Method to get account object details based on recordId
* @author        Persistent Systems
* @date          17/10/2018
* @parameter     String recordId
* @return        Account
**************************************************************************/

    public static Account getAccount(String recordId){
        Account acc = Database.query('Select id, name,draup_Id__c from account where id = :recordId');
        return acc;
    } 
    
 /*************************************************************************
* @description   Method to get decrypted JWT token
* @author        Persistent Systems
* @date          17/10/2018
* @parameter     String recordId
* @return        String
**************************************************************************/ 
     private static String getDecryptedToken(){
        String userId =userInfo.getUserId();
        User u =Database.query ('select id,Name,Draup_Token__c,ExpiryDate__c,profile.name from User where id =:userId');
        String accessToken = DraupEncryptUtil.getDecryptedValue(u.Draup_Token__c);
        return accessToken;
    } 
 /*************************************************************************
* @description   Method to insert rolodex draup data
* @author        Persistent Systems
* @date          17/10/2018
* @parameter     String recordId,String executiveId
* @return        void
**************************************************************************/
    @future(callout=true)
    public static void insertRolodexData(String recordId,String executiveId)
    { 
        try{
        system.debug('From rolodex insertion*******');
        Contact con = getContact(recordId);
        con.Draup_Id__c= executiveId;
        Http http = new Http();
        HttpRequest request = new HttpRequest();
       // String token = Database.query('Select id,Draup_Token__c From User Where Id = :UserInfo.getUserId()][0].Draup_Token__c');
        String tokenValue = getDecryptedToken();
        //System.debug('tokenValue ' + tokenValue );
         DraupEndPoints__c rolodexAllSearchEndPoint = DraupEndPoints__c.getValues('RolodexAllDetailsEndPoint');
         System.debug(' Label.RolodexSearchEndPoint **' + rolodexAllSearchEndPoint);
        request.setEndpoint(System.Label.Draup_Platform_Url+rolodexAllSearchEndPoint.draupApp__End_Point_Url__c+executiveId);
        request.setMethod('GET');
        request.setHeader('authorization', 'Bearer '+tokenValue);
        request.setHeader('Content-Type', 'application/json');
        request.setHeader('Accept', 'application/json');
        request.setTimeout(120000);
        HttpResponse response;
        string responeBody;
        Integer statusCode;
        if(!system.Test.isrunningtest()){
          response = http.send(request);
          responeBody = response.getBody();
          statusCode = response.getStatusCode();
        }
        else{
            statusCode = 200;
            responeBody = '{\n'+
            '"overview": [{  "key_vendors": [" "," "],"subverticals": [ "","" ],"budget_control": "LOW","deal_size_influencce": "LOW","location": "Greater Seattle Area, United States", "business_unit": "King", "image_link": "http://pbs.twimg.com/profile_images/116369133/mugshot_normal.jpg",\n'+
                            '"contact_details": null,"designation": "Senior Director", "opportunity_index": 2.2 } ],\n'+
           '"experiences": [{"end_date": null,"designation": "Vice President Power Software Development","account_name": "IBM","start_date": "2012-04-01"},{"end_date": "2012-04-01","designation": "Director, Power Firware Development","account_name": "International Business Machines","start_date": "2007-09-01"}],\n'+
           '"psychological_analysis": {"personalities": ["Persuasive","Adaptable","Resilient"],"interests": [{"Government Agency": ["Élysée"]},{"Sports Team": ["Peugeot Sport","Olympique Lyonnais"]}],"engagement_guidelines": ["Questions pertaining to the product/service are most likely to be associated"]}\n'+
                '}\n';
        }
        if (statusCode == 200) 
        {
            Id recordTypeId ;
            system.debug('response'+responeBody);
            transient Map<String,Object> obj= (Map<String,Object>)JSON.deserializeUntyped(responeBody); 
            DraupLeadInfoWrapper lInfoWrapper = DraupLeadInfoWrapper.parse(responeBody);
            System.debug('lInfoWrapper ' + lInfoWrapper);
            List<DraupChild__c> lDraupChild = new List<DraupChild__c>();
            List<DraupHeader__c> lDraupHeader = new List<DraupHeader__c>();
           
            Map<Id,List<DraupChild__c>> mDraupHeaderChild = new Map<Id,List<DraupChild__c>>();
            if(obj.containsKey('experiences'))
            {
                List<Object> expl = DraupConstants.EXPERIENCES;
                      
                lDraupChild = new List<DraupChild__c>();
                recordTypeId = Schema.SObjectType.DraupHeader__c.getRecordTypeInfosByName().get(String.valueOf(expl.get(0))).getRecordTypeId();
                DraupHeader__c oDraupHeader = new DraupHeader__c(RecordTypeId = recordTypeId,Draup_Id__c=executiveId,Contact__c=recordId,Type__c='Rolodex',displayOrder__c=Integer.valueOf(expl.get(1)));
                lDraupHeader.add(oDraupHeader);
                list <DraupLeadInfoWrapper.Experiences> lExperiences = lInfoWrapper.Experiences;
                integer order = 0;
                for(DraupLeadInfoWrapper.Experiences var : lExperiences )
                {
                    DraupChild__c oDraupChild = new DraupChild__c () ;
                    oDraupChild.End__c = var.end_date != null ? Date.valueOf(var.end_date):null;
                    oDraupChild.Role__c =var.designation;
                    System.debug('var.designation; ' + var.designation);
                    oDraupChild.CompanyName__c= var.account_name;
                    String dayOrDate = var.start_date;
                    System.debug(' GGB dayOrDate  ' + dayOrDate );
                    List<String> dateParts = dayOrDate.split('-');
                    Datetime dateWithTime = Datetime.newInstance(Integer.valueOf(dateParts[0]), Integer.valueOf(dateParts[1]), Integer.valueOf(dateParts[2]));
                    oDraupChild.Start__c =var.start_date != null ? Date.valueOf(var.start_date):null;
                    dayOrDate = dateWithTime.format('MMMM,D,YYYY');
                    System.debug('GGB after format dayOrDate ' + dayOrDate);
                     oDraupChild.Date__c = (var.start_date != null ?formatDate(oDraupChild.Start__c):null )+ ' - ' + (var.end_date != null ? formatDate(oDraupChild.End__c):'To Present' );
                    oDraupChild.expOrder__c = order;
                    lDraupChild.add(oDraupChild);
                    order++;
                }
                
                mDraupHeaderChild.put(recordTypeId,lDraupChild);
                
            }
            
            if(obj.containsKey('overview'))
            {
                 List<Object> overviewl = DraupConstants.OVERVIEW;
                lDraupChild = new List<DraupChild__c>();
                recordTypeId = Schema.SObjectType.DraupHeader__c.getRecordTypeInfosByName().get(String.valueOf(overviewl.get(0))).getRecordTypeId();
                DraupHeader__c oDraupHeader = new DraupHeader__c(RecordTypeId = recordTypeId,Draup_Id__c=executiveId,contact__c=recordId,Type__c='Rolodex',displayOrder__c=Integer.valueOf(overviewl.get(1)));
                lDraupHeader.add(oDraupHeader);
                list <DraupLeadInfoWrapper.Overview> lOverview = lInfoWrapper.Overview;
                DraupChild__c oDraupChild = new DraupChild__c () ;
                for(DraupLeadInfoWrapper.Overview var : lOverview )
                {
                    oDraupChild.DealSizeInfluence__c = var.deal_size_influencce;
                    oDraupChild.BudgetControl__c = var.budget_control;
                    oDraupChild.OpportunityIndex__c = var.opportunity_index;
                    oDraupChild.Location__c = var.location;
                    oDraupChild.BusinessUnit__c = var.business_unit;
                    oDraupChild.ContactDetails__c = var.contact_details;
                    oDraupChild.Designation__c = var.designation;
                    oDraupChild.ExecutiveName__c= var.executive_name;
                  
                    system.debug('<<<<imageLink>>>'+var.image_link);
                    if(var.image_link !=null){
                        oDraupChild.ImageLink__c = var.image_link;
                    }else{
                        system.debug('<<<<imageLink  inside else>>>'+var.image_link);
                        string myUrl =PageReference.forResource('noImage').getUrl();
                        myUrl = myUrl.subString(0, myUrl.indexOf('?'));
                        string headerdata= URL.getSalesforceBaseUrl().toExternalForm();
                        string invalidIMG = headerdata+myUrl; 
                        system.debug('<<<<imageLink  inside else>>>'+invalidIMG );
                        oDraupChild.ImageLink__c =invalidIMG ;
                    }
                    String sVendors='';
                    Boolean bVendorsCheck=true;
                    if(var.key_vendors!=null){
                    for(String s : var.key_vendors)
                    {
                        if(!bVendorsCheck)
                        {
                            sVendors += ',';
                        }
                        sVendors += s;
                        bVendorsCheck = false;
                    }
                   }
                    oDraupChild.KeyVendorsEngaged__c = sVendors;
                    String sSubVerticles='';
                    Boolean bVerticlesCheck = true ;
                    for(String s : var.subverticals)
                    {
                        if(!bVerticlesCheck)
                        {
                            sSubVerticles +=',';
                        }
                        sSubVerticles += s;
                        bVerticlesCheck = false;
                    }
                    oDraupChild.SubVerticalsLead__c = sSubVerticles;
                    lDraupChild.add(oDraupChild);
                }
                mDraupHeaderChild.put(recordTypeId,lDraupChild);   
            }
            
            if(obj.containsKey('psychological_analysis'))
            {
                
                 List<Object> psychol = DraupConstants.PSYCHOLOGICAL_ANALYSIS;
                lDraupChild = new List<DraupChild__c>();
                recordTypeId = Schema.SObjectType.DraupHeader__c.getRecordTypeInfosByName().get(String.valueOf(psychol.get(0))).getRecordTypeId();
                DraupHeader__c oDraupHeader = new DraupHeader__c(RecordTypeId = recordTypeId,Draup_Id__c=executiveId,Contact__c=recordId,Type__c='Rolodex',displayOrder__c=Integer.valueOf(psychol.get(1)));
                lDraupHeader.add(oDraupHeader);
                DraupLeadInfoWrapper.Psychological_analysis  oPsychologicalAnalysis  = lInfoWrapper.psychological_analysis;
                Map<String,Object> mPsychologicalAnalysis = (Map<String,Object>)obj.get('psychological_analysis');
                if(mPsychologicalAnalysis!=null){
                List<Object> minterest = (List<Object>)mPsychologicalAnalysis.get('interests');
                Map<String,Object> minterests = new Map<String,Object>();
                String sInterests = '';
                String subStr = '';
                Boolean bInterestsCheck=true;
                
                for(Object value : minterest)
                {
                    minterests =(Map<String,Object>)value;
                    for(String interestsHeader : minterests.keySet() )
                    {
                        if(!bInterestsCheck)
                        {
                            sInterests += '<br/>';
                        }
                        List<Object>  interestValuesList =(List<Object>) minterests.get(interestsHeader);
                        Boolean bInterestsValue=true;
                        String values='';
                        for(Object s : interestValuesList)
                        {
                            String strValue = (String) s;
                            if(!bInterestsValue)
                            {
                                values +=', ';
                            }
                            values += strValue;
                            bInterestsValue = false;
                        }
                       /* String values;
                        for(String s : (List<String>)minterests.get(interestsHeader))
                        {
                            if(!bInterestsValue)
                            {
                                values +=',';
                            }
                           values += s;
                           bInterestsValue = false;
                        }*/
                        sInterests += interestsHeader + ' - ' +values;
                        bInterestsCheck = false;    
                    }
                    
                }
                System.debug(' sInterests ' + sInterests);
                System.debug(' subStr ' + subStr);
                String sEGuidelines = '';
                String sPersonalities = '';
                Boolean bcheck = true;
                Boolean bcheckeg = true;
                if(oPsychologicalAnalysis !=null)
                {
                    for(String s : oPsychologicalAnalysis.engagement_guidelines)
                    {
                        sEGuidelines += '<li>'+s+'</li>'; 
                    }
                    for(String s : oPsychologicalAnalysis.personalities)
                    {
                        if(!bcheck)
                        {
                            sPersonalities += ', ';
                        }
                        sPersonalities += s;
                        bcheck = false;  
                    }
                }
                DraupChild__c oDraupChild = new DraupChild__c () ;
                oDraupChild.EngagementGuidelines__c= sEGuidelines ;
                oDraupChild.PersonalityCharacteristics__c = sPersonalities;
                oDraupChild.Interests__c = sInterests;
                    
                lDraupChild.add(oDraupChild);
                mDraupHeaderChild.put(recordTypeId,lDraupChild);
              }     
            }
            System.debug('GGB  lDraupHeader' + lDraupHeader);
            if(lDraupHeader.size() > 0 ){
                Database.insert(lDraupHeader);
            }
            Map<Id,Id> draupHeaderResMap = new Map<Id,Id>();
            for (DraupHeader__c dh : lDraupHeader)
                {
                    draupHeaderResMap.put(dh.RecordTypeId,dh.Id);
                }
            List<DraupChild__c> lFinalDraupChild = new List<DraupChild__c>();
                for(Id iRecordTypeId : mDraupHeaderChild.keyset()){
                for (DraupChild__c dc : mDraupHeaderChild.get(iRecordTypeId))
                {
                    dc.DraupHeader__c=draupHeaderResMap.get(iRecordTypeId);
                    lFinalDraupChild.add(dc);
                }
               
                }
            if(lFinalDraupChild.size() > 0){
                Database.insert(lFinalDraupChild);
            }
                Database.update(con); 
             } 
        else
        {
            system.debug('Bad Response'+response.getbody());
            ExceptionHandler.logApexCalloutError('DraupContactController', 'insertRolodexData', response);
        }
        }   
      catch(Exception ex)
      {
          system.debug('Exception occured'+ex.getMessage()+ex.getLineNumber());
          ExceptionHandler.logApexError('DraupContactController', 'insertRolodexData', String.valueOf(ex.getLineNumber()) , ex.getStackTraceString());   
      }
            
       
    }
    
    /*public static void insertRolodex(String recordId,String draupId,List<DraupHeader__c> draupList){
        try{       
            List<DraupHeader__c> headerList = new List<DraupHeader__c>();
            List<DraupChild__c> draupChildFinalList = new List<DraupChild__c>();
            Map<String,List<DraupChild__c>> childRecordMap = new Map<String,List<DraupChild__c>>();
            for(DraupHeader__c dHeader : draupList){
                dHeader.Id = null;
                headerList.add(dHeader);
                childRecordMap.put(dHeader.RecordType.Name,dHeader.DraupChild_Details__r);
                system.debug('dHeader.DraupChild_Details__r**'+dHeader.DraupChild_Details__r);
            }
            insert headerList;
            system.debug('dHeader**'+headerList);
            for(DraupHeader__c dh : headerList){
                system.debug('dh**'+dh.Id);
                List<DraupChild__c> childList = childRecordMap.get(dh.RecordType.Name);
                for(DraupChild__c dc : childList){
                    dc.Id = null;
                    dc.draupApp__DraupHeader__c = dh.Id;
                    draupChildFinalList.add(dc);
                }
            }
            insert draupChildFinalList;
            Contact con =getContact(recordId);
            con.draupApp__Draup_Id__c = draupId;
            
            update con;
        }catch(Exception ex){
            system.debug('exception occured::'+ex.getStackTraceString());
        }
    }*/
    
    public static Contact getContact(string recordId){
         Contact con = Database.query('Select id, name,draup_Id__c from Contact where id = :recordId');
        return con;
    } 
    
    public static String formatDate(Date dt) {
        Datetime dt1 = datetime.newInstance(dt.year(), dt.month(),dt.day());
         String formattedDate = dt1.format('MMMMM,yyyy');
        return  formattedDate;
    }
}