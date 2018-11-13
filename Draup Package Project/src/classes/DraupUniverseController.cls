/**************************************************************************************************************
*   @author         Persistent Systems
*   @date           19/09/2018
*   @description    This class is used to get and Display  Universe information
***************************************************************************************************************/
public with sharing class DraupUniverseController{
    
    Public static list<DraupUniverseWrapper> draupUVList {get;set;}
    
/***************************************************************************************************
* @description   This method is used to get maching Universe Data from draup
* @author        Persistent Systems
* Params		 Id
* @date          19/09/2018
* @return        list<DraupUniverseWrapper>
****************************************************************************************************/
     
    @AuraEnabled
    public static list<DraupUniverseWrapper> matchDraup (id recordId)
    {
       
            //recordId= ApexPages.currentPage().getParameters().get('id');
            String sObjName='';
            system.debug('recordId======'+recordId);
            //system.debug('Start Load==='+DateTime.Now().format('YYYY-MM-DD hh:mm:ss.SSS'));
            sObjName = string.valueOf(recordId.getSObjectType().getDescribe().getName());
            system.debug('sObjName==='+sObjName);
            system.debug('Authorize::'+DraupAuthentication.draupAuthorize);
        	String endpoint;
            if(recordId != NULL) {
                
                if(sObjName != '' && sObjName =='Account'){
                    Account acc = Database.query('Select id, name from account where id = :recordId');
                    DraupEndPoints__c universeSearchEndPoint = DraupEndPoints__c.getValues('AccountSearchEndPoint');
                    System.debug(' Label.universeSearchEndPoint **' + universeSearchEndPoint);
                    endpoint= System.Label.Draup_Platform_Url+universeSearchEndPoint.draupApp__End_Point_Url__c+EncodingUtil.urlEncode(acc.Name,'UTF-8');
                    //System.debug('AccName:'+acc.Name);
                    //System.debug('endpoint:'+endpoint);
                }}
                 try{
                HttpRequest httpReq = new HttpRequest();
                httpReq.setEndpoint(endpoint);
                httpReq.setMethod('GET');
                httpReq.setHeader('Accept', 'application/json');
                 String userId =userInfo.getUserId();
                User userAccessToken = Database.query('Select id, Draup_Token__c from User where id=:userId');
                httpReq.setHeader('Authorization', 'Bearer '+getDecryptedToken());
                httpReq.setHeader('Cache-Control', 'no-cache');
                httpReq.setHeader('Content-Type', 'application/json');
                
                http httpObj = new http();
                httpResponse response;
                string result ;
                Integer statusCode ;
                if(!System.Test.isRunningTest()){
                      response = httpObj.send(httpReq);
                      result = response.getBody();
                      statusCode = response.getStatusCode();
                      System.debug('response :: '+response);
                }else
                {
                      statusCode = 200;
                      result = '[{"account_id": 1376414,"account_name": "MicroStrategy Inc"},{"account_id": 556516, "account_name": "Microchip Technology Inc."}]';
                }
                
                if(statusCode == 200)
                {
                    system.debug('inside Response');
                   
                    if(sObjName != '' && sObjName =='Account'){
                        draupUVList = (List<DraupUniverseWrapper>)System.JSON.deserialize(result,List<DraupUniverseWrapper>.class);
                        
                        system.debug('Debug for Dsiplaying all the records: DraupSugestions'+draupUVList);
                    }
                    
                }
                else{
                    system.debug('Bad Response'+response.getbody());
                    ExceptionHandler.logApexCalloutError('DraupUniverseController', 'matchDraup', response);
                }
            
            }catch(exception ex)
            {
                System.debug('Message '+ ex.getMessage()+'line number '+ex.getLineNumber());
				 ExceptionHandler.logApexError('DraupUniverseController', 'matchDraup', String.valueOf(ex.getLineNumber()) , ex.getStackTraceString());
            }
        
        return draupUVList;
    }
    
/***************************************************************************************************
* @description   Method to verify whether account linked with Draup or not.If not linked it will link with draup.
* @author        Persistent Systems
* Params		 Id,Draup Id, Boolean,Draup Accoun Name
* @date          19/09/2018
* @return        void
****************************************************************************************************/
    public static  void checkDraupUniverseDataExists(String recordId,String accId,boolean checkSync,String draupAccName){
         Map<string,List<Map<string,string>>> draupMap;
        try{
            List<DraupHeader__c> draupHeaderDeleteList;
            Account acc = getAccount(recordId);
            if(acc.draupApp__Draup_Id__c ==null){
                insertUniverseData(recordId, accId,draupHeaderDeleteList,draupAccName);
            }else{
                system.debug('from else');
                /*draupHeaderDeleteList = Database.query('Select id,Draup_Id__c,lastmodifieddate from DraupHeader__c where Draup_Id__c = :accId and Account__C = :recordId');  
                sync_time__c syncTime  = sync_time__c.getValues('Sync_hour');
                Integer syncHr = Integer.valueOf(syncTime.Sync_hour__c);*/
                clientAuthDetails__c clntAuthDetails = clientAuthDetails__c.getValues('Auth');
                Integer syncHr = (clntAuthDetails.draupApp__SyncHour__c != null ?Integer.valueOf(clntAuthDetails.draupApp__SyncHour__c):0);
                system.debug('syncHr**'+syncHr);
                datetime myDateTime = getDateBasedOnTimezone(datetime.now()).addHours(-syncHr);
                system.debug('### DateTime>>>'+myDateTime +'***'+getDateBasedOnTimezone(datetime.now()));
                if(draupHeaderDeleteList!=null){
                    system.debug('### lastmodifieddate>>>'+draupHeaderDeleteList.get(0).lastmodifieddate);
                    Datetime lastmodifieddate =	getDateBasedOnTimezone(draupHeaderDeleteList.get(0).lastmodifieddate);		
                    system.debug('lastModDate***'+lastmodifieddate);
                    if(lastmodifieddate <= myDateTime || checkSync){
                        system.debug('inside > 24 hrs');
                        insertUniverseData(recordId, accId,draupHeaderDeleteList,draupAccName);
                    }
                }
            }
         
        }catch(Exception e){
            system.debug('Exception occurred'+e.getMessage());
            ExceptionHandler.logApexError('DraupUniverseController', 'checkDraupUniverseDataExists', String.valueOf(e.getLineNumber()), e.getStackTraceString());
        }

    }
/***************************************************************************************************
* @description   Method to Display linked draup data
* @author        Persistent Systems
* Params		 Id,Draup ID,Boolean,Draup Account Name
* @date          19/09/2018
* @return        Map<string,List<Map<string,string>>>
****************************************************************************************************/
    @AuraEnabled
    public static Map<string,List<Map<string,string>>> displayDraupData(String recordId,String accId,boolean checkSync,String draupAccName)
    {
        try{
            system.debug('datetime now***'+getDateBasedOnTimezone(datetime.now())+'**'+draupAccName);
            if(!checkSync){
                checkDraupUniverseDataExists(recordId,accId,checkSync,draupAccName);
            }
            //Id executiveid = (Id)executive_id;
            system.debug('accId'+accId);
            List<DraupHeader__c> draupList=Database.query('Select Name,RecordType.Name,(select OpportunityIndex__c,RDSpend__c,RDSpendGrowth__c,TotalRDWorkforce__c,TotalITWorkforce__c,Headquarters__c,Categories__c,TechStack__c,Locations__c,Headcount__c,LocationClass__c,SubVerticalsLead__c,Country__c,Vendors__c, KeyVendors__c,KeyLocations__c,KeySubVerticals__c,TopTitles__c,TopLocations__c,KeySkillsHired__c,ExecutiveName__c,MovementDate__c,ExecutiveMovementTitle__c,Link__c,StrategicSignalTitle__c,StrategicDate__c,Tag__c,DraupHeader__c,Type__c from DraupChild_Details__r) From DraupHeader__c  where Account__c=:recordId and Draup_Id__c =:accId Order by displayOrder__c');
            system.debug('draupList'+draupList);
            Map<string,Schema.SObjectField> fmap=DraupChild__c.getSObjectType().getDescribe().fields.getMap() ;
            Map<string,List<Map<string,string>>> draupHeaderChildMap = new Map<string,List<Map<string,string>>>();
            Map<string,string> contactValuesMap = new Map<string,string>();
            List<Map<string,string>> contactList = new List<Map<string,string>>();
            
            for(DraupHeader__c dh:draupList){
                
                if(draupHeaderChildMap.containsKey(dh.RecordType.Name)){
                    contactList = draupHeaderChildMap.get(dh.RecordType.Name);
                    system.debug('ifexecutiveValuesMap'+contactValuesMap);
                } else{
                    contactList = new List<Map<string,string>>();
                }
                for(DraupChild__c dhc : dh.DraupChild_Details__r)
                { 
                    contactValuesMap = new Map<string,string>();
                    for(String f :  dhc.getPopulatedFieldsAsMap().keySet())
                    {
                        if(f=='Id' || f== 'draupApp__DraupHeader__c' ){
                            continue;
                        }
                            Object value = dhc.get(f);
                            if (value != null) 
                            {
                                Schema.DescribeFieldResult dfr = fmap.get(f).getDescribe();
                                if(dfr==null){
                                    contactValuesMap.put(f, String.valueOf(value));
                                }else if(dfr.getLabel()=='Strategic Signal Title'){
                                    contactValuesMap.put(f, String.valueOf(value));
                                }else if(dfr.getLabel()=='Strategic Date'){
                                    contactValuesMap.put(f, String.valueOf(value));
                                }else{
                                    contactValuesMap.put(dfr.getLabel(), String.valueOf(value));
                                }
                            }
                        
                    }
                    if(contactValuesMap.size()>0){
                        contactList.add(contactValuesMap);
                    }
                }
                if(contactList.size()>0){
                    draupHeaderChildMap.put(dh.RecordType.Name,contactList);
                }
            }
            system.debug('GGB draupHeaderChildMap Values'+draupHeaderChildMap);
            return draupHeaderChildMap;      
        }catch(Exception e){
            system.debug('Exception occured'+e.getMessage());
            ExceptionHandler.logApexError('DraupUniverseController', 'displayDraupData', String.valueOf(e.getLineNumber()), e.getStackTraceString());
            return null;
        }
    }
/***************************************************************************************************
* @description   Method to Display globalizationData
* @author        Persistent Systems
* Params		 Id,Draup ID,type
* @date          19/09/2018
* @return        Map<string,Map<string,string>>
****************************************************************************************************/
    @AuraEnabled
    public static Map<string,Map<string,string>> globalizationData(String accId,String draupId,String type)
    {
        try{
            system.debug('accId'+accId);
            List<DraupChild__c> draupList=Database.query('select Locations__c,Location__c,Headcount__c,LocationClass__c,SubVerticalsAccount__c,Country__c,Vendors__c,Type__c,RecordTypeId from DraupChild__c where type__c=:type and DraupHeader__r.Draup_Id__c =:draupId and DraupHeader__r.recordtype.name = \'Globalization\' and DraupHeader__r.account__c=:accId ');
            system.debug('draupList'+draupList);
            Map<string,Schema.SObjectField> fmap=DraupChild__c.getSObjectType().getDescribe().fields.getMap() ;
            Map<string,Map<string,string>> draupHeaderChildMap = new Map<string,Map<string,string>>();
            Map<string,string> contactValuesMap = new Map<string,string>();
            for(DraupChild__c dh:draupList){
                if(draupHeaderChildMap.containsKey(dh.Location__c)){
                    contactValuesMap = draupHeaderChildMap.get(dh.Location__c);
                } else{
                    contactValuesMap = new Map<string,string>();
                }             
                for(String f :  dh.getPopulatedFieldsAsMap().keySet())
                {
                    if(f=='Id' || f== 'draupApp__DraupHeader__c' ||  f=='RecordTypeId'){
                        continue;
                    }
                        Object value = dh.get(f);
                        if (value != null) 
                        {
                            Schema.DescribeFieldResult dfr = fmap.get(f).getDescribe();
                            if(dfr==null){
                                contactValuesMap.put(f, String.valueOf(value));
                            }else{
                                contactValuesMap.put(dfr.getLabel(), String.valueOf(value));
                            }
                        }
                    
                }
                if(contactValuesMap.size()>0){
                    
                draupHeaderChildMap.put(dh.Location__c,contactValuesMap);
                }
                           }
            system.debug('draupHeaderChildMap Values'+draupHeaderChildMap);
            if(draupHeaderChildMap.size()>0){
            	return draupHeaderChildMap;  
            }else{
            	return null;
            }
        }catch(Exception e){
            system.debug('Exception occured'+e.getMessage());
            ExceptionHandler.logApexError('DraupUniverseController', 'globalizationData', String.valueOf(e.getLineNumber()), e.getStackTraceString());
            return null;
        }
    }
/***************************************************************************************************
* @description   Method to Display hiringData
* @author        Persistent Systems
* Params		 Id,Draup ID
* @date          19/09/2018
* @return        List<DraupChild__c>
****************************************************************************************************/
    @AuraEnabled
    public static List<DraupChild__c>  hiringData(String accId,String draupId)
    {
        try{
            //Id executiveid = (Id)executive_id;ild
            system.debug('accId'+accId);
            List<DraupChild__c> draupChildList =Database.query('Select TopLocations__c,KeySkillsHired__c,TopTitles__c from DraupChild__c where DraupHeader__r.RecordType.name = \'Hiring\' and DraupHeader__r.Account__c=:accId and DraupHeader__r.Draup_Id__c=:draupId');
            system.debug('draupChildList**'+draupChildList);
            return draupChildList;
        }catch(Exception e){
            system.debug('Exception Occured'+e.getMessage());
            ExceptionHandler.logApexError('DraupUniverseController', 'hiringData', String.valueOf(e.getLineNumber()), e.getStackTraceString());
            return null;
        }
        
    }

/***************************************************************************************************
* @description   Method to get record type of records
* @author        Persistent Systems
* Params		 Id,Draup ID
* @date          19/09/2018
* @return        List<String>
****************************************************************************************************/
    
    @AuraEnabled
    public static List<String> getTypes(String accId,String draupId)
    {
        List<String> types = new List<String>();
        try{
            for(AggregateResult ar : Database.query('SELECT COUNT_DISTINCT(id),type__c from DraupChild__c where DraupHeader__r.recordTYpe.name=\'Executive Movement\'  and DraupHeader__r.draup_Id__c=:draupId and DraupHeader__r.Account__c =:accId group by type__c')){
                types.add((String)ar.get('type__c'));
            }
            
        }catch(Exception e){
            system.debug('Exception Occured::'+e.getMessage());
            ExceptionHandler.logApexError('DraupUniverseController', 'getTypes', String.valueOf(e.getLineNumber()), e.getStackTraceString());
        }
        system.debug('types::'+types);
        return types;
    }

/***************************************************************************************************
* @description   Method to Display executiveMovementData
* @author        Persistent Systems
* Params		 Id,Draup ID,Type
* @date          19/09/2018
* @return        List<DraupChild__c>
****************************************************************************************************/

    
    @AuraEnabled
    public static List<DraupChild__c>  executiveMovementData(String accId,String draupId,String type)
    {
        try{
            system.debug('accId'+accId);
            List<DraupChild__c> draupChildList= Database.query('Select MovementDate__c,ExecutiveName__c,ExecutiveMovementTitle__c from DraupChild__c where type__c=:type and DraupHeader__r.RecordType.name = \'Executive Movement\' and DraupHeader__r.Account__c=:accId and DraupHeader__r.Draup_Id__c=:draupId ');
            system.debug('draupChildList**'+draupChildList);
            If(draupChildList.size()>0){
                return draupChildList;
            }else{
                return null;
            }
        }catch(Exception e){
            system.debug('Exception Occured'+e.getMessage());
            ExceptionHandler.logApexError('DraupUniverseController', 'executiveMovementData', String.valueOf(e.getLineNumber()), e.getStackTraceString());
            return null;
        }
    }
    
/***************************************************************************************************
* @description   Method to insert Darup universe data in to Darup header Draup and Child objects
* @author        Persistent Systems
* Params		 Id,Draup ID,draupHeaderDeleteList,Draup Account Name
* @date          19/09/2018
* @return        Void
****************************************************************************************************/
    
    @AuraEnabled
    public static void insertUniverseData(String recordId,String draupId,List<DraupHeader__c> draupHeaderDeleteList,String draupAccName)
    {
          try{
            String endpoint;
            system.debug('draupId after'+draupId);
            Account acc =getAccount(recordId);
            DraupEndPoints__c accountAllDetailsEndPoint = DraupEndPoints__c.getValues('AccountAllDetailsEndPoint');
            System.debug(' Label.RolodexSearchEndPoint **' + accountAllDetailsEndPoint);
            endpoint = System.Label.Draup_Platform_Url+accountAllDetailsEndPoint.End_Point_Url__c+draupId;
            acc.draupApp__Draup_Id__c = draupId;
            acc.draupApp__Draup_Account_Name__c=draupAccName;
            HttpRequest httpReq = new HttpRequest();
            httpReq.setEndpoint(endpoint);
            httpReq.setMethod('GET');
            httpReq.setHeader('Accept', 'application/json');
            String userAccessToken = getDecryptedToken();
            //String userAccessToken = fetchUser().Draup_Token__c;//'eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpZCI6MzQxLCJleHAiOjE1MzkxNDMxMDN9.Ezy-KVF9twNpWuNrlrBGfl2bYZued1no6fngpsQ2I8Q'; 
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
                if(draupHeaderDeleteList !=null && draupHeaderDeleteList.size() > 0){
                    Database.delete(draupHeaderDeleteList);
                }    
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
                ExceptionHandler.logApexCalloutError('DraupUniverseController', 'insertUniverseData',response);
            }
            
        }catch(exception ex)
        {
            System.debug('Message '+ ex.getMessage()+'line number '+ex.getLineNumber());
            ExceptionHandler.logApexError('DraupUniverseController', 'insertUniverseData', String.valueOf(ex.getLineNumber()), ex.getStackTraceString());
        }
    }
   
