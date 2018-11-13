@isTest
public class DraupExecutiveWrapperTest {
  @isTest static void testMethodOne(){
        
       string result = '[\n'+
    	'{"bio": null,"executive_id": "4676","account": "IBM","location": "Austin, Texas Area, United States","executive_name": "Amir Simon"\n'+
  		'}]\n';
 		Lead ld = DraupTestUtility.createLead('test','1234');
        List<DraupChild__c> dcList = DraupTestUtility.CreateDraupChildList(ld);
	    dcList.sort();
        DraupExecutiveWrapper.parse(result);
        DraupExecutiveWrapper dw = new DraupExecutiveWrapper();
        dw.isSelected = true;
      	System.assertEquals(dw.isSelected , true);
            
    }
}