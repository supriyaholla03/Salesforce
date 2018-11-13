/**************************************************************************************************************
*   @author         Persistent Systems
*   @date           09/11/2018
*   @description    This class is used in case custom labels are referenced only in lightning 
***************************************************************************************************************/

global with sharing class DescribePackageCustomLabels {
     /***************************************************************************************************
    * @description   This method is used to include all custom labels to be added in alphabatical order to be added during Package generation 
    * @author        Persistent Systems
    * @param       	 
    * @date          09/11/2018
    * @return        Boolean
    ****************************************************************************************************/
    global static Boolean describeLabelLs()
    {
        String draupPlatformURL = System.Label.Draup_Platform_Url;
        return true ;
    }
}