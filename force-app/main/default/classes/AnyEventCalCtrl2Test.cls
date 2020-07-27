@IsTest
private class AnyEventCalCtrl2Test {

	static testMethod void getEventsTest() {
		initClinicAppointment();
		Map<String, String> filterFields = new Map<String, String> { 'CustomCondition' => '(  Appointment_Status__c = \'Available\')' };
		AnyEventCalCtrl2.getEvents('Clinic_Appointment__c', 'CS_Title__c', 'CS_Start_Date__c', 'CS_End_Date__c', 'CS_Description__c', 'PCC__c', true, filterFields);
		AnyEventCalCtrl2.getEvents('Clinic_Appointment__c', 'CS_Title__c', 'CS_Start_Date__c', 'CS_End_Date__c', 'CS_Description__c', 'PCC__c', false, filterFields);
	}

	static testMethod void upsertEventsTest() {
		Opportunity opp = initOpportunity();
		Lead lead = initLead();
		Clinic_Appointment__c clinicAppointment = initClinicAppointment();
		AnyEventCalCtrl2.upsertEvents('{"id":"'+clinicAppointment.Id+'","isRebooking":true, "title":"dasdsad","startDateTime":"2017-04-26T17:00:00-07:00","endDateTime":"2017-04-26T19:00:00-07:00","description":"asdasd", "sObjectId" : "'+opp.Id+'" }', 'Clinic_Appointment__c', 'CS_Title__c', 'CS_Start_Date__c', 'CS_End_Date__c', 'CS_Description__c', 'PCC__c');
		AnyEventCalCtrl2.upsertEvents('{"id":"'+clinicAppointment.Id+'","isRebooking":true, "title":"dasdsad","startDateTime":"2017-04-26T17:00:00-07:00","endDateTime":"2017-04-26T19:00:00-07:00","description":"asdasd", "sObjectId" : "'+lead.Id+'" }', 'Clinic_Appointment__c', 'CS_Title__c', 'CS_Start_Date__c', 'CS_End_Date__c', 'CS_Description__c', 'PCC__c');
	}

	static testMethod void deleteEventTest() {
		AnyEventCalCtrl2.deleteEvent('00U41000006bFIA', 'Event', 'Subject', 'StartDateTime', 'EndDateTime', 'Description', 'OwnerId');
	}

	static testMethod void crudSecurityTest() {
		AnyEventCalCtrl2.isAccessible('Event');
		AnyEventCalCtrl2.isAccessible('Event','Subject');
		AnyEventCalCtrl2.isCreateable('Event');
		AnyEventCalCtrl2.isDeletable('Event');
	}

	private static Clinic_Appointment__c initClinicAppointment() {
        Id clinicId = initClinic().Id;
		Id recordType = Schema.SObjectType.Clinic_Appointment__c.getRecordTypeInfosByName().get('Pre-Ex Appointment').getRecordTypeId();
		Clinic_Appointment__c clinicAppointment = new Clinic_Appointment__c(
			Clinic__c = clinicId,
			MD_Day__c = initMDDay().Id,
			RecordTypeId = recordType,
			Appointment_Status__c = 'Available',
            Appointment_Counter__c = initAppointmentCounter(clinicId).Id
		);
		insert clinicAppointment;
		return clinicAppointment;
	}

	private static MD_Day__c initMDDay() {
		Id recordType = Schema.SObjectType.MD_Day__c.getRecordTypeInfosByName().get('MD Pre-Ex Day').getRecordTypeId();
		MD_Day__c clinicAppointment = new MD_Day__c(RecordTypeId = recordType);
		insert clinicAppointment;
		return clinicAppointment;
	}

	private static Account initClinic() {
		Account clinic = new Account(Name = 'TestClinic');
		insert clinic;
		return clinic;
	}

	private static Account initPersonAccount() {
		Id recordType = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Patient Account').getRecordTypeId();
		Account clinic = new Account(LastName = 'TestUser', RecordTypeId = recordType);
		insert clinic;
		return clinic;
	}

	private static Opportunity initOpportunity() {
		Opportunity opportunity = new Opportunity(
			Name = 'Test1',
			StageName = 'Open',
			CloseDate = Date.today().addDays(3),
			Accountid = initPersonAccount().Id
		);
		insert opportunity;
		return opportunity;
	}

	private static Lead initLead() {
		Id recordTypeId = Lead.getSObjectType().getDescribe().getRecordTypeInfosById().values()[0].getRecordTypeId();
		Lead lead = new Lead(LastName = 'leadToInsert', Email = 'test@test.de', RecordTypeId = recordTypeId, Company = 'Test');
		insert lead;
		return lead;
	}
    
    private static Appointment_Counter__c initAppointmentCounter(Id AccountId) {
    	Appointment_Counter__c appointmentCounter = new Appointment_Counter__c(Surgeon__c = AccountId, 
                                                                               Appointment_Counter_Matching__c = 'Test1');  
        insert appointmentCounter;
        return appointmentCounter;
    }
}