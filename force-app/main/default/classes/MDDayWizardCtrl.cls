/**
 * MDDayWizardCtrl class 1.0.0
 *
 * @description This class represents an MDDayWizardCtrl.
 *
 * @author Nadezhda Podobed
 * @date 12.03.2019
 */
public with sharing class MDDayWizardCtrl {

    private static final String CLASS_NAME = MDDayWizardCtrl.class.getName();

    private static final String STATUS_SUCCESS = 'success';
    private static final String STATUS_WARNING = 'warning';
    private static final String STATUS_ERROR = 'error';

    @AuraEnabled
    public static String saveMDDay(String mdDayDataJSON) {
        Response.Builder response = new Response.Builder();

        Savepoint sp = Database.setSavepoint();

        try {
            if (String.isNotBlank(mdDayDataJSON)) {
                Map<String, Object> mdDayData = (Map<String, Object>) JSON.deserializeUntyped(mdDayDataJSON);

                Map<String, Object> responseData = new Map<String, Object>();

                Map<String, Object> mdDay = saveMDDayData((Map<String, Object>) mdDayData.get('mdDay'));
                responseData.put('mdDay', mdDay);

                Map<String, Object> mdDayRepetitionRule = saveMDDayRepetitionRuleData((Map<String, Object>) mdDayData.get('mdDayRepetitionRule'), mdDay);
                responseData.put('mdDayRepetitionRule', mdDayRepetitionRule);

                response.setData(responseData)
                        .setStatus(STATUS_SUCCESS);
            } else {
                response.setMessage('One or more parameter values are not valid: ' + mdDayDataJSON)
                        .setStatus(STATUS_ERROR);
            }
        } catch (DmlException e) {
            Database.rollback(sp);
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
            Database.rollback(sp);
            response.setMessage(CLASS_NAME + ': ' + e.getMessage())
                    .setStatus(STATUS_ERROR);
            System.debug(e.getMessage());
            System.debug(e.getStackTraceString());
        }

        return JSON.serializePretty(response.build(), true);
    }

    private static Map<String, Object> saveMDDayData(Map<String, Object> mdDayData) {
        Map<String, Object> mdDayDataMap = new Map<String, Object>();

        if (mdDayData != null && !mdDayData.isEmpty()) {
            mdDayDataMap = saveFormData(mdDayData);
        }

        return mdDayDataMap;
    }

    private static Map<String, Object> saveMDDayRepetitionRuleData(Map<String, Object> mdDayRepetitionRuleData, Map<String, Object> mdDay) {
        Map<String, Object> mdDayRepetitionRuleDataMap = new Map<String, Object>();

        if (mdDayRepetitionRuleData != null && !mdDayRepetitionRuleData.isEmpty() && mdDay != null && !mdDay.isEmpty()) {
            if (!((Map<String, Object>) mdDayRepetitionRuleData.get('record')).containsKey('MDDay__c')) {
                ((Map<String, Object>) mdDayRepetitionRuleData.get('record')).put('MDDay__c', ((Map<String, Object>) mdDay.get('record')).get('Id'));

                mdDayRepetitionRuleDataMap = saveFormData(mdDayRepetitionRuleData);
            }
        }

        return mdDayRepetitionRuleDataMap;
    }

    private static Map<String, Object> saveFormData(Map<String, Object> formData) {
        Map<String, Object> formDataMap = new Map<String, Object>();

        if (formData != null && !formData.isEmpty()) {
            formDataMap = formData;

            String objectType = String.valueOf(formData.get('objectType'));

            Schema.DescribeSObjectResult describeSObjectResult = DescribeService.getDescribeSObjectResult(objectType);

            if (describeSObjectResult != null) {
                sObject sObjectRecord = describeSObjectResult.getSobjectType().newSObject();

                Map<String, Object> recordMap = (Map<String, Object>) formData.get('record');
                System.debug(JSON.serializePretty(recordMap));

                Map<String, Schema.SObjectField> objectFieldsMap = describeSObjectResult.fields.getMap();

                for (String fieldName : recordMap.keySet()) {
                    if (objectFieldsMap.containsKey(fieldName)) {
                        Schema.DescribeFieldResult describeFieldResult = objectFieldsMap.get(fieldName).getDescribe();

                        String fieldType = describeFieldResult.getType().name();

                        if (fieldType == 'Boolean') {
                            sObjectRecord.put(fieldName, Boolean.valueOf(recordMap.get(fieldName)));
                        } else if (fieldType == 'Date') {
                            String dateString = String.valueOf(recordMap.get(fieldName));
                            System.debug(dateString);

                            if (String.isNotBlank(dateString)) {
                                sObjectRecord.put(fieldName, (Date) JSON.deserialize(JSON.serialize(dateString), Date.class));
                            } else {
                                sObjectRecord.put(fieldName, null);
                            }
                        } else if (fieldType == 'DateTime') {
                            String dateTimeString = String.valueOf(recordMap.get(fieldName));
                            System.debug(dateTimeString);

                            if (String.isNotBlank(dateTimeString)) {
                                sObjectRecord.put(fieldName, (DateTime) JSON.deserialize(JSON.serialize(dateTimeString), DateTime.class));
                            } else {
                                sObjectRecord.put(fieldName, null);
                            }
                        } else if (fieldType == 'Time') {
                            String timeString = String.valueOf(recordMap.get(fieldName));
                            System.debug(timeString);

                            if (String.isNotBlank(timeString)) {
                                sObjectRecord.put(fieldName, (Time) JSON.deserialize(JSON.serialize(timeString + 'Z'), Time.class));
                            } else {
                                sObjectRecord.put(fieldName, null);
                            }
                        } else if (fieldType == 'String') {
                            sObjectRecord.put(fieldName, String.valueOf(recordMap.get(fieldName)));
                        } else if (fieldType == 'Double') {
                            sObjectRecord.put(fieldName, Double.valueOf(recordMap.get(fieldName)));
                        } else {
                            sObjectRecord.put(fieldName, recordMap.get(fieldName));
                        }
                    }
                }
                System.debug(JSON.serializePretty(sObjectRecord));
                System.debug(sObjectRecord);

                upsert sObjectRecord;

                if (!((Map<String, Object>) formDataMap.get('record')).containsKey('Id')) {
                    ((Map<String, Object>) formDataMap.get('record')).put('Id', sObjectRecord.Id);
                }
            }
        }

        return formDataMap;
    }

    private static String getExceptionMessage(String initialMessage) {
        String exceptionMessage;

        if (String.isNotBlank(initialMessage)) {
            if (initialMessage.containsIgnoreCase('caused by:')) {
                exceptionMessage = initialMessage.substringBetween('FIELD_CUSTOM_VALIDATION_EXCEPTION,', ': [');
            } else {
                exceptionMessage = initialMessage;
            }
        }

        return exceptionMessage;
    }

}