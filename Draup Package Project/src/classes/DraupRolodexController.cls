/**************************************************************************************************************
*   @author         Persistent Systems
*   @date           20/09/2018
*   @description    This class is used to get and display Executives information
***************************************************************************************************************/
public with sharing class DraupRolodexController {
    
    public static list<DraupExecutiveWrapper> draupExList {get;set;}
     /***************************************************************************************************
    * @description   This method is used to get maching executives from draup
    * @author        Persistent Systems
    * @param       	 ID
    * @date          20/09/2018
    * @return        List<DraupExecutiveWrapper> 
    ****************************************************************************************************/
    @AuraEnabled
    public static list<DraupExecutiveWrapper> matchDraup (id recordId)
    {
        try{
            String sObjName='';
            system.debug('recordId======'+recordId);
            //system.debug('Start Load==='+DateTime.Now().format('YYYY-MM-DD hh:mm:ss.SSS'));
            sObjName = string.valueOf(recordId.getSObjectType().getDescribe().getName());
            system.debug('sObjName==='+sObjName);
            //system.debug('Authorize::'+DraupAuthentication.draupAuthorize); 
            if(recordId != NULL) {  
                String endpoint; 
                //boolean leadValid = Utility.isAccessible(getLeadFieldList(),'Lead');
                if(sObjName != '' && sObjName =='Lead' /*&& Schema.sObjectType.Lead.isAccessible()*/){
                    Lead led = Database.query('SELECT Id, FirstName, LastName, Name, Company FROM Lead where id = :recordId');
                    String lname = led.FirstName +' '+ led.LastName; 
                    DraupEndPoints__c rolodexSearchEndPoint = DraupEndPoints__c.getValues('RolodexSearchEndPoint');
                    System.debug(' Label.RolodexSearchEndPoint **' + rolodexSearchEndPoint);
                    endpoint=System.Label.Draup_Platform_Url+rolodexSearchEndPoint.draupApp__End_Point_Url__c+EncodingUtil.urlEncode(led.Company,'UTF-8')+'&name='+EncodingUtil.urlEncode(lname,'UTF-8');
                    
                }
                
                HttpRequest httpReq = new HttpRequest();
                httpReq.setEndpoint(endpoint);
                httpReq.setMethod('GET');
                httpReq.setHeader('Accept', 'application/json'); 
                //String userId = UserInfo.getUserId();
                //User userAccessToken = Database.query('Select id, Draup_Token__c from User where id=:userId');
                String sUserToken = getDecryptedToken();
                httpReq.setHeader('Authorization', 'Bearer '+sUserToken);
                httpReq.setHeader('Cache-Control', 'no-cache');
                httpReq.setHeader('Content-Type', 'application/json');
                http httpObj = new http();
                httpResponse response = httpObj.send(httpReq);
                System.debug('response :: '+response);
                if(response.getStatusCode() == 200)
                {
                    if(sObjName != '' && sObjName =='Lead'){
                        DraupExList = (List<DraupExecutiveWrapper>)System.JSON.deserialize(response.getBody(),List<DraupExecutiveWrapper>.class);
                        system.debug('Debug for Dsiplaying all the records: DraupSugestions'+DraupExList);
                        
                    }
                }
                else{
                    system.debug('Bad Response'+response.getbody());
                    ExceptionHandler.logApexCalloutError('DraupRolodexController', 'matchDraup',response);
                }
                
                
            }
            return DraupExList;
        }catch(exception ex)
        {
            System.debug('Message '+ ex.getMessage()+'line number '+ex.getLineNumber());
            ExceptionHandler.logApexError('DraupRolodexController', 'matchDraup', String.valueOf(ex.getLineNumber()), ex.getStackTraceString());
            return null;
        }
    }
    /***************************************************************************************************
    * @description   This method is used to display linked executives data
    * @author        Persistent Systems
    * @param       	 String recordId,String executiveId,boolean syncCheck
    * @date          20/09/2018
    * @return        Map
    ****************************************************************************************************/
    @AuraEnabled
    public static Map<string,List<Map<string,string>>> displayDraupData(String recordId,String executiveId,boolean syncCheck)
    {
        try{
            //boolean valid = Utility.isAccessible(getDraupHeaderFieldList(),'DraupHeader__c');
            // boolean childValid = Utility.isAccessible(getDraupChildFieldList(),'DraupChild__c');
            /*if(!(valid && childValid)){
return null;
}*/
            
            List<DraupHeader__c> draupHeaderDeleteList = new List<DraupHeader__c>();
            if(!syncCheck){
                checkDraupRoledexDataExists(recordId,executiveId,syncCheck);
            }
            //Id executiveid = (Id)executiveId;
            system.debug('executiveId'+executiveId);
            List<DraupHeader__c> draupList=Database.query('Select Name,RecordType.Name,(select ExecutiveName__c,expOrder__c,Location__c,Designation__c,KeyVendorsEngaged__c,PersonalityCharacteristics__c,SubVerticalsLead__c,BusinessUnit__c,DealSizeInfluence__c,OpportunityIndex__c,BudgetControl__c,ContactDetails__c,CompanyName__c,Date__c,Role__c,EngagementGuidelines__c,Interests__c,DraupHeader__c,Type__c,End__c,start__c,ImageLink__c from DraupChild_Details__r) From DraupHeader__c  where  lead__c=:recordId and Draup_Id__c =:executiveId Order by displayOrder__c');
            system.debug('draupList'+draupList);
            Map<string,Schema.SObjectField> fmap=DraupChild__c.getSObjectType().getDescribe().fields.getMap() ;
            Map<string,List<Map<string,string>>> draupHeaderChildMap = new Map<string,List<Map<string,string>>>();
            Map<string,string> executiveValuesMap = new Map<string,string>();
            List<Map<string,string>> executiveList = new List<Map<string,string>>();
            // List<DraupChild__c> testDraupChild=new List<DraupChild__c>();
            Map<string,list<DraupChild__c>> headerChildMap= new Map<string,list<DraupChild__c>>();
            
            for(DraupHeader__c dh:draupList){
                headerChildMap.put(dh.RecordType.Name,dh.DraupChild_Details__r);
            }
            system.debug('headerChildMap***'+headerChildMap);
            List<DraupChild__c> childList = headerChildMap.get('Experience');
            system.debug('childList***'+childList);
            List<DraupExecutiveWrapper> rolodexSortList = new List<DraupExecutiveWrapper>();
            for(DraupChild__c dc : childList){
                rolodexSortList.add(new DraupExecutiveWrapper(dc));
            }
            rolodexSortList.sort();
            List<DraupChild__c> childExpList = new  List<DraupChild__c>();
            for(DraupExecutiveWrapper wrapper: rolodexSortList){
                childExpList.add(wrapper.draupChild);
            }
            headerChildMap.put('Experience',childExpList);
            system.debug('headerChildMap after**'+headerChildMap.get('Experience'));
            
            for(String recordType:headerChildMap.keySet()){
                if(draupHeaderChildMap.containsKey(recordType)){
                    executiveList = draupHeaderChildMap.get(recordType);
                    system.debug('ifexecutiveValuesMap'+executiveValuesMap);
                } else{
                    executiveList = new List<Map<string,string>>();
                }
                
                for(DraupChild__c dhc : headerChildMap.get(recordType)) //experience value 
                {   
                    //testDraupChild.add(dhc);
                    //system.debug('testDraupChild***'+testDraupChild);
                    executiveValuesMap = new Map<string,string>();
                    for(String f :  dhc.getPopulatedFieldsAsMap().keySet()) // exp fields i=4 - i=7
                    {
                        if(f=='Id' || f== 'draupApp__DraupHeader__c' ){
                            continue;
                        }
                        Object value = dhc.get(f);
                        if (value != null) 
                        {
                            Schema.DescribeFieldResult dfr = fmap.get(f).getDescribe();
                            if(dfr==null){
                                executiveValuesMap.put(f, String.valueOf(value));
                            }else if(dfr.getLabel()=='Company Name' || dfr.getLabel()=='start' || dfr.getLabel()=='end'){
                                executiveValuesMap.put(f, String.valueOf(value));
                            } else{
                                executiveValuesMap.put(dfr.getLabel(), String.valueOf(value));
                            }
                        }
                    }
                    if(executiveValuesMap.size()>0)
                        executiveList.add(executiveValuesMap);
                    //executiveList.sort();
                    
                }
                if(executiveList.size()>0)
                    draupHeaderChildMap.put(recordType,executiveList);
                
            }
            system.debug('draupHeaderChildMap Values'+draupHeaderChildMap);
            return draupHeaderChildMap;  
            
        }
        
        catch(Exception ex)
        {
            ExceptionHandler.logApexError('DraupRolodexController', 'displayDraupData', String.valueOf(ex.getLineNumber()) , ex.getStackTraceString());
            return null;
        }
        
    }
    
    /***************************************************************************************************
	* @description   Method to get queryParameters from client for authentication 
	* @author        Persistent Systems
	* Params		 -
	* @date          20/09/2018
	* @return        String 
	****************************************************************************************************/  
    @AuraEnabled
    public static String queryParametersForAuthentication()
    {
        system.debug('inside QP***');
        //system.debug(leadRecordId);
        String clientId = clientAuthDetails__c.getValues('Auth').draupApp__clientId__c;
        String redirectUrl = '&redirect_url=https://'+URL.getSalesforceBaseUrl().getHost()+'/apex/draupApp__DraupAuthRedirectPage'+'&error_url=https://'+URL.getSalesforceBaseUrl().getHost()+'/apex/draupApp__DraupAuthErrorPage';
        String queryParameters = clientId+redirectUrl;
        system.debug('**** '+clientId+'**queryParameters**'+queryParameters);
        return queryParameters;
    }
      /***************************************************************************************************
    * @description   This method is used to get current user details 
    * @author        Persistent Systems
    * @param 		 --
    * @date          20/09/2018
    * @return        user
    ****************************************************************************************************/
    @AuraEnabled 
    public static user fetchUser(){
        try{
            /* boolean valid = Utility.isAccessible(getUserFieldList(),'User');
            if(!valid){
            return null;
            }
            else{*/
            String userId =userInfo.getUserId();
            User u =Database.query ('select id,Name,Draup_Token__c,ExpiryDate__c,profile.name from User where id =:userId');
            system.debug('acess token'+u.Draup_Token__c);
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
            //}
        }catch(Exception ex){
            ExceptionHandler.logApexError('DraupRolodexController', 'fetchUser', String.valueOf(ex.getLineNumber()) , ex.getStackTraceString());
            return null;
        }
    }
      /***************************************************************************************************
    * @description   Method to insert Darup universe data in to Darup header Draup and Child objects
    * @author        Persistent Systems
    * @param 		 String recordId,String executiveId,List<DraupHeader__c> draupHeaderDeleteList
    * @date          20/09/2018
    * @return        void
    ****************************************************************************************************/
    @AuraEnabled 
    public static void insertRolodexData(String recordId,String executiveId,List<DraupHeader__c> draupHeaderDeleteList)
    { 
        try{
            system.debug('From rolodex insertion*******');
            Lead lead = getLead(recordId);
            lead.draupApp__Draup_Id__c= executiveId;
            Http http = new Http();
            HttpRequest request = new HttpRequest();
            //String token = [Select Draup_Token__c From User Where Id = :UserInfo.getUserId()][0].Draup_Token__c;
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
            httpResponse response;
            string result ;
            Integer statusCode ;
            if(!System.Test.isRunningTest()){
                response = http.send(request);
                result = response.getBody();
                statusCode = response.getStatusCode();
            }else{
                result ='{\n'+
                    '"overview": [{  "key_vendors": [" "," "],"subverticals": [ "","" ],"budget_control": "LOW","deal_size_influencce": "LOW","location": "Greater Seattle Area, United States", "business_unit": "King", "image_link": "http://pbs.twimg.com/profile_images/116369133/mugshot_normal.jpg",\n'+
                    '"contact_details": null,"designation": "Senior Director", "opportunity_index": 2.2 } ],\n'+
                    '"experiences": [{"end_date": null,"designation": "Vice President Power Software Development","account_name": "IBM","start_date": "2012-04-01"},{"end_date": "2012-04-01","designation": "Director, Power Firware Development","account_name": "International Business Machines","start_date": "2007-09-01"}],\n'+
                    '"psychological_analysis": {"personalities": ["Persuasive","Adaptable","Resilient"],"interests": [{"Government Agency": ["Élysée"]},{"Sports Team": ["Peugeot Sport","Olympique Lyonnais"]}],"engagement_guidelines": ["Questions pertaining to the product/service are most likely to be associated"]}\n'+
					'}';
                statusCode = 200;
            }
            if (statusCode == 200) 
            {
                Id recordTypeId ;
                system.debug('response'+result);
                transient Map<String,Object> obj= (Map<String,Object>)JSON.deserializeUntyped(result); 
                DraupLeadInfoWrapper lInfoWrapper = DraupLeadInfoWrapper.parse(result);
                System.debug('lInfoWrapper ' + lInfoWrapper);
                List<DraupChild__c> lDraupChild = new List<DraupChild__c>();
                List<DraupHeader__c> lDraupHeader = new List<DraupHeader__c>();
                
                //supriya need to uncomment
                /* boolean valid = Utility.isDeletable(getDraupHeaderFieldList(),'DraupHeader__c');
system.debug('valid delete**'+valid);
*/  
                if(draupHeaderDeleteList !=null && draupHeaderDeleteList.size()>0){
                    Database.delete(draupHeaderDeleteList);
                } 
                Map<Id,List<DraupChild__c>> mDraupHeaderChild = new Map<Id,List<DraupChild__c>>();
                if(obj.containsKey('experiences'))
                {
                    List<Object> expl = DraupConstants.EXPERIENCES;
                    
                    lDraupChild = new List<DraupChild__c>();
                    recordTypeId = Schema.SObjectType.DraupHeader__c.getRecordTypeInfosByName().get(String.valueOf(expl.get(0))).getRecordTypeId();
                    DraupHeader__c oDraupHeader = new DraupHeader__c(RecordTypeId = recordTypeId,Draup_Id__c=executiveId,Lead__c=recordId,Type__c='Rolodex',displayOrder__c=Integer.valueOf(expl.get(1)));
                    system.debug('Recrd**'+recordTypeId+'dfd'+oDraupHeader);
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
                       /* String dayOrDate = var.start_date;
                        System.debug(' GGB dayOrDate  ' + dayOrDate );
                        List<String> dateParts = dayOrDate.split('-');
                        Datetime dateWithTime = Datetime.newInstance(Integer.valueOf(dateParts[0]), Integer.valueOf(dateParts[1]), Integer.valueOf(dateParts[2]));
                        oDraupChild.Start__c =var.start_date != null ? Date.valueOf(var.start_date):null;
                        dayOrDate = dateWithTime.format('MMMM,D,YYYY');
                        System.debug('GGB after format dayOrDate ' + dayOrDate);*/
                        oDraupChild.Start__c =var.start_date != null ? Date.valueOf(var.start_date):null;
                        if(var.start_date == null && var.end_date == null)
                        {    
                        	oDraupChild.Date__c = '<br/>';//(var.start_date != null ?formatDate(oDraupChild.Start__c):' xxx ' )+ ' - ' + (var.end_date != null ? formatDate(oDraupChild.End__c):'To Present' );
                        }
                        else
                        {
                            oDraupChild.Date__c = (var.start_date != null ?formatDate(oDraupChild.Start__c):null )+ ' - ' + (var.end_date != null ? formatDate(oDraupChild.End__c):'To Present' );
                        }
                        //oDraupChild.Date__c = (var.start_date != null ?formatDate(oDraupChild.Start__c):null )+ ' - ' + (var.end_date != null ? formatDate(oDraupChild.End__c):'To Present' );
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
                    DraupHeader__c oDraupHeader = new DraupHeader__c(RecordTypeId = recordTypeId,Draup_Id__c=executiveId,Lead__c=recordId,Type__c='Rolodex',displayOrder__c=Integer.valueOf(overviewl.get(1)));
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
                        lead.draupApp__AccDraupId__c = var.account_id;
                        system.debug('<<<<imageLink>>>'+var.image_link);
                        if(var.image_link !=null){
                            oDraupChild.ImageLink__c = var.image_link;
                        }else{
                            system.debug('<<<<imageLink  inside else>>>'+var.image_link);
                            string myUrl =PageReference.forResource('noImage').getUrl();
                            myUrl = myUrl.subString(0, myUrl.indexOf('?'));
                            string headerdata= URL.getSalesforceBaseUrl().toExternalForm();
                            string invalidIMG = headerdata+myUrl; 
                            system.debug('<<<<imageLink  inside else>>>'+InvalidIMG);
                            oDraupChild.ImageLink__c =InvalidIMG;
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
                    DraupHeader__c oDraupHeader = new DraupHeader__c(RecordTypeId = recordTypeId,Draup_Id__c=executiveId,Lead__c=recordId,Type__c='Rolodex',displayOrder__c=Integer.valueOf(psychol.get(1)));
                    lDraupHeader.add(oDraupHeader);
                    DraupLeadInfoWrapper.Psychological_analysis oPsychologicalAnalysis  = lInfoWrapper.psychological_analysis;
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
                // boolean headerInsertvalid = Utility.isCreateable(getDraupHeaderFieldList(),'DraupHeader__c');
                if(lDraupHeader.size() > 0 /* && headerInsertvalid == true*/){
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
                //boolean childInsertvalid = Utility.isCreateable(getDraupChildFieldList(),'DraupChild__c');
                if(lFinalDraupChild.size()>0/*&& childInsertvalid == true*/){
                    Database.insert(lFinalDraupChild);
                }
                //if(Schema.sObjectType.Lead.fields.Draup_Id__c.isUpdateable()){
                Database.update(lead);
                //}
                
            }   else{
                system.debug('Bad Response'+response.getbody());
                ExceptionHandler.logApexCalloutError('DraupRolodexController', 'insertRolodexData',response);
            }
            
        }catch(exception ex)
        {
            System.debug('Message '+ ex.getMessage()+'line number '+ex.getLineNumber());
            ExceptionHandler.logApexError('DraupRolodexController', 'insertRolodexData', String.valueOf(ex.getLineNumber()), ex.getStackTraceString());
        }
        
        
    }  
    /***************************************************************************************************
    * @description   This method is used to formate the Date
    * @author        Persistent Systems
    * @param         Datetime dt
    * @date          20/09/2018
    * @return        string
    ****************************************************************************************************/
    public static String formatDate(Date dt) {
        
        try{
            Datetime dt1 = datetime.newInstance(dt.year(), dt.month(),dt.day());
            String formattedDate = dt1.format('MMMMM,yyyy');
            return  formattedDate;
        }
        catch(exception ex)
        {
            System.debug('Message '+ ex.getMessage()+'line number '+ex.getLineNumber());
            ExceptionHandler.logApexError('DraupRolodexController', 'formatDate', String.valueOf(ex.getLineNumber()) , ex.getStackTraceString());
            return  null;
        }
    }
      /***************************************************************************************************
    * @description   This method is used to get Lead Details
    * @author        Persistent Systems
    * @param         string recordId
    * @date          20/09/2018
    * @return        Lead
    ****************************************************************************************************/
   
    @AuraEnabled 
    public static Lead getLead(string recordId){
        /* if(Schema.sObjectType.Lead.isAccessible()){*/
        Lead lead = Database.query('Select id, name,draup_Id__c from Lead where id = :recordId');
        return lead;
        /* }
else{
return null;
}*/
    } 
      /***************************************************************************************************
    * @description   This method is used to get the decrypted token
    * @author        Persistent Systems
    * @param         --
    * @date          20/09/2018
    * @return        string
    ****************************************************************************************************/
    private static String getDecryptedToken(){
        
        try{
            /* boolean valid = Utility.isAccessible(getUserFieldList(),'User');
if(!valid){
return null;
}
else{*/
            if(Schema.sObjectType.user.fields.Draup_Token__c.isAccessible()){
                String userId = UserInfo.getUserId();
                User userObj = Database.query ('Select id, Draup_Token__c from User where id=:userId');
                String accessToken = DraupEncryptUtil.getDecryptedValue(userObj.Draup_Token__c);
                return accessToken;
            }
            else
            {
                return null;
            }
            
        }
        catch(exception ex)
        {
            System.debug('Message '+ ex.getMessage()+'line number '+ex.getLineNumber());
            ExceptionHandler.logApexError('DraupRolodexController', 'getDecryptedToken', String.valueOf(ex.getLineNumber()) , ex.getStackTraceString());
            return  null;
        }
        
    } 
    
    /***************************************************************************************************
    * @description   This method is used to unlink executive data 
    * @author        Persistent Systems
    * @param         String recordId, String executiveId
    * @date          20/09/2018
    * @return        boolean
    ****************************************************************************************************/
    @AuraEnabled
    Public Static Boolean removeRolodexData(String recordId, String executiveId)
    {
        try{
            Boolean bStatus = false ;
            //boolean valid = Utility.isDeletable(getDraupHeaderFieldList(),'DraupHeader__c');
            System.debug('GGB Iside Apex Class');
            List<DraupHeader__c> lDraupHeader = Database.query('Select id,Draup_Id__c from DraupHeader__c where Draup_Id__c = :executiveId and Lead__c = :recordId');  
            if(lDraupHeader != null && lDraupHeader.size()>0 /*&& valid == true*/)
            {
                Database.Delete(lDraupHeader);
                bStatus = true;
            }
            Lead lead = getLead(recordId);
            
            if(Lead != null /*&& Schema.sObjectType.Lead.fields.Draup_Id__c.isUpdateable()*/)
            {
                lead.Draup_Id__c= null;
                lead.AccDraupId__c=null;
                Database.update(lead);
            }
            return bStatus;
        }
        catch(exception ex)
        {
            System.debug('Message '+ ex.getMessage()+'line number '+ex.getLineNumber());
            ExceptionHandler.logApexError('DraupRolodexController', 'removeRolodexData', String.valueOf(ex.getLineNumber()) , ex.getStackTraceString());
            return  null;
        }
        
    }
   /***************************************************************************************************
    * @description   This method is used to sync or refresh the Contact data 
    * @author        Persistent Systems
    * @param         String recordId,String executiveId
    * @date          20/09/2018
    * @return        boolean
    ****************************************************************************************************/
    @AuraEnabled
    public static boolean syncRolodexData(String recordId,String executiveId){
        try{
            system.debug('from sync');
            //boolean valid = Utility.isAccessible(getDraupHeaderFieldList(),'DraupHeader__c');
            //if(Valid == true){
            List<DraupHeader__c>  draupHeaderDeleteList = Database.query('Select id,Draup_Id__c,lastmodifieddate from DraupHeader__c where Draup_Id__c = :executiveId and Lead__c=:recordId ');  
            insertRolodexData(recordId, executiveId, draupHeaderDeleteList);
            return true;
            
        }catch(Exception ex){
            //system.debug('Exception occured::'+e.getLineNumber()+'**'+e.getMessage());
            ExceptionHandler.logApexError('DraupRolodexController', 'syncRolodexData', String.valueOf(ex.getLineNumber()), ex.getStackTraceString());
            return false;
        }
    }
    /***************************************************************************************************
    * @description   Method to verify whether Lead linked with Draup or not.If not linked it will link with draup
    * @author        Persistent Systems
    * @param         String recordId,String executiveId,boolean syncCheck
    * @date          20/09/2018
    * @return        void
    ****************************************************************************************************/
    public static void checkDraupRoledexDataExists(String recordId,String executiveId,boolean syncCheck){
        try{
            boolean valid = true;//Utility.isAccessible(getDraupHeaderFieldList(),'DraupHeader__c');
            //if(valid == true){
            List<DraupHeader__c> draupHeaderDeleteList;
            Lead lead = getLead(recordId);
            if(lead.Draup_Id__c ==null){
                insertRolodexData(recordId, executiveId,draupHeaderDeleteList);
            }else{
                system.debug('from else');
                draupHeaderDeleteList = Database.query('Select id,Draup_Id__c,lastmodifieddate from DraupHeader__c where Draup_Id__c = :executiveId and Lead__c = :recordId ');  
                /*sync_time__c syncTime  = sync_time__c.getValues('Sync_hour');
                Integer syncHr = Integer.valueOf(syncTime.Sync_hour__c);
                system.debug('syncHr**'+syncHr);*/
                clientAuthDetails__c clntAuthDetails = clientAuthDetails__c.getValues('Auth');
                Integer syncHr = (clntAuthDetails.draupApp__SyncHour__c != null ?Integer.valueOf(clntAuthDetails.draupApp__SyncHour__c):0);
                system.debug('syncHr**'+syncHr);
                datetime myDateTime = getDateBasedOnTimezone(datetime.now()).addHours(-syncHr);
                system.debug('### DateTime>>>'+myDateTime +'***'+getDateBasedOnTimezone(datetime.now()));
                if(draupHeaderDeleteList!=null){
                    system.debug('### lastmodifieddate>>>'+draupHeaderDeleteList.get(0).lastmodifieddate);
                    Datetime lastmodifieddate = getDateBasedOnTimezone(draupHeaderDeleteList.get(0).lastmodifieddate);
                    lastModifiedDate = getDateBasedOnTimezone(draupHeaderDeleteList.get(0).lastmodifieddate);
                    system.debug('lastModifiedDate***'+lastModifiedDate);
                    if(lastmodifieddate <= myDateTime || syncCheck){
                        system.debug('inside > 24 hrs');
                        insertRolodexData(recordId, executiveId,draupHeaderDeleteList);
                    }
                }
            }
            
            
            
        }catch(Exception ex){
            ExceptionHandler.logApexError('DraupRolodexController', 'checkDraupRoledexDataExists', String.valueOf(ex.getLineNumber()), ex.getStackTraceString());
        }
    }
    /***************************************************************************************************
	* @description   Method to get time with respect to time zone
	* @author        Persistent Systems
	* Params		 Date
	* @date          20/09/2018
	* @return        DateTime 
	****************************************************************************************************/ 
    
    @TestVisible private static Datetime getDateBasedOnTimezone(datetime dt)
    {    
        DateTime utcTime = dt;
        Datetime localTime = dt.Date();
        localTime = localTime.addHours(utcTime.hour());
        localTime = localTime.addMinutes(utcTime.minute());
        localTime = localTime.addSeconds(utcTime.second());
        
        return localTime;
    }
     /***************************************************************************************************
    * @description   This method is used to get lastModified Date from lead
    * @author        Persistent Systems
    * @param         String executiveId,string recordId
    * @date          20/09/2018
    * @return        string
    ****************************************************************************************************/
    @AuraEnabled
    public static String getLastModDate(String executiveId,string recordId)
    {
        try{
            //boolean valid = true; Utility.isAccessible(getDraupHeaderFieldList(),'DraupHeader__c');
            //if(valid == true){
            String lastModDate ;
            //System.debug(' GGB lastModDate ' + lastModDate);
            if(executiveId != null)
            {
                System.debug(' executiveId ' + executiveId);
                System.debug(' recordId ' + recordId);
                List<DraupHeader__c>  dhList = Database.query('SELECT LastModifiedDate FROM DraupHeader__c where Draup_Id__c = :executiveId and Lead__C = :recordId limit 1');
                System.debug(' dh ' + dhList);
                if(dhList!=null && dhList.size()>0){
                    lastModDate = (dhList.get(0).LastModifiedDate !=null ?getFormatLastModifiedDate(dhList.get(0).LastModifiedDate):''); 
                }
                system.debug('lastModDate**'+lastModDate);
                
            }
            return lastModDate;
        }catch(Exception ex){
            ExceptionHandler.logApexError('DraupRolodexController', 'getLastModDate', String.valueOf(ex.getLineNumber()), ex.getStackTraceString());
            return null;
        }
        
    } 
     /***************************************************************************************************
    * @description   This method is used to formate lastModified Date
    * @author        Persistent Systems
    * @param         Datetime lastModDate
    * @date          20/09/2018
    * @return        string
    ****************************************************************************************************/
    public static String getFormatLastModifiedDate(Datetime lastModDate){
        try{
            String formattedDate = lastModDate.format('MMM,dd yyyy HH:mm:ss');
            return  formattedDate;
        }catch(Exception ex){
            ExceptionHandler.logApexError('DraupRolodexController', 'getFormatLastModifiedDate', String.valueOf(ex.getLineNumber()), ex.getStackTraceString());
            return null;
        }
    }
   /* public static List<String> getUserFieldList()
    {
        try{
            Map<String, Schema.SObjectField> schemaFieldMap = Schema.SObjectType.user.fields.getMap();
            List<String> fieldList = new List<String>();
            for(String field :schemaFieldMap.keyset()){
                fieldList.add(field);
            }
            return fieldList;
        }catch(Exception ex){
            ExceptionHandler.logApexError('DraupRolodexController', 'getUserFieldList', String.valueOf(ex.getLineNumber()), ex.getStackTraceString());
            return null;
        }
    }
    public static List<String> getLeadFieldList()
    {
        try{
            Map<String, Schema.SObjectField> schemaFieldMap = Schema.SObjectType.Lead.fields.getMap();
            List<String> fieldList = new List<String>();
            for(String field :schemaFieldMap.keyset()){
                fieldList.add(field);
            }
            return fieldList;
        }catch(Exception ex){
            ExceptionHandler.logApexError('DraupRolodexController', 'getLeadFieldList', String.valueOf(ex.getLineNumber()), ex.getStackTraceString());
            return null;
        }
    }
    
     public static List<String> getDraupHeaderFieldList()
{
Map<String, Schema.SObjectField> schemaFieldMap = Schema.SObjectType.draupApp__DraupHeader__c.fields.getMap();
List<String> fieldList = new List<String>();
for(String field :schemaFieldMap.keyset()){
fieldList.add(field);
}
return fieldList;
}
    public static List<String> getDraupChildFieldList()
    {
        Map<String, Schema.SObjectField> schemaFieldMap = Schema.SObjectType.draupApp__DraupChild__c.fields.getMap();
        List<String> fieldList = new List<String>();
        for(String field :schemaFieldMap.keyset()){
            fieldList.add(field);
        }
        return fieldList;
    }*/
}