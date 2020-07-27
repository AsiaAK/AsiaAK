public without sharing class SaferpayUtils {
    public static final Map<String, String> BEHAVIOUR_DICTIONARY = new Map<String, String> {
        'ABORT'=>'Do not retry this request. It will never succeed.',
        'RETRY'=>'',
        'RETRY_LATER'=>'',
        'OTHER_MEANS'=>''
    };
    
    public static final Map<String, String> ERROR_DICTIONARY = new Map<String, String> {
        'AUTHENTICATION_FAILED'=>'Wrong password, wrong client certificate, invalid token, wrong HMAC. Solution: Use proper credentials, fix HMAC calculation, use valid token',
        'ALIAS_INVALID'=>'The alias is not known or already used (in case of registration). Solution: Use another alias for registration',
        'BLOCKED_BY_RISK_MANAGEMENT'=>'Action blocked by risk management. Solution: Unblock in Saferpay Risk Management (Backoffice)',
        'CARD_CHECK_FAILED'=>'Invalid card number or cvc (this is only returned for the SIX-internal chard check feature for Alias/InsertDirect). Solution: Let the card holder correct the entered data',
        'CARD_CVC_INVALID'=>'Wrong cvc entered. Solution: Retry with correct cvc',
        'CARD_CVC_REQUIRED'=>'Cvc not entered but required. Solution: Retry with cvc entered',
        'CARD_EXPIRED'=>'Card expired. Solution: Use another card or correct expiry date',
        'PAYMENTMEANS_INVALID'=>'Invalid means of payment (e.g. invalid card)',
        'INTERNAL_ERROR'=>'Internal error in Saferpay. Solution: Try again',
        '3DS_AUTHENTICATION_FAILED'=>'3D-secure authentication failed – the transaction must be aborted. Solution: Use another card or means of payment',
        'NO_CONTRACT'=>'No contract available for the brand / currency combination. Solution: Use another card or change the currency to match an existing contract or have the currency activated for the contract.',
        'NO_CREDITS_AVAILABLE'=>'No more credits available for this account. Solution: Buy more transaction credits',
        'PERMISSION_DENIED'=>'No permission (e.g. terminal does not belong to the customer)',
        'TRANSACTION_DECLINED'=>'Declined by the processor. Solution: Use another card or check details.',
        'VALIDATION_FAILED'=>'Validation failed. Solution: Fix request',
        'AMOUNT_INVALID'=>'The amount does not adhere to the restrictions for this action. E.g. it might be exceeding the allowed capture amount.',
        'CURRENCY_INVALID'=>'Currency does not match referenced transaction currency.',
        'COMMUNICATION_FAILED'=>'The communication to the processor failed. Solution: Try again or use another means of payment',
        'COMMUNICATION_TIMEOUT'=>'Saferpay did not receive a response from the external system in time. It’s possible that an authorization was created, but Saferpay is not able to know this. Solution: Check with the acquirer if there is an authorization which needs to be canceled.',
        'TOKEN_EXPIRED'=>'The token is expired. Solution: Create a new token.',
        'TOKEN_INVALID'=>'The token either does not exist for this customer or was already used',
        'TRANSACTION_IN_WRONG_STATE'=>'',
        'ACTION_NOT_SUPPORTED'=>'',
        'TRANSACTION_NOT_FOUND'=>'',
        'CONDITION_NOT_SATISFIED'=>'The condition which was defined in the request could not be satisfied.',
        'TRANSACTION_NOT_STARTED'=>'The transaction was not started by the payer. Therefore, no final result for the transaction is available. Solution: Try again later.',
        'TRANSACTION_ABORTED'=>'The transaction was aborted by the payer.'
    };
    
    public static Saferpay__c config;
    public static String namedCredential;
    
    static {
        config = Saferpay__c.getValues((isSandbox()? 'Config Sandbox' : 'Config'));
        if(config == null) {
            config = new Saferpay__c(
                Name = 'Config',
                CustomerId__c = '',
                TerminalId__c = '',
                SpecVersion__c = '',
                ResultUrl__c = '',
                NotifyUrl__c = '',
                CssUrl__c = '',
                NotifyAddress__c = '',
                UseHttpsInterface__c = false
            );
        }
        namedCredential = (isSandbox()? 'callout:SaferpaySandbox' : 'callout:Saferpay');
    }
    
    public static SaferpayError__c mapErrorWrapperToSobject(SaferpayErrorResponse errorWrapper, Integer httpStatusCode) {
        SaferpayError__c errorRecord = new SaferpayError__c();
        errorRecord.Behavior__c = errorWrapper.Behavior;
        errorRecord.BehaviourDescription__c = SaferpayUtils.BEHAVIOUR_DICTIONARY.get(errorWrapper.Behavior);
        errorRecord.ErrorDescription__c = SaferpayUtils.ERROR_DICTIONARY.get(errorWrapper.ErrorName);
        if(errorWrapper.ErrorDetail != null && !errorWrapper.ErrorDetail.isEmpty()) {
            errorRecord.ErrorDetail__c = System.String.join(errorWrapper.ErrorDetail, '\r\n');
        }
        errorRecord.ErrorMessage__c = errorWrapper.ErrorMessage;
        errorRecord.ErrorName__c = errorWrapper.ErrorName;
        errorRecord.HttpStatusCode__c = httpStatusCode;
        errorRecord.PaymentRef__c = errorWrapper.ResponseHeader.RequestId;
        errorRecord.ProcessorMessage__c = errorWrapper.ProcessorMessage;
        errorRecord.ProcessorName__c = errorWrapper.ProcessorName;
        errorRecord.ProcessorResult__c = errorWrapper.ProcessorResult;
        errorRecord.RequestId__c = errorWrapper.ResponseHeader.RequestId;
        errorRecord.TransactionId__c = errorWrapper.TransactionId;
        return errorRecord;
    }
    
    public static SaferpayPPInitializeRequest mapPaymentToInitializeRequest(Payment__c record) {
        System.debug('Name: ' + record.Name);
        SaferpayPPInitializeRequest initializeRequestWrapper = new SaferpayPPInitializeRequest();
            SaferpayPPInitializeRequest.RequestHeader requestHeaderWrapper = new SaferpayPPInitializeRequest.RequestHeader();
            requestHeaderWrapper.SpecVersion = config.SpecVersion__c;
            requestHeaderWrapper.CustomerId = config.CustomerId__c;
            requestHeaderWrapper.RequestId = record.Id;
            requestHeaderWrapper.RetryIndicator = 0;
        initializeRequestWrapper.RequestHeader = requestHeaderWrapper;
        initializeRequestWrapper.TerminalId = config.TerminalId__c;
            SaferpayPPInitializeRequest.Payment paymentWrapper = new SaferpayPPInitializeRequest.Payment();
            paymentWrapper.OrderId = record.PaymentID__c;
            paymentWrapper.Description = record.Name;
                SaferpayPPInitializeRequest.Amount amountWrapper = new SaferpayPPInitializeRequest.Amount();
                amountWrapper.Value = String.valueOf((nullSafe(record.PaymentAmount__c) * 100).intValue());
                amountWrapper.CurrencyCode = record.CurrencyIsoCode;
            paymentWrapper.Amount = amountWrapper;
        initializeRequestWrapper.Payment = paymentWrapper;
            SaferpayPPInitializeRequest.ReturnUrls returnUrlsWrapper = new SaferpayPPInitializeRequest.ReturnUrls();
            returnUrlsWrapper.Success = config.ResultUrl__c + '?paymentId=' + record.PaymentID__c;
            returnUrlsWrapper.Fail = config.ResultUrl__c + '?paymentId=' + record.PaymentID__c;
            returnUrlsWrapper.Abort = config.ResultUrl__c + '?paymentId=' + record.PaymentID__c;
        initializeRequestWrapper.ReturnUrls = returnUrlsWrapper;
            SaferpayPPInitializeRequest.Notification notficationWrapper = new SaferpayPPInitializeRequest.Notification();
            notficationWrapper.NotifyUrl = config.NotifyUrl__c + '?paymentId=' + record.PaymentID__c;
        initializeRequestWrapper.Notification = notficationWrapper;
        if(String.isNotBlank(config.CssUrl__c)) {
            SaferpayPPInitializeRequest.Styling stylingWrapper = new SaferpayPPInitializeRequest.Styling();
            stylingWrapper.CssUrl = config.CssUrl__c;
            initializeRequestWrapper.Styling = stylingWrapper;
        }
        return initializeRequestWrapper;
    }
    
    public static SaferpayTCaptureRequest mapPaymentToCaptureRequest(Payment__c record) {
        SaferpayTCaptureRequest captureRequestWrapper = new SaferpayTCaptureRequest();
            SaferpayTCaptureRequest.RequestHeader requestHeaderWrapper = new SaferpayTCaptureRequest.RequestHeader();
            requestHeaderWrapper.SpecVersion = config.SpecVersion__c;
            requestHeaderWrapper.CustomerId = config.CustomerId__c;
            requestHeaderWrapper.RequestId = record.Id;
            requestHeaderWrapper.RetryIndicator = 0;
        captureRequestWrapper.RequestHeader = requestHeaderWrapper;
            SaferpayTCaptureRequest.TransactionReference transactionReferenceWrapper = new SaferpayTCaptureRequest.TransactionReference();
            transactionReferenceWrapper.TransactionId = record.TransactionId__c;
        captureRequestWrapper.TransactionReference = transactionReferenceWrapper;
        return captureRequestWrapper;
    }
    
    public static SaferpayPPAssertRequest mapPaymentToAssertRequest(Payment__c record) {
        SaferpayPPAssertRequest assertRequestWrapper = new SaferpayPPAssertRequest();
            SaferpayPPAssertRequest.RequestHeader requestHeaderWrapper = new SaferpayPPAssertRequest.RequestHeader();
            requestHeaderWrapper.SpecVersion = config.SpecVersion__c;
            requestHeaderWrapper.CustomerId = config.CustomerId__c;
            requestHeaderWrapper.RequestId = record.Id;
            requestHeaderWrapper.RetryIndicator = 0;
        assertRequestWrapper.RequestHeader = requestHeaderWrapper;
        assertRequestWrapper.Token = record.PaymentToken__c;
        return assertRequestWrapper;
    }
    
    public static Datetime iso8601StringToDatetime(String datetimeString) {
        Datetime datetimeObject;
        datetimeObject = Datetime.valueOf(datetimeString.replace('T',' '));
        return datetimeObject;
    }
    
    public static Decimal nullSafe(Decimal value) {
        if(value == null) {
            value = 0;
        }
        return value;
    }
    
    public static Payment__c getPaymentByPaymentId(String paymentId) {
        Payment__c record;
        if(String.isBlank(paymentId)) {
            return record;
        }
        try {
            if(config.UseHttpsInterface__c) {
                record = [SELECT Id, PaymentToken__c, LegacyPaymentLink__c FROM Payment__c WHERE Id = :paymentId];
            } else {
                record = [SELECT Id, PaymentToken__c, LegacyPaymentLink__c FROM Payment__c WHERE PaymentID__c = :paymentId];
            }
        } catch(Exception ex) {
            record = null;
        }
        return record;
    }

    public static Boolean isSandbox() {
        return [SELECT IsSandbox FROM Organization LIMIT 1].IsSandbox;
    }
}