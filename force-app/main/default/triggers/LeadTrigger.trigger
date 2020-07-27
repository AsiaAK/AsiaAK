trigger LeadTrigger on Lead (before insert, after insert, before update, after update) {
    GeolocateHandler locationHandler = new GeolocateHandler();
    locationHandler.geolocateAddress('Lead', Trigger.new, Trigger.oldMap, Trigger.isBefore);
    
   /* if(Trigger.isInsert && Trigger.isAfter) {
        LeadHandler.afterInsert(Trigger.new);
    }
    
    if(Trigger.isUpdate && Trigger.isAfter) {
        LeadHandler.afterUpdate(Trigger.new, Trigger.oldMap);
    }*/
}