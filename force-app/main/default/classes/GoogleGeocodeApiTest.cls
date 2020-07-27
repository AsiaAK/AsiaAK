@IsTest private class GoogleGeocodeApiTest {
    
    @IsTest static void testLocateAddress(){
        
        GoogleGeocodeApi gapi = new GoogleGeocodeApi();
        RecordAddress[] records = new RecordAddress[]{};
            
            for(Integer i = 0; i < 3; i++){
                RecordAddress c = new RecordAddress();
                c.city = i + '1';
                c.zip = i + '2';
                c.street = i + '333';
                records.add(c);
            }
        Test.startTest();
        gapi.locateAddresses(records);
        Test.stopTest();
    }
    
    @IsTest static void testLocateAddressAsync(){
        insert new MD_Day_Location__c[]{
            new MD_Day_Location__c(Street__c = '3',City__c = '32', Post_code__c ='41'),
                new MD_Day_Location__c(Street__c = '3',City__c = '32', Post_code__c ='41'),
                new MD_Day_Location__c(Street__c = '3',City__c = '32', Post_code__c ='41')
                };
        GoogleGeocodeApi gapi = new GoogleGeocodeApi();
        RecordAddress[] records = new RecordAddress[]{};
            
            for(MD_Day_Location__c loc: [SELECT Id, Street__c, City__c, Post_code__c FROM MD_Day_Location__c]){
                records.add(RecordAddress.createFromMdDayLocation(loc));
            }
        
        Test.startTest();
        System.enqueueJob(gapi.locateAddressesAsync(records, new MDDayUpdateLocationCallback()));
        Test.stopTest();
    }
}