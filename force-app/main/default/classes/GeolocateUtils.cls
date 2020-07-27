global with sharing class GeolocateUtils {
    private static String geocodingKey = 'AIzaSyAjDNte86epLdl3JsiCStRLIjq1UwU10nw'; //'AIzaSyBPQZbhsPiFPvBt76BP1aG5G3RCMFYXVDg';//'AIzaSyCw2lUe6fhv8LyTRCiSF4tTbP2S_d_utLg';

    public static void geocodeAccounts(List<sObject> sobjects, Map<Id, List<String>> addressesPrefixes, List<String> allAddressesPrefixes) {
        Boolean geocodeAllAddresses = allAddressesPrefixes == null ? false : true;
        for (sObject a : sobjects) {
            List<String> prefixes = geocodeAllAddresses ? allAddressesPrefixes : addressesPrefixes.get(a.Id);
            for (String prefix : prefixes) {
                getAddress(a, prefix);
            }
        }
        update sobjects;
    }

    public static String createAddressString(sObject obj, String prefix) {
        //create a string for the address to pass to Google Geocoding API
        String geoAddress = '';
        if (obj.get(prefix + 'PostalCode') == null || obj.get(prefix + 'Country') == null)
            return '';

        if (obj.get(prefix + 'Street') != null)
            geoAddress += obj.get(prefix + 'Street') + ', ';
        if (obj.get(prefix + 'City') != null)
            geoAddress += obj.get(prefix + 'City') + ', ';
        if (obj.get(prefix + 'State') != null)
            geoAddress += obj.get(prefix + 'State') + ', ';
        if (obj.get(prefix + 'Country') != null)
            geoAddress += obj.get(prefix + 'Country') + ', ';
        if (obj.get(prefix + 'PostalCode') != null)
            geoAddress += obj.get(prefix + 'PostalCode');

        return geoAddress;
    }

    public static void getAddress(sObject obj, String prefix) {
        String geoAddress = createAddressString(obj, prefix);
        //initialize co-ordinates
        double latitude = null;
        double longitude = null;
        if (geoAddress != '') {
            //encode the string so we can pass it as part of URL
            geoAddress = EncodingUtil.urlEncode(geoAddress, 'UTF-8');

            //build and make the callout to the Geocoding API
            Http http = new Http();
            HttpRequest request = new HttpRequest();
            request.setEndpoint('https://maps.googleapis.com/maps/api/geocode/json?address=' + geoAddress + '&key=' + geocodingKey + '&sensor=false');
            request.setMethod('GET');
            request.setTimeout(60000);

            try {
                //make the http callout
                HttpResponse response = new HttpResponse();
                String responseString;
                if (!Test.isRunningTest()) {
                    response = http.send(request);
                    System.debug('response:::' + response + ':::' + response.getBody());
                    responseString = response.getBody();
                } else {
                    responseString = GeolocateUtilsTest.getResponse();
                }
                //parse JSON to extract co-ordinates
                JSONParser responseParser = JSON.createParser(responseString);

                while (responseParser.nextToken() != null) {
                    if ((responseParser.getCurrentToken() == JSONToken.FIELD_NAME) && (responseParser.getText() == 'location')) {
                        responseParser.nextToken();
                        while (responseParser.nextToken() != JSONToken.END_OBJECT) {
                            String locationText = responseParser.getText();
                            responseParser.nextToken();
                            if (locationText == 'lat')
                                latitude = responseParser.getDoubleValue(); else if (locationText == 'lng')
                                longitude = responseParser.getDoubleValue();
                        }
                    }
                }
            } catch (Exception e) {
            }

            if (latitude != null && longitude != null) {
                obj.put(prefix + 'Latitude', latitude);
                obj.put(prefix + 'Longitude', longitude);
            }
        }
    }


    public static GeocodeResult getGeocodeAddress(RecordAddress address) {
//        String geoAddress = createAddressString(obj, prefix);
        //initialize co-ordinates
        GeocodeResult result = new GeocodeResult();
        result.sfid = address.sfid;
//        if(geoAddress != '') {
        //encode the string so we can pass it as part of URL
//        geoAddress = EncodingUtil.urlEncode(geoAddress, 'UTF-8');

        //build and make the callout to the Geocoding API
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        request.setEndpoint('https://maps.googleapis.com/maps/api/geocode/json?address=' + address.toGoogleAddressString() + '&key=' + geocodingKey + '&sensor=false');
        request.setMethod('GET');
        request.setTimeout(60000);
        HttpResponse response = null; // http.send(request);
//        HttpResponse response = new HttpResponse();
        String responseString;
        if (Test.isRunningTest()) {
            responseString = GeolocateUtilsTest.getResponse();
        } else {
            response = http.send(request);
            System.debug('response:::' + response + ':::' + response.getBody());
            responseString = response.getBody();

        }
        //parse JSON to extract co-ordinates
        JSONParser responseParser = JSON.createParser(responseString);

        while (responseParser.nextToken() != null) {
            if ((responseParser.getCurrentToken() == JSONToken.FIELD_NAME) && (responseParser.getText() == 'location')) {
                responseParser.nextToken();
                while (responseParser.nextToken() != JSONToken.END_OBJECT) {
                    String locationText = responseParser.getText();
                    responseParser.nextToken();
                    if (locationText == 'lat') {
                        result.latitude = responseParser.getDecimalValue();
                    } else if (locationText == 'lng') {
                        result.longitude = responseParser.getDecimalValue();
                    }
                }
            }
        }

        return result;
    }

    public static void processAddress(sObject newObj, sObject olObj, String prefix, Boolean postponeGeocoding, Map<Id, LIst<String>> accountAddresses) {
        if (geolocationNeeded(newObj, olObj, prefix)) {
            if (!postponeGeocoding)
                accountAddresses.get(newObj.Id).add(prefix); else {
                newObj.put(prefix + 'Latitude', null);
                newObj.put(prefix + 'Longitude', null);
            }
        }
    }

    private static Boolean geolocationNeeded(sObject newObj, sObject olObj, String addressPrefix) {
        if (olObj == null)
            return true;
        if (newObj.get(addressPrefix + 'Street') != olObj.get(addressPrefix + 'Street'))
            return true;
        if (newObj.get(addressPrefix + 'City') != olObj.get(addressPrefix + 'City'))
            return true;
        if (newObj.get(addressPrefix + 'State') != olObj.get(addressPrefix + 'State'))
            return true;
        if (newObj.get(addressPrefix + 'Country') != olObj.get(addressPrefix + 'Country'))
            return true;
        if (newObj.get(addressPrefix + 'PostalCode') != olObj.get(addressPrefix + 'PostalCode'))
            return true;

        return false;
    }

}