/**
 * Created by pavel on 4/10/2018.
 */

public with sharing class MDDayUpdateLocationCallback implements GeocodeResultCallback {
    public void execute(Map<Id, GeocodeResult> result) {
        MD_Day_Location__c[] locations = new List<MD_Day_Location__c>();

        for (GeocodeResult geocode:result.values()) {
            locations.add(new MD_Day_Location__c(
                    Id = geocode.sfid,
                    Location__Latitude__s = geocode.latitude,
                    Location__Longitude__s = geocode.longitude)
            );
        }

        System.debug(locations);

        update locations;
    }
}