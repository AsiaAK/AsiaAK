public with sharing class oekopostHandler {
    public static Oekopost__c credentials;
    static {
        credentials = Oekopost__c.getValues('Credentials');
        if(credentials == null) {
            credentials = new Oekopost__c(
                Name = 'Credentials',
                Username__c = '',
                Password__c = ''
            );
            insert credentials;
        }
    }
    
    public static void sendPdf(Blob document, Id paymentId) {
        oekopostwebservice.OekopostWebServicePort obj = new oekopostwebservice.OekopostWebServicePort();
        String passwordHashTmp = EncodingUtil.convertToHex(Crypto.generateDigest('MD5', Blob.valueOf(oekopostHandler.credentials.Password__c)));
        String salt = oekopostHandler.generateRandomString();
        String passwordHash = EncodingUtil.convertToHex(Crypto.generateDigest('MD5', Blob.valueOf(passwordHashTmp + salt)));
        
        String documentMD5 = EncodingUtil.convertToHex(Crypto.generateDigest('MD5', document));
        String documentBase64 = EncodingUtil.base64Encode(document);
        oekopostwebservice.submitPDFLetterResponse_element resp = new oekopostwebservice.submitPDFLetterResponse_element();
        if(!Test.isRunningTest()) {
            resp = obj.submitPDFLetter(oekopostHandler.credentials.Username__c,passwordHash,salt,documentBase64,documentMD5, 100, false, false, 'C6', 'DE');
        } else {
            resp = oekopostHandlerTest.getResponse();
        }
        
        if(resp.status != 'OK') {
            oekopostError__c error = new oekopostError__c();
            error.Message__c = resp.status;
            error.Payment__c = paymentId;
            insert error;
        }
        System.debug('resp:::'+resp);
    }
    
    private static String generateRandomString() {
        final String chars = '0123456789';
        String randStr = '';
        while (randStr.length() < 9) {
           Integer idx = Math.mod(Math.abs(Crypto.getRandomInteger()), chars.length());
           randStr += chars.substring(idx, idx+1);
        }
        return randStr; 
    }
}