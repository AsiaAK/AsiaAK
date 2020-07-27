global class GeolocateSchedule implements Schedulable {
    global void execute(SchedulableContext sc) {
        Database.executeBatch(new GeolocateBatch('Account'), 30);
        Database.executeBatch(new GeolocateBatch('PersonAccount'), 20);
        Database.executeBatch(new GeolocateBatch('Contact'), 20);
        Database.executeBatch(new GeolocateBatch('Lead'), 30);
    }
}