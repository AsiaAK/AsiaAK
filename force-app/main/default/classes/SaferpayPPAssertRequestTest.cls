@IsTest
public class SaferpayPPAssertRequestTest {
    
    static testMethod void testParse() {
        String json = '{'+
        '  \"RequestHeader\": {'+
        '    \"SpecVersion\": \"1.3\",'+
        '    \"CustomerId\": \"405714\",'+
        '    \"RequestId\": \"dasdasd\",'+
        '    \"RetryIndicator\": 0'+
        '  },'+
        '  \"Token\": \"234uhfh78234hlasdfh8234e\"'+
        '}';
        SaferpayPPAssertRequest obj = SaferpayPPAssertRequest.parse(json);
        System.assert(obj != null);
    }
}