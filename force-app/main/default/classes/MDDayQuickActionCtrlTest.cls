@isTest
private class MDDayQuickActionCtrlTest {

	@testSetup
	private static void prepareTestData() {
		List<Account> accounts = new List<Account>();
		Account clinicAccount = new Account();
		clinicAccount.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('ClinicsRecordType').getRecordTypeId();
		clinicAccount.Name = 'Doctor Star';
		clinicAccount.CurrencyIsoCode = 'EUR';
		accounts.add(clinicAccount);

		insert accounts;

		List<MD_Day_Location__c> mdDayLocations = new List<MD_Day_Location__c>();
		MD_Day_Location__c preExLocation = new MD_Day_Location__c();
		preExLocation.Name = 'preEx location';
		preExLocation.RecordTypeId = Schema.SObjectType.MD_Day_Location__c.getRecordTypeInfosByDeveloperName().get('Pre_ex_Location').getRecordTypeId();
		preExLocation.City__c = 'Amsterdam';
		preExLocation.Street__c = 'Green';
		preExLocation.Post_code__c ='2029';
		preExLocation.Additional_Address_Information__c = 'additional3';
		preExLocation.Comments__c = 'comments3';
		preExLocation.Overnight_Invoice_issued_by__c = 'Medidate';
		preExLocation.Room_Fee_Model__c = 'Flat Fee per Surgery';
		preExLocation.Anesthesia_Fee_Model__c = 'Fixed Fee for some time + Fee per Time Unit';
		preExLocation.ClinicLocation__c = 'MD clinic';
		preExLocation.Email__c = '60605efew@erge.rthrt';
		preExLocation.Price_Per_Hour__c = 33;
		preExLocation.Overtime_Penalty__c = 9;
		preExLocation.bernachtungskosten__c = 'he3';
		preExLocation.Materiallager__c = 'material3';
		preExLocation.Anesthesia_Information_for_Clinics__c = 'Anesthesia Information3';
		mdDaylocations.add(preExLocation);

		insert mdDaylocations;

		List<MD_Day__c> mdDays = new List<MD_Day__c>();
		MD_Day__c preExMdDay = new MD_Day__c();
		preExMdDay.RecordTypeId = Schema.SObjectType.MD_Day__c.getRecordTypeInfosByDeveloperName().get('MD_Pre_Ex_Day').getRecordTypeId();
		preExMdDay.MD_Day_Location__c = preExLocation.Id;
		DateTime day7 = DateTime.now().addDays(7);
		preExMdDay.Operation_Day_Start_Time__c = DateTime.newInstance(day7.year(), day7.month(), day7.day(), 8, 0, 0);
		preExMdDay.Operation_Day_End_Time__c = DateTime.newInstance(day7.year(), day7.month(), day7.day(), 17, 0, 0);
		preExMdDay.Date__c = Date.newInstance(day7.year(), day7.month(), day7.day());
		preExMdDay.Total_available_Operation_Time_Minutes__c  = 300;
		preExMdDay.Surgeon_Clinic__c = clinicAccount.Id;
		mdDays.add(preExMdDay);
		insert mdDays;
	}


	@isTest
	private static void testGetMdDayRecordTypesForAccount() {
		MD_Day__c mdDay = [SELECT Id FROM MD_Day__c LIMIT 1];
		Map<String, Object> mdDayRecordTypesFilter = new Map<String, Object>{
			'recordId' => mdDay.Id,
			'sObjectName' => 'Account'
		};
		Test.startTest();

		String response = MDDayQuickActionCtrl.getMdDayRecordTypes(JSON.serialize(mdDayRecordTypesFilter));

		Test.stopTest();

		Map<String, Object> responseMap = (Map<String, Object>) JSON.deserializeUntyped(response);
		Map<String, Object> responseMapData = (Map<String, Object>) responseMap.get('data');
		List<Object> responseMdDayRecordTypes = (List<Object>) responseMapData.get('mdDayRecordTypes');
		System.assertNotEquals(responseMdDayRecordTypes.size(), 0);
		
	}

	@isTest
	private static void testGetMdDayRecordTypesForLocation() {
		MD_Day_Location__c mdDayLocation = [SELECt Id FROM MD_Day_Location__c LIMIT 1];
		Map<String, Object> mdDayRecordTypesFilter = new Map<String, Object>{
			'recordId' => mdDayLocation.Id,
			'sObjectName' => 'MD_Day_Location__c'
		};
		Test.startTest();

		String response = MDDayQuickActionCtrl.getMdDayRecordTypes(JSON.serialize(mdDayRecordTypesFilter));

		Test.stopTest();

		Map<String, Object> responseMap = (Map<String, Object>) JSON.deserializeUntyped(response);
		Map<String, Object> responseMapData = (Map<String, Object>) responseMap.get('data');
		List<Object> responseMdDayRecordTypes = (List<Object>) responseMapData.get('mdDayRecordTypes');
		System.assertNotEquals(responseMdDayRecordTypes.size(), 0);
	}

	@isTest
	private static void testGetMdDayRecordTypesInvalid() {
		Test.startTest();

		String response = MDDayQuickActionCtrl.getMdDayRecordTypes(null);

		Test.stopTest();

		Map<String, Object> responseMap = (Map<String, Object>) JSON.deserializeUntyped(response);
		String status = (String) responseMap.get('status');
		System.assert(status == 'error');
	}
}