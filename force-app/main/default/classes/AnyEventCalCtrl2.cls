/**
* ─────────────────────────────────────────────────────────────────────────────────────────────────┐
* Get, Upsert and Delete relevent sObject declared in the Lightning and Community Builder
* ──────────────────────────────────────────────────────────────────────────────────────────────────
* @author         Randy Grewal   <rgrewal@salesfore.com>
* @modifiedBy     Randy Grewal   <rgrewal@salesfore.com>
* @maintainedBy   Randy Grewal   <rgrewal@salesfore.com>
* @version        1.1
* @created        2017-05-01
* @modified       2017-06-12
* ──────────────────────────────────────────────────────────────────────────────────────────────────
* @changes
* v1.1            rgrewal@salesfore.com
* 2017-06-08        Added option to filter query by logged in user and removed System.debug logs
* 2017-06-12        Security Review Fixes:
*                   Added isAccessible(), isCreateable(), isDeletable() for CRUD/FLS Enforcement fix
*                   Added Typecasting to all injected field API names for SOQL Injection fix
*                   Added "with sharing" keyword to Class for Sharing Violation Fix
* ─────────────────────────────────────────────────────────────────────────────────────────────────┘
*/

public with sharing class AnyEventCalCtrl2 {
    @AuraEnabled
    public static List<EventObj> getEvents(String sObjectName, 
                                           String titleField, 
                                           String startDateTimeField, 
                                           String endDateTimeField, 
                                           String descriptionField, 
                                           String userField, 
                                           Boolean filterByUserField,
                                           Map<String, String> filterFields) {
        Map<String, String> fieldApiNames = new Map<String, String> {
            'title' => titleField,
            'startDateTime' => startDateTimeField,
            'endDateTime' => endDateTimeField,
            'description' => descriptionField,
            'owner' => userField
        };
        // currentTime needs for getting time now for SOQL. Don't delete
        DateTime currentTime = DateTime.now();
                                               
        String relativeObject = getAdditionalFieldsByName(sObjectName);
        String q = 'SELECT Id,' +
            String.valueOf(titleField) + ',' +
            String.valueOf(startDateTimeField) + ',' +
            String.valueOf(endDateTimeField) + ',' +
            String.valueOf(descriptionField) + ',' +
            String.valueOf(userField) +
            (String.isNotBlank(relativeObject) ? ',' + relativeObject : '') + ' FROM ' +
            String.valueOf(sObjectName);

        if (filterByUserField) {
            q +=  ' WHERE ' + String.valueOf(userField) + ' = \'' + UserInfo.getUserId() + '\'';
        }

        // If any filter fields
        if (filterFields != null && !filterFields.isEmpty()) {
            String filterString = '';

            // Fill filters
            for (String filterField : filterFields.keySet()) {
                if(filterField.equals('CustomCondition')) {
                    filterString += ' AND ' + filterFields.get(filterField) ;
                } else {
                    filterString += ' AND ' + String.valueOf(filterField) + ' = \'' + filterFields.get(filterField) + '\'';
                }
            }

            // Add WHERE clause if not added
            if (!filterByUserField) { 
                filterString = ' WHERE ' + filterString.removeStart(' AND ');
            }
            q += filterString;
        }
        
        List<EventObj> eventRecords = new List<EventObj>();
        System.debug(q);
        if (isAccessible(sObjectName)) {
            for (sObject obj : Database.query(q)) {
                eventRecords.add(fillEventObjectItem(obj, fieldApiNames));
            }
        }
        return eventRecords;
    }

    @AuraEnabled
    public static EventObj upsertEvents(String sEventObj,
                                        String sObjectName,
                                        String titleField,
                                        String startDateTimeField,
                                        String endDateTimeField,
                                        String descriptionField,
                                        String userField) {
        Map<String, String> fieldApiNames = new Map<String, String> {
            'title' => titleField,
            'startDateTime' => startDateTimeField,
            'endDateTime' => endDateTimeField,
            'description' => descriptionField,
            'owner' => userField
        };
        return upsertAndBookingEvents(sEventObj, sObjectName, JSON.serialize(fieldApiNames));
    }

    @AuraEnabled
    public static EventObj upsertAndBookingEvents(  String sEventObj,
                                                    String sObjectName,
                                                    String fieldApiNamesJSON) {
        EventObj upsertingEvent = (EventObj)JSON.deserialize(sEventObj, EventObj.class);
        System.debug(upsertingEvent);
        Map<String, String> fieldApiNames = (Map<String, String>) JSON.deserialize(fieldApiNamesJSON, Map<String, String>.class);
        fieldApiNames = checkRelativeObject(sObjectName, upsertingEvent.sObjectId, fieldApiNames);
        List<sObject> updateRecords = new List<SObject>();

        sObject newRecord = fillNewRecords(sObjectName, fieldApiNames, upsertingEvent);
        List<sObject> relativeRecords = fillRelativeRecords(upsertingEvent);
        System.debug(JSON.serializePretty(relativeRecords));

        updateRecords.add(newRecord);
        if(relativeRecords != null && !relativeRecords.isEmpty()) {
            updateRecords.addAll(relativeRecords);
        }

        try {
            update updateRecords;
            return new EventObj(newRecord.Id,
                String.valueOf(newRecord.get(fieldApiNames.get('title'))),
                DateTime.valueOf(newRecord.get(fieldApiNames.get('startDateTime'))),
                DateTime.valueOf(newRecord.get(fieldApiNames.get('endDateTime'))),
                String.valueOf(newRecord.get(fieldApiNames.get('description'))),
                String.valueOf(newRecord.get(fieldApiNames.get('owner'))),
                upsertingEvent.sObjectId,
                fieldApiNames.get('isRebooking') == null? false :
                                newRecord.get(fieldApiNames.get('isRebooking')) == null? false:
                                    Boolean.valueOf(newRecord.get(fieldApiNames.get('isRebooking'))),
                upsertingEvent.priority,
                upsertingEvent.appDate,
                upsertingEvent.clinic
            );
        } catch (DmlException e) {
            System.debug(e.getMessage());
            runAuraHandledException(e.getMessage());
            return null;
        }
    }

    @AuraEnabled
    public static String deleteEvent(String eventId, String sObjectName, String titleField, String startDateTimeField, String endDateTimeField, String descriptionField, String userField){
        String q = 'SELECT Id FROM ' + sObjectName + ' WHERE Id = \'' + eventId  + '\'';
        List<sObject> sObjectList = Database.query(q);
        try {
            if(isDeletable(sObjectName)) {
                delete sObjectList;
            }
            return eventId;
        } catch (DmlException e) {
            System.debug(e.getMessage());
            runAuraHandledException(e.getMessage());
            return null;
        }
        
    }

    public static Boolean isAccessible(String sObjectType, String fieldName){
        SObjectType schemaType = Schema.getGlobalDescribe().get(sObjectType);
        Map<String, SObjectField> fields = schemaType.getDescribe().fields.getMap();
        DescribeFieldResult fieldDescribe = fields.get(fieldName).getDescribe();
        return fieldDescribe.isAccessible();
    }

    public static Boolean isAccessible(String sObjectType){
        SObjectType schemaType = Schema.getGlobalDescribe().get(sObjectType);
        return schemaType.getDescribe().isAccessible();
    }

    public static Boolean isCreateable(String sObjectType){
        SObjectType schemaType = Schema.getGlobalDescribe().get(sObjectType);
        return schemaType.getDescribe().isCreateable();
    }

    public static Boolean isDeletable(String sObjectType){
        SObjectType schemaType = Schema.getGlobalDescribe().get(sObjectType);
        return schemaType.getDescribe().isDeletable();
    }

    private static Boolean isOpportunity(String opportunityId) {
        Boolean isOppId = false;
        if(String.isNotBlank(opportunityId)) {
            try {
                isOppId = Schema.Opportunity.SObjectType == Id.valueOf(opportunityId).getSobjectType();
            } catch (Exception ex) {
                runAuraHandledException(ex.getMessage());
            }
        }
        return isOppId;
    }

    private static Boolean isLead(String leadId) {
        Boolean isLeadId = false;
        if(String.isNotBlank(leadId)) {
            try {
                isLeadId = Schema.Lead.SObjectType == Id.valueOf(leadId).getSobjectType();
            } catch (Exception ex) {
                runAuraHandledException(ex.getMessage());
            }
        }
        return isLeadId;
    }

    private static Map<String, String> checkRelativeObject(String sObjectName, String sObjectId, Map<String, String> fieldApiNames) {
        if(sObjectName.equals(Clinic_Appointment__c.sObjectType.getDescribe().getName())) {
            if (String.isNotBlank(sObjectId)) {
                String relativeObject = '';
                String cleanField = '';
                if (isOpportunity(sObjectId)) {
                    relativeObject = Clinic_Appointment__c.Opportunity__c.getDescribe().getName();
                    cleanField = Clinic_Appointment__c.Lead__c.getDescribe().getName();
                } else if (isLead(sObjectId)) {
                    relativeObject = Clinic_Appointment__c.Lead__c.getDescribe().getName();
                    cleanField = Clinic_Appointment__c.Opportunity__c.getDescribe().getName();
                }
                if (String.isNotBlank(relativeObject)) {
                    fieldApiNames.put('sObjectId', relativeObject);
                    fieldApiNames.put('cleanField', cleanField);
                }
            }
            fieldApiNames.put('status', Clinic_Appointment__c.Appointment_Status__c.getDescribe().getName());
            fieldApiNames.put('isRebooking', Clinic_Appointment__c.Rebooking__c.getDescribe().getName());
            fieldApiNames.put('priority', Clinic_Appointment__c.Priority__c.getDescribe().getName());
        }
        return fieldApiNames;
    }

    private static sObject fillNewRecords(String sObjectName, Map<String, String> fieldApiNames, EventObj upsertingEvent) {
        sObject newRecord = Schema.getGlobalDescribe().get(sObjectName).newSObject();
        if (upsertingEvent.Id != null && isAccessible(sObjectName,'Id')){
            newRecord.put('Id',upsertingEvent.Id);
        }
        if (isAccessible(sObjectName,fieldApiNames.get('title'))) {
            newRecord.put(fieldApiNames.get('title'), upsertingEvent.title);
        }
        if (isAccessible(sObjectName,fieldApiNames.get('startDateTime'))) {
            newRecord.put(fieldApiNames.get('startDateTime'), upsertingEvent.startDateTime);
        }
        if (isAccessible(sObjectName,fieldApiNames.get('endDateTime'))) {
            newRecord.put(fieldApiNames.get('endDateTime'), upsertingEvent.endDateTime);
        }
        if (isAccessible(sObjectName,fieldApiNames.get('description'))) {
            newRecord.put(fieldApiNames.get('description'), upsertingEvent.description);
        }
        if (fieldApiNames.containsKey('sObjectId') && isAccessible(sObjectName,fieldApiNames.get('sObjectId'))) {
            newRecord.put(fieldApiNames.get('sObjectId'), upsertingEvent.sObjectId);
        }
        if (fieldApiNames.containsKey('cleanField') && isAccessible(sObjectName,fieldApiNames.get('cleanField'))) {
            newRecord.put(fieldApiNames.get('cleanField'), null);
        }
        if (fieldApiNames.containsKey('status') && isAccessible(sObjectName,fieldApiNames.get('status'))) {
            newRecord.put(fieldApiNames.get('status'), 'Reserved');
        }
        if(fieldApiNames.containsKey('isRebooking') && isAccessible(sObjectName,fieldApiNames.get('isRebooking'))) {
            newRecord.put(fieldApiNames.get('isRebooking'), false);
        }
        return newRecord;
    }

    private static List<sObject> fillRelativeRecords(EventObj upsertingEvent) {
        List<sObject> records = new List<SObject> ();
        sObject sObj = bookingEvent(upsertingEvent);
        if(sObj != null) {
            records.add(bookingEvent(upsertingEvent));
        }
        List<sObject> objs = rebookingEvent(upsertingEvent);
        if(objs != null && !objs.isEmpty()) {
            records.addAll(objs);
        }
        return records;
    }

    private static sObject bookingEvent(EventObj upsertingEvent) {
        sObject newRecord = null;
        if(isOpportunity(upsertingEvent.sObjectId)) {
            newRecord = Opportunity.sObjectType.newSObject(upsertingEvent.sObjectId);
            if (isAccessible(Opportunity.sObjectType.getDescribe().getName(),Opportunity.Clinic_Appointment__c.getDescribe().getName())) {
                newRecord.put(Opportunity.Clinic_Appointment__c.getDescribe().getName(), upsertingEvent.Id);
            }
            if (isAccessible(Opportunity.sObjectType.getDescribe().getName(),Opportunity.AppointmentDate__c.getDescribe().getName())) {
                newRecord.put(Opportunity.AppointmentDate__c.getDescribe().getName(), upsertingEvent.appDate);
            }
            if (isAccessible(Opportunity.sObjectType.getDescribe().getName(),Opportunity.Clinic__c.getDescribe().getName())) {
                newRecord.put(Opportunity.Clinic__c.getDescribe().getName(), upsertingEvent.clinic);
            }
            if (isAccessible(Opportunity.sObjectType.getDescribe().getName(),Opportunity.ClinicProduct__c.getDescribe().getName())) {
                newRecord.put(Opportunity.ClinicProduct__c.getDescribe().getName(), upsertingEvent.clinicProduct);
            }
        } else if(isLead(upsertingEvent.sObjectId)) {
            newRecord = Lead.sObjectType.newSObject(upsertingEvent.sObjectId);
            if (isAccessible(Lead.sObjectType.getDescribe().getName(),Lead.Clinic_Appointment__c.getDescribe().getName())) {
                newRecord.put(Lead.Clinic_Appointment__c.getDescribe().getName(), upsertingEvent.Id);
            }
            if (isAccessible(Lead.sObjectType.getDescribe().getName(),Lead.AppointmentDate__c.getDescribe().getName())) {
                newRecord.put(Lead.AppointmentDate__c.getDescribe().getName(), upsertingEvent.appDate);
            }
            if (isAccessible(Lead.sObjectType.getDescribe().getName(),Lead.Clinic__c.getDescribe().getName())) {
                newRecord.put(Lead.Clinic__c.getDescribe().getName(), upsertingEvent.clinic);
            }
            if (isAccessible(Lead.sObjectType.getDescribe().getName(),Lead.ClinicProduct__c.getDescribe().getName())) {
                newRecord.put(Lead.ClinicProduct__c.getDescribe().getName(), upsertingEvent.clinicProduct);
            }
        }
        return newRecord;
    }

    private static List<sObject> rebookingEvent(EventObj upsertingEvent) {
        List<sObject> oldRecords = new List<sObject>();
        if(isOpportunity(upsertingEvent.sObjectId)) {
            oldRecords = [
                SELECT Id, Rebooking__c, Appointment_Status__c
                FROM Clinic_Appointment__c
                WHERE Opportunity__c =: upsertingEvent.sObjectId
                    AND Id !=: upsertingEvent.id];
        } else if(isLead(upsertingEvent.sObjectId)) {
            oldRecords = [
                SELECT Id, Rebooking__c, Appointment_Status__c
                FROM Clinic_Appointment__c
                WHERE Lead__c =: upsertingEvent.sObjectId
                AND Id !=: upsertingEvent.id];
        }

        for (sObject record : oldRecords) {
            record.put(Clinic_Appointment__c.Rebooking__c.getDescribe().getName(), true);
            record.put(Clinic_Appointment__c.Appointment_Status__c.getDescribe().getName(),'Available');
        }
        return oldRecords;
    }

    private static String getAdditionalFieldsByName(String sObjectName) {
        String relativeObject = '';
        if(String.isNotBlank(sObjectName) && sObjectName.equals(Clinic_Appointment__c.sObjectType.getDescribe().getName())) {
            relativeObject =  Clinic_Appointment__c.Opportunity__c.getDescribe().getName() + ', '
                + Clinic_Appointment__c.Lead__c.getDescribe().getName() + ', '
                + Clinic_Appointment__c.Rebooking__c.getDescribe().getName() + ', '
                + Clinic_Appointment__c.Priority__c.getDescribe().getName() + ', '
                + Clinic_Appointment__c.Clinic__c.getDescribe().getName() + ', '
                + Clinic_Appointment__c.Appointment_Date__c.getDescribe().getName();
        }
        return relativeObject;
    }

    private static EventObj fillEventObjectItem(sObject obj, Map<String, String> fieldApiNames) {
        String relativeObjectValue = String.isNotBlank((String)obj.get(Clinic_Appointment__c.Opportunity__c.getDescribe().getName()))
            ? (String)obj.get(Clinic_Appointment__c.Opportunity__c.getDescribe().getName())
            : String.isNotBlank((String)obj.get(Clinic_Appointment__c.Lead__c.getDescribe().getName()))
                ? (String)obj.get(Clinic_Appointment__c.Lead__c.getDescribe().getName())
                : '';
        Boolean isRebooking = obj.get(Clinic_Appointment__c.Rebooking__c.getDescribe().getName()) != null
            ? (Boolean) obj.get(Clinic_Appointment__c.Rebooking__c.getDescribe().getName())
            : false;
        Decimal priority = obj.get(Clinic_Appointment__c.Priority__c.getDescribe().getName()) != null
            ? (Decimal) obj.get(Clinic_Appointment__c.Priority__c.getDescribe().getName())
            : 0.0;
        Datetime aD = obj.get(Clinic_Appointment__c.Appointment_Date__c.getDescribe().getName()) != null
            ? (Datetime) obj.get(Clinic_Appointment__c.Appointment_Date__c.getDescribe().getName())
            : null;
        String cl = String.isNotBlank((String)obj.get(Clinic_Appointment__c.Clinic__c.getDescribe().getName()))
            ? (String) obj.get(Clinic_Appointment__c.Clinic__c.getDescribe().getName())
            : null;
        return new EventObj(obj.Id,
            String.valueOf(obj.get(fieldApiNames.get('title'))),
            DateTime.valueOf(obj.get(fieldApiNames.get('startDateTime'))),
            DateTime.valueOf(obj.get(fieldApiNames.get('endDateTime'))),
            String.valueOf(obj.get(fieldApiNames.get('description'))),
            String.valueOf(obj.get(fieldApiNames.get('owner'))),
            relativeObjectValue,
            isRebooking,
            priority,
            aD,
            cl
        );
    }

    private static void runAuraHandledException(String errorMsg) {
        AuraHandledException e = new AuraHandledException(errorMsg);
        e.setMessage(errorMsg);
        throw e;
    }

    public class EventObj {
        @AuraEnabled public String Id { get;set; }
        @AuraEnabled public String title { get;set; }
        @AuraEnabled public DateTime startDateTime { get;set; }
        @AuraEnabled public DateTime endDateTime { get;set; }
        @AuraEnabled public String description { get;set; }
        @AuraEnabled public String owner { get;set; }
        @AuraEnabled public String sObjectId { get;set; }
        @AuraEnabled public Boolean isRebooking { get;set; }
        @AuraEnabled public Decimal priority { get;set; }
        @AuraEnabled public DateTime appDate { get;set; }
        @AuraEnabled public String clinic { get;set; }
        @AuraEnabled public String clinicProduct { get;set; }

        public EventObj(String i,
                        String t,
                        DateTime s,
                        DateTime e,
                        String d,
                        String o,
                        String sOb,
                        Boolean r,
                        Decimal p,
                        Datetime aD,
                        String cl){
            Id = i;
            title = t;
            startDateTime = s;
            endDateTime = e;
            description = d;
            owner = o;
            sObjectId = sOb;
            isRebooking = r;
            priority = p;
            appDate = aD;
            clinic = cl;
        }

    }
}