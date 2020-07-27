/**
 * Created by pavel on 4/9/2018.
 */

public with sharing class RecordAddress {
    public Id sfid { get; set; }
    public String street { get; set; }
    public String city { get; set; }
    public String state { get; set; }
    public String country { get; set; }
    public String zip { get; set; }

    public String toGoogleAddressString() {
        return EncodingUtil.urlEncode(String.join(new String[]{
                this.street, this.city, this.state, this.country, this.zip
        }, ','), 'UTF-8');
    }

    public static RecordAddress createFromMdDayLocation(MD_Day_Location__c record) {
        RecordAddress address = new RecordAddress();
        address.street = record.Street__c;
        address.city = record.City__c;
//        address.state = record.Coun;
        address.zip = record.Post_code__c;
        address.sfid = record.Id;
        return address;
    }
}