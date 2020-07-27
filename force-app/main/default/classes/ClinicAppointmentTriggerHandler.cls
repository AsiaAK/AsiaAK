/**
 * ClinicAppointmentTriggerHandler class 1.0.0
 *
 * @description This class represents a ClinicAppointmentTriggerHandler.
 *
 * @author Nadezhda Podobed
 * @date 19.03.2019
 */
public with sharing class ClinicAppointmentTriggerHandler implements TriggerHandler {

	public void execute(TriggerOperation operationType,
                        List<sObject> oldSObjectsList, List<sObject> newSObjectsList,
                        Map<Id, sObject> oldSObjectsMap, Map<Id, sObject> newSObjectsMap) {
        switch on operationType {
            when BEFORE_INSERT {
                onBeforeInsert(newSObjectsList);
            }
            when BEFORE_UPDATE {
                onBeforeUpdate(oldSObjectsList, newSObjectsList, oldSObjectsMap, newSObjectsMap);
            }
            when AFTER_UPDATE {
                onAfterUpdate(oldSObjectsList, newSObjectsList, oldSObjectsMap, newSObjectsMap);
            }
        }
	}

	private static void onBeforeInsert(List<sObject> newSObjectsList) {
        List<Clinic_Appointment__c> newClinicAppointments = (List<Clinic_Appointment__c>) newSObjectsList;

        ClinicAppointmentTriggerService.checkDuplicatesOnInsert(newClinicAppointments);

		ClinicAppointmentTriggerService.ckeckDurationOnInsert(newClinicAppointments);

        ClinicAppointmentTriggerService.checkAfterCareAppointmentsBookingLimitOnInsert(newClinicAppointments);

        ClinicAppointmentTriggerService.checkPreMedAppointmentsBookingLimitOnInsert(newClinicAppointments);
    }

	private static void onBeforeUpdate(List<sObject> oldSObjectsList, List<sObject> newSObjectsList,
						        Map<Id, sObject> oldSObjectsMap, Map<Id, sObject> newSObjectsMap) {
        List<Clinic_Appointment__c> newClinicAppointments = (List<Clinic_Appointment__c>) newSObjectsList;
        Map<Id, Clinic_Appointment__c> oldClinicAppointmentsMap = (Map<Id, Clinic_Appointment__c>) oldSObjectsMap;

		ClinicAppointmentTriggerService.checkOpportunityOperationAppointmentOnUpdate(newClinicAppointments, oldClinicAppointmentsMap);
		
        ClinicAppointmentTriggerService.checkDuplicatesOnUpdate(newClinicAppointments, oldClinicAppointmentsMap);

        ClinicAppointmentTriggerService.checkAfterCareAppointmentsBookingLimitOnUpdate(newClinicAppointments, oldClinicAppointmentsMap);

        ClinicAppointmentTriggerService.checkPreMedAppointmentsBookingLimitOnUpdate(newClinicAppointments, oldClinicAppointmentsMap);
    }

	private static void onAfterUpdate(List<sObject> oldSObjectsList, List<sObject> newSObjectsList,
						        Map<Id, sObject> oldSObjectsMap, Map<Id, sObject> newSObjectsMap) {
        List<Clinic_Appointment__c> newClinicAppointments = (List<Clinic_Appointment__c>) newSObjectsList;
        Map<Id, Clinic_Appointment__c> oldClinicAppointmentsMap = (Map<Id, Clinic_Appointment__c>) oldSObjectsMap;

		ClinicAppointmentTriggerService.checkClinicAppointmentStatus(newClinicAppointments, oldClinicAppointmentsMap);
    }

}