@IsTest
public class SaferpayErrorResponseTest {
    
    static testMethod void testParse() {
        String json = '{'+
        '  \"ResponseHeader\": {'+
        '    \"SpecVersion\": \"1.3\",'+
        '    \"RequestId\": \"dasdasd\"'+
        '  },'+
        '  \"Behavior\": \"ABORT\",'+
        '  \"ErrorName\": \"VALIDATION_FAILED\",'+
        '  \"ErrorMessage\": \"Request validation failed\",'+
        '  \"TransactionId\": \"723n4MAjMdhjSAhAKEUdA8jtl9jb\",'+
        '  \"ErrorDetail\": ['+
        '    \"PaymentMeans.BankAccount.IBAN: The field IBAN is invalid.\"'+
        '  ],'+
        '  \"ProcessorName\": \"processor\",'+
        '  \"ProcessorResult\": \"processor result\",'+
        '  \"ProcessorMessage\": \"processor message\"'+
        '}';
        SaferpayErrorResponse obj = SaferpayErrorResponse.parse(json);
        System.assert(obj != null);
    }
}