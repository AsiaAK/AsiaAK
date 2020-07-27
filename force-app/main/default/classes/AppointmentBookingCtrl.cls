/**
 * AppointmentBookingCtrl class 1.0.0
 *
 * @description This class represents an AppointmentBookingCtrl.
 *
 * @author Nadezhda Podobed
 * @date 16.03.2019
 */
public with sharing class AppointmentBookingCtrl {

    private static final String CLASS_NAME = AppointmentBookingCtrl.class.getName();

    private static final String STATUS_SUCCESS = 'success';
    private static final String STATUS_WARNING = 'warning';
    private static final String STATUS_ERROR = 'error';

    @AuraEnabled
    public static String getOpportunity(String opportunityFilterJSON) {
        Response.Builder response = new Response.Builder();

        try {
            if (String.isNotBlank(opportunityFilterJSON)) {
                Map<String, Object> opportunityFilter = (Map<String, Object>) JSON.deserializeUntyped(opportunityFilterJSON);

                Map<String, Object> responseData = new Map<String, Object>();

                Opportunity opportunity = getOpportunityRecord(opportunityFilter);
                responseData.put('opportunity', opportunity);

                response.setData(responseData)
                        .setStatus(STATUS_SUCCESS);
            } else {
                response.setMessage('One or more parameter values are not valid: ' + opportunityFilterJSON)
                        .setStatus(STATUS_ERROR);
            }
        } catch (Exception e) {
            response.setMessage(CLASS_NAME + ': ' + e.getMessage())
                    .setStatus(STATUS_ERROR);
            System.debug(e.getStackTraceString());
        }

        return JSON.serializePretty(response.build(), true);
    }

    @AuraEnabled
    public static String checkNumberOfPreMedAppointments(String opportunityFilterJSON){
        Response.Builder response = new Response.Builder();
        try {
            if (String.isNotBlank(opportunityFilterJSON)) {
                Map<String, Object> opportunityFilter = (Map<String, Object>) JSON.deserializeUntyped(opportunityFilterJSON);

                Map<String, Object> responseData = new Map<String, Object>();

                Integer appointmentNumber = checkNumebrOfPreMedAppointmentsRecord(opportunityFilter);
                responseData.put('appointmentNumber', appointmentNumber);

                response.setData(responseData)
                        .setStatus(STATUS_SUCCESS);
            } else {
                response.setMessage('One or more parameter values are not valid: ' + opportunityFilterJSON)
                        .setStatus(STATUS_ERROR);
            }
        } catch (Exception e) {
            response.setMessage(CLASS_NAME + ': ' + e.getMessage())
                    .setStatus(STATUS_ERROR);
            System.debug(e.getStackTraceString());
        }

        return JSON.serializePretty(response.build(), true);
    }

    @AuraEnabled
    public static String getPreexAvailabilities(String availabilitiesFilterJSON) {
        Response.Builder response = new Response.Builder();

        try {
            if (String.isNotBlank(availabilitiesFilterJSON)) {
                Map<String, Object> availabilitiesFilter = (Map<String, Object>) JSON.deserializeUntyped(availabilitiesFilterJSON);

                Map<String, Object> responseData = new Map<String, Object>();

                List<Map<String, Object>> availabilities = new List<Map<String, Object>>();
                availabilities.addAll(getPreexAvailabilityRecords(availabilitiesFilter));
                availabilities.addAll(getAfterCareAndPremedAvailabilityRecords(availabilitiesFilter));
                responseData.put('availabilities', availabilities);

                responseData.put('resources', getResourceRecords(availabilities));

                response.setData(responseData)
                        .setStatus(STATUS_SUCCESS);
            } else {
                response.setMessage('One or more parameter values are not valid: ' + availabilitiesFilterJSON)
                        .setStatus(STATUS_ERROR);
            }
        } catch (Exception e) {
            response.setMessage(CLASS_NAME + ': ' + e.getMessage())
                    .setStatus(STATUS_ERROR);
            System.debug(e.getStackTraceString());
        }

        return JSON.serializePretty(response.build(), true);
    }

    @AuraEnabled
    public static String getOperationAvailabilities(String availabilitiesFilterJSON) {
        Response.Builder response = new Response.Builder();

        try {
            if (String.isNotBlank(availabilitiesFilterJSON)) {
                Map<String, Object> availabilitiesFilter = (Map<String, Object>) JSON.deserializeUntyped(availabilitiesFilterJSON);

                Map<String, Object> responseData = new Map<String, Object>();

                List<Map<String, Object>> availabilities = new List<Map<String, Object>>();

                List<Map<String, Object>> moAvailabilities = getMOOperationAvailabilityRecords(availabilitiesFilter);
                availabilities.addAll(moAvailabilities);

                List<Map<String, Object>> mdAvailabilities = getMDOperationAvailabilityRecords(availabilitiesFilter);
                availabilities.addAll(mdAvailabilities);

                responseData.put('availabilities', availabilities);

                responseData.put('resources', getResourceRecords(availabilities));

                response.setData(responseData)
                        .setStatus(STATUS_SUCCESS);
            } else {
                response.setMessage('One or more parameter values are not valid: ' + availabilitiesFilterJSON)
                        .setStatus(STATUS_ERROR);
            }
        } catch (Exception e) {
            response.setMessage(CLASS_NAME + ': ' + e.getMessage())
                    .setStatus(STATUS_ERROR);
            System.debug(e.getStackTraceString());
        }

        System.debug(JSON.serializePretty(response.build(), true));

        return JSON.serializePretty(response.build(), true);
    }

    @AuraEnabled
    public static String savePreMedAppointment(String preMedAppointmentDataJSON) {
        Response.Builder response = new Response.Builder();

        try {
            if (String.isNotBlank(preMedAppointmentDataJSON)) {
                Map<String, Object> preMedAppointmentData = (Map<String, Object>) JSON.deserializeUntyped(preMedAppointmentDataJSON);

                System.debug(preMedAppointmentData);

                Map<String, Object> responseData = new Map<String, Object>();

                Map<String, Object> preMedAppointment = savePreMedAppointmentData(preMedAppointmentData);
                responseData.put('preMedAppointment', preMedAppointment);

                System.debug(responseData);

                response.setData(responseData)
                        .setStatus(STATUS_SUCCESS);
            } else {
                response.setMessage('One or more parameter values are not valid: ' + preMedAppointmentDataJSON)
                        .setStatus(STATUS_ERROR);
            }
        } catch (DmlException e) {
            System.debug(e.getTypeName());
            System.debug(e.getDmlMessage(0));
            response.setMessage(CLASS_NAME + ': ' + getExceptionMessage(e.getDmlMessage(0)))
                    .setStatus(STATUS_ERROR);
            System.debug(e.getStackTraceString());
        } catch (Exception e) {
            response.setMessage(CLASS_NAME + ': ' + e.getMessage())
                    .setStatus(STATUS_ERROR);
            System.debug(e.getStackTraceString());
        }

        return JSON.serializePretty(response.build(), true);
    }

    @AuraEnabled
    public static String saveAfterCareAppointment(String afterCareAppointmentDataJSON) {
        Response.Builder response = new Response.Builder();

        try {
            if (String.isNotBlank(afterCareAppointmentDataJSON)) {
                Map<String, Object> afterCareAppointmentData = (Map<String, Object>) JSON.deserializeUntyped(afterCareAppointmentDataJSON);

                Map<String, Object> responseData = new Map<String, Object>();

                Map<String, Object> afterCareAppointment = saveAfterCareAppointmentData(afterCareAppointmentData);
                responseData.put('afterCareAppointment', afterCareAppointment);

                response.setData(responseData)
                        .setStatus(STATUS_SUCCESS);
            } else {
                response.setMessage('One or more parameter values are not valid: ' + afterCareAppointmentDataJSON)
                        .setStatus(STATUS_ERROR);
            }
        } catch (DmlException e) {
            System.debug('Exception type caught: ' + e.getTypeName());    
            System.debug('Message: ' + e.getMessage());    
            System.debug('Cause: ' + e.getCause());
            System.debug('Line number: ' + e.getLineNumber());    
            System.debug('Stack trace: ' + e.getStackTraceString());  
            response.setMessage(CLASS_NAME + ': ' + getExceptionMessage(e.getDmlMessage(0)))
                    .setStatus(STATUS_ERROR);
            System.debug(e.getNumDml());
            System.debug(e.getDmlId(0));
            System.debug(e.getDmlFieldNames(0));
            System.debug(e.getDmlMessage(0));
        } catch (Exception e) {
            System.debug(e.getTypeName());
            response.setMessage(CLASS_NAME + ': ' + e.getMessage())
                    .setStatus(STATUS_ERROR);
            System.debug(e.getStackTraceString());
        }

        return JSON.serializePretty(response.build(), true);
    }

    @AuraEnabled
    public static String saveMDOperationAppointment(String mdOperationAppointmentDataJSON) {
        Response.Builder response = new Response.Builder();

        try {
            if (String.isNotBlank(mdOperationAppointmentDataJSON)) {
                Map<String, Object> mdOperationAppointmentData = (Map<String, Object>) JSON.deserializeUntyped(mdOperationAppointmentDataJSON);

                Map<String, Object> responseData = new Map<String, Object>();

                Map<String, Object> mdOperationAppointment = saveMDOperationAppointmentData(mdOperationAppointmentData);
                responseData.put('mdOperationAppointment', mdOperationAppointment);

                response.setData(responseData)
                        .setStatus(STATUS_SUCCESS);
            } else {
                response.setMessage('One or more parameter values are not valid: ' + mdOperationAppointmentDataJSON)
                        .setStatus(STATUS_ERROR);
            }
        } catch (Exception e) {
            response.setMessage(CLASS_NAME + ': ' + e.getMessage())
                    .setStatus(STATUS_ERROR);
            System.debug(e.getStackTraceString());
        }

        return JSON.serializePretty(response.build(), true);
    }

    @AuraEnabled
    public static String saveMOOperationAppointment(String moOperationAppointmentDataJSON) {
        Response.Builder response = new Response.Builder();

        try {
            if (String.isNotBlank(moOperationAppointmentDataJSON)) {
                Map<String, Object> moOperationAppointmentData = (Map<String, Object>) JSON.deserializeUntyped(moOperationAppointmentDataJSON);

                Map<String, Object> responseData = new Map<String, Object>();

                Map<String, Object> moOperationAppointment = saveMOOperationAppointmentData(moOperationAppointmentData);
                responseData.put('moOperationAppointment', moOperationAppointment);

                response.setData(responseData)
                        .setStatus(STATUS_SUCCESS);
            } else {
                response.setMessage('One or more parameter values are not valid: ' + moOperationAppointmentDataJSON)
                        .setStatus(STATUS_ERROR);
            }
        } catch (Exception e) {
            response.setMessage(CLASS_NAME + ': ' + e.getMessage())
                    .setStatus(STATUS_ERROR);
            System.debug(e.getStackTraceString());
        }

        return JSON.serializePretty(response.build(), true);
    }

    private static Opportunity getOpportunityRecord(Map<String, Object> opportunityFilter) {
        Opportunity opportunity;

        if (opportunityFilter != null && !opportunityFilter.isEmpty()) {
            Set<String> recordQueryFields = new Set<String>{
                    SObjectType.Opportunity.fields.Id.Name,
                    SObjectType.Opportunity.fields.Clinic__c.Name
            };

            List<String> conditions = new List<String>();

            String recordId = (String) opportunityFilter.get('recordId');

            conditions.add(QueryService.getCondition(
                    SObjectType.Opportunity.fields.Id.Name,
                    '=',
                    recordId,
                    true
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
                    .setOrderByToken(
                            new SOQLOrderBy.Builder()
                                    .setOrderFields(SObjectType.Opportunity.fields.CreatedDate.Name)
                                    .setOrderType('DESC')
                                    .build()
                    )
                    .setQueryLimit(String.valueOf(50000))
                    .build()
                    .toString();
            System.debug(recordsQueryString);

            if (String.isNotBlank(recordsQueryString)) {
                List<Opportunity> opportunities = Database.query(recordsQueryString);

                if (!opportunities.isEmpty()) {
                    opportunity = opportunities.get(0);
                }
            }
        }

        return opportunity;
    }

    private static Integer checkNumebrOfPreMedAppointmentsRecord(Map<String, Object> opportunityFilter) {
        Integer appointmentNumber = 0;
        if (opportunityFilter != null && !opportunityFilter.isEmpty()) {
            String recordId = (String) opportunityFilter.get('recordId');

            List<AggregateResult> appointmentNumberList =  [
                SELECT Count(Id)
                FROM Clinic_Appointment__c
                WHERE Opportunity__c = :recordId
                    AND Apppointment_Type__c = 'Surgery Preparation Appointment'
            ];

            appointmentNumber = (Integer) appointmentNumberList[0].get('expr0');
        }
        
        return appointmentNumber;
    }

    
    private static List<Map<String, Object>> getAfterCareAndPremedAvailabilityRecords(Map<String, Object> availabilitiesFilter) {
        List<Map<String, Object>> availabilities = new List<Map<String, Object>>();

        if (availabilitiesFilter != null && !availabilitiesFilter.isEmpty()) {
            Set<String> recordQueryFields = new Set<String>{
                    SObjectType.Clinic_Appointment__c.fields.Id.Name,
                    SObjectType.Clinic_Appointment__c.fields.Clinic__c.Name,
                    SObjectType.Clinic_Appointment__c.fields.MD_Day__c.Name,
                    SObjectType.Clinic_Appointment__c.fields.Name.Name,
                    SObjectType.Clinic_Appointment__c.fields.CS_Start_Date__c.Name,
                    SObjectType.Clinic_Appointment__c.fields.CS_End_Date__c.Name,
                    SObjectType.Clinic_Appointment__c.fields.Appointment_Status__c.Name,
                    SObjectType.Clinic_Appointment__c.fields.BookedStatus__c.Name,
                    SObjectType.Clinic_Appointment__c.fields.Reminder_Call_Status__c.Name,
                    'Clinic__r.Name'
            };

            List<String> conditions = new List<String>();

            String clinicId = (String) availabilitiesFilter.get('clinicId');

            conditions.add(QueryService.getCondition(
                    SObjectType.Clinic_Appointment__c.fields.Clinic__c.Name,
                    '=',
                    clinicId,
                    true
            ));

            Map<String, Object> activityRange = (Map<String, Object>) availabilitiesFilter.get('range');

            conditions.add(QueryService.getCondition(
                    SObjectType.Clinic_Appointment__c.fields.CS_Start_Date__c.Name,
                    '>=',
                    String.valueOf(activityRange.get('start')),
                    false
            ));

            conditions.add(QueryService.getCondition(
                    SObjectType.Clinic_Appointment__c.fields.CS_End_Date__c.Name,
                    '<=',
                    String.valueOf(activityRange.get('end')),
                    false
            ));

            Set<String> appointmentStatuses = new Set<String>{
                'Reserved',
                'Clinic Confirmed'
            };

            conditions.add(QueryService.getCondition(
                    SObjectType.Clinic_Appointment__c.fields.Appointment_Status__c.Name,
                    'IN',
                    ':appointmentStatuses',
                    false
            ));

            conditions.add(QueryService.getCondition(
                    SObjectType.Clinic_Appointment__c.fields.Ghost_Appointment__c.Name,
                    '!=',
                    'True',
                    true
            ));

            String appointmentRecordTypeName = (String) availabilitiesFilter.get('appointmentRecordTypeName');

            conditions.add(QueryService.getCondition(
                    'RecordType.DeveloperName',
                    '=',
                    appointmentRecordTypeName,
                    true
            ));

            List<Object> appointmentTypes = (List<Object>) availabilitiesFilter.get('additionalAppointmentTypes');

            Set<String> appTypes = new Set<String>();

            for (Object selectedAppointmentType : appointmentTypes) {
                appTypes.add(String.valueOf(selectedAppointmentType));
            } 

            conditions.add(QueryService.getCondition(
                    SObjectType.Clinic_Appointment__c.fields.Apppointment_Type__c.Name,
                    'IN',
                    ':appTypes',
                    false
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
                    .setOrderByToken(
                            new SOQLOrderBy.Builder()
                                    .setOrderFields(SObjectType.Clinic_Appointment__c.fields.CreatedDate.Name)
                                    .setOrderType('DESC')
                                    .build()
                    )
                    .setQueryLimit(String.valueOf(50000))
                    .build()
                    .toString();
            System.debug(recordsQueryString);

            if (String.isNotBlank(recordsQueryString)) {

                Map<String, Map<String, String>> preMedAppointmentColors = new Map<String, Map<String, String>>{ 
                    'Reserved' => new Map<String, String>{
                        'color' => 'red',
                        'textColor' => 'white'
                    },
                    'Clinic Confirmed' => new Map<String, String>{
                        'color' => 'green',
                        'textColor' => 'white'
                    }
                };

                List<Clinic_Appointment__c> availabilityRecords = Database.query(recordsQueryString);

                for (Clinic_Appointment__c availabilityRecord : availabilityRecords) {
                    Map<String, Object> availability = new Map<String, Object>();
                    availability.put('id', availabilityRecord.Id);
                    availability.put('resourceId', availabilityRecord.Clinic__c);
                    availability.put('resourceTitle', availabilityRecord.Clinic__r.Name);
                    availability.put('mdDayId', availabilityRecord.MD_Day__c);
                    availability.put(
                            'title',
                            availabilityRecord.Reminder_Call_Status__c != null
                                    ? availabilityRecord.Name + ' ' + availabilityRecord.Reminder_Call_Status__c
                                    : availabilityRecord.Name
                    );
                    availability.put('start', availabilityRecord.CS_Start_Date__c);
                    availability.put('end', availabilityRecord.CS_End_Date__c);
                    availability.put('allDay', false);
                    availability.put('color', preMedAppointmentColors.get(availabilityRecord.Appointment_Status__c).get('color'));
                    availability.put('afterCarePreMedSlot', true);
                    availabilities.add(availability);
                }
            }
        }

        return availabilities;
    }
    
    private static List<Map<String, Object>> getPreexAvailabilityRecords(Map<String, Object> availabilitiesFilter) {
        List<Map<String, Object>> availabilities = new List<Map<String, Object>>();

        if (availabilitiesFilter != null && !availabilitiesFilter.isEmpty()) {
            Set<String> recordQueryFields = new Set<String>{
                    SObjectType.Clinic_Appointment__c.fields.Id.Name,
                    SObjectType.Clinic_Appointment__c.fields.Clinic__c.Name,
                    SObjectType.Clinic_Appointment__c.fields.MD_Day__c.Name,
                    SObjectType.Clinic_Appointment__c.fields.Name.Name,
                    SObjectType.Clinic_Appointment__c.fields.CS_Start_Date__c.Name,
                    SObjectType.Clinic_Appointment__c.fields.CS_End_Date__c.Name,
                    SObjectType.Clinic_Appointment__c.fields.Appointment_Status__c.Name,
                    SObjectType.Clinic_Appointment__c.fields.BookedStatus__c.Name,
                    SObjectType.Clinic_Appointment__c.fields.Reminder_Call_Status__c.Name,
                    'Clinic__r.Name'
            };

            List<String> conditions = new List<String>();

            String clinicId = (String) availabilitiesFilter.get('clinicId');

            conditions.add(QueryService.getCondition(
                    SObjectType.Clinic_Appointment__c.fields.Clinic__c.Name,
                    '=',
                    clinicId,
                    true
            ));

            Map<String, Object> activityRange = (Map<String, Object>) availabilitiesFilter.get('range');

            conditions.add(QueryService.getCondition(
                    SObjectType.Clinic_Appointment__c.fields.CS_Start_Date__c.Name,
                    '>=',
                    String.valueOf(activityRange.get('start')),
                    false
            ));

            conditions.add(QueryService.getCondition(
                    SObjectType.Clinic_Appointment__c.fields.CS_End_Date__c.Name,
                    '<=',
                    String.valueOf(activityRange.get('end')),
                    false
            ));

            Set<String> appointmentStatuses = new Set<String>{
                'Available',
                'Reserved',
                'Paid',
                'Clinic Confirmed',
                'Cancelled by Clinic',
                'Show Up',
                'No Show Up',
                'Cancelled by MD'
            };

            conditions.add(QueryService.getCondition(
                    SObjectType.Clinic_Appointment__c.fields.Appointment_Status__c.Name,
                    'IN',
                    ':appointmentStatuses',
                    false
            ));

            conditions.add(QueryService.getCondition(
                    SObjectType.Clinic_Appointment__c.fields.Ghost_Appointment__c.Name,
                    '!=',
                    'True',
                    true
            ));

            String appointmentRecordTypeName = (String) availabilitiesFilter.get('appointmentRecordTypeName');

            conditions.add(QueryService.getCondition(
                    'RecordType.DeveloperName',
                    '=',
                    appointmentRecordTypeName,
                    true
            ));

            String appointmentType = (String) availabilitiesFilter.get('appointmentType');

            conditions.add(QueryService.getCondition(
                    SObjectType.Clinic_Appointment__c.fields.Apppointment_Type__c.Name,
                    '=',
                    appointmentType,
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
                    .setOrderByToken(
                            new SOQLOrderBy.Builder()
                                    .setOrderFields(SObjectType.Clinic_Appointment__c.fields.CreatedDate.Name)
                                    .setOrderType('DESC')
                                    .build()
                    )
                    .setQueryLimit(String.valueOf(50000))
                    .build()
                    .toString();
            System.debug(recordsQueryString);

            if (String.isNotBlank(recordsQueryString)) {

                Map<String, Map<String, String>> preMedAppointmentColors = new Map<String, Map<String, String>>{
                    'Available' => new Map<String, String>{
                        'color' => 'blue',
                        'textColor' => 'white'
                    }, 
                    'Reserved' => new Map<String, String>{
                        'color' => 'red',
                        'textColor' => 'white'
                    },
                    'Paid' => new Map<String, String>{
                        'color' => 'yellow',
                        'textColor' => 'black'
                    },
                    'Clinic Confirmed' => new Map<String, String>{
                        'color' => 'green',
                        'textColor' => 'white'
                    },
                    'Cancelled by Clinic' => new Map<String, String>{
                        'color' => 'purple',
                        'textColor' => 'white'
                    },
                    'Show Up' => new Map<String, String>{
                        'color' => 'orange',
                        'textColor' => 'white' 
                    },
                    'No Show Up' => new Map<String, String> {
                        'color' => 'grey',
                        'textColor' => 'white' 
                    },
                    'Cancelled by MD' => new Map<String, String> {
                        'color' => 'purple',
                        'textColor' => 'white'
                    }
                };

                List<Clinic_Appointment__c> availabilityRecords = Database.query(recordsQueryString);

                for (Clinic_Appointment__c availabilityRecord : availabilityRecords) {
                    Map<String, Object> availability = new Map<String, Object>();
                    availability.put('id', availabilityRecord.Id);
                    availability.put('resourceId', availabilityRecord.Clinic__c);
                    availability.put('resourceTitle', availabilityRecord.Clinic__r.Name);
                    availability.put('mdDayId', availabilityRecord.MD_Day__c);
                    availability.put(
                            'title',
                            availabilityRecord.Reminder_Call_Status__c != null
                                    ? availabilityRecord.Name + ' ' + availabilityRecord.Reminder_Call_Status__c
                                    : availabilityRecord.Name
                    );
                    availability.put('start', availabilityRecord.CS_Start_Date__c);
                    availability.put('end', availabilityRecord.CS_End_Date__c);
                    availability.put('allDay', false);
                    availability.put('color', preMedAppointmentColors.get(availabilityRecord.Appointment_Status__c).get('color'));
                    availabilities.add(availability);
                }
            }
        }

        return availabilities;
    }

    private static List<Map<String, Object>> getMOOperationAvailabilityRecords(Map<String, Object> availabilitiesFilter) {
        List<Map<String, Object>> availabilities = new List<Map<String, Object>>();

        if (availabilitiesFilter != null && !availabilitiesFilter.isEmpty()) {
            Set<String> recordQueryFields = new Set<String>{
                    SObjectType.Clinic_Appointment__c.fields.Id.Name,
                    SObjectType.Clinic_Appointment__c.fields.Clinic__c.Name,
                    SObjectType.Clinic_Appointment__c.fields.MD_Day__c.Name,
                    SObjectType.Clinic_Appointment__c.fields.Name.Name,
                    SObjectType.Clinic_Appointment__c.fields.CS_Start_Date__c.Name,
                    SObjectType.Clinic_Appointment__c.fields.CS_End_Date__c.Name,
                    SObjectType.Clinic_Appointment__c.fields.Appointment_Status__c.Name,
                    SObjectType.Clinic_Appointment__c.fields.BookedStatus__c.Name,
                    SObjectType.Clinic_Appointment__c.fields.MOAvailability__c.Name,
                    SObjectType.Clinic_Appointment__c.fields.Preliminary_appointment__c.Name,
                    SObjectType.Clinic_Appointment__c.fields.Appointment_Status__c.Name,
                    'Clinic__r.Name'
            };

            List<String> conditions = new List<String>();

            String clinicId = (String) availabilitiesFilter.get('clinicId');

            conditions.add(QueryService.getCondition(
                    SObjectType.Clinic_Appointment__c.fields.Clinic__c.Name,
                    '=',
                    clinicId,
                    true
            ));

            conditions.add(QueryService.getCondition(
                    SObjectType.Clinic_Appointment__c.fields.Preliminary_appointment__c.Name,
                    '=',
                    'false',
                    false
            ));

            Map<String, Object> activityRange = (Map<String, Object>) availabilitiesFilter.get('range');

            conditions.add(QueryService.getCondition(
                    SObjectType.Clinic_Appointment__c.fields.CS_Start_Date__c.Name,
                    '>=',
                    String.valueOf(activityRange.get('start')),
                    false
            ));

            conditions.add(QueryService.getCondition(
                    SObjectType.Clinic_Appointment__c.fields.CS_End_Date__c.Name,
                    '<=',
                    String.valueOf(activityRange.get('end')),
                    false
            ));

            Set<String> bookedStatuses = new Set<String>{
                'Not Booked',
                'Booked'
            };

            conditions.add(QueryService.getCondition(
                    SObjectType.Clinic_Appointment__c.fields.BookedStatus__c.Name,
                    'IN',
                    ':bookedStatuses',
                    false
            ));

            String appointmentRecordTypeName = (String) availabilitiesFilter.get('appointmentRecordTypeName');

            conditions.add(QueryService.getCondition(
                    'RecordType.DeveloperName',
                    '=',
                    appointmentRecordTypeName,
                    true
            ));

            conditions.add(QueryService.getCondition(
                    SObjectType.Clinic_Appointment__c.fields.MOClinicAppointment__c.Name,
                    '=',
                    'true',
                    false
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
                    .setOrderByToken(
                            new SOQLOrderBy.Builder()
                                    .setOrderFields(SObjectType.Clinic_Appointment__c.fields.CS_Start_Date__c.Name)
                                    .setOrderType('ASC')
                                    .build()
                    )
                    .setQueryLimit(String.valueOf(50000))
                    .build()
                    .toString();
            System.debug(recordsQueryString);

            if (String.isNotBlank(recordsQueryString)) {
                List<Clinic_Appointment__c> moOperationAppointmentRecords = Database.query(recordsQueryString);

                Map<String, Map<String, Object>> availabilityAppointments = new Map<String, Map<String, Object>>();

                for (Clinic_Appointment__c moOperationAppointmentRecord : moOperationAppointmentRecords) {
                    if (moOperationAppointmentRecord.MOAvailability__c != null) {
                        if (!availabilityAppointments.containsKey(moOperationAppointmentRecord.MOAvailability__c)) {
                            availabilityAppointments.put(moOperationAppointmentRecord.MOAvailability__c, new Map<String, Object>());
                        }

                        if (!availabilityAppointments.get(moOperationAppointmentRecord.MOAvailability__c).containsKey('appointments')) {
                            availabilityAppointments.get(moOperationAppointmentRecord.MOAvailability__c).put('appointments', new List<Clinic_Appointment__c>());
                        }

                        if (moOperationAppointmentRecord.Appointment_Status__c != 'Cancelled by Clinic'
                                || moOperationAppointmentRecord.Appointment_Status__c != 'Cancelled by MD') {
                            ((List<Clinic_Appointment__c>) availabilityAppointments.get(moOperationAppointmentRecord.MOAvailability__c).get('appointments')).add(moOperationAppointmentRecord);
                        }
                    } else {
                        if (!availabilityAppointments.containsKey(moOperationAppointmentRecord.Id)) {
                            availabilityAppointments.put(moOperationAppointmentRecord.Id, new Map<String, Object>());
                        }

                        if (!availabilityAppointments.get(moOperationAppointmentRecord.Id).containsKey('appointments')) {
                            availabilityAppointments.get(moOperationAppointmentRecord.Id).put('appointments', new List<Clinic_Appointment__c>());
                        }

                        availabilityAppointments.get(moOperationAppointmentRecord.Id).put('availability', moOperationAppointmentRecord);
                    }
                }

                System.debug(JSON.serializePretty(availabilityAppointments));

                for (String moOperationAvailabilityId : availabilityAppointments.keySet()) {
                    Map<String, Object> moOperationAvailabilityMap = availabilityAppointments.get(moOperationAvailabilityId);

                    List<Clinic_Appointment__c> moOperationAvailabilityAppointments = (List<Clinic_Appointment__c>) moOperationAvailabilityMap.get('appointments');

                    Clinic_Appointment__c moOperationAvailability = (Clinic_Appointment__c) moOperationAvailabilityMap.get('availability');

                    if (moOperationAvailabilityAppointments.isEmpty()) {
                        Map<String, Object> availability = new Map<String, Object>();
                        availability.put('id', moOperationAvailability.Id);
                        availability.put('resourceId', moOperationAvailability.Clinic__c);
                        availability.put('resourceTitle', moOperationAvailability.Clinic__r.Name);
                        availability.put('mdDayId', moOperationAvailability.MD_Day__c);
                        availability.put('title', moOperationAvailability.Name);
                        availability.put('start', moOperationAvailability.CS_Start_Date__c);
                        availability.put('end', moOperationAvailability.CS_End_Date__c);
                        availability.put('type', 'mo');
                        availability.put('allDay', false);
                        availability.put('color', 'green');

                        availabilities.add(availability);
                    } else {
                        DateTime startDatetime = moOperationAvailability.CS_Start_Date__c;
                        System.debug(startDatetime);

                        for (Integer i = 0; i < moOperationAvailabilityAppointments.size(); i++) {
                            System.debug(startDatetime);
                            Clinic_Appointment__c moOperationAvailabilityAppointment = moOperationAvailabilityAppointments.get(i);
                            System.debug(JSON.serializePretty(moOperationAvailabilityAppointment));

                            if (startDatetime < moOperationAvailabilityAppointment.CS_Start_Date__c) {
                                System.debug('startDatetime < moOperationAvailabilityAppointment.CS_Start_Date__c');
                                if (i == moOperationAvailabilityAppointments.size() - 1) {
                                    System.debug('i == moOperationAvailabilityAppointments.size() - 1');
                                    if (moOperationAvailabilityAppointment.CS_End_Date__c < moOperationAvailability.CS_End_Date__c) {
                                        System.debug('moOperationAvailabilityAppointment.CS_End_Date__c < moOperationAvailability.CS_End_Date__c');
                                        Map<String, Object> availability = new Map<String, Object>();
                                        availability.put('id', moOperationAvailability.Id);
                                        availability.put('resourceId', moOperationAvailability.Clinic__c);
                                        availability.put('resourceTitle', moOperationAvailability.Clinic__r.Name);
                                        availability.put('mdDayId', moOperationAvailability.MD_Day__c);
                                        availability.put('title', moOperationAvailability.Name);
                                        availability.put('start', startDatetime);
                                        availability.put('end', moOperationAvailabilityAppointment.CS_Start_Date__c);
                                        availability.put('type', 'mo');
                                        availability.put('allDay', false);
                                        availability.put('color', 'green');

                                        availabilities.add(availability);

                                        Map<String, Object> lastAvailability = new Map<String, Object>();
                                        lastAvailability.put('id', moOperationAvailability.Id);
                                        lastAvailability.put('resourceId', moOperationAvailability.Clinic__c);
                                        lastAvailability.put('resourceTitle', moOperationAvailability.Clinic__r.Name);
                                        lastAvailability.put('mdDayId', moOperationAvailability.MD_Day__c);
                                        lastAvailability.put('title', moOperationAvailability.Name);
                                        lastAvailability.put('start', moOperationAvailabilityAppointment.CS_End_Date__c);
                                        lastAvailability.put('end', moOperationAvailability.CS_End_Date__c);
                                        lastAvailability.put('type', 'mo');
                                        lastAvailability.put('allDay', false);
                                        lastAvailability.put('color', 'green');

                                        availabilities.add(lastAvailability);
                                    } else if (moOperationAvailabilityAppointment.CS_End_Date__c == moOperationAvailability.CS_End_Date__c) {
                                        System.debug('moOperationAvailabilityAppointment.CS_End_Date__c == moOperationAvailability.CS_End_Date__c');
                                        Map<String, Object> availability = new Map<String, Object>();
                                        availability.put('id', moOperationAvailability.Id);
                                        availability.put('resourceId', moOperationAvailability.Clinic__c);
                                        availability.put('resourceTitle', moOperationAvailability.Clinic__r.Name);
                                        availability.put('mdDayId', moOperationAvailability.MD_Day__c);
                                        availability.put('title', moOperationAvailability.Name);
                                        availability.put('start', startDatetime);
                                        availability.put('end', moOperationAvailabilityAppointment.CS_Start_Date__c);
                                        availability.put('type', 'mo');
                                        availability.put('allDay', false);
                                        availability.put('color', 'green');
                                        System.debug(JSON.serializePretty(availability));

                                        availabilities.add(availability);
                                    }
                                } else {
                                    System.debug('i != moOperationAvailabilityAppointments.size() - 1');
                                    Map<String, Object> availability = new Map<String, Object>();
                                    availability.put('id', moOperationAvailability.Id);
                                    availability.put('resourceId', moOperationAvailability.Clinic__c);
                                    availability.put('resourceTitle', moOperationAvailability.Clinic__r.Name);
                                    availability.put('mdDayId', moOperationAvailability.MD_Day__c);
                                    availability.put('title', moOperationAvailability.Name);
                                    availability.put('start', startDatetime);
                                    availability.put('end', moOperationAvailabilityAppointment.CS_Start_Date__c);
                                    availability.put('type', 'mo');
                                    availability.put('allDay', false);
                                    availability.put('color', 'green');

                                    availabilities.add(availability);

                                    startDatetime = moOperationAvailabilityAppointment.CS_End_Date__c;
                                }
                            } else if (startDatetime == moOperationAvailabilityAppointment.CS_Start_Date__c) {
                                System.debug('startDatetime == moOperationAvailabilityAppointment.CS_Start_Date__c');
                                if (i == moOperationAvailabilityAppointments.size() - 1) {
                                    System.debug('i == moOperationAvailabilityAppointments.size() - 1');
                                    if (moOperationAvailabilityAppointment.CS_End_Date__c < moOperationAvailability.CS_End_Date__c) {
                                        System.debug('moOperationAvailabilityAppointment.CS_End_Date__c < moOperationAvailability.CS_End_Date__c');
                                        Map<String, Object> availability = new Map<String, Object>();
                                        availability.put('id', moOperationAvailability.Id);
                                        availability.put('resourceId', moOperationAvailability.Clinic__c);
                                        availability.put('resourceTitle', moOperationAvailability.Clinic__r.Name);
                                        availability.put('mdDayId', moOperationAvailability.MD_Day__c);
                                        availability.put('title', moOperationAvailability.Name);
                                        availability.put('start', moOperationAvailabilityAppointment.CS_End_Date__c);
                                        availability.put('end', moOperationAvailability.CS_End_Date__c);
                                        availability.put('type', 'mo');
                                        availability.put('allDay', false);
                                        availability.put('color', 'green');

                                        availabilities.add(availability);
                                    }
                                } else {
                                    System.debug('i != moOperationAvailabilityAppointments.size() - 1');
                                    startDatetime = moOperationAvailabilityAppointment.CS_End_Date__c;
                                }
                            }
                        }
                    }
                }
            }
        }
        System.debug(JSON.serializePretty(availabilities));

        return availabilities;
    }

    private static List<Map<String, Object>> getMDOperationAvailabilityRecords(Map<String, Object> availabilitiesFilter) {
        List<Map<String, Object>> availabilities = new List<Map<String, Object>>();

        if (availabilitiesFilter != null && !availabilitiesFilter.isEmpty()) {
            /*set record fields */
            Set<String> recordQueryFields = new Set<String>{
                    SObjectType.Clinic_Appointment__c.fields.Id.Name,
                    SObjectType.Clinic_Appointment__c.fields.Clinic__c.Name,
                    SObjectType.Clinic_Appointment__c.fields.MD_Day__c.Name,
                    SObjectType.Clinic_Appointment__c.fields.Name.Name,
                    SObjectType.Clinic_Appointment__c.fields.CS_Start_Date__c.Name,
                    SObjectType.Clinic_Appointment__c.fields.CS_End_Date__c.Name,
                    SObjectType.Clinic_Appointment__c.fields.Appointment_Status__c.Name,
                    SObjectType.Clinic_Appointment__c.fields.BookedStatus__c.Name,
                    SObjectType.Clinic_Appointment__c.fields.Preliminary_appointment__c.Name,
                    'Clinic__r.Name'
            };

            List<String> conditions = new List<String>();

            String clinicId = (String) availabilitiesFilter.get('clinicId');

            conditions.add(QueryService.getCondition(
                    SObjectType.Clinic_Appointment__c.fields.Clinic__c.Name,
                    '=',
                    clinicId,
                    true
            ));

           conditions.add(QueryService.getCondition(
                    SObjectType.Clinic_Appointment__c.fields.Preliminary_appointment__c.Name,
                    '=',
                    'false',
                    false
            ));

            Map<String, Object> activityRange = (Map<String, Object>) availabilitiesFilter.get('range');

            conditions.add(QueryService.getCondition(
                    SObjectType.Clinic_Appointment__c.fields.CS_Start_Date__c.Name,
                    '>=',
                    String.valueOf(activityRange.get('start')),
                    false
            ));

            conditions.add(QueryService.getCondition(
                    SObjectType.Clinic_Appointment__c.fields.CS_End_Date__c.Name,
                    '<=',
                    String.valueOf(activityRange.get('end')),
                    false
            ));

            conditions.add(QueryService.getCondition(
                    SObjectType.Clinic_Appointment__c.fields.BookedStatus__c.Name,
                    '=',
                    'Not Booked',
                    true
            ));

            String appointmentRecordTypeName = (String) availabilitiesFilter.get('appointmentRecordTypeName');

            conditions.add(QueryService.getCondition(
                    'RecordType.DeveloperName',
                    '=',
                    appointmentRecordTypeName,
                    true
            ));

            if (availabilitiesFilter.containsKey('appointmentType')) {
                String appointmentType = (String) availabilitiesFilter.get('appointmentType');

                conditions.add(QueryService.getCondition(
                        SObjectType.Clinic_Appointment__c.fields.Apppointment_Type__c.Name,
                        '=',
                        appointmentType,
                        true
                ));
            }

            conditions.add(QueryService.getCondition(
                    SObjectType.Clinic_Appointment__c.fields.MOClinicAppointment__c.Name,
                    '=',
                    'false',
                    false
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
                    .setOrderByToken(
                            new SOQLOrderBy.Builder()
                                    .setOrderFields(SObjectType.Clinic_Appointment__c.fields.CreatedDate.Name)
                                    .setOrderType('DESC')
                                    .build()
                    )
                    .setQueryLimit(String.valueOf(50000))
                    .build()
                    .toString();
            System.debug(recordsQueryString);

            if (String.isNotBlank(recordsQueryString)) {
                List<Clinic_Appointment__c> availabilityRecords = Database.query(recordsQueryString);

                for (Clinic_Appointment__c availabilityRecord : availabilityRecords) {
                    Map<String, Object> availability = new Map<String, Object>();
                    availability.put('id', availabilityRecord.Id);
                    availability.put('resourceId', availabilityRecord.Clinic__c);
                    availability.put('resourceTitle', availabilityRecord.Clinic__r.Name);
                    availability.put('mdDayId', availabilityRecord.MD_Day__c);
                    availability.put('title', availabilityRecord.Name);
                    availability.put('start', availabilityRecord.CS_Start_Date__c);
                    availability.put('end', availabilityRecord.CS_End_Date__c);
                    availability.put('type', 'md');
                    availability.put('allDay', false);
                    availability.put('color', 'blue');

                    availabilities.add(availability);
                }
            }
        }

        return availabilities;
    }

    private static List<Map<String, Object>> getResourceRecords(List<Map<String, Object>> availabilities) {
        List<Map<String, Object>> resources = new List<Map<String, Object>>();

        if (availabilities != null && !availabilities.isEmpty()) {
            Map<String, Map<String, Object>> resourcesMap = new Map<String, Map<String, Object>>();

            for (Map<String, Object> availability : availabilities) {
                String resourceId = String.valueOf(availability.get('resourceId'));

                if (!resourcesMap.containsKey(resourceId)) {
                    Map<String, Object> resource = new Map<String, Object>();
                    resource.put('id', resourceId);
                    resource.put('title', availability.get('resourceTitle'));

                    resourcesMap.put(resourceId, resource);
                }
            }

            resources = resourcesMap.values();
        }

        return resources;
    }

    private static Map<String, Object> savePreMedAppointmentData(Map<String, Object> preMedAppointmentData) {
        Map<String, Object> preMedAppointment = new Map<String, Object>();

        if (preMedAppointmentData != null && !preMedAppointmentData.isEmpty()) {
            String recordId = (String) preMedAppointmentData.get('recordId');

            Clinic_Appointment__c clinicAppointment = getAppointmentRecord(recordId);

            if (clinicAppointment != null) {
                Clinic_Appointment__c clonedClinicAppointment = clinicAppointment.clone(false, false, false, false);

                List<Object> appointmentFields = (List<Object>) preMedAppointmentData.get('predefinedFields');
                System.debug(JSON.serializePretty(appointmentFields));

                Opportunity opportunity = new Opportunity();
                for (Object appointmentField : appointmentFields) {
                    Map<String, Object> appointmentFieldMap = (Map<String, Object>) appointmentField;
                    if (String.valueOf(appointmentFieldMap.get('name')) == 'Opportunity__c') {
                        opportunity.Id = (Id) appointmentFieldMap.get('value');
                    }
                }

                clonedClinicAppointment = (Clinic_Appointment__c) setRecordFieldValues(clonedClinicAppointment, appointmentFields);
                clonedClinicAppointment.CS_End_Date__c = clonedClinicAppointment.CS_Start_Date__c.addMinutes(15);
                System.debug(JSON.serializePretty(clonedClinicAppointment));

                insert clonedClinicAppointment;

                if (opportunity.Id != null) {
                    Opportunity opp = [
                        SELECT Id,
                               Surgery_Preparation_Appointment__c
                        FROM Opportunity
                        WHERE Id = :opportunity.Id
                    ];     
                
                    opportunity.Surgery_Preparation_Appointment__c = clonedClinicAppointment.CS_Start_Date__c;

                    System.debug(opportunity);

                    update opportunity;
                }

                preMedAppointment.put('id', clonedClinicAppointment.Id);
            }
        }

        return preMedAppointment;
    }

    private static Map<String, Object> saveAfterCareAppointmentData(Map<String, Object> afterCareAppointmentData) {
        Map<String, Object> afterCareAppointment = new Map<String, Object>();

        if (afterCareAppointmentData != null && !afterCareAppointmentData.isEmpty()) {
            Map<String, Object> clinicAppointmentMap = (Map<String, Object>) afterCareAppointmentData.get('Clinic_Appointment__c');

            String recordId = (String) clinicAppointmentMap.get('recordId');

            Clinic_Appointment__c clinicAppointment = getAppointmentRecord(recordId);

            if (clinicAppointment != null) {
                Clinic_Appointment__c clonedClinicAppointment = clinicAppointment.clone(false, false, false, false);

                List<Object> appointmentFields = (List<Object>) clinicAppointmentMap.get('fields');
                System.debug(JSON.serializePretty(appointmentFields));

                Opportunity opportunity = new Opportunity();
                for (Object appointmentField : appointmentFields) {
                    Map<String, Object> appointmentFieldMap = (Map<String, Object>) appointmentField;
                    if (String.valueOf(appointmentFieldMap.get('name')) == 'Opportunity__c') {
                        opportunity.Id = (Id) appointmentFieldMap.get('value');
                    }
                }

                clonedClinicAppointment = (Clinic_Appointment__c) setRecordFieldValues(clonedClinicAppointment, appointmentFields);
                //clonedClinicAppointment.CS_End_Date__c = clonedClinicAppointment.CS_Start_Date__c.addMinutes(15);
                System.debug(JSON.serializePretty(clonedClinicAppointment));

                insert clonedClinicAppointment;

                if (opportunity.Id != null) {
                    Opportunity opp = [
                        SELECT Id,
                               After_Care_Appointment__c,
                               X2_After_Care_Appointment__c,
                               X3_After_Care_Appointment__c,
                               X4_After_Care_Appointment__c
                        FROM Opportunity
                        WHERE Id = :opportunity.Id
                    ];     
                
                    if (opp != null) {
                        if (opp.After_Care_Appointment__c == null) {
                            opportunity.After_Care_Appointment__c = clonedClinicAppointment.CS_Start_Date__c;
                        } else if (opp.X2_After_Care_Appointment__c == null) {
                            opportunity.X2_After_Care_Appointment__c = clonedClinicAppointment.CS_Start_Date__c;
                        } else if (opp.X3_After_Care_Appointment__c == null) {
                            opportunity.X3_After_Care_Appointment__c = clonedClinicAppointment.CS_Start_Date__c;
                        } else if (opp.X4_After_Care_Appointment__c == null) {
                            opportunity.X4_After_Care_Appointment__c = clonedClinicAppointment.CS_Start_Date__c;
                        } else {
                            opportunity.After_Care_Appointment__c = clonedClinicAppointment.CS_Start_Date__c;
                        }
                    }

                    System.debug(opportunity);

                    update opportunity;
                }

                afterCareAppointment.put('id', clonedClinicAppointment.Id);
            }
        }

        return afterCareAppointment;
    }

    private static Map<String, Object> saveMDOperationAppointmentData(Map<String, Object> mdOperationAppointmentData) {
        Map<String, Object> mdOperationAppointment = new Map<String, Object>();

        if (mdOperationAppointmentData != null && !mdOperationAppointmentData.isEmpty()) {
            Map<String, Object> clinicAppointmentMap = (Map<String, Object>) mdOperationAppointmentData.get('Clinic_Appointment__c');

            String appointmentRecordId = (String) clinicAppointmentMap.get('recordId');

            Clinic_Appointment__c clinicAppointment = new Clinic_Appointment__c();
            clinicAppointment.Id = appointmentRecordId;

            List<Object> appointmentFields = (List<Object>) clinicAppointmentMap.get('fields');
            System.debug(JSON.serializePretty(appointmentFields));

            clinicAppointment = (Clinic_Appointment__c) setRecordFieldValues(clinicAppointment, appointmentFields);
            System.debug(JSON.serializePretty(clinicAppointment));

            update clinicAppointment;

            mdOperationAppointment.put('id', appointmentRecordId);

            Map<String, Object> opportunityMap = (Map<String, Object>) mdOperationAppointmentData.get('Opportunity');

            String opportunityRecordId = (String) opportunityMap.get('recordId');

            Opportunity opportunity = new Opportunity();
            opportunity.Id = opportunityRecordId;

            List<Object> opportunityFields = (List<Object>) opportunityMap.get('fields');
            System.debug(JSON.serializePretty(opportunityFields));

            opportunity = (Opportunity) setRecordFieldValues(opportunity, opportunityFields);
            System.debug(JSON.serializePretty(opportunity));

            update opportunity;
        }

        return mdOperationAppointment;
    }

    private static Map<String, Object> saveMOOperationAppointmentData(Map<String, Object> moOperationAppointmentData) {
        Map<String, Object> moOperationAppointment = new Map<String, Object>();

        if (moOperationAppointmentData != null && !moOperationAppointmentData.isEmpty()) {
            Map<String, Object> clinicAppointmentMap = (Map<String, Object>) moOperationAppointmentData.get('Clinic_Appointment__c');

            String recordId = (String) clinicAppointmentMap.get('recordId');

            Clinic_Appointment__c clinicAppointment = getAppointmentRecord(recordId);

            if (clinicAppointment != null) {
                Clinic_Appointment__c clonedClinicAppointment = clinicAppointment.clone(false, false, false, false);

                List<Object> appointmentFields = (List<Object>) clinicAppointmentMap.get('fields');
                System.debug(JSON.serializePretty(appointmentFields));

                clonedClinicAppointment = (Clinic_Appointment__c) setRecordFieldValues(clonedClinicAppointment, appointmentFields);
                System.debug(JSON.serializePretty(clonedClinicAppointment));

                insert clonedClinicAppointment;

                moOperationAppointment.put('id', clonedClinicAppointment.Id);

                Map<String, Object> opportunityMap = (Map<String, Object>) moOperationAppointmentData.get('Opportunity');

                String opportunityRecordId = (String) opportunityMap.get('recordId');

                Opportunity opportunity = new Opportunity();
                opportunity.Id = opportunityRecordId;

                List<Object> opportunityFields = (List<Object>) opportunityMap.get('fields');
                System.debug(JSON.serializePretty(opportunityFields));

                opportunity = (Opportunity) setRecordFieldValues(opportunity, opportunityFields);
                System.debug(JSON.serializePretty(opportunity));

                if (opportunity.RevisionSurgery__c == true) {
                    opportunity.Revision_Operation_Appointment__c = clonedClinicAppointment.Id;
                    opportunity.Operation_Appointment__c = null;
                } else {
                    opportunity.Operation_Appointment__c = clonedClinicAppointment.Id;
                    opportunity.Revision_Operation_Appointment__c = null;
                }
                System.debug(JSON.serializePretty(opportunity));

                update opportunity;
            }
        }

        return moOperationAppointment;
    }

    private static Clinic_Appointment__c getAppointmentRecord(String recordId) {
        Clinic_Appointment__c appointment;

        if (String.isNotBlank(recordId)) {
            Set<String> recordQueryFields = new Set<String>();

            Map<String, Schema.SObjectField> fieldsMap = Schema.SObjectType.Clinic_Appointment__c.fields.getMap();

            for (Schema.SObjectField sObjectField : fieldsMap.values()) {
                Schema.DescribeFieldResult describeFieldResult = sObjectField.getDescribe();

                recordQueryFields.add(describeFieldResult.getName());
            }

            List<String> conditions = new List<String>();

            conditions.add(QueryService.getCondition(
                    SObjectType.Clinic_Appointment__c.fields.Id.Name,
                    '=',
                    recordId,
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
                    .setOrderByToken(
                            new SOQLOrderBy.Builder()
                                    .setOrderFields(SObjectType.Clinic_Appointment__c.fields.CreatedDate.Name)
                                    .setOrderType('DESC')
                                    .build()
                    )
                    .setQueryLimit(String.valueOf(50000))
                    .build()
                    .toString();
            System.debug(recordsQueryString);

            if (String.isNotBlank(recordsQueryString)) {
                List<Clinic_Appointment__c> appointments = Database.query(recordsQueryString);

                if (!appointments.isEmpty()) {
                    appointment = appointments.get(0);
                }
            }
        }

        return appointment;
    }

    private static sObject setRecordFieldValues(sObject record, List<Object> fields) {
        sObject sObjectRecord;

        if (record != null && fields != null) {
            sObjectRecord = record;

            String objectType = record.getSObjectType().getDescribe().getName();

            Schema.DescribeSObjectResult describeSObjectResult = DescribeService.getDescribeSObjectResult(objectType);

            if (describeSObjectResult != null) {
                Map<String, Schema.SObjectField> objectFieldsMap = describeSObjectResult.fields.getMap();

                for (Object field : fields) {
                    Map<String, Object> fieldMap = (Map<String, Object>) field;

                    String fieldName = String.valueOf(fieldMap.get('name'));

                    if (objectFieldsMap.containsKey(fieldName)) {
                        Schema.DescribeFieldResult describeFieldResult = objectFieldsMap.get(fieldName).getDescribe();

                        String fieldType = describeFieldResult.getType().name();

                        Object fieldValue = fieldMap.get('value');

                        if (fieldType == 'Boolean') {
                            sObjectRecord.put(fieldName, Boolean.valueOf(fieldValue));
                        } else if (fieldType == 'Date') {
                            String dateString = String.valueOf(fieldValue);
                            System.debug(dateString);

                            if (String.isNotBlank(dateString)) {
                                sObjectRecord.put(fieldName, (Date) JSON.deserialize(JSON.serialize(dateString), Date.class));
                            } else {
                                sObjectRecord.put(fieldName, null);
                            }
                        } else if (fieldType == 'DateTime') {
                            String dateTimeString = String.valueOf(fieldValue);
                            System.debug(dateTimeString);

                            if (String.isNotBlank(dateTimeString)) {
                                sObjectRecord.put(fieldName, (DateTime) JSON.deserialize(JSON.serialize(dateTimeString), DateTime.class));
                            } else {
                                sObjectRecord.put(fieldName, null);
                            }
                        } else if (fieldType == 'Time') {
                            String timeString = String.valueOf(fieldValue);
                            System.debug(timeString);

                            if (String.isNotBlank(timeString)) {
                                sObjectRecord.put(fieldName, (Time) JSON.deserialize(JSON.serialize(timeString + 'Z'), Time.class));
                            } else {
                                sObjectRecord.put(fieldName, null);
                            }
                        } else if (fieldType == 'String') {
                            sObjectRecord.put(fieldName, String.valueOf(fieldValue));
                        } else if (fieldType == 'Double') {
                            sObjectRecord.put(fieldName, Double.valueOf(fieldValue));
                        } else {
                            sObjectRecord.put(fieldName, fieldValue);
                        }
                    }
                }
            }
        }

        return sObjectRecord;
    }


    private static String getExceptionMessage(String initialMessage) {
        String exceptionMessage;

        if (String.isNotBlank(initialMessage)) {
            if (initialMessage.containsIgnoreCase('We can\'t save')) {
                exceptionMessage = initialMessage.substringBetween('FIELD_CUSTOM_VALIDATION_EXCEPTION:', 'You can look up');
                if (String.isBlank(exceptionMessage)) {
                    exceptionMessage = initialMessage;
                }
            } else {
                exceptionMessage = initialMessage;
            }
        }

        return exceptionMessage;
    }

}