public class Saferpay {
    public static void initializePayment(Payment__c record) {
        String path = '/Payment/v1/PaymentPage/Initialize';
        String payload = SaferpayHelper.getPayload('initialize', record);
        system.debug(payload);
        HttpRequest request = new HttpRequest();
        request.setEndpoint(SaferpayUtils.namedCredential + path);
        request.setMethod('POST');
        request.setHeader('Content-Type', 'application/json; charset=utf-8');
        request.setHeader('Accept', 'application/json');
        request.setBody(payload);
        Http httpObject = new Http();
        HttpResponse response = httpObject.send(request);
        system.debug(response.getBody());
        SaferpayHelper.deserializeResponse('initialize', response);
    }
    
    public static void assertPayment(Payment__c record) {
        String path = '/Payment/v1/PaymentPage/Assert';
        String payload = SaferpayHelper.getPayload('assert', record);
        system.debug(payload);
        HttpRequest request = new HttpRequest();
        request.setEndpoint(SaferpayUtils.namedCredential + path);
        request.setMethod('POST');
        request.setHeader('Content-Type', 'application/json; charset=utf-8');
        request.setHeader('Accept', 'application/json');
        request.setBody(payload);
        Http httpObject = new Http();
        HttpResponse response = httpObject.send(request);
        system.debug(response.getBody());
        SaferpayHelper.deserializeResponse('assert', response);
    }
    
    public static void captureTransaction(Payment__c record) {
        String path = '/Payment/v1/Transaction/Capture';
        String payload = SaferpayHelper.getPayload('capture', record);
        system.debug(payload);
        HttpRequest request = new HttpRequest();
        request.setEndpoint(SaferpayUtils.namedCredential + path);
        request.setMethod('POST');
        request.setHeader('Content-Type', 'application/json; charset=utf-8');
        request.setHeader('Accept', 'application/json');
        request.setBody(payload);
        Http httpObject = new Http();
        HttpResponse response = httpObject.send(request);
        system.debug(response.getBody());
        SaferpayHelper.deserializeResponse('capture', response);
    }
    
    public static void httpsInterface(Payment__c record) {
        String endpoint = 'https://www.saferpay.com/hosting/CreatePayInit.asp?';
        String parameters = 'ACCOUNTID=' + SaferpayUtils.config.CustomerId__c + '-' + SaferpayUtils.config.TerminalId__c +
            '&AMOUNT=' + String.valueOf((SaferpayUtils.nullSafe(record.PaymentAmount__c) * 100).intValue()) + 
            '&CURRENCY=' + record.CurrencyIsoCode + 
            '&DESCRIPTION=Voruntersuchung' + 
            '&ORDERID=' + record.Id +
            '&SUCCESSLINK=' + SaferpayUtils.config.ResultUrl__c + '?paymentId=' + record.Id +
            '&NOTIFYURL=' + SaferpayUtils.config.ResultUrl__c + '?paymentId=' + record.Id +
            '&NOTIFYADDRESS=' + SaferpayUtils.config.NotifyAddress__c + 
            '&DELIVERY=no' + 
            '&APPEARANCE=mobile' + 
            '&CSSURL=' + SaferpayUtils.config.CssUrl__c;
        HttpRequest request = new HttpRequest();
        request.setEndpoint(endpoint + parameters);
        request.setMethod('GET');
        Http httpObject = new Http();
        HttpResponse response = httpObject.send(request);
        system.debug(response.getBody());
        if(response.getStatusCode() == 200) {
            record.LegacyPaymentLink__c = response.getBody();
            //record.LongPaymentLink__c = response.getBody();
            if(record.LegacyPaymentLink__c !=null && record.Short_Payment_Link__c==null){
                GoogleUrlShortener.shortenURL(response.getBody(),record.id);
            }
            record.TransactionStatus__c = 'Pending';
            record.HasError__c = false;
            SaferpayHelper.recordsToUpdate.add(record);
        } else {
            SaferpayError__c errorRecord = new SaferpayError__c();
            errorRecord.ErrorDescription__c = 'Https Interface error';
            errorRecord.ErrorMessage__c = response.getBody();
            errorRecord.HttpStatusCode__c = response.getStatusCode();
            errorRecord.PaymentRef__c = record.id;
            record.TransactionStatus__c = 'Failed';
            record.HasError__c = true;
            record.LastErrorReceivedAt__c = System.now();
            SaferpayHelper.recordsToUpdate.add(record);
            SaferpayHelper.errorList.add(errorRecord);
        }
    }
    public static String httpsVerify(String dataString, String signature, Payment__c record) {
        String endpoint = 'https://www.saferpay.com/hosting/VerifyPayConfirm.asp?';
        String parameters = 'DATA=' + EncodingUtil.urlEncode(dataString, 'UTF-8') +
            '&SIGNATURE=' + signature;
        HttpRequest request = new HttpRequest();
        request.setEndpoint(endpoint);
        request.setMethod('POST');
        request.setBody(parameters);
        Http httpObject = new Http();
        HttpResponse response = httpObject.send(request);
        String resultString = response.getBody();
        if(response.getStatusCode() == 200 && resultString.startsWith('OK')) {
            return resultString;
        } else {
            SaferpayError__c errorRecord = new SaferpayError__c();
            errorRecord.ErrorDescription__c = 'Https Interface error';
            errorRecord.ErrorMessage__c = response.getBody();
            errorRecord.HttpStatusCode__c = response.getStatusCode();
            errorRecord.PaymentRef__c = record.Id;
            record.TransactionStatus__c = 'Failed';
            record.HasError__c = true;
            record.LastErrorReceivedAt__c = System.now();
            SaferpayHelper.recordsToUpdate.add(record);
            SaferpayHelper.errorList.add(errorRecord);
        }
        return '';
    }
    
    public static Boolean httpsConfirm(String saferpayPaymentId, Payment__c record) {
        String endpoint = 'https://www.saferpay.com/hosting/PayCompleteV2.asp';
        String parameters = 'ACCOUNTID=' + SaferpayUtils.config.CustomerId__c + '-' + SaferpayUtils.config.TerminalId__c +
            '&ID=' + saferpayPaymentId;
        HttpRequest request = new HttpRequest();
        request.setEndpoint(endpoint);
        request.setMethod('POST');
        request.setBody(parameters);
        Http httpObject = new Http();
        HttpResponse response = httpObject.send(request);
        system.debug(response.getBody());
        if(response.getStatusCode() == 200) {
            return true;
        } else {
            SaferpayError__c errorRecord = new SaferpayError__c();
            errorRecord.ErrorDescription__c = 'Https Interface error';
            errorRecord.ErrorMessage__c = response.getBody();
            errorRecord.HttpStatusCode__c = response.getStatusCode();
            errorRecord.PaymentRef__c = record.Id;
            record.TransactionStatus__c = 'Failed';
            record.HasError__c = true;
            record.LastErrorReceivedAt__c = System.now();
            SaferpayHelper.recordsToUpdate.add(record);
            SaferpayHelper.errorList.add(errorRecord);
        }
        return false;
    }
}