/***************************************************************************************************
* @description   Method to get Account details 
* @author        Persistent Systems
* Params		 Id
* @date          19/09/2018
* @return        Account
****************************************************************************************************/
    @AuraEnabled
    public static Account getAccount(String recordId){
        if(recordId !=null){
        Account acc = Database.query('Select id, name,draup_Id__c from account where id = :recordId');
        return acc;
        }else{
        return null;
        }
    } 
/***************************************************************************************************
* @description   Method to Sync Draup Universe data or Refresh the Data
* @author        Persistent Systems
* Params		 Id,Draup Id,Draup Account Name
* @date          19/09/2018
* @return        Boolean
****************************************************************************************************/   
    
    @AuraEnabled
    public static boolean syncUniverseData(String recordId,String accId,String draupAccName){
       /* boolean status = removeUniverseData(recordId, accId);
        system.debug('status**'+status);
        if(status){*/
        try{
            system.debug('from sync');
           List<DraupHeader__c>  draupHeaderDeleteList = Database.query('Select id,Draup_Id__c,lastmodifieddate from DraupHeader__c where Draup_Id__c = :accId and Account__C = :recordId ');  
               insertUniverseData(recordId, accId, draupHeaderDeleteList,draupAccName);
       /* Map<string,List<Map<string,string>>> result = displayDraupData(recordId, accId, true);
        return result;*/
            return true;
        }catch(Exception e){
            system.debug('Exception occured::'+e.getLineNumber()+'**'+e.getMessage());
            ExceptionHandler.logApexError('DraupUniverseController', 'syncUniverseData', String.valueOf(e.getLineNumber()), e.getStackTraceString());
            return false;
        }


        //}
    }
