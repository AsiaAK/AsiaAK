public class SaferpayPPInitializeRequest {
    public RequestHeader RequestHeader;
    public String TerminalId;
    public Payment Payment;
    public ReturnUrls ReturnUrls;
    public Notification Notification;
    public Styling Styling;
    
    public class Payment {
        public Amount Amount;
        public String OrderId;
        public String Description;
    }

    public class ReturnUrls {
        public String Success;
        public String Fail;
        public String Abort;
    }
    
    public class Notification {
        public String MerchantEmail;
        public String PayerEmail;
        public String NotifyUrl;
    }

    public class Amount {
        public String Value;
        public String CurrencyCode;
    }

    public class RequestHeader {
        public String SpecVersion;
        public String CustomerId;
        public String RequestId;
        public Integer RetryIndicator;
    }
    
    public class Styling {
        public String CssUrl;
        public String Theme;
    }
    
    public static SaferpayPPInitializeRequest parse(String json) {
        return (SaferpayPPInitializeRequest) System.JSON.deserialize(json, SaferpayPPInitializeRequest.class);
    }
}