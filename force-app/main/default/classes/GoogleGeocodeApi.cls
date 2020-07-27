public with sharing class GoogleGeocodeApi {

    public Map<Id, GeocodeResult> locateAddresses(RecordAddress[] addresses) {
        Map<Id, GeocodeResult> geocodeResult = new Map<Id, GeocodeResult>();
        for (RecordAddress address :addresses) {
            GeocodeResult result = GeolocateUtils.getGeocodeAddress(address);
            geocodeResult.put(result.sfid, result);
        }
        return geocodeResult;
    }

    public Queueable locateAddressesAsync(RecordAddress[] addresses, GeocodeResultCallback callback) {
        return new AsyncLocateAddressInvoker(addresses, callback);
    }

    private class AsyncLocateAddressInvoker implements Queueable, Database.AllowsCallouts {
        private RecordAddress[] addresses;
        private GeocodeResultCallback callback;

        public AsyncLocateAddressInvoker(RecordAddress[] addresses, GeocodeResultCallback callback) {
            this.addresses = addresses;
            this.callback = callback;
        }

        public void execute(QueueableContext qctx) {
            GoogleGeocodeApi api = new GoogleGeocodeApi();
            Map<Id, GeocodeResult> result = api.locateAddresses(this.addresses);
            this.callback.execute(result);
        }
    }
}