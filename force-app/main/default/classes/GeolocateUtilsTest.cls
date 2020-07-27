@IsTest (seeAllData=false)
public class GeolocateUtilsTest {
    static testMethod void testAccountInsert() {
        Test.startTest();
        Account obj = new Account(Name = 'Test', BillingStreet = 'Test', BillingCity = 'Test', BillingPostalCode = 'Test', ShippingStreet = 'Test', ShippingCity = 'Test', ShippingPostalCode = 'Test');
        insert obj;
        Test.stopTest();
        
        Account obj2 = [Select BillingLongitude from Account where id = :obj.Id];
        System.assertNotEquals(obj2.BillingLongitude, null);
    }
    
    static testMethod void testAccountUpdate1() {
        Account obj = new Account(Name = 'Test', BillingStreet = 'Test', BillingCity = 'Test', BillingPostalCode = 'Test', ShippingStreet = 'Test', ShippingCity = 'Test', ShippingPostalCode = 'Test');
        insert obj;
        
        Test.startTest();
        obj.BillingStreet = 'Test1';
        update obj;
        Test.stopTest();
        
        Account obj2 = [Select BillingLongitude from Account where id = :obj.Id];
        System.assertNotEquals(obj2.BillingLongitude, null);
    }
    static testMethod void testAccountUpdate2() {
        Account obj = new Account(Name = 'Test', BillingStreet = 'Test', BillingCity = 'Test', BillingPostalCode = 'Test', ShippingStreet = 'Test', ShippingCity = 'Test', ShippingPostalCode = 'Test');
        insert obj;
        
        Test.startTest();
        obj.BillingCity = 'Test1';
        update obj;
        Test.stopTest();
        
        Account obj2 = [Select BillingLongitude from Account where id = :obj.Id];
        System.assertNotEquals(obj2.BillingLongitude, null);
    }
    static testMethod void testAccountUpdate3() {
        Account obj = new Account(Name = 'Test', BillingStreet = 'Test', BillingCity = 'Test', BillingPostalCode = 'Test', ShippingStreet = 'Test', ShippingCity = 'Test', ShippingPostalCode = 'Test');
        insert obj;
        
        Test.startTest();
        obj.BillingPostalCode = 'Test1';
        update obj;
        Test.stopTest();
        
        Account obj2 = [Select BillingLongitude from Account where id = :obj.Id];
        System.assertNotEquals(obj2.BillingLongitude, null);
    }    
    static testMethod void testAccountPostpone() {
        List<Account> obj = new List<Account>();
        for(Integer i = 1; i<= 12; i++) {
            obj.add(new Account(Name = 'Test'+i, BillingStreet = 'Test', BillingCity = 'Test', BillingPostalCode = 'Test'));
        }
        
        Test.startTest();
        insert obj;
        Test.stopTest();
    } 
    
    static testMethod void testContactInsert() {
        Test.startTest();
        Contact obj = new Contact(LastName = 'Test', MailingStreet = 'Test', MailingCity = 'Test', MailingPostalCode = 'Test', OtherStreet = 'Test', OtherCity = 'Test', OtherPostalCode = 'Test');
        insert obj;
        Test.stopTest();
        
        Contact obj2 = [Select OtherLongitude from Contact where id = :obj.Id];
        System.assertNotEquals(obj2.OtherLongitude, null);
    }
    
    static testMethod void testLeadInsert() {
        Test.startTest();
        Lead obj = new Lead(Company = 'Test', LastName = 'Test', Street = 'Test', City = 'Test', PostalCode = 'Test');
        insert obj;
        Test.stopTest();
        
        Lead obj2 = [Select Longitude from Lead where id = :obj.Id];
        System.assertNotEquals(obj2.Longitude, null);
    }
    
    static testMethod void testBatch1() {
        List<Account> obj = new List<Account>();
        for(Integer i = 1; i<= 12; i++) {
            obj.add(new Account(Name = 'Test'+i, BillingStreet = 'Test', BillingCity = 'Test', BillingPostalCode = 'Test'));
        }
        
        Test.startTest();
        insert obj;
        Database.executeBatch(new GeolocateBatch('Account'));
        Test.stopTest();
    }
    static testMethod void testBatch2() {
        List<Contact> obj = new List<Contact>();
        for(Integer i = 1; i<= 12; i++) {
            obj.add(new Contact(LastName = 'Test', MailingStreet = 'Test', MailingCity = 'Test', MailingPostalCode = 'Test', OtherStreet = 'Test', OtherCity = 'Test', OtherPostalCode = 'Test'));
        }
        
        Test.startTest();
        insert obj;
        Database.executeBatch(new GeolocateBatch('Contact'));
        Test.stopTest();
    }
    static testMethod void testBatch3() {
        List<Lead> obj = new List<Lead>();
        for(Integer i = 1; i<= 12; i++) {
            obj.add(new Lead(Company = 'Test', LastName = 'Test', Street = 'Test', City = 'Test', PostalCode = 'Test'));
        }
        
        Test.startTest();
        insert obj;
        Database.executeBatch(new GeolocateBatch('Lead'));
        Test.stopTest();
    }
    static testMethod void testBatch4() {
        Test.startTest();
        Database.executeBatch(new GeolocateBatch('PersonAccount'));
        Test.stopTest();
    }
    static testMethod void testSchedule() {
        Test.startTest();
        system.schedule('TestGeolocationSchedule', '0 0 0 1 * ? *', new GeolocateSchedule());
        Test.stopTest();
    }
    
    public static String getResponse() {
        String json = '{\"results\" : ['+
              '{'+
                 '\"formatted_address\" : \"Urbanstraße 72, 10967 Berlin, Germany\",'+
                 '\"geometry\" : {'+
                    '\"location\" : {'+
                       '\"lat\" : 52.48829929999999,'+
                       '\"lng\" : 13.4235525'+
                    '},'+
                    '\"location_type\" : \"ROOFTOP\",'+
                    '\"viewport\" : {'+
                       '\"northeast\" : {' +
                          '\"lat\" : 52.4896482802915,'+
                          '\"lng\" : 13.4249014802915'+
                       '},'+
                       '\"southwest\" : {'+
                          '\"lat\" : 52.4869503197085,'+
                          '\"lng\" : 13.4222035197085'+
                       '}'+
                    '}'+
                 '},'+
                 '\"place_id\" : \"ChIJNW9Vv7dPqEcR2O6GKUaIYrM\",'+
                 '\"types\" : [ \"street_address\" ]'+
              '}'+
           '],'+
           '\"status\" : \"OK\"'+
        '}';
        return json;
    }
}