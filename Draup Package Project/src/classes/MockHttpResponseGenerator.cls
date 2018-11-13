/**************************************************************************************************************
*   @author         Persistent Systems
*   @date           17/10/2018
*   @description    This class is used for mock http callouts in Test classes
***************************************************************************************************************/
public with sharing class MockHttpResponseGenerator implements HttpCalloutMock {
    // Implement this interface method
    public String jsonResponse;
    public Integer statusCode;
    public MockHttpResponseGenerator(){
        
    }
    
    public MockHttpResponseGenerator(String jsonResponse,Integer statusCode){
        System.debug('this.jsonResponse '+jsonResponse);
        system.debug('this.jsonResponse '+statusCode);
        this.jsonResponse = jsonResponse;
        this.statusCode = statusCode;
    }
/*************************************************************************
* @description   Method to get Httpresponse based on request
* @author        Persistent Systems
* @date          23/10/2018
* @parameter     HTTPRequest req
* @return        HTTPResponse
**************************************************************************/
    public HTTPResponse respond(HTTPRequest req) {
        // Create a fake response
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        res.setBody(jsonResponse);
        res.setStatusCode(statusCode);
        System.assertNotEquals(res, null);
        return res;
    }
}