/***************************************************************************************************
* @description   Method to get Decrypted token
* @author        Persistent Systems
* Params		 -
* @date          26/09/2018
* @return        String 
****************************************************************************************************/  
    private static String getDecryptedToken(){
        // Supriya need to change select statement as per security concern
        String userId =userInfo.getUserId();
        User u =Database.query ('select id,Name,Draup_Token__c,ExpiryDate__c,profile.name from User where id =:userId');
        String accessToken = DraupEncryptUtil.getDecryptedValue(u.Draup_Token__c);
        return accessToken;
    }

/***************************************************************************************************
* @description   Method to get queryParameters from client for authentication 
* @author        Persistent Systems
* Params		 -
* @date          26/09/2018
* @return        String 
****************************************************************************************************/  
    @AuraEnabled
    public static String queryParametersForAuthentication()
    {
        try{
            system.debug('inside QP***');
            //system.debug(leadRecordId);
            String clientId = clientAuthDetails__c.getValues('Auth').draupApp__clientId__c;
            String redirectUrl = '&redirect_url=https://'+URL.getSalesforceBaseUrl().getHost()+'/apex/draupApp__DraupAuthRedirectPage'+'&error_url=https://'+URL.getSalesforceBaseUrl().getHost()+'/apex/draupApp__DraupAuthErrorPage';
            String queryParameters = clientId+redirectUrl;
            system.debug('**** '+clientId+'**queryParameters**'+queryParameters);
            return queryParameters;
        }catch(Exception ex){
            system.debug('Exception occured::'+ex.getLineNumber()+'**'+ex.getMessage());
            ExceptionHandler.logApexError('DraupUniverseController', 'queryParametersForAuthentication', String.valueOf(ex.getLineNumber()), ex.getStackTraceString());
            return null;
        }
    }
