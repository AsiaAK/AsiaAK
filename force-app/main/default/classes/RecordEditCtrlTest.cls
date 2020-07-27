@isTest
private class RecordEditCtrlTest {

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

		List<MD_Day_Location__c> mdDayLocations = new List<MD_Day_Location__c>();
		MD_Day_Location__c mdLocation = new MD_Day_Location__c();
		mdLocation.Name = 'md location1';
		mdLocation.RecordTypeId = Schema.SObjectType.MD_Day_Location__c.getRecordTypeInfosByDeveloperName().get('Operation_Location').getRecordTypeId();
		mdLocation.City__c = 'Paris';
		mdLocation.Street__c = 'Bush';
		mdLocation.Post_code__c ='3434';
		mdLocation.Additional_Address_Information__c = 'additional';
		mdLocation.Comments__c = 'comments';
		mdLocation.Overnight_Invoice_issued_by__c = 'Medidate';
		mdLocation.Room_Fee_Model__c = 'Flat Fee per Surgery';
		mdLocation.Anesthesia_Fee_Model__c = 'Fixed Fee for some time + Fee per Time Unit';
		mdLocation.ClinicLocation__c = 'MD clinic';
		mdLocation.Email__c = '235423efew@erge.rthrt';
		mdLocation.Price_Per_Hour__c = 34;
		mdLocation.Overtime_Penalty__c = 3;
		mdLocation.bernachtungskosten__c = 'we';
		mdLocation.Materiallager__c = 'material';
		mdLocation.Anesthesia_Information_for_Clinics__c = 'Anesthesia Information';
		mdDayLocations.add(mdLocation);

		MD_Day_Location__c moLocation = new MD_Day_Location__c();
		moLocation.Name = 'mo location1';
		moLocation.RecordTypeId = Schema.SObjectType.MD_Day_Location__c.getRecordTypeInfosByDeveloperName().get('Operation_Location').getRecordTypeId();
		moLocation.City__c = 'Brest';
		moLocation.Street__c = 'Privet';
		moLocation.Post_code__c ='5050';
		moLocation.Additional_Address_Information__c = 'additional2';
		moLocation.Comments__c = 'comments2';
		moLocation.Overnight_Invoice_issued_by__c = 'Medidate';
		moLocation.Room_Fee_Model__c = 'Flat Fee per Surgery';
		moLocation.Anesthesia_Fee_Model__c = 'Fixed Fee for some time + Fee per Time Unit';
		moLocation.ClinicLocation__c = 'MO clinic';
		moLocation.Email__c = '101020efew@erge.rthrt';
		moLocation.Price_Per_Hour__c = 30;
		moLocation.Overtime_Penalty__c = 2;
		moLocation.bernachtungskosten__c = 'he';
		moLocation.Materiallager__c = 'material2';
		moLocation.Anesthesia_Information_for_Clinics__c = 'Anesthesia Information2';
		mdDaylocations.add(moLocation);

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

		MD_Day__c mdOperationDay = new MD_Day__c();
		mdOperationDay.RecordTypeId = Schema.SObjectType.MD_Day__c.getRecordTypeInfosByDeveloperName().get('MD_Operation_Day').getRecordTypeId();
		mdOperationDay.MD_Day_Location__c = mdLocation.Id;
		DateTime day6 = DateTime.now().addDays(6);
		mdOperationDay.Operation_Day_Start_Time__c = DateTime.newInstance(day6.year(), day6.month(), day6.day(), 8, 0, 0);
		mdOperationDay.Operation_Day_End_Time__c = DateTime.newInstance(day6.year(), day6.month(), day6.day(), 17, 0, 0);
		mdOperationDay.Date__c = Date.newInstance(day6.year(), day6.month(), day6.day());
		mdOperationDay.Total_available_Operation_Time_Minutes__c  = 200;
		mdOperationDay.Surgeon_Clinic__c = clinicAccount.Id;
		mdDays.add(mdOperationDay); 

		insert mdDays;

		List<Clinic_Appointment__c> additionalAppointments = new List<Clinic_Appointment__c>();
		Clinic_Appointment__c appointmentWithPreExLocation = [SELECT Id, RecordTypeId, Operation_Day_Start_Time__c, Clinic__c, MD_Day__c, Appointment_Counter__c, Appointment_Date__c FROM Clinic_Appointment__c WHERE MD_Day__c IN (SELECT Id FROM MD_Day__c WHERE MD_Day_Location__r.Name = 'preEx location')].get(0);
		Clinic_Appointment__c preMedAppointment = new Clinic_Appointment__c();
		preMedAppointment.Clinic__c = appointmentWithPreExLocation.Clinic__c;
		preMedAppointment.MD_Day__c = appointmentWithPreExLocation.MD_Day__c;
		preMedAppointment.Appointment_Counter__c = appointmentWithPreExLocation.Appointment_Counter__c;
		preMedAppointment.Appointment_Date__c = appointmentWithPreExLocation.Appointment_Date__c;
		preMedAppointment.Apppointment_Type__c = 'Surgery Preparation Appointment';
		preMedAppointment.CS_Start_Date__c = appointmentWithPreExLocation.Operation_Day_Start_Time__c;
		preMedAppointment.CS_End_Date__c = (preMedAppointment.CS_Start_Date__c).addHours(1);
		preMedAppointment.Appointment_Status__c = 'Available';
		preMedAppointment.Name = 'preMed Appointment';
		preMedAppointment.RecordTypeId = appointmentWithPreExLocation.RecordTypeId;
		additionalAppointments.add(preMedAppointment);

