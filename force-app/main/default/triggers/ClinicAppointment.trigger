trigger ClinicAppointment on Clinic_Appointment__c (before insert, before update, after insert, after update) {
    TriggerFactory.execute(Clinic_Appointment__c.sObjectType);
}