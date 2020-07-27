@isTest
public class GoogleServiceV3HttpMockup implements HttpCalloutMock {
    private Boolean isSuccess;
    public GoogleServiceV3HttpMockup(Boolean isSuccess) {
        this.isSuccess = isSuccess;
    }
    public HTTPResponse respond(HTTPRequest req) {
        HttpResponse res = new HttpResponse();
        if(this.isSuccess) {
            res = TestObjectFactory.getGoogleServiceToken();
        } else {
            res.setStatusCode(400);
            res.setStatus('Bad Request');
        }
        return res;
    }

}