/***************************************************************************************************
* @description   Method to get current user details  
* @author        Persistent Systems
* Params		 -
* @date          26/09/2018
* @return        User 
****************************************************************************************************/  
    @AuraEnabled 
    public static user fetchUser(){
       String userId =userInfo.getUserId();
        User u = Database.query ('select id,Name,Draup_Token__c,ExpiryDate__c,profile.name from User where id =:userId');
        //system.debug('acess token'+u.Draup_Token__c);
        clientAuthDetails__c clntAuthDetails = clientAuthDetails__c.getValues('Auth');
        String superUserProfiles = clntAuthDetails.draupApp__SuperUserProfile__c;
        if(superUserProfiles!=null){
            List<String> finalSuperUsers= new List<String>();
            List<String> superUsers= superUserProfiles.split(',');
            for(String superUser: superUsers){
               finalSuperUsers.add(superUser.touppercase());
            }
            String profile = u.profile.name.toUpperCase();
            if(finalSuperUsers.contains(profile)){
                system.debug('superUser**');
               u.draupApp__isSuperUser__c = true; 
            }else{
                 u.draupApp__isSuperUser__c = false; 
            }
        }
        
        
        return u;
    }
    /*@AuraEnabled 
    public static List<DraupHeader__c>  hideLinkButton(String recordId,String accId){
        system.debug('accountId'+recordId);
        system.debug('draupId'+accId);
        List<DraupHeader__c> draupList = Database.query('Select Name,Draup_Id__c From DraupHeader__c where Account__c=:accId and Draup_Id__c=:accId');
        system.debug('Hide link draup list'+draupList); 
        return draupList;
    }*/

