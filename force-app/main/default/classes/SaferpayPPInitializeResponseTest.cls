@IsTest
public class SaferpayPPInitializeResponseTest {
    
    static testMethod void testParse() {
        String json = '{'+
        '  \"ResponseHeader\": {'+
        '    \"SpecVersion\": \"1.3\",'+
        '    \"RequestId\": \"dasdasd\"'+
        '  },'+
        '  \"Token\": \"234uhfh78234hlasdfh8234e1234\",'+
        '  \"Expiration\": \"2015-01-30T12:45:22.258+01:00\",'+
        '  \"RedirectUrl\": \"https://www.saferpay.com/vt2/api/...\"'+
        '}';
        SaferpayPPInitializeResponse obj = SaferpayPPInitializeResponse.parse(json);
        System.assert(obj != null);
    }
}