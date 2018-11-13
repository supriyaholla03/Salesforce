@istest
public class DraupEncryptUtillTest {
    
   static testMethod void testDraupEncryptUtill() {
       
       CryptoKeys__c key = new CryptoKeys__c();
       key.name = 'Key';
       key.Key__c = 'hjshkashfalskdjfhirutowirutyurie';
       insert key;
       System.assertEquals(key.name, 'Key');
       DraupEncryptUtil.getCryptoKey();
       
   }

}