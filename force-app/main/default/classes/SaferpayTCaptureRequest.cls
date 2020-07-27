public class SaferpayTCaptureRequest {
    public RequestHeader RequestHeader;
    public TransactionReference TransactionReference;
    
    public class RequestHeader {
        public String SpecVersion;
        public String CustomerId;
        public String RequestId;
        public Integer RetryIndicator;
    }
    
    public class TransactionReference {
        public String TransactionId;
        public String OrderId;
    }
}