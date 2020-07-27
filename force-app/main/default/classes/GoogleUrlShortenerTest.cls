@isTest(seeAllData=true)
private class GoogleUrlShortenerTest {
     @isTest static void testCallout() {
     Payment__c payment = [select id from payment__c limit 1];
     string url= 'http://test.com';
            // Set mock callout class 
     Test.setMock(HttpCalloutMock.class, new GoogleURLShortnerCalloutMock ());
     
     GoogleUrlShortener.shortenURL(url,payment.id);
        
    }
}