@isTest
private class DraupAccountResponseParseTest {

    static testMethod void parseJsonResponseForAccountMethod(){
   String jsonResponse = '{\n'+
    '"techstack": {"IT Service Management (ITSM)": ["Nagios","Webpack"],"Operations Management": ["Microsoft Dynamics GP"]},\n'+
    '"overview": {"rnd_spend_growth": 2.67,"rnd_spend": 13037,"total_it_workforce": 58790,"total_rnd_workforce": 35390,"headquarters": "Greater Seattle Area, United States","opportunity_index": 4.47024888234089},\n'+
    '"hiring": {"Coventry, United Kingdom": {"titles": {"AI Programmer": 1,"Senior UI/UX Engineer": 1},"skills": {"hardware": 1,"qa": 1}},\n'+
      '"Beijing Area, China": {"titles": {"Graphic Designer": 1,"Senior Software Engineer": 6},"skills": {"iot": 1,"bigdata": 1}}},\n'+
    '"executive_movement": [{"title": "Chief Technology Officer","executive_name": "Sven Oftedal","flux_date": "2018-08-30T12:00:00", "flux_type": "EXIT"},\n'+
        '{"title": "Executive Vice President, Windows and Devices Group","executive_name": "Terry Myerson","flux_date": "2018-08-30T12:00:00","flux_type": "EXIT"},\n'+
        '{"title": "Studio Head, The Initiative","executive_name": "Darrell Gallagher","flux_date": "2018-04-15T12:00:00","flux_type": "HIRED"}],\n'+
    '"outsourcing": {"locations": [ "Greater Seattle Area, United States","Hyderabad Area, India","Beijing Area, China","Bengaluru Area, India","National Capital Region, India","Chennai Area, India","Pune Area, India"],\n'+
        '"vendors": ["Accenture","HCL"],\n'+
        '"subverticals": ["Software Testing","UI/UX Design"]\n'+
    '},\n'+
    '"globalization": {"R&D": \n'+
			'[{"vendors": ["Accenture","Adisys Corporation"],"location_class": "Headquarter","headcount": 21000, "site_class": "R&D","subverticals": ["Cloud Engineering","Big Data Engineering"],"location": "Greater Seattle Area, United States","country": "United States of America"},\n'+
            '{ "vendors": ["Accenture","Capgemini"],"location_class": "Satellite","headcount": 1650, "site_class": "R&D","subverticals": [ "Cloud Engineering","Big Data Engineering"],"location": "Hyderabad Area, India","country": "India"}],\n'+
          '"IT": [\n'+
            '{"vendors": ["Accenture","Capgemini"], "location_class": null,"headcount": 2205,"site_class": "IT","subverticals": ["Information Technology"],"location": "Hyderabad Area, India","country": "India"}\n'+
			']\n'+
    '}\n,'+
    '"startegic_signals": [{\n'+
            '"news_title": "Biogen, Microsoft gain; PriceSmart, Silicon Motion fall","news_url": "https://www.washingtonpost.com/business/biogen-microsoft-gain-pricesmart-silicon-motion-fall/2018/07/06/c5ce02ba-815c-11e8-b3b5-b61896f90919_story.html","signal_type": "Financial and Market Activity","date_captured": "2018-07-06T00:00:00"\n'+
     '}\n'+
    ']\n'+
'}\n';
        
        Id accId = DraupTestUtility.CreateAccount();
        String draupId = '1234';
        List<DraupHeader__c> draupHeaderList = new List<DraupHeader__c>();
    DraupAccountResponseParser.parseJsonResponseForAccount(jsonResponse, draupHeaderList, accId, draupId);
    }
}