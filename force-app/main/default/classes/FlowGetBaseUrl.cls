global class FlowGetBaseUrl {
    
    @InvocableMethod(
        label='Get Base URL' 
        description='Returns the base url for the current org' 
        category='Users'
    )
    global static List<BaseUrl> getBaseUrl() {
        BaseUrl bu = new BaseUrl();
        bu.orgBaseUrl = System.URL.getSalesforceBaseUrl().toExternalForm();
        List<BaseUrl> lstUrls = new List<BaseUrl>();
        lstUrls.add(bu);
        return lstUrls;
    }
    
    global class BaseUrl {
        @InvocableVariable(label='Base URL')
        global String orgBaseUrl;
    }

}