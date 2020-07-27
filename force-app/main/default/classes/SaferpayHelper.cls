public class SaferpayHelper {
    public static List<SaferpayError__c> errorList;
    public static List<Payment__c> recordsToUpdate;
    
    static {
        errorList = new List<SaferpayError__c>();
        recordsToUpdate = new List<Payment__c>();
    }
    
    public static String getPayload(String requestType, Payment__c record) {
        String payload;
        if(requestType.equals('initialize')) {
            payload = serializePPInitializeRequest(record);
        }
        if(requestType.equals('assert')) {
            payload = serializePPAssertRequest(record);
        }
        if(requestType.equals('capture')) {
            payload = serializeTCaptureRequest(record);
        }
        return payload;
    }
    
    public static void deserializeResponse(String requestType, HttpResponse response) {
        if(response.getStatusCode() != 200) {
            deserializeErrorResponse(response);
        } else {
            if(requestType.equals('initialize')) {
                deserializePPInitializeResponse(response);
            }
            if(requestType.equals('assert')) {
                deserializePPAssertResponse(response);
            }
            if(requestType.equals('capture')) {
                deserializeTCaptureResponse(response);
            }
        }
    }
    
    public static void performDML() {
        try {
            if(!errorList.isEmpty()) {
                insert errorList;
            }
            if(!recordsToUpdate.isEmpty()) {
                update recordsToUpdate;
            }
        } catch(Exception ex) {
            System.debug(ex.getStackTraceString());
        }
    }
    
    private static String serializePPInitializeRequest(Payment__c record) {
        SaferpayPPInitializeRequest initializeRequestWrapper = SaferpayUtils.mapPaymentToInitializeRequest(record);
        return System.JSON.serialize(initializeRequestWrapper);
    }
    
    private static String serializePPAssertRequest(Payment__c record) {
        SaferpayPPAssertRequest assertRequestWrapper = SaferpayUtils.mapPaymentToAssertRequest(record);
        return System.JSON.serialize(assertRequestWrapper);
    }
    
    private static String serializeTCaptureRequest(Payment__c record) {
        SaferpayTCaptureRequest captureRequestWrapper = SaferpayUtils.mapPaymentToCaptureRequest(record);
        return System.JSON.serialize(captureRequestWrapper);
    }
    
    private static void deserializeErrorResponse(HttpResponse response) {
        SaferpayErrorResponse responseWrapper = SaferpayErrorResponse.parse(response.getBody());
        errorList.add(SaferpayUtils.mapErrorWrapperToSobject(responseWrapper, response.getStatusCode()));
        Payment__c tempPaymentRecord = findPaymentById(responseWrapper.ResponseHeader.RequestId);
        if(tempPaymentRecord == null) {
            recordsToUpdate.add(new Payment__c(
	            Id = responseWrapper.ResponseHeader.RequestId, 
	            IsPaymentComplete__c = false,
	            HasError__c = true,
	            LastErrorReceivedAt__c = System.now(),
	            TransactionId__c = null,
	            TransactionStatus__c = 'Failed'
	        ));
        } else {
            tempPaymentRecord.IsPaymentComplete__c = false;
            tempPaymentRecord.HasError__c = true;
            tempPaymentRecord.LastErrorReceivedAt__c = System.now();
            tempPaymentRecord.TransactionId__c = null;
            tempPaymentRecord.TransactionStatus__c = 'Failed';
        }
    }
    
    private static void deserializePPInitializeResponse(HttpResponse response) {
        SaferpayPPInitializeResponse responseWrapper = SaferpayPPInitializeResponse.parse(response.getBody());
        recordsToUpdate.add(new Payment__c(
            Id = responseWrapper.ResponseHeader.RequestId, 
            IsPaymentComplete__c = false,
            HasError__c = false,
            PaymentToken__c = responseWrapper.Token,
            PaymentTokenExpiration__c = SaferpayUtils.iso8601StringToDatetime(responseWrapper.Expiration),
            LegacyPaymentLink__c = responseWrapper.RedirectUrl,
            TransactionId__c = null,
            TransactionStatus__c = 'Pending'
        ));
    }
    
    private static void deserializePPAssertResponse(HttpResponse response) {
        SaferpayPPAssertResponse responseWrapper = SaferpayPPAssertResponse.parse(response.getBody());
        Payment__c tempPaymentRecord = findPaymentById(responseWrapper.ResponseHeader.RequestId);
        if(tempPaymentRecord == null) {
            recordsToUpdate.add(new Payment__c(
                Id = responseWrapper.ResponseHeader.RequestId, 
                TransactionId__c = responseWrapper.Transaction_Z.Id,
                TransactionStatus__c = (responseWrapper.Transaction_Z.Status == 'AUTHORIZED')? 'Pending' : 'Paid',
                HasError__c = false,
                PaymentDate__c = (responseWrapper.Transaction_Z.Status == 'AUTHORIZED')? null : System.today(),
                PaymentMethod__c = (responseWrapper.PaymentMeans != null && responseWrapper.PaymentMeans.Brand != null && String.isNotBlank(responseWrapper.PaymentMeans.Brand.PaymentMethod))? responseWrapper.PaymentMeans.Brand.PaymentMethod : null
            ));
        } else {
            tempPaymentRecord.TransactionId__c = responseWrapper.Transaction_Z.Id;
            tempPaymentRecord.TransactionStatus__c = (responseWrapper.Transaction_Z.Status == 'AUTHORIZED')? 'Pending' : 'Paid';
            tempPaymentRecord.HasError__c = false;
            tempPaymentRecord.PaymentDate__c = (responseWrapper.Transaction_Z.Status == 'AUTHORIZED')? null : System.today();
            tempPaymentRecord.PaymentMethod__c = (responseWrapper.PaymentMeans != null && responseWrapper.PaymentMeans.Brand != null && String.isNotBlank(responseWrapper.PaymentMeans.Brand.PaymentMethod))? responseWrapper.PaymentMeans.Brand.PaymentMethod : null;
        }
        
    }
    
    private static void deserializeTCaptureResponse(HttpResponse response) {
        SaferpayTCaptureResponse responseWrapper = SaferpayTCaptureResponse.parse(response.getBody());
        Payment__c tempPaymentRecord = findPaymentById(responseWrapper.ResponseHeader.RequestId);
        if(tempPaymentRecord == null) {
            recordsToUpdate.add(new Payment__c(
                Id = responseWrapper.ResponseHeader.RequestId, 
                TransactionStatus__c = 'Paid',
                TransactionCaptureDate__c = SaferpayUtils.iso8601StringToDatetime(responseWrapper.CaptureDate),
                HasError__c = false,
                IsPaymentComplete__c = true,
                PaymentDate__c = System.today()
            ));
        } else {
            tempPaymentRecord.TransactionCaptureDate__c = SaferpayUtils.iso8601StringToDatetime(responseWrapper.CaptureDate);
            tempPaymentRecord.TransactionStatus__c = 'Paid';
            tempPaymentRecord.HasError__c = false;
            tempPaymentRecord.IsPaymentComplete__c = true;
            tempPaymentRecord.PaymentDate__c = System.today();
        }
        
    }
    
    private static Payment__c findPaymentById(String id) {
        for(Payment__c tempPaymentRecord : recordsToUpdate) {
            if(tempPaymentRecord.Id == id) {
                return tempPaymentRecord;
            }
        }
        return null;
    }
}