/**************************************************************************************************************
*   @author         Persistent Systems
*   @date           26/09/2018
*   @description    This class is used to provide Encryption and decryption for String parameters 
***************************************************************************************************************/
public with sharing class DraupEncryptUtil {
    
/*************************************************************************************************************
* @description Method to get Crypto key from custom settings
* @author      Persistent Systems
* @param       -
* @date        26/09/2018
* @return      String
**************************************************************************************************************/

    public Static String getCryptoKey()
    {
        try{
        CryptoKeys__c oCk = CryptoKeys__c.getValues('Key');
            return oCk.Key__c;
        }catch(Exception ex){
            system.debug('Exception Occured'+ex.getMessage());
            ExceptionHandler.logApexError('DraupEncryptUtil', 'getCryptoKey', String.valueOf(ex.getLineNumber()), ex.getStackTraceString());
            return null;
        }
    }
    
/*************************************************************************************************************
* @description Method to Encrypt the String 
* @author      Persistent Systems
* @param       String Value
* @date        26/09/2018
* @return      String
**************************************************************************************************************/

    public Static String getEncryptedValue(String sValue)
    {
        try{
            String cryptoKey = DraupEncryptUtil.getCryptoKey();
            Blob data = Blob.valueOf(sValue);
            Blob encryptedData = Crypto.encryptWithManagedIV('AES128', EncodingUtil.base64Decode(cryptoKey), data);
            String sEncryptedData = EncodingUtil.base64Encode(encryptedData);
            return sEncryptedData;
        }catch(Exception ex){
            system.debug('Exception Occured'+ex.getMessage());
            ExceptionHandler.logApexError('DraupEncryptUtil', 'getEncryptedValue', String.valueOf(ex.getLineNumber()), ex.getStackTraceString());
            return null;
        }
    }
    
/*************************************************************************************************************
* @description Method to Decrypt the Encrypted Value 
* @author      Persistent Systems
* @param       String Value
* @date        26/09/2018
* @return      String
**************************************************************************************************************/
    public Static String getDecryptedValue(String sValue)
    {
        try{
            Blob cryptoKey = EncodingUtil.base64Decode(DraupEncryptUtil.getCryptoKey());
            Blob payloadBlob = EncodingUtil.base64Decode(sValue);
            Blob decryptedData  = Crypto.decryptWithManagedIV('AES128', cryptoKey, payloadBlob);
            String tokenValue = decryptedData.toString();
            return tokenValue;
        }
        catch(Exception ex)
        {
            System.debug('Line Number' + ex.getLineNumber() + 'Msg' +ex.getMessage() ); 
            ExceptionHandler.logApexError('DraupEncryptUtil', 'getDecryptedValue', String.valueOf(ex.getLineNumber()), ex.getStackTraceString());
            return null;
        }
    }

    
   
}