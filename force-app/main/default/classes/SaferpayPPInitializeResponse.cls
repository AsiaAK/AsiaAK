public class SaferpayPPInitializeResponse {

    public class ResponseHeader {
        public String SpecVersion;
        public String RequestId;
    }

    public ResponseHeader ResponseHeader;
    public String Token;
    public String Expiration;
    public String RedirectUrl;
    
    public static SaferpayPPInitializeResponse parse(String json) {
        return (SaferpayPPInitializeResponse) System.JSON.deserialize(json, SaferpayPPInitializeResponse.class);
    }
}