public with sharing class Utility{

	/***********************************************************************
    * @description   Method to encrypt the credentials used in Rest Callout.
    * @author        Persistent Systems
    * @date          16/10/2018
    * @return        String
    ************************************************************************/
    /*public static String Encrypt(String data){        
        if(data != null && data.length() > 0){
            // Create an instance for JDA_Constants and call the variables
           // JDA_Constants constants = new JDA_Constants();
            Blob key = EncodingUtil.base64Decode(constants.EncryptKey.trim());
            Blob dataBlob = Blob.valueOf(data);
          //  Blob encrypted = Crypto.encryptWithManagedIV('AES128', key,dataBlob);
            
            return EncodingUtil.base64Encode(encrypted);
        }else{
            return null;
        }
    }*/
    
    /************************************************************************
    * @description   Method to decrypt the credentials used in Rest Callout.
    * @author        Persistent Systems
    * @date          16/11/2017
    * @return        String
    *************************************************************************/
  /*  public static String Decrypt(String data){        
        if(data != null && data.length() > 0){
            // Create an instance for JDA_Constants and call the variables
            //JDA_Constants constants = new JDA_Constants();
            //Blob key = EncodingUtil.base64Decode(constants.EncryptKey.trim());        
            Blob encryptedBlob = EncodingUtil.base64Decode(data);
          //  Blob decrypted = Crypto.decryptWithManagedIV('AES128', key,encryptedBlob);
            return decrypted.toString();
        }else{
            return null;
        }
    }*/
    
    /************************************************************************************
    * @description   This method ensures the fields are Createable. Ensuring FLS.
    * @author        Persistent Systems
    * @date          16/11/2017
    * @return        Boolean
    ************************************************************************************/
	/*public static Boolean isCreateable(List<String> fieldNames, String objName){
		Boolean isValid = false;
		
		Map<String,Schema.SObjectType> sObjectSchemaMap = Schema.getGlobalDescribe();
		SObjectType currentObj = sObjectSchemaMap.get(objName);
		
		if(currentObj.getDescribe().isAccessible() && currentObj.getDescribe().isCreateable()){ 
			for(String fieldName : fieldNames){
				SObjectField currentField = currentObj.getDescribe().fields.getMap().get(fieldName);
				
				if(currentField.getDescribe().isAccessible() && currentField.getDescribe().isCreateable()){
					isValid = true;
				}else{
					isValid = false;
					break;
				} 
			}
		}else{
			isValid = false;
		}
		return isValid;
	}*/
	
	/***************************************************************************************************
    * @description   This method ensures the fields are Createable and Updateable. Ensuring FLS.
    * @author        Persistent Systems
    * @date          16/11/2017
    * @return        Boolean
    ****************************************************************************************************/
   /* public static Boolean isUpdateable(List<String> fieldNames, String objName){
        Boolean isValid = false;
        Map<String,Schema.SObjectType> schemaMap = Schema.getGlobalDescribe();
        SObjectType currentObj = schemaMap.get(objName);
        
        if(currentObj.getDescribe().isAccessible() && currentObj.getDescribe().isUpdateable()){ 
            for(String fieldName : fieldNames){
                SObjectField currentField = currentObj.getDescribe().fields.getMap().get(fieldName);
                
                if(currentField.getDescribe().isAccessible() && currentField.getDescribe().isUpdateable()){
                    isValid = true;
                }else{
                    isValid = false;
                    break;
                }    
            }
        }else{
            isValid = false;
        }
        return isValid;
    }*/
    
    /***************************************************************************************************
    * @description   This method ensures the fields are Accessible. Ensuring FLS.
    * @author        Persistent Systems
    * @date          16/11/2017
    * @return        Boolean
    ****************************************************************************************************/
    public static Boolean isAccessible(List<String> fieldNames, String objName){
        Boolean isValid = false;
        Map<String, Schema.SObjectType> schemaMap = Schema.getGlobalDescribe();
        SObjectType currentObj = schemaMap.get(objName);
        
        if(currentObj.getDescribe().isAccessible()){ 
            for(String fieldName : fieldNames){
                SObjectField currentField = currentObj.getDescribe().fields.getMap().get(fieldName);
                
                if(currentField.getDescribe().isAccessible()){
                    isValid = true;
                }else{
                    isValid = false;
                    break;
                }    
            }
        }else{
            isValid = false;
        }
        return isValid;
    }
	
	/***************************************************************************************************
    * @description   This method ensures the fields are Deletable. Ensuring FLS.
    * @author        Persistent Systems
    * @date          16/11/2017
    * @return        Boolean
    ****************************************************************************************************/
  /*  public static Boolean isDeletable(List<String> fieldNames, String objName){
        Boolean isValid = false;
        Map<String, Schema.SObjectType> schemaMap = Schema.getGlobalDescribe();
        SObjectType currentObj = schemaMap.get(objName);
        
        if(currentObj.getDescribe().isAccessible() && currentObj.getDescribe().isDeletable()){ 
            for(String fieldName : fieldNames){
                SObjectField currentField = currentObj.getDescribe().fields.getMap().get(fieldName);
                
                if(currentField.getDescribe().isAccessible() ){
                    isValid = true;
                }else{
                    isValid = false;
                    break;
                }    
            }
        }else{
            isValid = false;
        }
        return isValid;
    }*/

}