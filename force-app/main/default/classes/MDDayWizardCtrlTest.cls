@isTest
private class MDDayWizardCtrlTest {

	@testSetup
	private static void prepareTestData() {
		List<Account> accounts = new List<Account>();
		Account personAccount = new Account();
		personAccount.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('PersonAccount').getRecordTypeId();
		personAccount.LastName = 'Mike Black';
		personAccount.CurrencyIsoCode = 'EUR';
		accounts.add(personAccount);

		Account clinicAccount = new Account();
		clinicAccount.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('ClinicsRecordType').getRecordTypeId();
		clinicAccount.Name = 'Doctor Star';
		clinicAccount.CurrencyIsoCode = 'EUR';
		accounts.add(clinicAccount);

		insert accounts;

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
		insert preExLocation;
	}

	@isTest
	private static void testSaveMDDayError() {
		Id mdDayRecordId = Schema.SObjectType.MD_Day__c.getRecordTypeInfosByDeveloperName().get('MD_Pre_Ex_Day').getRecordTypeId();
		Date todayDay = Date.today();
		DateTime day3 = DateTime.now().addDays(3);
		DateTime startTime = DateTime.newInstance(day3.year(), day3.month(), day3.day(), 8, 0, 0);
		DateTime endTime = DateTime.newInstance(day3.year(), day3.month(), day3.day(), 17, 0, 0);
		MD_Day_Location__c mdLocation = [SELECT Id FROM MD_Day_Location__c WHERE Name = 'preEx location' LIMIT 1];
		Account clinic = [SELECT Id FROM Account WHERE Name = 'Doctor Star' LIMIT 1];
		Map<String, Object> mdDayRecord = new Map<String, Object>{
			'Date__c' => todayDay,
			'Operation_Day_Start_Time__c' => startTime,
			'Operation_Day_End_Time__c' => endTime,
			'MD_Day_Location__c' => mdLocation.Id,
			'Surgeon_Clinic__c' => clinic.Id,
			'RecordTypeId' => mdDayRecordId
			
		};
		Map<String, Object> mdDayRepetitionRuleRecord = new Map<String, Object>{
			'Monday__c' => false,
			'Tuesday__c' => false,
			'Wednesday__c' => true,
			'Thursday__c' => false,
			'Friday__c' => false,
			'Saturday__c' => false,
			'Sunday__c' => false,
			'RepeatTill__c' => todayDay.addDays(51),
			'RepeatEvery__c' => '1'
		};

		Map<String, Object> mdDayRepetitionRuleRecord2 = new Map<String, Object>{
			'Monday__c' => false,
			'Tuesday__c' => false,
			'Wednesday__c' => true,
			'Thursday__c' => true,
			'Friday__c' => false,
			'Saturday__c' => false,
			'Sunday__c' => false,
			'RepeatTill__c' => todayDay.addDays(51),
			'RepeatEvery__c' => '1'
		};
		Map<String, Object> mdDayDataJSON = new Map<String, Object>{
			'mdDay' => new Map<String, Object>{
				'record' => mdDayRecord,
                'objectType' => 'MD_Day__c'
			},
			'mdDayRepetitionRule' => new Map<String, Object>{
				'record' => mdDayRepetitionRuleRecord,
				 'objectType' => 'MDDayRepetitionRule__c'
			}
		};

		Test.startTest();

		String response = MDDayWizardCtrl.saveMDDay(JSON.serialize(mdDayDataJSON));
		String response2 = MDDayWizardCtrl.saveMDDay(JSON.serialize(null));

		Test.stopTest();

		Map<String, Object> responseMap = (Map<String, Object>) JSON.deserializeUntyped(response);
		String status = (String) responseMap.get('status');
		System.assert(status == 'success');

		Map<String, Object> responseMap2 = (Map<String, Object>) JSON.deserializeUntyped(response2);
		String status2 = (String) responseMap2.get('status');
		System.assert(status2 == 'error');
	}
}