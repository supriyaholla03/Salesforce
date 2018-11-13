/**************************************************************************************************************
*   @author         Persistent Systems
*   @date           20/09/2018
*   @description    This wrapper class is used to parse executive  response
***************************************************************************************************************/
public with sharing class DraupLeadInfoWrapper {

	public List<Experiences> experiences;
	public Psychological_analysis psychological_analysis;
	public List<Overview> overview;

	public class Psychological_analysis {
		public List<String> personalities;
		public List<String> engagement_guidelines;
	}
	public class Experiences {
		public String start_date;
		public String account_name;
		public String designation;
		public String end_date;
	}
	public class Overview {
		public String budget_control;
		public String image_link;
		public Double opportunity_index;
		public String designation;
		public List<String> subverticals;
		public List<String> key_vendors;
		public String deal_size_influencce;
		public String contact_details;
		public String business_unit;
		public String location;
        public String account_id;
        public String executive_name;
	}

/***************************************************************************************************
    * @description   This method is used to Parse the response
    * @author        Persistent Systems
    * @date          20/09/2018
    * @return        List
    ****************************************************************************************************/	
public static DraupLeadInfoWrapper parse(String json) 
{
    	System.debug(' GG 12 response ' + json);
		return (DraupLeadInfoWrapper) System.JSON.deserialize(json, DraupLeadInfoWrapper.class);
	}
}