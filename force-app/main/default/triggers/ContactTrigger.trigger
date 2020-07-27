trigger ContactTrigger on Contact (before insert, after insert, before update, after update) {
    GeolocateHandler locationHandler = new GeolocateHandler();
    locationHandler.geolocateAddress('Contact', Trigger.new, Trigger.oldMap, Trigger.isBefore);
}