		Clinic_Appointment__c afterCareAppointment = new Clinic_Appointment__c();
		afterCareAppointment.Clinic__c = appointmentWithPreExLocation.Clinic__c;
		afterCareAppointment.MD_Day__c = appointmentWithPreExLocation.MD_Day__c;
		afterCareAppointment.Appointment_Counter__c = appointmentWithPreExLocation.Appointment_Counter__c;
		afterCareAppointment.Appointment_Date__c = appointmentWithPreExLocation.Appointment_Date__c;
		afterCareAppointment.Apppointment_Type__c = 'Aftercare Appointment';
		afterCareAppointment.CS_Start_Date__c = appointmentWithPreExLocation.Operation_Day_Start_Time__c;
		afterCareAppointment.CS_End_Date__c = (afterCareAppointment.CS_Start_Date__c).addHours(1);
		afterCareAppointment.Appointment_Status__c = 'Available';
		afterCareAppointment.Name = 'afterCare Appointment';
		afterCareAppointment.RecordTypeId = appointmentWithPreExLocation.RecordTypeId;
		additionalAppointments.add(afterCareAppointment);

		insert additionalAppointments;

		List<Opportunity> opportunities = new List<Opportunity>();
		Opportunity opportunity = new Opportunity();
		opportunity.Name = 'Andrey Sidorov';
		opportunity.RecordTypeId =  Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('Body').getRecordTypeId();
		opportunity.CloseDate = System.today() + 14;
		opportunity.StageName = 'Interested in Financing';
		opportunity.PaymentType__c = 'Pre-Payment';
		opportunity.AccountId =  personAccount.Id;
		opportunity.Clinic__c = clinicAccount.Id;
		opportunity.VU_OP_Caretaker__c  = UserInfo.getUserId();
		opportunity.Show_Up_Control__c = true;
		opportunity.Operation_Duration_Minutes__c = 60;
		opportunities.add(opportunity);
		insert opportunities;
	}

	@isTest
	private static void testGetFormData() {
		Id mdDayId = [SELECT Id FROM MD_Day__c WHERE MD_Day_Location__r.Name = 'preEx location' LIMIT 1].Id;
		List<String> fields = new List<String>{
			'Date__c',
			'Operation_Day_Start_Time__c',
			'Operation_Day_End_Time__c',
			'MD_Day_Location__c',
			'Surgeon_Clinic__c',
			'Total_available_Operation_Time_Minutes__c'
		};
		Map<String, Object> formDataFilter = new Map<String, Object>{
			'objectType' => 'MD_Day__c',
			'recordType' => Schema.SObjectType.MD_Day__c.getRecordTypeInfosByDeveloperName().get('MD_Pre_Ex_Day').getRecordTypeId(),
			'recordId' => mdDayId, 
			'fields' => fields

		};
		Test.startTest();

		String response = RecordEditCtrl.getFormData(JSON.serialize(formDataFilter));

		Test.stopTest();

		Map<String, Object> responseMap = (Map<String, Object>) JSON.deserializeUntyped(response);
		String status = (String) responseMap.get('status');
		System.assert(status == 'success');
	}

	@isTest
	private static void testGetFormDataInvalid() {
		Test.startTest();

		String response = RecordEditCtrl.getFormData(null);

		Test.stopTest();

		Map<String, Object> responseMap = (Map<String, Object>) JSON.deserializeUntyped(response);
		String status = (String) responseMap.get('status');
		System.assert(status == 'error');
	}

	@isTest
	private static void testGetFormDataException() {
		Map<String, Object> formDataFilter = new Map<String, Object>{
			'objectType' => 'MD_Day__c',
			'recordType' => Schema.SObjectType.MD_Day__c.getRecordTypeInfosByDeveloperName().get('MD_Pre_Ex_Day').getRecordTypeId(),
			'recordId' => null, 
			'fields' => 1

		};
		Test.startTest();

		String response = RecordEditCtrl.getFormData(JSON.serialize(formDataFilter));

		Test.stopTest();

		Map<String, Object> responseMap = (Map<String, Object>) JSON.deserializeUntyped(response);
		String status = (String) responseMap.get('status');
		System.assert(status == 'error');
	}
}