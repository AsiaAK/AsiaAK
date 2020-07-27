public with sharing class GeolocateQueuable implements Queueable, Database.AllowsCallouts {
    
    List<Id> Ids {get;set;} 
    Map<Id, List<String>> addressesPrefixes {get;set;}
    String objectName {get; set;}
    
    public GeolocateQueuable(List<Id> Ids, Map<Id, List<String>> addressesPrefixes, String objectName){
        this.Ids = Ids;
        this.addressesPrefixes = addressesPrefixes;
        this.objectName = objectName;
    }
    
    
    public void execute(QueueableContext context) {
        String query = '';
        if(objectName == 'PersonAccount') 
            query = 'select id, BillingStreet, BillingCity, BillingCountry, BillingState, BillingPostalCode, BillingLatitude, BillingLongitude, ShippingStreet, ShippingCity, ShippingCountry, ShippingState, ShippingPostalCode, ShippingLatitude, ShippingLongitude, PersonMailingStreet, PersonMailingCity, PersonMailingCountry, PersonMailingState, PersonMailingPostalCode, PersonMailingLatitude, PersonMailingLongitude, PersonOtherStreet, PersonOtherCity, PersonOtherCountry, PersonOtherState, PersonOtherPostalCode, PersonOtherLatitude, PersonOtherLongitude from account where id in :Ids';
        else if(objectName == 'Account')
            query = 'select id, BillingStreet, BillingCity, BillingCountry, BillingState, BillingPostalCode, BillingLatitude, BillingLongitude, ShippingStreet, ShippingCity, ShippingCountry, ShippingState, ShippingPostalCode, ShippingLatitude, ShippingLongitude from account where id in :Ids';
        else if(objectName == 'Contact')
            query = 'select id, MailingStreet, MailingCity, MailingCountry, MailingState, MailingPostalCode, MailingLatitude, MailingLongitude, OtherStreet, OtherCity, OtherCountry, OtherState, OtherPostalCode, OtherLatitude, OtherLongitude from Contact  where id in :Ids';
        else if(objectName == 'Lead')
            query = 'select id, Street, City, Country, State, PostalCode, Latitude, Longitude from lead where id in :Ids and isConverted = false';
        
        if(query != '') {
            List<sObject> objects = Database.query(query);
            GeolocateUtils.geocodeAccounts(objects, addressesPrefixes, null);
        }
    }
    
}