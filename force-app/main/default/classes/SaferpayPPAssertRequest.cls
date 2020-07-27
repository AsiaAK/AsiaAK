public class SaferpayPPAssertRequest {

    public RequestHeader RequestHeader;
    public String Token;

    public class RequestHeader {
        public String SpecVersion;
        public String CustomerId;
        public String RequestId;
        public Integer RetryIndicator;
    }
    
    public static SaferpayPPAssertRequest parse(String json) {
        return (SaferpayPPAssertRequest) System.JSON.deserialize(json, SaferpayPPAssertRequest.class);
    }
}