/***************************************************************************************************
* @description   Method to unlink Universe Draup Data 
* @author        Persistent Systems
* Params		 Id,Draup Id
* @date          10/10/2018
* @return        Boolean 
****************************************************************************************************/  
    @AuraEnabled 
    public static Boolean removeUniverseData(String recordId,String accId)
    {
        Boolean bStatus = false;
        try{
        System.debug('recordId '+ recordId);
        System.debug('accId '+ accId);
        System.debug('GGB Iside Apex Class');
        List<Contact> con = Database.query('SELECT Id, Name,Draup_Id__c FROM contact where AccountId=:recordId and Draup_Id__c != null');
        System.debug('con ' + con);
         List<DraupHeader__c> lDraupHeader;
        if(con!=null && con.size()>0){
        String draupId = con.get(0).draupApp__Draup_Id__c ; 
            system.debug('Account DraupID'+draupId);
        String contactId = con.get(0).id;
			system.debug('Contact DraupID'+contactId);
        lDraupHeader = Database.query('Select id,Draup_Id__c from DraupHeader__c where (Draup_Id__c = :accId or Draup_Id__c=:draupId) and (Account__C = :recordId or Contact__c=:contactId) ');  
        }else{
        lDraupHeader = Database.query('Select id,Draup_Id__c from DraupHeader__c where (Draup_Id__c = :accId ) and (Account__C = :recordId) ');  
          }  
        if(lDraupHeader != null && lDraupHeader.size() > 0)
        {
            System.debug(' lDraupHeader ' + lDraupHeader);
            Database.Delete(lDraupHeader);
            bStatus = true;
        }
        Account oAccount = getAccount(recordId);
        if(oAccount != null)
        {
            oAccount.draupApp__Draup_Id__c= null;
            Database.update(oAccount);
        }
        List<contact> oContact = getContact(recordId);
        if(oContact != null && oContact.size()>0)
        {
            system.debug('oContact'+oContact);
            Database.update(oContact);
        }
        }catch(Exception ex){
             system.debug('Exception occured::'+ex.getLineNumber()+'**'+ex.getMessage());
            ExceptionHandler.logApexError('DraupUniverseController', 'removeUniverseData', String.valueOf(ex.getLineNumber()), ex.getStackTraceString());
           
        }
        return bstatus;
    }
 /***************************************************************************************************
* @description   Method to get time with respect to time zone
* @author        Persistent Systems
* Params		 Date
* @date          10/10/2018
* @return        DateTime 
****************************************************************************************************/ 
    private static Datetime getDateBasedOnTimezone(datetime dt)
    {    
        DateTime utcTime = dt;
        Datetime localTime = dt.Date();
        localTime = localTime.addHours(utcTime.hour());
        localTime = localTime.addMinutes(utcTime.minute());
        localTime = localTime.addSeconds(utcTime.second());
        
        return localTime;
    }
