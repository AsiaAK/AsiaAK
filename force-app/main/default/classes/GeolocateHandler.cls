public with sharing class GeolocateHandler {
    
    public static Integer MAX_LIST_SIZE = 10;
    
    public void geolocateAddress(String objectName, List<sObject> newData, Map<Id, sObject> oldData, Boolean isBefore) {
        
        Boolean postponeGeocoding = newData.size() > MAX_LIST_SIZE ? true : false;
        
        Map<Id, LIst<String>> addressPrefixes = new Map<Id, LIst<String>>();
        List<Id> accountsToUpdate = new List<Id>();
        List<Id> personAccountsToUpdate = new List<Id>();
        List<Id> contactsToUpdate = new List<Id>();
        List<Id> leadsToUpdate = new List<Id>();
        
        //process on before only if we postpone geocoding
        //process on after if we geocode imediately 
        if((postponeGeocoding && isBefore) || (!postponeGeocoding && !isBefore)) {
            for(sObject obj: newData) {
                sObject oldObj = (oldData != null) ? oldData.get(obj.Id) : null;
                addressPrefixes.put(obj.Id, new List<String>());
                
                
                if (objectName == 'Account') {
                    if(Boolean.valueOf(obj.get('isPersonAccount')) == false) {
                        GeolocateUtils.processAddress(obj, oldObj, 'Billing', postponeGeocoding, addressPrefixes);
                        GeolocateUtils.processAddress(obj, oldObj, 'Shipping', postponeGeocoding, addressPrefixes);
                        if(addressPrefixes.get(obj.Id).size() > 0 ) accountsToUpdate.add(obj.Id);
                    } else {
                        GeolocateUtils.processAddress(obj, oldObj, 'Billing', postponeGeocoding, addressPrefixes);
                        GeolocateUtils.processAddress(obj, oldObj, 'Shipping', postponeGeocoding, addressPrefixes);
                        GeolocateUtils.processAddress(obj, oldObj, 'PersonMailing', postponeGeocoding, addressPrefixes);
                        GeolocateUtils.processAddress(obj, oldObj, 'PersonOther', postponeGeocoding, addressPrefixes);
                        if(addressPrefixes.get(obj.Id).size() > 0 ) personAccountsToUpdate.add(obj.Id);
                    }
                } else if(objectName == 'Contact') {
                    GeolocateUtils.processAddress(obj, oldObj, 'Mailing', postponeGeocoding, addressPrefixes);
                    GeolocateUtils.processAddress(obj, oldObj, 'Other', postponeGeocoding, addressPrefixes);
                    if(addressPrefixes.get(obj.Id).size() > 0 ) contactsToUpdate.add(obj.Id);
                } else if(objectName == 'Lead' && !Boolean.valueOf(obj.get('isConverted'))) {
                    GeolocateUtils.processAddress(obj, oldObj, '', postponeGeocoding, addressPrefixes);
                    if(addressPrefixes.get(obj.Id).size() > 0 ) leadsToUpdate.add(obj.Id);
                }
            }
        }
        
        if(!postponeGeocoding && !isBefore) {
            if(accountsToUpdate.size() > 0)
                System.enqueueJob(new GeolocateQueuable(accountsToUpdate, addressPrefixes, 'Account'));
            if(personAccountsToUpdate.size() > 0)
                System.enqueueJob(new GeolocateQueuable(personAccountsToUpdate, addressPrefixes, 'PersonAccount'));
            if(contactsToUpdate.size() > 0)
                System.enqueueJob(new GeolocateQueuable(contactsToUpdate, addressPrefixes, 'Contact'));
            if(leadsToUpdate.size() > 0)
                System.enqueueJob(new GeolocateQueuable(leadsToUpdate, addressPrefixes, 'Lead'));
        }
    }
    
}