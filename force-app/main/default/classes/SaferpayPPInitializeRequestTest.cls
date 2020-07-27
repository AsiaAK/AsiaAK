@IsTest
public class SaferpayPPInitializeRequestTest {
    
    static testMethod void testParse() {
        String json = '{'+
        '  \"RequestHeader\": {'+
        '    \"SpecVersion\": \"1.3\",'+
        '    \"CustomerId\": \"405714\",'+
        '    \"RequestId\": \"dasdasd\",'+
        '    \"RetryIndicator\": 0'+
        '  },'+
        '  \"TerminalId\": \"17821363 \",'+
        '  \"Payment\": {'+
        '    \"Amount\": {'+
        '      \"Value\": \"100\",'+
        '      \"CurrencyCode\": \"CHF\"'+
        '    },'+
        '    \"OrderId\": \"213124\",'+
        '    \"Description\": \"Description of payment\"'+
        '  },'+
        '  \"ReturnUrls\": {'+
        '    \"Success\": \"https://test.salesforce.com\",'+
        '    \"Fail\": \"https://test.salesforce.com\"'+
        '  }'+
        '}';
        SaferpayPPInitializeRequest obj = SaferpayPPInitializeRequest.parse(json);
        System.assert(obj != null);
    }
}