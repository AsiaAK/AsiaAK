public with sharing class Esendex {
    public static EsendexMessageDispatcherResponse messageDispatcher(EsendexMessageDispatcherRequest messageDispatcherRequest) {
        String path = '/messagedispatcher';
        String payload = messageDispatcherRequest.serialize();
        system.debug(payload);
        HttpRequest request = new HttpRequest();
        request.setEndpoint('callout:Esendex' + path);
        request.setMethod('POST');
        request.setHeader('Content-Type', 'application/xml');
        request.setHeader('Accept', 'application/xml');
        request.setBody(payload);
        Http httpObject = new Http();
        HttpResponse response = httpObject.send(request);
        return new EsendexMessageDispatcherResponse(response);
    }
    
    public static EsendexMessageHeaderResponse messageHeader(String headerId) {
        String path = '/messageheaders/' + headerId;
        HttpRequest request = new HttpRequest();
        request.setEndpoint('callout:Esendex' + path);
        request.setMethod('GET');
        request.setHeader('Content-Type', 'application/xml');
        request.setHeader('Accept', 'application/xml');
        Http httpObject = new Http();
        HttpResponse response = httpObject.send(request);
        return new EsendexMessageHeaderResponse(response);
    }
}