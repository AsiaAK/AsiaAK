//Generated by wsdl2apex

public class oekopostwebservice {
    public class getAccountBalanceRequest_element {
        public String userName;
        public String passwordHash;
        public String passwordSalt;
        private String[] userName_type_info = new String[]{'userName','urn:OekopostWebService',null,'0','1','false'};
        private String[] passwordHash_type_info = new String[]{'passwordHash','urn:OekopostWebService',null,'0','1','false'};
        private String[] passwordSalt_type_info = new String[]{'passwordSalt','urn:OekopostWebService',null,'0','1','false'};
        private String[] apex_schema_type_info = new String[]{'urn:OekopostWebService','false','false'};
        private String[] field_order_type_info = new String[]{'userName','passwordHash','passwordSalt'};
    }
    public class checkAccountLoginResponse_element {
        public String status;
        private String[] status_type_info = new String[]{'status','urn:OekopostWebService',null,'0','1','false'};
        private String[] apex_schema_type_info = new String[]{'urn:OekopostWebService','false','false'};
        private String[] field_order_type_info = new String[]{'status'};
    }
    public class getAccountBalanceResponse_element {
        public String status;
        public Integer balanceCents;
        private String[] status_type_info = new String[]{'status','urn:OekopostWebService',null,'0','1','false'};
        private String[] balanceCents_type_info = new String[]{'balanceCents','urn:OekopostWebService',null,'0','1','false'};
        private String[] apex_schema_type_info = new String[]{'urn:OekopostWebService','false','false'};
        private String[] field_order_type_info = new String[]{'status','balanceCents'};
    }
    public class checkAccountLoginRequest_element {
        public String userName;
        public String passwordHash;
        public String passwordSalt;
        private String[] userName_type_info = new String[]{'userName','urn:OekopostWebService',null,'0','1','false'};
        private String[] passwordHash_type_info = new String[]{'passwordHash','urn:OekopostWebService',null,'0','1','false'};
        private String[] passwordSalt_type_info = new String[]{'passwordSalt','urn:OekopostWebService',null,'0','1','false'};
        private String[] apex_schema_type_info = new String[]{'urn:OekopostWebService','false','false'};
        private String[] field_order_type_info = new String[]{'userName','passwordHash','passwordSalt'};
    }
    public class submitPDFLetterRequest_element {
        public String userName;
        public String passwordHash;
        public String passwordSalt;
        public String data;
        public String dataHash;
        public Integer dispatchTimeStamp;
        public Boolean printColor;
        public Boolean printDuplex;
        public String envelopeType;
        public String destinationCountry;
        private String[] userName_type_info = new String[]{'userName','urn:OekopostWebService',null,'0','1','false'};
        private String[] passwordHash_type_info = new String[]{'passwordHash','urn:OekopostWebService',null,'0','1','false'};
        private String[] passwordSalt_type_info = new String[]{'passwordSalt','urn:OekopostWebService',null,'0','1','false'};
        private String[] data_type_info = new String[]{'data','urn:OekopostWebService',null,'0','1','false'};
        private String[] dataHash_type_info = new String[]{'dataHash','urn:OekopostWebService',null,'0','1','false'};
        private String[] dispatchTimeStamp_type_info = new String[]{'dispatchTimeStamp','urn:OekopostWebService',null,'0','1','false'};
        private String[] printColor_type_info = new String[]{'printColor','urn:OekopostWebService',null,'0','1','false'};
        private String[] printDuplex_type_info = new String[]{'printDuplex','urn:OekopostWebService',null,'0','1','false'};
        private String[] envelopeType_type_info = new String[]{'envelopeType','urn:OekopostWebService',null,'0','1','false'};
        private String[] destinationCountry_type_info = new String[]{'destinationCountry','urn:OekopostWebService',null,'0','1','false'};
        private String[] apex_schema_type_info = new String[]{'urn:OekopostWebService','false','false'};
        private String[] field_order_type_info = new String[]{'userName','passwordHash','passwordSalt','data','dataHash','dispatchTimeStamp','printColor','printDuplex','envelopeType','destinationCountry'};
    }
    public class submitSMSRequest_element {
        public String userName;
        public String passwordHash;
        public String passwordSalt;
        public String from_x;
        public String to;
        public String text;
        public Integer dispatchTimeStamp;
        public Integer smsType;
        private String[] userName_type_info = new String[]{'userName','urn:OekopostWebService',null,'0','1','false'};
        private String[] passwordHash_type_info = new String[]{'passwordHash','urn:OekopostWebService',null,'0','1','false'};
        private String[] passwordSalt_type_info = new String[]{'passwordSalt','urn:OekopostWebService',null,'0','1','false'};
        private String[] from_x_type_info = new String[]{'from','urn:OekopostWebService',null,'0','1','false'};
        private String[] to_type_info = new String[]{'to','urn:OekopostWebService',null,'0','1','false'};
        private String[] text_type_info = new String[]{'text','urn:OekopostWebService',null,'0','1','false'};
        private String[] dispatchTimeStamp_type_info = new String[]{'dispatchTimeStamp','urn:OekopostWebService',null,'0','1','false'};
        private String[] smsType_type_info = new String[]{'smsType','urn:OekopostWebService',null,'0','1','false'};
        private String[] apex_schema_type_info = new String[]{'urn:OekopostWebService','false','false'};
        private String[] field_order_type_info = new String[]{'userName','passwordHash','passwordSalt','from_x','to','text','dispatchTimeStamp','smsType'};
    }
    public class submitSMSResponse_element {
        public String status;
        public String jobID;
        public Integer chargedCents;
        private String[] status_type_info = new String[]{'status','urn:OekopostWebService',null,'0','1','false'};
        private String[] jobID_type_info = new String[]{'jobID','urn:OekopostWebService',null,'0','1','false'};
        private String[] chargedCents_type_info = new String[]{'chargedCents','urn:OekopostWebService',null,'0','1','false'};
        private String[] apex_schema_type_info = new String[]{'urn:OekopostWebService','false','false'};
        private String[] field_order_type_info = new String[]{'status','jobID','chargedCents'};
    }
    public class submitPDFLetterResponse_element {
        public String status;
        public String jobID;
        public Integer chargedCents;
        private String[] status_type_info = new String[]{'status','urn:OekopostWebService',null,'0','1','false'};
        private String[] jobID_type_info = new String[]{'jobID','urn:OekopostWebService',null,'0','1','false'};
        private String[] chargedCents_type_info = new String[]{'chargedCents','urn:OekopostWebService',null,'0','1','false'};
        private String[] apex_schema_type_info = new String[]{'urn:OekopostWebService','false','false'};
        private String[] field_order_type_info = new String[]{'status','jobID','chargedCents'};
    }
    public class OekopostWebServicePort {
        public String endpoint_x = 'https://www.oekopost.de:443/soap/index.php';
        public Map<String,String> inputHttpHeaders_x;
        public Map<String,String> outputHttpHeaders_x;
        public String clientCertName_x;
        public String clientCert_x;
        public String clientCertPasswd_x;
        public Integer timeout_x;
        private String[] ns_map_type_info = new String[]{'urn:OekopostWebService', 'oekopostwebservice'};
        public oekopostwebservice.submitPDFLetterResponse_element submitPDFLetter(String userName,String passwordHash,String passwordSalt,String data,String dataHash,Integer dispatchTimeStamp,Boolean printColor,Boolean printDuplex,String envelopeType,String destinationCountry) {
            oekopostwebservice.submitPDFLetterRequest_element request_x = new oekopostwebservice.submitPDFLetterRequest_element();
            request_x.userName = userName;
            request_x.passwordHash = passwordHash;
            request_x.passwordSalt = passwordSalt;
            request_x.data = data;
            request_x.dataHash = dataHash;
            request_x.dispatchTimeStamp = dispatchTimeStamp;
            request_x.printColor = printColor;
            request_x.printDuplex = printDuplex;
            request_x.envelopeType = envelopeType;
            request_x.destinationCountry = destinationCountry;
            oekopostwebservice.submitPDFLetterResponse_element response_x;
            Map<String, oekopostwebservice.submitPDFLetterResponse_element> response_map_x = new Map<String, oekopostwebservice.submitPDFLetterResponse_element>();
            response_map_x.put('response_x', response_x);
            WebServiceCallout.invoke(
              this,
              request_x,
              response_map_x,
              new String[]{endpoint_x,
              'urn:OekopostWebService#submitPDFLetter',
              'urn:OekopostWebService',
              'submitPDFLetterRequest',
              'urn:OekopostWebService',
              'submitPDFLetterResponse',
              'oekopostwebservice.submitPDFLetterResponse_element'}
            );
            response_x = response_map_x.get('response_x');
            return response_x;
        }
        public oekopostwebservice.getAccountBalanceResponse_element getAccountBalance(String userName,String passwordHash,String passwordSalt) {
            oekopostwebservice.getAccountBalanceRequest_element request_x = new oekopostwebservice.getAccountBalanceRequest_element();
            request_x.userName = userName;
            request_x.passwordHash = passwordHash;
            request_x.passwordSalt = passwordSalt;
            oekopostwebservice.getAccountBalanceResponse_element response_x;
            Map<String, oekopostwebservice.getAccountBalanceResponse_element> response_map_x = new Map<String, oekopostwebservice.getAccountBalanceResponse_element>();
            response_map_x.put('response_x', response_x);
            WebServiceCallout.invoke(
              this,
              request_x,
              response_map_x,
              new String[]{endpoint_x,
              'urn:OekopostWebService#getAccountBalance',
              'urn:OekopostWebService',
              'getAccountBalanceRequest',
              'urn:OekopostWebService',
              'getAccountBalanceResponse',
              'oekopostwebservice.getAccountBalanceResponse_element'}
            );
            response_x = response_map_x.get('response_x');
            return response_x;
        }
        public String checkAccountLogin(String userName,String passwordHash,String passwordSalt) {
            oekopostwebservice.checkAccountLoginRequest_element request_x = new oekopostwebservice.checkAccountLoginRequest_element();
            request_x.userName = userName;
            request_x.passwordHash = passwordHash;
            request_x.passwordSalt = passwordSalt;
            oekopostwebservice.checkAccountLoginResponse_element response_x;
            Map<String, oekopostwebservice.checkAccountLoginResponse_element> response_map_x = new Map<String, oekopostwebservice.checkAccountLoginResponse_element>();
            response_map_x.put('response_x', response_x);
            WebServiceCallout.invoke(
              this,
              request_x,
              response_map_x,
              new String[]{endpoint_x,
              'urn:OekopostWebService#checkAccountLogin',
              'urn:OekopostWebService',
              'checkAccountLoginRequest',
              'urn:OekopostWebService',
              'checkAccountLoginResponse',
              'oekopostwebservice.checkAccountLoginResponse_element'}
            );
            response_x = response_map_x.get('response_x');
            return response_x.status;
        }
        public oekopostwebservice.submitSMSResponse_element submitSMS(String userName,String passwordHash,String passwordSalt,String from_x,String to,String text,Integer dispatchTimeStamp,Integer smsType) {
            oekopostwebservice.submitSMSRequest_element request_x = new oekopostwebservice.submitSMSRequest_element();
            request_x.userName = userName;
            request_x.passwordHash = passwordHash;
            request_x.passwordSalt = passwordSalt;
            request_x.from_x = from_x;
            request_x.to = to;
            request_x.text = text;
            request_x.dispatchTimeStamp = dispatchTimeStamp;
            request_x.smsType = smsType;
            oekopostwebservice.submitSMSResponse_element response_x;
            Map<String, oekopostwebservice.submitSMSResponse_element> response_map_x = new Map<String, oekopostwebservice.submitSMSResponse_element>();
            response_map_x.put('response_x', response_x);
            WebServiceCallout.invoke(
              this,
              request_x,
              response_map_x,
              new String[]{endpoint_x,
              'urn:OekopostWebService#submitSMS',
              'urn:OekopostWebService',
              'submitSMSRequest',
              'urn:OekopostWebService',
              'submitSMSResponse',
              'oekopostwebservice.submitSMSResponse_element'}
            );
            response_x = response_map_x.get('response_x');
            return response_x;
        }
    }
}