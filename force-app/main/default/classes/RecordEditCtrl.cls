/**
 * RecordEditCtrl class 1.0.0
 *
 * @description This class represents a RecordEditCtrl.
 *
 * @author Nadezhda Podobed
 * @date 23.02.2019
 */
public with sharing class RecordEditCtrl {

    private static final String CLASS_NAME = RecordEditCtrl.class.getName();

    private static final String STATUS_SUCCESS = 'success';
    private static final String STATUS_WARNING = 'warning';
    private static final String STATUS_ERROR = 'error';

    @AuraEnabled
    public static String getFormData(String formDataFilterJSON) {
        Response.Builder response = new Response.Builder();

        try {
            if (String.isNotBlank(formDataFilterJSON)) {
                Map<String, Object> formDataFilter = (Map<String, Object>) JSON.deserializeUntyped(formDataFilterJSON);

                Map<String, Object> responseData = new Map<String, Object>();

                responseData.put('formData', getFormDataMap(formDataFilter));

                response.setData(responseData)
                        .setStatus(STATUS_SUCCESS);
            } else {
                response.setMessage('One or more parameter values are not valid: ' + formDataFilterJSON)
                        .setStatus(STATUS_ERROR);
            }
        } catch (Exception e) {
            response.setMessage(CLASS_NAME + ': ' + e.getMessage())
                    .setStatus(STATUS_ERROR);
            System.debug(e.getStackTraceString());
        }

        return JSON.serializePretty(response.build(), true);
    }

    private static Map<String, Object> getFormDataMap(Map<String, Object> formDataFilter) {
        Map<String, Object> formData = new Map<String, Object>();

        if (formDataFilter != null && !formDataFilter.isEmpty()) {
            String objectType = String.valueOf(formDataFilter.get('objectType'));

            Schema.DescribeSObjectResult describeSObjectResult = DescribeService.getDescribeSObjectResult(objectType);

            String recordTypeId = String.valueOf(formDataFilter.get('recordType'));

            String recordId = String.valueOf(formDataFilter.get('recordId'));

            List<String> fields = new List<String>();

            for (Object field : (List<Object>) formDataFilter.get('fields')) {
                fields.add(String.valueOf(field));
            }

            Map<String, Object> fieldValues = getFieldValues(objectType, recordId, fields);

            formData.put('fields', getFormFields(describeSObjectResult, fields, fieldValues));
        }

        return formData;
    }

    private static Map<String, Map<String, Object>> getFormFields(Schema.DescribeSObjectResult describeSObjectResult, List<String> fields, Map<String, Object> fieldValues) {
        Map<String, Map<String, Object>> formFields = new Map<String, Map<String, Object>>();

        if (describeSObjectResult != null && fields != null && !fields.isEmpty()) {
            Map<String, Schema.SObjectField> objectFieldsMap = describeSObjectResult.fields.getMap();

            for (String fieldName : fields) {
                if (objectFieldsMap.containsKey(fieldName)) {
                    Schema.DescribeFieldResult describeFieldResult = objectFieldsMap.get(fieldName).getDescribe();
                    System.debug('fieldName: ' + fieldName);
                    System.debug('isAccessible: ' + describeFieldResult.isAccessible());
                    System.debug('isCreateable: ' + describeFieldResult.isCreateable());
                    System.debug('isUpdateable: ' + describeFieldResult.isUpdateable());

                    if (describeFieldResult.isAccessible() && describeFieldResult.isCreateable() && describeFieldResult.isUpdateable()) {
                        Map<String, Object> formField = new Map<String, Object>();
                        formField.put('name', describeFieldResult.getName());
                        formField.put('value', fieldValues.containsKey(describeFieldResult.getName()) && fieldValues.get(describeFieldResult.getName()) != null
                                ? fieldValues.get(describeFieldResult.getName())
                                : describeFieldResult.getDefaultValue());
                        formField.put('type', describeFieldResult.getType());
    
                        if (describeFieldResult.getType().name() == 'Picklist'
                                || describeFieldResult.getType().name() == 'Combobox'
                                || describeFieldResult.getType().name() == 'MultiPicklist') {
                            List<Map<String, Object>> options = new List<Map<String, Object>>();

                            for (Schema.PicklistEntry picklistEntry : describeFieldResult.getPicklistValues()) {
                                if (picklistEntry.isActive()) {
                                    Map<String, Object> option = new Map<String, Object>();
                                    option.put('value', picklistEntry.getValue());
                                    option.put('label', picklistEntry.getLabel());
                                    option.put('selected', picklistEntry.isDefaultValue());

                                    options.add(option);
                                }
                            }

                            formField.put('options', options);
                        }

                        formFields.put(describeFieldResult.getName(), formField);
                    }
                }
            }
        }

        return formFields;
    }

    private static Map<String, Object> getFieldValues(String objectType, String recordId, List<String> fields) {
        Map<String, Object> fieldValues = new Map<String, Object>();

        if (String.isNotBlank(recordId)) {
            fieldValues = getRecord(objectType, recordId, fields);
        }

        return fieldValues;
    }

    private static Map<String, Object> getRecord(String objectType, String recordId, List<String> fields) {
        Map<String, Object> record = new Map<String, Object>();

        if (String.isNotBlank(objectType) && String.isNotBlank(recordId) && fields != null && !fields.isEmpty()) {
            Set<String> recordQueryFields = new Set<String>(fields);

            List<String> conditions = new List<String>();

            conditions.add(QueryService.getCondition(
                    'Id',
                    '=',
                    recordId,
                    true
            ));

            String whereConditions = String.join(conditions, ' AND ');

            String recordsQueryString = new SOQLQuery.Builder()
                    .setSelectToken(
                            new SOQLSelect.Builder()
                                    .setObject(objectType)
                                    .setRequiredFields(recordQueryFields)
                                    .build()
                    )
                    .setObject(objectType)
                    .setWhereConditions(whereConditions)
                    .setQueryLimit(String.valueOf(1))
                    .build()
                    .toString();
            System.debug(recordsQueryString);

            if (String.isNotBlank(recordsQueryString)) {
                List<sObject> records = Database.query(recordsQueryString);
                if (!records.isEmpty()) {
                    record = records.get(0).getPopulatedFieldsAsMap();
                }
            }
        }

        return record;
    }
   
}