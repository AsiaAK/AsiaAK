@IsTest
private class SaferpayTCaptureResponseTest {
    
    // This test method should give 100% coverage
    static testMethod void testParse() {
        String json = '{'+
        '  \"ResponseHeader\": {'+
        '    \"SpecVersion\": \"1.3\",'+
        '    \"RequestId\": \"[your request id]\"'+
        '  },'+
        '  \"TransactionId\": \"723n4MAjMdhjSAhAKEUdA8jtl9jb\",'+
        '  \"Date\": \"2015-01-30T12:45:22.258+01:00\"'+
        '}';
        SaferpayTCaptureResponse r = SaferpayTCaptureResponse.parse(json);
        System.assert(r != null);

        json = '{\"TestAMissingObject\": { \"TestAMissingArray\": [ { \"TestAMissingProperty\": \"Some Value\" } ] } }';
        SaferpayTCaptureResponse.ResponseHeader objResponseHeader = new SaferpayTCaptureResponse.ResponseHeader(System.JSON.createParser(json));
        System.assert(objResponseHeader != null);
        System.assert(objResponseHeader.SpecVersion == null);
        System.assert(objResponseHeader.RequestId == null);

        json = '{\"TestAMissingObject\": { \"TestAMissingArray\": [ { \"TestAMissingProperty\": \"Some Value\" } ] } }';
        SaferpayTCaptureResponse objRoot = new SaferpayTCaptureResponse(System.JSON.createParser(json));
        System.assert(objRoot != null);
        System.assert(objRoot.ResponseHeader == null);
        System.assert(objRoot.TransactionId == null);
        System.assert(objRoot.CaptureDate == null);
    }
}