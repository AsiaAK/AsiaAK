@IsTest private class GeolocationMDDayLocationIActTest {
    @IsTest static void testLocateAddressAsync(){
        insert new MD_Day_Location__c[]{
            new MD_Day_Location__c(Street__c = '3',City__c = '32', Post_code__c ='41'),
                new MD_Day_Location__c(Street__c = '3',City__c = '32', Post_code__c ='41'),
                new MD_Day_Location__c(Street__c = '3',City__c = '32', Post_code__c ='41')
                };
    
        
        Test.startTest();
        GeolocationMDDayLocationInvocableAction.getLocation([SELECT Id, Street__c, City__c, Post_code__c FROM MD_Day_Location__c]);
        Test.stopTest();
    }
}