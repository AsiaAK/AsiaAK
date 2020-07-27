@isTest
public class EsendexHttpCalloutMockup implements HttpCalloutMock {
    private Boolean isFailure;
    
    public EsendexHttpCalloutMockup(Boolean isFailure) {
        this.isFailure = isFailure;
    }
    
    public HTTPResponse respond(HTTPRequest req) {
        HttpResponse res = new HttpResponse();
        if(req.getEndpoint().contains('messagedispatcher')) {
            if(isFailure) {
                 res.setBody('failed');
                 res.setStatusCode(400);
            } else {
                res.setBody(TestObjectFactory.getEsendexMessageDispatcherResponse().getBody());
                res.setStatusCode(200);
            }
        }
        if(req.getEndpoint().contains('messageheaders')) {
            if(isFailure) {
                 res.setBody('failed');
                 res.setStatusCode(400);
            } else {
                res.setBody(TestObjectFactory.getEsendexMessageHeaderResponse().getBody());
                res.setStatusCode(200);
            }
        }
        return res;
    }

}