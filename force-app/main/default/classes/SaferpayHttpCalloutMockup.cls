@isTest
public class SaferpayHttpCalloutMockup implements HttpCalloutMock {
    private String paymentId;
    private Boolean doError;
    public SaferpayHttpCalloutMockup(String paymentId, Boolean doError) {
        this.paymentId = paymentId;
        this.doError = doError;
    }
    
    public HTTPResponse respond(HTTPRequest req) {
        HttpResponse res = new HttpResponse();
        if(req.getEndpoint().contains('Initialize')) {
            res.setBody(TestObjectFactory.getSaferpayInitializeResponse(this.paymentId));
            res.setStatusCode(200);
        }
        if(req.getEndpoint().contains('Assert')) {
            res.setBody(TestObjectFactory.getSaferpayAssertResponse(this.paymentId));
            res.setStatusCode(200);
        }
        if(req.getEndpoint().contains('Capture')) {
            res.setBody(TestObjectFactory.getSaferpayCaptureResponse(this.paymentId));
            res.setStatusCode(200);
        }
        if(req.getEndpoint().contains('VerifyPayConfirm')) {
            res.setBody('OK');
            res.setStatusCode(200);
        }
        if(req.getEndpoint().contains('PayCompleteV2')) {
            res.setBody('OK');
            res.setStatusCode(200);
        }
        if(req.getEndpoint().contains('CreatePayInit')) {
            res.setBody('OK');
            res.setStatusCode(200);
        }
        if(doError) {
            res.setStatusCode(400);
        }
        return res;
    }

}