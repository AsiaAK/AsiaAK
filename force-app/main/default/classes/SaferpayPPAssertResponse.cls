public class SaferpayPPAssertResponse {
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

    public class Brand {
        public String PaymentMethod {get;set;} 
        public String Name {get;set;} 

        public Brand(JSONParser parser) {
            while (parser.nextToken() != JSONToken.END_OBJECT) {
                if (parser.getCurrentToken() == JSONToken.FIELD_NAME) {
                    String text = parser.getText();
                    if (parser.nextToken() != JSONToken.VALUE_NULL) {
                        if (text == 'PaymentMethod') {
                            PaymentMethod = parser.getText();
                        } else if (text == 'Name') {
                            Name = parser.getText();
                        } else {
                            System.debug(LoggingLevel.WARN, 'Brand consuming unrecognized property: '+text);
                            consumeObject(parser);
                        }
                    }
                }
            }
        }
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
    public Transaction_Z Transaction_Z {get;set;} // in json: Transaction
    public PaymentMeans PaymentMeans {get;set;} 

    public SaferpayPPAssertResponse(JSONParser parser) {
        while (parser.nextToken() != JSONToken.END_OBJECT) {
            if (parser.getCurrentToken() == JSONToken.FIELD_NAME) {
                String text = parser.getText();
                if (parser.nextToken() != JSONToken.VALUE_NULL) {
                    if (text == 'ResponseHeader') {
                        ResponseHeader = new ResponseHeader(parser);
                    } else if (text == 'Transaction') {
                        Transaction_Z = new Transaction_Z(parser);
                    } else if (text == 'PaymentMeans') {
                        PaymentMeans = new PaymentMeans(parser);
                    } else {
                        System.debug(LoggingLevel.WARN, 'Root consuming unrecognized property: '+text);
                        consumeObject(parser);
                    }
                }
            }
        }
    }
    
    public class Amount {
        public String Value {get;set;} 
        public String CurrencyCode {get;set;} 

        public Amount(JSONParser parser) {
            while (parser.nextToken() != JSONToken.END_OBJECT) {
                if (parser.getCurrentToken() == JSONToken.FIELD_NAME) {
                    String text = parser.getText();
                    if (parser.nextToken() != JSONToken.VALUE_NULL) {
                        if (text == 'Value') {
                            Value = parser.getText();
                        } else if (text == 'CurrencyCode') {
                            CurrencyCode = parser.getText();
                        } else {
                            System.debug(LoggingLevel.WARN, 'Amount consuming unrecognized property: '+text);
                            consumeObject(parser);
                        }
                    }
                }
            }
        }
    }
    
    public class Transaction_Z {
        public String Type_Z {get;set;} // in json: Type
        public String Status {get;set;} 
        public String Id {get;set;} 
        public String Date_Z {get;set;} 
        public Amount Amount {get;set;} 
        public String AcquirerName {get;set;} 
        public String AcquirerReference {get;set;} 
        public String ApprovalCode {get;set;}

        public Transaction_Z(JSONParser parser) {
            while (parser.nextToken() != JSONToken.END_OBJECT) {
                if (parser.getCurrentToken() == JSONToken.FIELD_NAME) {
                    String text = parser.getText();
                    if (parser.nextToken() != JSONToken.VALUE_NULL) {
                        if (text == 'Type') {
                            Type_Z = parser.getText();
                        } else if (text == 'Status') {
                            Status = parser.getText();
                        } else if (text == 'Id') {
                            Id = parser.getText();
                        } else if (text == 'Date') {
                            Date_Z = parser.getText();
                        } else if (text == 'Amount') {
                            Amount = new Amount(parser);
                        } else if (text == 'AcquirerName') {
                            AcquirerName = parser.getText();
                        } else if (text == 'AcquirerReference') {
                            AcquirerReference = parser.getText();
                        } else if (text == 'ApprovalCode') {
                            ApprovalCode = parser.getText();
                        } else {
                            System.debug(LoggingLevel.WARN, 'Transaction_Z consuming unrecognized property: '+text);
                            consumeObject(parser);
                        }
                    }
                }
            }
        }
    }
    
    public class Card {
        public String MaskedNumber {get;set;} 
        public Integer ExpYear {get;set;} 
        public Integer ExpMonth {get;set;} 
        public String HolderName {get;set;} 
        public String CountryCode {get;set;} 

        public Card(JSONParser parser) {
            while (parser.nextToken() != JSONToken.END_OBJECT) {
                if (parser.getCurrentToken() == JSONToken.FIELD_NAME) {
                    String text = parser.getText();
                    if (parser.nextToken() != JSONToken.VALUE_NULL) {
                        if (text == 'MaskedNumber') {
                            MaskedNumber = parser.getText();
                        } else if (text == 'ExpYear') {
                            ExpYear = parser.getIntegerValue();
                        } else if (text == 'ExpMonth') {
                            ExpMonth = parser.getIntegerValue();
                        } else if (text == 'HolderName') {
                            HolderName = parser.getText();
                        } else if (text == 'CountryCode') {
                            CountryCode = parser.getText();
                        } else {
                            System.debug(LoggingLevel.WARN, 'Card consuming unrecognized property: '+text);
                            consumeObject(parser);
                        }
                    }
                }
            }
        }
    }
    
    public class PaymentMeans {
        public Brand Brand {get;set;} 
        public String DisplayText {get;set;} 
        public Card Card {get;set;} 

        public PaymentMeans(JSONParser parser) {
            while (parser.nextToken() != JSONToken.END_OBJECT) {
                if (parser.getCurrentToken() == JSONToken.FIELD_NAME) {
                    String text = parser.getText();
                    if (parser.nextToken() != JSONToken.VALUE_NULL) {
                        if (text == 'Brand') {
                            Brand = new Brand(parser);
                        } else if (text == 'DisplayText') {
                            DisplayText = parser.getText();
                        } else if (text == 'Card') {
                            Card = new Card(parser);
                        } else {
                            System.debug(LoggingLevel.WARN, 'PaymentMeans consuming unrecognized property: '+text);
                            consumeObject(parser);
                        }
                    }
                }
            }
        }
    }
    
    
    public static SaferpayPPAssertResponse parse(String json) {
        return new SaferpayPPAssertResponse(System.JSON.createParser(json));
    }
}