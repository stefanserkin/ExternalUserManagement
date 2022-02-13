@isTest
private class FlowGetBaseUrl_Test {
    
    @isTest
    static void testGetBaseUrl() {
        String orgBaseUrl = System.URL.getSalesforceBaseUrl().toExternalForm();
        List<FlowGetBaseUrl.BaseUrl> lstReturnedUrls = FlowGetBaseUrl.getBaseUrl();
        String returnedUrl = lstReturnedUrls.get(0).orgBaseUrl;
        System.assertEquals(
            orgBaseUrl, 
            returnedUrl,
            'Should have received the base url for the org'
        );
    }

}