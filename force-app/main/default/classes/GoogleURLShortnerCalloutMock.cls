@isTest
global class GoogleURLShortnerCalloutMock implements HttpCalloutMock{
    global HttpResponse respond(HTTPRequest req){
        HttpResponse res = new HttpResponse();
        res.setStatus('OK');
        res.setStatusCode(200);
        res.setBody('{"longUrl" : "https://www.google.com"}');
        return res;
    }
}