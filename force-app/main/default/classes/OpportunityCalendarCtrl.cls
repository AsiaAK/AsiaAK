/**
 * OpportunityCalendarCtrl class 1.0.0
 *
 * @description This class represents a OpportunityCalendarCtrl.
 *
 * @author Nadezhda Podobed
 * @date 30.05.2019
 */
public with sharing class OpportunityCalendarCtrl {

    private static final String CLASS_NAME = OpportunityCalendarCtrl.class.getName();

    private static final String STATUS_SUCCESS = 'success';
    private static final String STATUS_WARNING = 'warning';
    private static final String STATUS_ERROR = 'error';

    @AuraEnabled
    public static String getClinicAppointmentRecordTypes() {
        Response.Builder response = new Response.Builder();

        try {
            Map<String, Object> responseData = new Map<String, Object>();

            List<Map<String, Object>> clinicAppointmentRecordTypes = getClinicAppointmentRecordTypeRecords();
            responseData.put('clinicAppointmentRecordTypes', clinicAppointmentRecordTypes);

            response.setData(responseData)
                    .setStatus(STATUS_SUCCESS);
        } catch (Exception e) {
            response.setMessage(CLASS_NAME + ': ' + e.getMessage())
                    .setStatus(STATUS_ERROR);
            System.debug(e.getStackTraceString());
        }

        return JSON.serializePretty(response.build(), true);
    }

    @AuraEnabled
    public static String getActivities(String activitiesFilterJSON) {
        Response.Builder response = new Response.Builder();

        try {
            if (String.isNotBlank(activitiesFilterJSON)) {
                Map<String, Object> activitiesFilter = (Map<String, Object>) JSON.deserializeUntyped(activitiesFilterJSON);

                Map<String, Object> responseData = new Map<String, Object>();

                List<Map<String, Object>> events = getEventRecords(activitiesFilter);
                responseData.put('events', events);

                responseData.put('resources', getResourceRecords(events));

                response.setData(responseData)
                        .setStatus(STATUS_SUCCESS);
            } else {
                response.setMessage('One or more parameter values are not valid: ' + activitiesFilterJSON)
                        .setStatus(STATUS_ERROR);
            }
        } catch (Exception e) {
            response.setMessage(CLASS_NAME + ': ' + e.getMessage())
                    .setStatus(STATUS_ERROR);
            System.debug(e.getStackTraceString());
        }

        return JSON.serializePretty(response.build(), true);
    }

    private static List<Map<String, Object>> getClinicAppointmentRecordTypeRecords() {
        List<Map<String, Object>> clinicAppointmentRecordTypes = new List<Map<String, Object>>();

        Schema.DescribeSObjectResult describeSObjectResult = DescribeService.getDescribeSObjectResult(SObjectType.Clinic_Appointment__c.Name);

        if (describeSObjectResult != null) {
            List<Schema.RecordTypeInfo> recordTypeInfos = describeSObjectResult.getRecordTypeInfos();

            for (Schema.RecordTypeInfo recordTypeInfo : recordTypeInfos) {
                if (recordTypeInfo.isActive() && !recordTypeInfo.isMaster()) {
                    Map<String, Object> recordTypeMap = new Map<String, Object>();
                    recordTypeMap.put('label', recordTypeInfo.getName());
                    recordTypeMap.put('value', recordTypeInfo.getRecordTypeId());

                    clinicAppointmentRecordTypes.add(recordTypeMap);
                }
            }
        }

        return clinicAppointmentRecordTypes;
    }

    private static List<Map<String, Object>> getEventRecords(Map<String, Object> activitiesFilter) {
        List<Map<String, Object>> events = new List<Map<String, Object>>();

        if (activitiesFilter != null && !activitiesFilter.isEmpty()) {
            String groupBy = (String) activitiesFilter.get('groupBy');

            Set<String> recordQueryFields = new Set<String>{
                    SObjectType.Clinic_Appointment__c.fields.Id.Name,
                    groupBy == 'Doctor' ? SObjectType.Clinic_Appointment__c.fields.Clinic__c.Name : 'MD_Day__r.MD_Day_Location__c',
                    SObjectType.Clinic_Appointment__c.fields.Name.Name,
                    SObjectType.Clinic_Appointment__c.fields.CS_Start_Date__c.Name,
                    SObjectType.Clinic_Appointment__c.fields.CS_End_Date__c.Name,
                    SObjectType.Clinic_Appointment__c.fields.Appointment_Status__c.Name,
                    SObjectType.Clinic_Appointment__c.fields.BookedStatus__c.Name,
                    SObjectType.Clinic_Appointment__c.fields.Apppointment_Type__c.Name,
                    SObjectType.Clinic_Appointment__c.fields.Ghost_Appointment__c.Name,
                    SObjectType.Clinic_Appointment__c.fields.Reminder_Call_Status__c.Name,
                    SObjectType.Clinic_Appointment__c.fields.Opportunity_Stage__c.Name,
                    SObjectType.Clinic_Appointment__c.fields.Clinic_Product__c.Name,
                    SObjectType.Clinic_Appointment__c.fields.Paid__c.Name,
                    SObjectType.Clinic_Appointment__c.fields.Opportunity__c.Name,
                    'Opportunity__r.Name',
                    groupBy == 'Doctor' ? 'Clinic__r.Name' : 'MD_Day__r.MD_Day_Location__r.Name'
            };

            List<String> conditions = new List<String>();

            Map<String, Object> activityRange = (Map<String, Object>) activitiesFilter.get('range');

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

            String opportunityId = (String) activitiesFilter.get('opportunityId');

            conditions.add(QueryService.getCondition(
                    SObjectType.Clinic_Appointment__c.fields.Opportunity__c.Name,
                    '=',
                    ':opportunityId',
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
                List<Clinic_Appointment__c> eventRecords = Database.query(recordsQueryString);

                Map<String, Map<String, String>> clinicAppointmentColors = new Map<String, Map<String, String>>{
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

                String orgDomainURL = URL.getOrgDomainUrl().toExternalForm();

                for (Clinic_Appointment__c eventRecord : eventRecords) {
                    Map<String, Object> event = new Map<String, Object>();
                    event.put('id', eventRecord.Id);
                    event.put('resourceId', groupBy == 'Doctor' ? eventRecord.Clinic__c : eventRecord.MD_Day__r.MD_Day_Location__c);
                    event.put('resourceTitle', groupBy == 'Doctor' ? eventRecord.Clinic__r.Name : eventRecord.MD_Day__r.MD_Day_Location__r.Name);
                    if (eventRecord.Reminder_Call_Status__c != null) {
                        event.put('title', eventRecord.Name + ' ' + eventRecord.Reminder_Call_Status__c);
                    } else {
                        event.put('title', eventRecord.Name);
                    }
                    event.put('titleHoverName', eventRecord.Name);
                    event.put('titleHoverAppointmentStatus', eventRecord.Appointment_Status__c == null ? '' : eventRecord.Appointment_Status__c);
                    event.put('titleHoverReminderCallStatus', eventRecord.Reminder_Call_Status__c == null ? '' : eventRecord.Reminder_Call_Status__c);
                    event.put('titleHoverOpportunityName', eventRecord.Opportunity__r.Name == null ? '' : eventRecord.Opportunity__r.Name);
                    event.put('titleHoverOpportunityStage', eventRecord.Opportunity_Stage__c == null ? '' : eventRecord.Opportunity_Stage__c);
                    event.put('titleHoverClinicProduct', eventRecord.Clinic_Product__c == null ? '' : eventRecord.Clinic_Product__c);
                    event.put('titleHoverPaid', eventRecord.Paid__c);
                    event.put('titleHoverAppointmentType', eventRecord.Apppointment_Type__c == null ? '' : eventRecord.Apppointment_Type__c);                    
                    event.put('start', eventRecord.CS_Start_Date__c);
                    event.put('end', eventRecord.CS_End_Date__c);
                    event.put('color', clinicAppointmentColors.get(eventRecord.Appointment_Status__c).get('color'));
                    event.put('textColor', clinicAppointmentColors.get(eventRecord.Appointment_Status__c).get('textColor'));
                    event.put('allDay', false);
                    event.put('url', orgDomainURL + '/' + eventRecord.Id);
                    event.put('order', eventRecord.Apppointment_Type__c == 'Regular Appointment Type' ? '1' : '2');

                    events.add(event);
                }
            }
        }

        return events;
    }

    private static List<Map<String, Object>> getResourceRecords(List<Map<String, Object>> events) {
        List<Map<String, Object>> resources = new List<Map<String, Object>>();

        if (events != null && !events.isEmpty()) {
            Map<String, Map<String, Object>> resourcesMap = new Map<String, Map<String, Object>>();

            for (Map<String, Object> event : events) {
                String resourceId = String.valueOf(event.get('resourceId'));

                if (!resourcesMap.containsKey(resourceId)) {
                    Map<String, Object> resource = new Map<String, Object>();
                    resource.put('id', resourceId);
                    resource.put('title', event.get('resourceTitle'));

                    resourcesMap.put(resourceId, resource);
                }
            }

            resources = resourcesMap.values();
        }

        return resources;
    }

}