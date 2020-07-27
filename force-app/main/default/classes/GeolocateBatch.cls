global with sharing class GeolocateBatch implements Database.Batchable<sObject>, Database.AllowsCallouts{
    global final String query;
    global final String objectName;
    
    global GeolocateBatch(String objectName) {
        this.objectName = objectName;
        if(objectName == 'PersonAccount') 
            this.query = 'select id, BillingStreet, BillingCity, BillingCountry, BillingState, BillingPostalCode, BillingLatitude, BillingLongitude, ShippingStreet, ShippingCity, ShippingCountry, ShippingState, ShippingPostalCode, ShippingLatitude, ShippingLongitude, PersonMailingStreet, PersonMailingCity, PersonMailingCountry, PersonMailingState, PersonMailingPostalCode, PersonMailingLatitude, PersonMailingLongitude, PersonOtherStreet, PersonOtherCity, PersonOtherCountry, PersonOtherState, PersonOtherPostalCode, PersonOtherLatitude, PersonOtherLongitude from account where isPersonAccount = true and (PersonMailingLatitude = null OR PersonOtherLatitude = null) ';
        else if(objectName == 'Account')
            this.query = 'select id, BillingStreet, BillingCity, BillingCountry, BillingState, BillingPostalCode, BillingLatitude, BillingLongitude, ShippingStreet, ShippingCity, ShippingCountry, ShippingState, ShippingPostalCode, ShippingLatitude, ShippingLongitude from account where isPersonAccount = false and (BillingLatitude = null OR ShippingLatitude = null) ';
        else if(objectName == 'Contact')
            this.query = 'select id, MailingStreet, MailingCity, MailingCountry, MailingState, MailingPostalCode, MailingLatitude, MailingLongitude, OtherStreet, OtherCity, OtherCountry, OtherState, OtherPostalCode, OtherLatitude, OtherLongitude from Contact where isPersonAccount = false and (MailingLatitude = null OR OtherLatitude = null) ';
        else if(objectName == 'Lead')
            this.query = 'select id, Street, City, Country, State, PostalCode, Latitude, Longitude from lead where Latitude = null and isConverted = false';
    }
    
    global Database.QueryLocator start(Database.BatchableContext BC){
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC, List<sObject> scope) {
        Map<Id, LIst<String>> addressPrefixes = new Map<Id, LIst<String>>();
        for(sObject obj: scope) {
            
            sObject oldObj = null;
            addressPrefixes.put(obj.Id, new List<String>());
            
            if(objectName == 'PersonAccount') {
                if(obj.get('PersonOtherLatitude') == null) addressPrefixes.get(obj.Id).add('PersonOther');
                if(obj.get('PersonMailingLatitude') == null) addressPrefixes.get(obj.Id).add('PersonMailing');
                if(obj.get('BillingLatitude') == null) addressPrefixes.get(obj.Id).add('Billing');
                if(obj.get('ShippingLatitude') == null) addressPrefixes.get(obj.Id).add('Shipping');
            } else if(objectName == 'Account') {
                if(obj.get('BillingLatitude') == null) addressPrefixes.get(obj.Id).add('Billing');
                if(obj.get('ShippingLatitude') == null) addressPrefixes.get(obj.Id).add('Shipping');
            } else if(objectName == 'Contact') {
                if(obj.get('MailingLatitude') == null) addressPrefixes.get(obj.Id).add('Mailing');
                if(obj.get('OtherLatitude') == null) addressPrefixes.get(obj.Id).add('Other');
            } else if(objectName == 'Lead') {
                if(obj.get('Latitude') == null) addressPrefixes.get(obj.Id).add('');
            }
        }
        GeolocateUtils.geocodeAccounts(scope, addressPrefixes, null);
    }
    
    global void finish(Database.BatchableContext BC){
        
    }
}