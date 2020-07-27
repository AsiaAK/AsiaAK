public class SaferpayTCaptureResponse {
    public static void consumeObject(JSONParser parser) {
        Integer depth = 0;
        do {
            JSONToken curr = parser.getCurrentToken();
            if (curr == JSONToken.START_OBJECT || 
                curr == JSONToken.START_ARRAY) {
                depth++;
            } else if (curr == JSONToken.END_OBJECT ||
                curr == JSONToken.END_ARRAY) {
                depth--;
            }
        } while (depth > 0 && parser.nextToken() != null);
    }

    public class ResponseHeader {
        public String SpecVersion {get;set;} 
        public String RequestId {get;set;} 

        public ResponseHeader(JSONParser parser) {
            while (parser.nextToken() != JSONToken.END_OBJECT) {
                if (parser.getCurrentToken() == JSONToken.FIELD_NAME) {
                    String text = parser.getText();
                    if (parser.nextToken() != JSONToken.VALUE_NULL) {
                        if (text == 'SpecVersion') {
                            SpecVersion = parser.getText();
                        } else if (text == 'RequestId') {
                            RequestId = parser.getText();
                        } else {
                            System.debug(LoggingLevel.WARN, 'ResponseHeader consuming unrecognized property: '+text);
                            consumeObject(parser);
                        }
                    }
                }
            }
        }
    }
    
    public ResponseHeader ResponseHeader {get;set;} 
    public String TransactionId {get;set;} 
    public String CaptureDate {get;set;} 

    public SaferpayTCaptureResponse(JSONParser parser) {
        while (parser.nextToken() != JSONToken.END_OBJECT) {
            if (parser.getCurrentToken() == JSONToken.FIELD_NAME) {
                String text = parser.getText();
                if (parser.nextToken() != JSONToken.VALUE_NULL) {
                    if (text == 'ResponseHeader') {
                        ResponseHeader = new ResponseHeader(parser);
                    } else if (text == 'TransactionId') {
                        TransactionId = parser.getText();
                    } else if (text == 'Date') {
                        CaptureDate = parser.getText();
                    } else {
                        System.debug(LoggingLevel.WARN, 'Root consuming unrecognized property: '+text);
                        consumeObject(parser);
                    }
                }
            }
        }
    }
    
    
    public static SaferpayTCaptureResponse parse(String json) {
        return new SaferpayTCaptureResponse(System.JSON.createParser(json));
    }
}