public class SaferpayErrorResponse {

    public class ResponseHeader {
        public String SpecVersion;
        public String RequestId;
    }

    public ResponseHeader ResponseHeader;
    public String Behavior;
    public String ErrorName;
    public String ErrorMessage;
    public String TransactionId;
    public List<String> ErrorDetail;
    public String ProcessorName;
    public String ProcessorResult;
    public String ProcessorMessage;
    
    public static SaferpayErrorResponse parse(String json) {
        return (SaferpayErrorResponse) System.JSON.deserialize(json, SaferpayErrorResponse.class);
    }
}