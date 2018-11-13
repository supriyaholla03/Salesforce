@isTest
private class ExceptionHandlerTest {
 @isTest static void testMethodlogApexError(){
     System.test.startTest();
     ExceptionHandler.logApexError('Test Class','testMethod','12','Error occured');
      System.test.stopTest();
 }
  @isTest static void testMethodlogApexCalloutError(){
     System.test.startTest();
      HttpResponse response = new HttpResponse();
      response.setBody('Value error');
      response.setStatusCode(500);
     ExceptionHandler.logApexCalloutError('Test Class','testMethod',response);
      System.test.stopTest();
 }
}