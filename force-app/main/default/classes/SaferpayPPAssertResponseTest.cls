@IsTest
public class SaferpayPPAssertResponseTest {
    
    // This test method should give 100% coverage
    static testMethod void testParse() {
        String json = '{'+
        '  \"ResponseHeader\": {'+
        '    \"SpecVersion\": \"1.3\",'+
        '    \"RequestId\": \"dasdasd\"'+
        '  },'+
        '  \"Transaction\": {'+
        '    \"Type\": \"PAYMENT\",'+
        '    \"Status\": \"AUTHORIZED\",'+
        '    \"Id\": \"723n4MAjMdhjSAhAKEUdA8jtl9jb\",'+
        '    \"Date\": \"2015-01-30T12:45:22.258+01:00\",'+
        '    \"Amount\": {'+
        '      \"Value\": \"100\",'+
        '      \"CurrencyCode\": \"CHF\"'+
        '    },'+
        '    \"AcquirerName\": \"Saferpay Test Card\",'+
        '    \"AcquirerReference\": \"000000\",'+
        '    \"ApprovalCode\": \"000000\"'+
        '  },'+
        '  \"PaymentMeans\": {'+
        '    \"Brand\": {'+
        '      \"PaymentMethod\": \"SAFERPAYTEST\",'+
        '      \"Name\": \"Saferpay Test Card\"'+
        '    },'+
        '    \"DisplayText\": \"9123 45xx xxxx 1234\",'+
        '    \"Card\": {'+
        '      \"MaskedNumber\": \"912345xxxxxx1234\",'+
        '      \"ExpYear\": 2015,'+
        '      \"ExpMonth\": 9,'+
        '      \"HolderName\": \"Max Mustermann\",'+
        '      \"CountryCode\": \"CH\"'+
        '    }'+
        '  }'+
        '}';
        SaferpayPPAssertResponse r = SaferpayPPAssertResponse.parse(json);
        System.assert(r != null);

        json = '{\"TestAMissingObject\": { \"TestAMissingArray\": [ { \"TestAMissingProperty\": \"Some Value\" } ] } }';
        SaferpayPPAssertResponse.Brand objBrand = new SaferpayPPAssertResponse.Brand(System.JSON.createParser(json));
        System.assert(objBrand != null);
        System.assert(objBrand.PaymentMethod == null);
        System.assert(objBrand.Name == null);

        json = '{\"TestAMissingObject\": { \"TestAMissingArray\": [ { \"TestAMissingProperty\": \"Some Value\" } ] } }';
        SaferpayPPAssertResponse.ResponseHeader objResponseHeader = new SaferpayPPAssertResponse.ResponseHeader(System.JSON.createParser(json));
        System.assert(objResponseHeader != null);
        System.assert(objResponseHeader.SpecVersion == null);
        System.assert(objResponseHeader.RequestId == null);

        json = '{\"TestAMissingObject\": { \"TestAMissingArray\": [ { \"TestAMissingProperty\": \"Some Value\" } ] } }';
        SaferpayPPAssertResponse objRoot = new SaferpayPPAssertResponse(System.JSON.createParser(json));
        System.assert(objRoot != null);
        System.assert(objRoot.ResponseHeader == null);
        System.assert(objRoot.Transaction_Z == null);
        System.assert(objRoot.PaymentMeans == null);

        json = '{\"TestAMissingObject\": { \"TestAMissingArray\": [ { \"TestAMissingProperty\": \"Some Value\" } ] } }';
        SaferpayPPAssertResponse.Amount objAmount = new SaferpayPPAssertResponse.Amount(System.JSON.createParser(json));
        System.assert(objAmount != null);
        System.assert(objAmount.Value == null);
        System.assert(objAmount.CurrencyCode == null);

        json = '{\"TestAMissingObject\": { \"TestAMissingArray\": [ { \"TestAMissingProperty\": \"Some Value\" } ] } }';
        SaferpayPPAssertResponse.Transaction_Z objTransaction_Z = new SaferpayPPAssertResponse.Transaction_Z(System.JSON.createParser(json));
        System.assert(objTransaction_Z != null);
        System.assert(objTransaction_Z.Type_Z == null);
        System.assert(objTransaction_Z.Status == null);
        System.assert(objTransaction_Z.Id == null);
        System.assert(objTransaction_Z.Date_Z == null);
        System.assert(objTransaction_Z.Amount == null);
        System.assert(objTransaction_Z.AcquirerName == null);
        System.assert(objTransaction_Z.AcquirerReference == null);

        json = '{\"TestAMissingObject\": { \"TestAMissingArray\": [ { \"TestAMissingProperty\": \"Some Value\" } ] } }';
        SaferpayPPAssertResponse.Card objCard = new SaferpayPPAssertResponse.Card(System.JSON.createParser(json));
        System.assert(objCard != null);
        System.assert(objCard.MaskedNumber == null);
        System.assert(objCard.ExpYear == null);
        System.assert(objCard.ExpMonth == null);
        System.assert(objCard.HolderName == null);
        System.assert(objCard.CountryCode == null);

        json = '{\"TestAMissingObject\": { \"TestAMissingArray\": [ { \"TestAMissingProperty\": \"Some Value\" } ] } }';
        SaferpayPPAssertResponse.PaymentMeans objPaymentMeans = new SaferpayPPAssertResponse.PaymentMeans(System.JSON.createParser(json));
        System.assert(objPaymentMeans != null);
        System.assert(objPaymentMeans.Brand == null);
        System.assert(objPaymentMeans.DisplayText == null);
        System.assert(objPaymentMeans.Card == null);
    }
}