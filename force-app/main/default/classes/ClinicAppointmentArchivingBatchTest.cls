@IsTest
private class ClinicAppointmentArchivingBatchTest {

	@IsTest
	private static void checkScheduleRun() {
		initCustomsettings();
		Test.startTest();
		System.assertEquals([SELECT COUNT() FROM AsyncApexJob WHERE JobType = 'ScheduledApex' AND Status != 'Aborted'], 0);
		ClinicAppointmentArchivingBatch.startScheduler();
		System.assertEquals([SELECT COUNT() FROM AsyncApexJob WHERE JobType = 'ScheduledApex' AND Status != 'Aborted'], 1);
		Test.stopTest();
	}

	@IsTest
	private static void checkScheduleStop() {
		initCustomsettings();
		Test.startTest();
		System.assertEquals([SELECT COUNT() FROM AsyncApexJob WHERE JobType = 'ScheduledApex' AND Status != 'Aborted'], 0);
		ClinicAppointmentArchivingBatch.startScheduler();
		System.assertEquals([SELECT COUNT() FROM AsyncApexJob WHERE JobType = 'ScheduledApex' AND Status != 'Aborted'], 1);
		ClinicAppointmentArchivingBatch.stopScheduler();
		System.assertEquals([SELECT COUNT() FROM AsyncApexJob WHERE JobType = 'ScheduledApex' AND Status != 'Aborted'], 0);
		Test.stopTest();
	}

	@IsTest
	private static void checkBatch() {
		initCustomsettings();
		initClinicAppointment();
		System.assertEquals([SELECT COUNT() FROM Clinic_Appointment__c], 1);
		Test.startTest();
		Database.executeBatch(new ClinicAppointmentArchivingBatch(),100);
		Test.stopTest();
		System.assertEquals([SELECT COUNT() FROM Clinic_Appointment__c], 0);
	}

	private static void initCustomsettings() {
		insert new ClinicAppointmentBatch__c(
			Schedule_Time__c = '0 0 0 * * ?',
			Start_Date__c = Datetime.now().addHours(-1) ,
			End_Date__c = Datetime.now().addHours(1)
		);
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
    
    private static Appointment_Counter__c initAppointmentCounter(Id AccountId) {
    	Appointment_Counter__c appointmentCounter = new Appointment_Counter__c(Surgeon__c = AccountId, 
                                                                               Appointment_Counter_Matching__c = 'Test1');  
        insert appointmentCounter;
        return appointmentCounter;
    }
}