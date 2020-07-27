/**
 * ClinicAppointmentTriggerService class 1.0.0
 *
 * @description This class represents a ClinicAppointmentTriggerService.
 *
 * @author Nadezhda Podobed
 * @date 19.03.2019
 */
public with sharing class ClinicAppointmentTriggerService {

    private static Map<String, Set<Id>> processedRecordIds = new Map<String, Set<Id>>();

    private static Id preExAppointmentId = Schema.SObjectType.Clinic_Appointment__c.getRecordTypeInfosByDeveloperName().get('Pre_Ex_Appointment').getRecordTypeId();
   

    public static void checkDuplicatesOnInsert(List<Clinic_Appointment__c> newClinicAppointments) {
        List<Clinic_Appointment__c> validClinicAppointments = new List<Clinic_Appointment__c>();

        for (Clinic_Appointment__c newClinicAppointment : newClinicAppointments) {
            if (!isRecordProcessed('checkDuplicatesOnInsert', newClinicAppointment.Id)) {
                if (newClinicAppointment.CS_Start_Date__c != null && newClinicAppointment.CS_End_Date__c != null
                        && newClinicAppointment.CS_Start_Date__c.date() == newClinicAppointment.CS_End_Date__c.date()
                        && newClinicAppointment.Clinic__c != null
                        && newClinicAppointment.RecordTypeId != preExAppointmentId
                        && (newClinicAppointment.BookedStatus__c == 'Not Booked' || newClinicAppointment.BookedStatus__c == 'Booked')) {
                    validClinicAppointments.add(newClinicAppointment);
                }
            }
        }

        checkDuplicates(validClinicAppointments);
    } 

    public static void ckeckDurationOnInsert(List<Clinic_Appointment__c> newClinicAppointments) {
        for (Clinic_Appointment__c newClinicAppointment : newClinicAppointments) {
            if (newClinicAppointment.CS_Start_Date__c != null 
                    && newClinicAppointment.CS_End_Date__c != null 
                    && newClinicAppointment.CS_Start_Date__c >= newClinicAppointment.CS_End_Date__c
                    && newClinicAppointment.Clinic__c != null
                    && (newClinicAppointment.BookedStatus__c == 'Not Booked' || newClinicAppointment.BookedStatus__c == 'Booked')
                    && newClinicAppointment.Apppointment_Type__c != 'Surgery Preparation Appointment'
                    && newClinicAppointment.Apppointment_Type__c != 'Aftercare Appointment'
                    && newClinicAppointment.Ghost_Appointment__c != 'True') {
                newClinicAppointment.addError('Start time should be earlier than End time!');
            }
        }
    } 

    public static void checkDuplicatesOnUpdate(List<Clinic_Appointment__c> newClinicAppointments, Map<Id, Clinic_Appointment__c> oldClinicAppointmentsMap) {
        List<Clinic_Appointment__c> validClinicAppointments = new List<Clinic_Appointment__c>();

        for (Clinic_Appointment__c newClinicAppointment : newClinicAppointments) {
            if (!isRecordProcessed('checkDuplicatesOnUpdate', newClinicAppointment.Id)) {
                if (newClinicAppointment.CS_Start_Date__c != null && newClinicAppointment.CS_End_Date__c != null
                        && newClinicAppointment.CS_Start_Date__c.date() == newClinicAppointment.CS_End_Date__c.date()
                        && newClinicAppointment.Clinic__c != null
                        && newClinicAppointment.RecordTypeId != preExAppointmentId
                        && (newClinicAppointment.BookedStatus__c == 'Not Booked' || newClinicAppointment.BookedStatus__c == 'Booked')) {
                    if (oldClinicAppointmentsMap.containsKey(newClinicAppointment.Id)) {
                        Clinic_Appointment__c oldClinicAppointment = oldClinicAppointmentsMap.get(newClinicAppointment.Id);

                        if (newClinicAppointment.CS_Start_Date__c != oldClinicAppointment.CS_Start_Date__c
                                || newClinicAppointment.CS_End_Date__c != oldClinicAppointment.CS_End_Date__c
                                || newClinicAppointment.Clinic__c != oldClinicAppointment.Clinic__c
                                || newClinicAppointment.BookedStatus__c != oldClinicAppointment.BookedStatus__c
                                || newClinicAppointment.Ghost_Appointment__c != oldClinicAppointment.Ghost_Appointment__c
                                || newClinicAppointment.Apppointment_Type__c != oldClinicAppointment.Apppointment_Type__c) {
                            validClinicAppointments.add(newClinicAppointment);
                        }
                    } else {
                        validClinicAppointments.add(newClinicAppointment);
                    }
                }
            }
        }

        checkDuplicates(validClinicAppointments);
    } 

    public static void checkAfterCareAppointmentsBookingLimitOnInsert(List<Clinic_Appointment__c> newClinicAppointments) {
        List<Clinic_Appointment__c> validClinicAppointments = new List<Clinic_Appointment__c>();

        Set<Id> opportunityIds = new Set<Id>();

        for (Clinic_Appointment__c newClinicAppointment : newClinicAppointments) {
            if (!isRecordProcessed('checkAfterCareAppointmentsBookingLimitOnInsert', newClinicAppointment.Id)) {
                if (newClinicAppointment.Apppointment_Type__c == 'Aftercare Appointment' && newClinicAppointment.Opportunity__c != null) {
                    validClinicAppointments.add(newClinicAppointment);
                    opportunityIds.add(newClinicAppointment.Opportunity__c);
                }
            }
        }

        //checkAfterCareAppointmentsBookingLimit(validClinicAppointments, opportunityIds);
    } 

    public static void checkPreMedAppointmentsBookingLimitOnInsert(List<Clinic_Appointment__c> newClinicAppointments) {
        List<Clinic_Appointment__c> validClinicAppointments = new List<Clinic_Appointment__c>();

        Set<Id> opportunityIds = new Set<Id>();

        for (Clinic_Appointment__c newClinicAppointment : newClinicAppointments) {
            if (!isRecordProcessed('checkPreMedAppointmentsBookingLimitOnInsert', newClinicAppointment.Id)) {
                if (newClinicAppointment.Apppointment_Type__c == 'Surgery Preparation Appointment' && newClinicAppointment.Opportunity__c != null) {
                    validClinicAppointments.add(newClinicAppointment);
                    opportunityIds.add(newClinicAppointment.Opportunity__c);
                }
            }
        }

        //checkPreMedAppointmentsBookingLimit(validClinicAppointments, opportunityIds);
    } 

    public static void checkOpportunityOperationAppointmentOnUpdate(List<Clinic_Appointment__c> newClinicAppointments, Map<Id, Clinic_Appointment__c> oldClinicAppointmentsMap) {
         Map<Id, Clinic_Appointment__c> opportunitiesClinicAppointmentMap = new Map<Id, Clinic_Appointment__c>();

         for (Clinic_Appointment__c newClinicAppointment : newClinicAppointments) {
            if ((newClinicAppointment.Apppointment_Type__c == 'Aftercare Appointment' || newClinicAppointment.Apppointment_Type__c == 'Surgery Preparation Appointment')
                    && newClinicAppointment.Opportunity__c != null) {
                opportunitiesClinicAppointmentMap.put(newClinicAppointment.Opportunity__c, newClinicAppointment);
            }
        }

        Map<Id, Opportunity> opportunitiesMap = new Map<Id, Opportunity>([
            SELECT Id,
                Operation_Appointment__c
            FROM Opportunity
            WHERE Id IN :opportunitiesClinicAppointmentMap.keySet()
                AND Operation_Appointment__c = NULL
        ]); 
        
        /* for (Id opportunityId : opportunitiesMap.keySet()) {
            if (opportunitiesClinicAppointmentMap.containsKey(opportunityId)) {
                opportunitiesClinicAppointmentMap.get(opportunityId).addError('Book operation appointment for opportunity first!');
            }
        } */

    }

    public static void checkAfterCareAppointmentsBookingLimitOnUpdate(List<Clinic_Appointment__c> newClinicAppointments, Map<Id, Clinic_Appointment__c> oldClinicAppointmentsMap) {
        List<Clinic_Appointment__c> validClinicAppointments = new List<Clinic_Appointment__c>();

        Set<Id> opportunityIds = new Set<Id>();

        for (Clinic_Appointment__c newClinicAppointment : newClinicAppointments) {
            if (!isRecordProcessed('checkAfterCareAppointmentsBookingLimitOnUpdate', newClinicAppointment.Id)) {
                if (newClinicAppointment.Apppointment_Type__c == 'Aftercare Appointment'
                        && newClinicAppointment.Opportunity__c != null) {
                    if (oldClinicAppointmentsMap.containsKey(newClinicAppointment.Id)) {
                        Clinic_Appointment__c oldClinicAppointment = oldClinicAppointmentsMap.get(newClinicAppointment.Id);

                        if (newClinicAppointment.Apppointment_Type__c != oldClinicAppointment.Apppointment_Type__c
                                || newClinicAppointment.Opportunity__c != oldClinicAppointment.Opportunity__c) {
                            validClinicAppointments.add(newClinicAppointment);
                            opportunityIds.add(newClinicAppointment.Opportunity__c);
                        }
                    }
                }
            }
        }

        //checkAfterCareAppointmentsBookingLimit(validClinicAppointments, opportunityIds);
    } 

    public static void checkPreMedAppointmentsBookingLimitOnUpdate(List<Clinic_Appointment__c> newClinicAppointments, Map<Id, Clinic_Appointment__c> oldClinicAppointmentsMap) {
        List<Clinic_Appointment__c> validClinicAppointments = new List<Clinic_Appointment__c>(); 

        Set<Id> opportunityIds = new Set<Id>();

        for (Clinic_Appointment__c newClinicAppointment : newClinicAppointments) {
            if (!isRecordProcessed('checkPreMedAppointmentsBookingLimitOnUpdate', newClinicAppointment.Id)) {
                if (newClinicAppointment.Apppointment_Type__c == 'Surgery Preparation Appointment'
                        && newClinicAppointment.Opportunity__c != null) {
                    if (oldClinicAppointmentsMap.containsKey(newClinicAppointment.Id)) {
                        Clinic_Appointment__c oldClinicAppointment = oldClinicAppointmentsMap.get(newClinicAppointment.Id);

                        if (newClinicAppointment.Apppointment_Type__c != oldClinicAppointment.Apppointment_Type__c
                                || newClinicAppointment.Opportunity__c != oldClinicAppointment.Opportunity__c) {
                            validClinicAppointments.add(newClinicAppointment);
                            opportunityIds.add(newClinicAppointment.Opportunity__c);
                        }
                    }
                }
            }
        }

        //checkPreMedAppointmentsBookingLimit(validClinicAppointments, opportunityIds);
    } 

    public static void checkClinicAppointmentStatus(List<Clinic_Appointment__c> newClinicAppointments, Map<Id, Clinic_Appointment__c> oldClinicAppointmentsMap) {
        Set<Id> clinicAppointmentIds = new Set<Id>();

        System.debug(JSON.serializePretty(newClinicAppointments));
        System.debug(JSON.serializePretty(oldClinicAppointmentsMap));

        for (Clinic_Appointment__c newClinicAppointment : newClinicAppointments) {
            if (oldClinicAppointmentsMap.containsKey(newClinicAppointment.Id)) {
                Clinic_Appointment__c oldClinicAppointment = oldClinicAppointmentsMap.get(newClinicAppointment.Id);
                System.debug(JSON.serializePretty(oldClinicAppointment));
                if (newClinicAppointment.Appointment_Status__c != oldClinicAppointment.Appointment_Status__c
                    && newClinicAppointment.Appointment_Status__c == 'Available'
                    && newClinicAppointment.MOClinicAppointment__c == true
                    && newClinicAppointment.MOAvailability__c != null) {
                        System.debug(JSON.serializePretty(newClinicAppointment));
                        clinicAppointmentIds.add(newClinicAppointment.Id);
                }
            }
        }

        Database.delete(new List<Id>(clinicAppointmentIds));
    } 

   /* private static void checkAfterCareAppointmentsBookingLimit(List<Clinic_Appointment__c> validClinicAppointments, Set<Id> opportunityIds) {
        if (!validClinicAppointments.isEmpty() && !opportunityIds.isEmpty()) {
            String appointmentType = 'Aftercare Appointment';
            Map<Id, Opportunity> opportunitiesMap = getOpportunities(opportunityIds, appointmentType);

            System.debug(opportunitiesMap);

            for (Clinic_Appointment__c validClinicAppointment : validClinicAppointments) {
                if (opportunitiesMap.containsKey(validClinicAppointment.Opportunity__c)) {
                    Opportunity opportunity = opportunitiesMap.get(validClinicAppointment.Opportunity__c);
                    if (opportunity.Clinic_Appointments__r.size() > 3) {
                        validClinicAppointment.addError('You can not create more than 4 after care appointments for specified opportunity record!');
                    }
                }
            }
        }
    } */

    /* private static void checkPreMedAppointmentsBookingLimit(List<Clinic_Appointment__c> validClinicAppointments, Set<Id> opportunityIds) {
        if (!validClinicAppointments.isEmpty() && !opportunityIds.isEmpty()) {
            String appointmentType = 'Surgery Preparation Appointment';
            Map<Id, Opportunity> opportunitiesMap = getOpportunities(opportunityIds, appointmentType);

            System.debug(opportunitiesMap);

            for (Clinic_Appointment__c validClinicAppointment : validClinicAppointments) {
                if (opportunitiesMap.containsKey(validClinicAppointment.Opportunity__c)) {
                    Opportunity opportunity = opportunitiesMap.get(validClinicAppointment.Opportunity__c);
                    if (opportunity.Clinic_Appointments__r.size() > 0) {
                        validClinicAppointment.addError('You can not create more than 1 pre med appointments for specified opportunity record!');
                    }
                }
            }
        }
    } */

    private static void checkDuplicates(List<Clinic_Appointment__c> validClinicAppointments) {
        if (!validClinicAppointments.isEmpty()) {
            Set<Id> clinicIds = new Set<Id>();

            Set<Date> availabilityDates = new Set<Date>();

            for (Clinic_Appointment__c validClinicAppointment : validClinicAppointments) {
                if (validClinicAppointment.Apppointment_Type__c != 'Surgery Preparation Appointment'
                        && validClinicAppointment.Apppointment_Type__c != 'Aftercare Appointment'
                        && validClinicAppointment.Ghost_Appointment__c != 'True') {
                    clinicIds.add(validClinicAppointment.Clinic__c);

                    availabilityDates.add(validClinicAppointment.CS_Start_Date__c.date());
                    availabilityDates.add(validClinicAppointment.CS_End_Date__c.date());
                }
            }

            List<Clinic_Appointment__c> existedAppointments = getExistedAppointments(clinicIds, availabilityDates);

            Map<Id, Map<Date, List<Clinic_Appointment__c>>> existedClinicDateAppointmentsMap = new Map<Id, Map<Date, List<Clinic_Appointment__c>>>();

            for (Clinic_Appointment__c existedAppointment : existedAppointments) {
                if (!existedClinicDateAppointmentsMap.containsKey(existedAppointment.Clinic__c)) {
                    existedClinicDateAppointmentsMap.put(existedAppointment.Clinic__c, new Map<Date, List<Clinic_Appointment__c>>());
                }

                if (!existedClinicDateAppointmentsMap.get(existedAppointment.Clinic__c).containsKey(existedAppointment.CS_Start_Date__c.date())) {
                    existedClinicDateAppointmentsMap.get(existedAppointment.Clinic__c).put(existedAppointment.CS_Start_Date__c.date(), new List<Clinic_Appointment__c>());
                }

                existedClinicDateAppointmentsMap.get(existedAppointment.Clinic__c).get(existedAppointment.CS_Start_Date__c.date()).add(existedAppointment);
            }

            for (Clinic_Appointment__c validClinicAppointment : validClinicAppointments) {
                if (existedClinicDateAppointmentsMap.containsKey(validClinicAppointment.Clinic__c)
                        && existedClinicDateAppointmentsMap.get(validClinicAppointment.Clinic__c).containsKey(validClinicAppointment.CS_Start_Date__c.date())) {
                    List<Clinic_Appointment__c> existedClinicDateAppointments = existedClinicDateAppointmentsMap.get(validClinicAppointment.Clinic__c).get(validClinicAppointment.CS_Start_Date__c.date());

                    Boolean hasDuplicates = hasDuplicates(validClinicAppointment, existedClinicDateAppointments);

                    if (hasDuplicates) {
                        validClinicAppointment.addError('There are duplicate records with the specified values!');
                    }
                }
            }
        }
    } 

    private static Boolean hasDuplicates(Clinic_Appointment__c validClinicAppointment, List<Clinic_Appointment__c> existedClinicDateAppointments) {
        Boolean hasDuplicates = false;

        if (validClinicAppointment != null && !existedClinicDateAppointments.isEmpty()) {
            for (Clinic_Appointment__c existedClinicDateAppointment : existedClinicDateAppointments) {
                if (validClinicAppointment.Id != existedClinicDateAppointment.Id
                        && validClinicAppointment.MOAvailability__c != existedClinicDateAppointment.Id) {
                    if (validClinicAppointment.CS_Start_Date__c == existedClinicDateAppointment.CS_Start_Date__c
                            || validClinicAppointment.CS_End_Date__c == existedClinicDateAppointment.CS_End_Date__c) {
                        hasDuplicates = true;
                        break;
                    }

                    if (validClinicAppointment.CS_Start_Date__c > existedClinicDateAppointment.CS_Start_Date__c
                            && validClinicAppointment.CS_Start_Date__c < existedClinicDateAppointment.CS_End_Date__c) {
                        hasDuplicates = true;
                        break;
                    }

                    if (validClinicAppointment.CS_End_Date__c > existedClinicDateAppointment.CS_Start_Date__c
                            && validClinicAppointment.CS_End_Date__c < existedClinicDateAppointment.CS_End_Date__c) {
                        hasDuplicates = true;
                        break;
                    }

                    if (validClinicAppointment.CS_Start_Date__c < existedClinicDateAppointment.CS_Start_Date__c
                            && validClinicAppointment.CS_End_Date__c > existedClinicDateAppointment.CS_End_Date__c) {
                        hasDuplicates = true;
                        break;
                    }
                }
            }
        }

        return hasDuplicates;
    } 

    private static List<Clinic_Appointment__c> getExistedAppointments(Set<Id> clinicIds, Set<Date> availabilityDates) {
        List<Clinic_Appointment__c> existedAppointments = new List<Clinic_Appointment__c>();

        if (!clinicIds.isEmpty() && !availabilityDates.isEmpty()) {
            Set<String> recordQueryFields = new Set<String>{
                    SObjectType.Clinic_Appointment__c.fields.Id.Name,
                    SObjectType.Clinic_Appointment__c.fields.Clinic__c.Name,
                    SObjectType.Clinic_Appointment__c.fields.CS_Start_Date__c.Name,
                    SObjectType.Clinic_Appointment__c.fields.CS_End_Date__c.Name
            };

            List<String> conditions = new List<String>();

            conditions.add(QueryService.getCondition(
                    SObjectType.Clinic_Appointment__c.fields.Clinic__c.Name,
                    'IN',
                    ':clinicIds',
                    false
            ));

            Set<Id> recordTypeIds = new Set<Id>{
                    Schema.SObjectType.Clinic_Appointment__c.getRecordTypeInfosByDeveloperName().get('Pre_Ex_Appointment').getRecordTypeId(),
                    Schema.SObjectType.Clinic_Appointment__c.getRecordTypeInfosByDeveloperName().get('Operation_Date').getRecordTypeId()
            };

            conditions.add(QueryService.getCondition(
                    SObjectType.Clinic_Appointment__c.fields.RecordTypeId.Name,
                    'IN',
                    ':recordTypeIds',
                    false
            ));

            conditions.add(QueryService.getCondition(
                    'DAY_ONLY(' + SObjectType.Clinic_Appointment__c.fields.CS_Start_Date__c.Name + ')',
                    'IN',
                    ':availabilityDates',
                    false
            ));

            conditions.add(QueryService.getCondition(
                    'DAY_ONLY(' + SObjectType.Clinic_Appointment__c.fields.CS_End_Date__c.Name + ')',
                    'IN',
                    ':availabilityDates',
                    false
            ));

            Set<String> bookedStatuses = new Set<String>{'Not Booked', 'Booked'};

            conditions.add(QueryService.getCondition(
                    SObjectType.Clinic_Appointment__c.fields.BookedStatus__c.Name,
                    'IN',
                    ':bookedStatuses',
                    false
            ));

            conditions.add(QueryService.getCondition(
                    SObjectType.Clinic_Appointment__c.fields.Ghost_Appointment__c.Name,
                    '!=',
                    'True',
                    true
            ));

            String whereConditions = String.join(conditions, ' AND ');

            String recordsQueryString = new SOQLQuery.Builder()
                    .setSelectToken(
                            new SOQLSelect.Builder()
                                    .setObject(SObjectType.Clinic_Appointment__c.Name)
                                    .setRequiredFields(recordQueryFields)
                                    .build()
                    )
                    .setObject(SObjectType.Clinic_Appointment__c.Name)
                    .setWhereConditions(whereConditions)
                    .setQueryLimit(String.valueOf(50000))
                    .build()
                    .toString();
            System.debug(recordsQueryString);

            if (String.isNotBlank(recordsQueryString)) {
                existedAppointments = Database.query(recordsQueryString);
            }
        }

        return existedAppointments;
    } 

    private static Map<Id, Opportunity> getOpportunities(Set<Id> opportunityIds, String appointmentType) {
        Map<Id, Opportunity> opportunities = new Map<Id, Opportunity>();

        if (!opportunityIds.isEmpty()) {

            Set<String> recordQueryFields = new Set<String>{
                    '(SELECT Id FROM Clinic_Appointments__r WHERE Apppointment_Type__c = \'' +  appointmentType + '\')'
            };

            List<String> conditions = new List<String>();

            conditions.add(QueryService.getCondition(
                    SObjectType.Opportunity.fields.Id.Name,
                    'IN',
                    ':opportunityIds',
                    false
            ));

            String whereConditions = String.join(conditions, ' AND ');

            String recordsQueryString = new SOQLQuery.Builder()
                    .setSelectToken(
                            new SOQLSelect.Builder()
                                    .setObject(SObjectType.Opportunity.Name)
                                    .setRequiredFields(recordQueryFields)
                                    .build()
                    )
                    .setObject(SObjectType.Opportunity.Name)
                    .setWhereConditions(whereConditions)
                    .setQueryLimit(String.valueOf(50000))
                    .build()
                    .toString();
            System.debug(recordsQueryString);

            if (String.isNotBlank(recordsQueryString)) {
                opportunities = new Map<Id, Opportunity>((List<Opportunity>) Database.query(recordsQueryString));
            }
        }

        return opportunities;
    } 

    private static Boolean isRecordProcessed(String operationName, Id recordId) {
        Boolean isRecordProcessed = false;

        if (String.isNotBlank(operationName) && recordId != null) {
            if (!processedRecordIds.containsKey(operationName)) {
                processedRecordIds.put(operationName, new Set<Id>());
            }

            if (!processedRecordIds.get(operationName).contains(recordId)) {
                isRecordProcessed = false;

                processedRecordIds.get(operationName).add(recordId);
            } else {
                isRecordProcessed = true;
            }
        }

        return isRecordProcessed;
    }

}