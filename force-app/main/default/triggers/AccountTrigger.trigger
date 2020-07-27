trigger AccountTrigger on Account (before insert, after insert, before update, after update) {
    GeolocateHandler locationHandler = new GeolocateHandler();
    locationHandler.geolocateAddress('Account', Trigger.new, Trigger.oldMap, Trigger.isBefore);
}