/**************************************************************************************************************
*   @author         Persistent Systems
*   @date           27/10/2018
*   @description    This class is used to log errors in ErrorLog custom object in case of error occured in 
                     catch block or callouts for bad response
***************************************************************************************************************/
public with sharing class ExceptionHandler
{
/*************************************************************************
* @description   Method to insert error caught in try/catch block
* @author        Persistent Systems
* @date          27/10/2018
* @parameter     String className,String methodName,String lineno,String errorDescription
* @return        void
**************************************************************************/
    public static void logApexError(String className,String methodName,String lineno,String errorDescription)
    {
        ErrorLog__c log = new ErrorLog__c();
        log.draupApp__Class_Name__c = className;
        log.draupApp__Error_Description__c = errorDescription;
        log.draupApp__Method_Name__c = methodName;
        log.draupApp__Line_Number__c	 = lineno;
        log.draupApp__Log_Time__c=System.now();
        log.draupApp__User__c = UserInfo.getUserId();
        Database.Insert (log);	
    }	
/*************************************************************************
* @description   Method to insert into errorlog object when bad response received in API callout 
* @author        Persistent Systems
* @date          27/10/2018
* @parameter     String className,String methodName,HttpResponse response
* @return        void
**************************************************************************/
    public static void logApexCalloutError(String className,String methodName,HttpResponse response)
    {
        ErrorLog__c log = new ErrorLog__c();
        log.draupApp__Class_Name__c = className;
        log.draupApp__Method_Name__c = methodName;
        log.draupApp__Log_Time__c=System.now();
        log.draupApp__User__c = UserInfo.getUserId();
        // You can get HTTP Status Code and Response Body
        if(response!=null)
        {
            log.draupApp__Error_Description__c = String.valueOf(response.getBody());
            log.draupApp__HTTP_Status_code__c = String.valueOf(response.getStatusCode());			
        }
        System.debug(' log *** '+log);
        Database.Insert (log);		
    }	
}