/***************************************************************************************************
* @description   Method to get record lost modifide date
* @author        Persistent Systems
* Params		 Draup ID,Id
* @date          10/10/2018
* @return        String 
****************************************************************************************************/ 
    
    @AuraEnabled
    public static String getLastModDate(String accId,string recordId)
    {
        String lastModDate ;
        try{
        //System.debug(' GGB lastModDate ' + lastModDate);
        if(accId != null)
        {
            System.debug(' accId' + accId);
            System.debug(' recordId' + recordId);
            List<DraupHeader__c>  dhList = Database.query('SELECT LastModifiedDate FROM DraupHeader__c where Draup_Id__c = :accId and Account__C = :recordId limit 1');
             System.debug(' dh ' + dhList);
            if(dhList!=null && dhList.size()>0){
                lastModDate = (dhList.get(0).LastModifiedDate !=null ?getFormatLastModifiedDate(dhList.get(0).LastModifiedDate):''); 
            }
            system.debug('lastModDate**'+lastModDate);
        }
        }catch(Exception ex){
             system.debug('Exception occured::'+ex.getLineNumber()+'**'+ex.getMessage());
            ExceptionHandler.logApexError('DraupUniverseController', 'getLastModDate', String.valueOf(ex.getLineNumber()), ex.getStackTraceString());
         
        }
        return lastModDate;
    } 

