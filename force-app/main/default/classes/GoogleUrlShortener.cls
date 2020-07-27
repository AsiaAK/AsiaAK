global class GoogleUrlShortener {
   
    webService static void  shortenURL( String longURL, String paymentid ) {
         //String encKey   = Google_API_Setting__c.getInstance( 'URL Shortener Key' ).Value__c;
        //String endPoint = Google_API_Setting__c.getInstance( 'URL Shortener Endpoint' ).Value__c;
        //String endPoint = 'https://www.googleapis.com/urlshortener/v1/url?key='+accessToken;
        String endPoint = 'https://www.googleapis.com/urlshortener/v1/url?key=AIzaSyAakW0kPWep876LmnC6lab2EnPdtY3bPaQ';
        system.debug('myendpoint'+endPoint);
        String  body    = '{"longUrl" : "' + longURL+ '"}';
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        request.setEndpoint(endPoint);
        request.setMethod('POST');
        request.setbody(body);
        request.setHeader( 'Content-Type', 'application/json;charset=UTF-8');
        //request.setHeader( 'Content-Type', 'application/json');
        HttpResponse response = http.send(request);
        system.debug('myreq'+response);
        // If the request is successful, parse the JSON response.
        if (response.getStatusCode() == 200) {
             //Deserializes the JSON string into collections of primitive data types.
            Map<String, Object> results = (Map<String, Object>) JSON.deserializeUntyped(response.getBody());
            system.debug('Mayank'+results);
            string sUrl = string.valueof(results.get('id'));
            system.debug('Sharma'+sUrl);
           /* JSONParser parser = JSON.createParser( response.getBody() );
            parser.nextToken();
            parser.nextToken();
            parser.nextToken();
            parser.nextValue();
            String sUrl =  parser.getText();*/
            system.debug('Sharma'+sUrl);
            Payment__c p = new Payment__c ();
            p.Id   = paymentid;
            p.Short_Payment_Link__c = sUrl;
            update p;
            /*Payment__c payment =[select opportunity__c from payment__c where id=:paymentid];
            Opportunity o = new Opportunity(id=payment.opportunity__c);
            o.Short_Payment_Link__c = sUrl;
            update o;*/
        }
    }
}