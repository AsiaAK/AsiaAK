/**
 * Created by pavel on 4/9/2018.
 */

public with sharing class GeolocationMDDayLocationInvocableAction {

    @InvocableMethod(Label='Find Location')
    public static void getLocation(MD_Day_Location__c[] objects) {
        RecordAddress[] addresses = new List<RecordAddress>();

        for (MD_Day_Location__c location:objects) {
            addresses.add(RecordAddress.createFromMdDayLocation(location));
        }

        GoogleGeocodeApi api = new GoogleGeocodeApi();
        System.enqueueJob(api.locateAddressesAsync(addresses, new MDDayUpdateLocationCallback()));
    }
}