/***************************************************************************************************
* @description   Method to provide formatted Date
* @author        Persistent Systems
* Params		 lastModified date
* @date          10/10/2018
* @return        String 
****************************************************************************************************/ 
    public static String getFormatLastModifiedDate(Datetime lastModDate){
         String formattedDate = lastModDate.format('MMM,dd yyyy HH:mm:ss');
        return  formattedDate;
    }

/***************************************************************************************************
* @description   To get contact record details 
* @author        Persistent Systems
* Params		 Id
* @date          10/10/2018
* @return        List<Contact>  
****************************************************************************************************/ 
     @AuraEnabled 
     public static List<Contact> getContact(string recordId){
         try{
         List<Contact> conList = Database.query('Select id, name,Draup_Id__c from Contact where AccountID = :recordId and Draup_Id__c != null ');
         for(Contact cont : conList){
             cont.draupApp__Draup_Id__c = null;
         }
         return (conList !=null && conList.size()>0 ?conList : null);
         }catch(Exception ex){
              system.debug('Exception occured::'+ex.getLineNumber()+'**'+ex.getMessage());
            ExceptionHandler.logApexError('DraupUniverseController', 'getContact', String.valueOf(ex.getLineNumber()), ex.getStackTraceString());
         	return null; 
         }
         
         }

/***************************************************************************************************
* @description   To verify whether account has contcat or not 
* @author      	 Persistent Systems
* Params		 Id,Drapu Id
* @date          10/10/2018
* @return      	 Integer 
****************************************************************************************************/ 
    @AuraEnabled 
     public static Integer verifyContactExistance(String recordId,String accId)
     {
         try{
         Integer conCount = 0;
         List<Contact> con = Database.query('SELECT Id, Name,Draup_Id__c FROM contact where AccountId=:recordId and Draup_Id__c !=null');
         if(con!=null && con.size()>0)
         {
             conCount = con.size();
          }
         return conCount;
         }catch(Exception ex){
              system.debug('Exception occured::'+ex.getLineNumber()+'**'+ex.getMessage());
            ExceptionHandler.logApexError('DraupUniverseController', 'verifyContactExistance', String.valueOf(ex.getLineNumber()), ex.getStackTraceString());
         	return null; 
         }
     }
    /*public List<String> getUserFieldList()
    {
        Map<String, Schema.SObjectField> schemaFieldMap = Schema.SObjectType.user.fields.getMap();
        List<String> fieldList = new List<String>();
        for(String field :schemaFieldMap.keyset()){
            fieldList.add(field);
        }
        return fieldList;
    }*/
    
}