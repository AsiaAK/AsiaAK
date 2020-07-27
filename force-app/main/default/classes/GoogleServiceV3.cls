public class GoogleServiceV3 {
    
    public static final String JWT_AUD = 'https://accounts.google.com/o/oauth2/token';
    public static final String JWT_GRANT_TYPE = 'urn:ietf:params:oauth:grant-type:jwt-bearer';
    public static final String JWT_ENDPOINT = 'https://accounts.google.com/o/oauth2/token';
    public static final String PRIVATE_KEY = 'MIIEvwIBADANBgkqhkiG9w0BAQEFAASCBKkwggSlAgEAAoIBAQCk45Fa55cXpTgr\n9Sn+iULa2XtcArkXjNnedRDfOfP8c476HzwYONa9Ii2kmJLfcTjVouA3UNP9i24P\n62ILjfghgn+VZsfEGSZKmF09wucVSAUtg0w4233kV35e8Rnx3vk+gU6gGVmZzTmG\nOJHWG2LZYomIns/jxgREqX5RpSIFUnmAW7bMrEWeMi1YtYII7/6VQrhEz8E6TThZ\nw0oIbkg964cUTZrDgTfJJ6ue8av4prQr3VXcy66SD2JYs3MBLcm7Fgz2ze9KMEma\npvv9guTqYK8gWSl6Ap6XWQrBMgG+bzS64IpfQjvoosmTgL3mFR10zC4eC7kD23zk\nB4MKutsHAgMBAAECggEAKabesfLshOmUfe4pVIYB4Fytv7lkXiGTa5Fw2KLAElZy\nmJZJTOkWvaIjm397InxsWfMR5odBdbvB6r2P/9E2C+j2J5xV/CBKPu+sJgzU6NhP\njoarO3WeoI7FemA3KJUlqvdpECI3MxXXYSNrG4XBe55blapgY25C58FVCnTHWkZq\nOd7RHXESywZ75LiUajPgkv5XJQDq7NXGnEvFjpd4A3YZnVwnwbDtUJR0+tfxttH5\n7ftFUsDNufS7kWDg8IJp1HKe6d26j7cJuHLnm7xbf0HP/2GMcgorvoFJy1p5Lz8V\nFJbHNot958nMk3zLg3houHCsfd/Vn60sEvGxLgaN8QKBgQDZYUkX5eGSz6TDP/9a\nbN8yHGA67SYCxnE4cWaRzLXM+adxA8A/T+NM2cH30PGMT/QdN7fBaiJG6CfvkHsf\noAfWxn4Skrof6YBVGrnpnFjojc2GEVHuVoF8XnzrnfWnLjN993NwQi2ys0nEYf8v\njc2GxWYDs3wLq+eIJKRJvjkymQKBgQDCLuwZ4SzzWbSB+BtgnKIdGfhuKtVGbYoU\n/7jG2zJHaxPubKBEdam3Yxl5PUcbxArEWwHyb3F/IC2ZQPvfoN5JEwzMz+kfuD+a\n8UO+koY88Y/Y5HLQYmKog1j4XEbgTAjdUbl23/ESKku7PfLTsexhncufm0BHfgsA\nLGToTgqenwKBgQCCc1hq6AB7mvJ0XZZ/DHDQ4Kh7FE/IQJA3YA4+lsvPC08Jike3\ndtigCNnXPuOF4YFMe2BhyLBzPuSgZmMM8nthz1JfEQBzICxsZhKFd9b/EAHzX7d8\nQRuJqCZtOyjtP9OU14fGKWDFKcSt/mUmg4GATDvRIsfhNTNHxz10J5ypmQKBgQDA\nrlqs21kFJ7ALfyt7VDEwe0Kd3na+aZcoew7Yk0xyvXeLj9H/3FlJlVYDjaBvlrmw\nWTW3YInYQQ++EFNddXzcOcDrwipqxSKoFlrIURBOjMvVxel/iQCogZzY5IeXrRrm\nsV88672D7uAyrae0E8qgmjkg6KaByjoUM/j04et7tQKBgQCPg2E8tLP/U/Wx9IeP\nDXjG3hU1LwRsSPywsXYx2Ct55BQk9dfKHdvmu2E6yZAyfxCs43Y8d3/IOze0JTNS\nnTqbheI8S8k/ko9L8ADl8cThBpVkNWuAXKVrkOhsJKBA1FY67JVJLHhhE+HNETqD\nFeN6STFyyAYsn1u9UgUfKnuJAw==';
    public static final String SCOPE_READWRITE = 'https://www.googleapis.com/auth/calendar';
    
    private String token_type;
    private String access_token;
    
    public GoogleServiceV3() {
    }
    
    public Boolean authenticate(JWT jwt) {
        if (jwt.aud == null) {
            jwt.aud = JWT_AUD;
        }
        if (jwt.iat == null) {
            jwt.iat = Datetime.now();
        }
        if (jwt.exp == null) {
            jwt.exp = jwt.iat.addHours(1);
        }
        if( jwt.scope == null) {
            jwt.scope = SCOPE_READWRITE;
        }
        String str = jwt.getEncodedString();
        str += '.' + jwt.sign(EncodingUtil.base64Decode(PRIVATE_KEY));
        System.debug('JWT:' + jwt);
        HttpRequest req = createRequest();
        String content = 'grant_type=' + EncodingUtil.urlEncode(JWT_GRANT_TYPE, 'utf-8') +
            '&assertion=' + EncodingUtil.urlEncode(str, 'utf-8');
        req.setEndpoint(JWT_ENDPOINT);
        req.setHeader('Content-Type','application/x-www-form-urlencoded');
        req.setMethod('POST');
        req.setBody(content);
        
        HttpResponse res = sendRequest(req);
        if (isOK(res)) {
            AuthResponse auth = (AuthResponse)JSON.deserialize(res.getBody(), AuthResponse.class);
            this.token_type = auth.token_type;
            this.access_token = auth.access_token;
            return  true;
        }
        return false;
    }
    
    private boolean isOK(HttpResponse res) {
        if(res != null){
            return res.getStatusCode() >= 200 && res.getStatusCode() < 300;
        }else{
            return false;
        }
    }
    
    private HttpRequest createRequest() {
        HttpRequest req = new HttpRequest();
        req.setHeader('User-Agent','apex-google-api');
        return req;
    }
    
    private HttpResponse sendRequest(HttpRequest req) {
        Http http = new Http();
        try {
            System.debug('HttpRequest :' +req.getbody());
            HttpResponse res = http.send(req);
            System.debug('STATUS:' + res.getBody());
            return res;
        } catch( System.Exception e) {
        }
        return null;
    }
    
    public String getToken() {
        return this.access_token;
    }
    
    public class AuthResponse {
        public String access_token { get;}
        public String refresh_token { get;}
        public Long expires_in { get;}
        public String token_type { get;} 
    }
}