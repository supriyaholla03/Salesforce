@IsTest
public class DraupUniverseWrapperTest {
    
    @isTest static void testMethodOne(){
        
       string result = '[{"account_id": 1376414,"account_name": "MicroStrategy Inc","isSelected": false},{"account_id": 556516, "account_name": "Microchip Technology Inc.","isSelected": false}]';

        DraupUniverseWrapper.parse(result);
        DraupUniverseWrapper dw = new DraupUniverseWrapper();
        dw.isSelected = true;
            
    }

}