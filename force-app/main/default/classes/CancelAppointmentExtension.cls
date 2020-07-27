public with sharing class CancelAppointmentExtension {
    public String accessToken {get; set;}
    public Opportunity opp {get; set;}
    public CancelAppointmentExtension(ApexPages.StandardController stdController) {
        this.opp = [SELECT Id, CalendarTimeZone__c FROM Opportunity WHERE Id = :stdController.getId()];
        GoogleServiceV3 service = new GoogleServiceV3();
        JWT jwt = new JWT('259361316346-j6g8e0ij1e379c2q2kot9cce1d4u5ad1@developer.gserviceaccount.com');
        service.authenticate(jwt);
        accessToken = service.getToken();
    }
}