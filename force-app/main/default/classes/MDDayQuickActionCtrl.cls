/**
 * MDDayQuickActionCtrl class 1.0.0
 *
 * @description This class represents an MDDayQuickActionCtrl.
 *
 * @author Nadezhda Podobed
 * @date 05.03.2019
 */
public with sharing class MDDayQuickActionCtrl {

    private static final String CLASS_NAME = MDDayQuickActionCtrl.class.getName();

    private static final String STATUS_SUCCESS = 'success';
    private static final String STATUS_WARNING = 'warning';
    private static final String STATUS_ERROR = 'error';

    @AuraEnabled
    public static String getMdDayRecordTypes(String mdDayRecordTypesFilterJSON) {
        Response.Builder response = new Response.Builder();

        try {
            if (String.isNotBlank(mdDayRecordTypesFilterJSON)) {
                Map<String, Object> mdDayRecordTypesFilter = (Map<String, Object>) JSON.deserializeUntyped(mdDayRecordTypesFilterJSON);

                Map<String, Object> responseData = new Map<String, Object>();

                List<Map<String, Object>> mdDayRecordTypes = getMdDayRecordTypeValues(mdDayRecordTypesFilter);
                responseData.put('mdDayRecordTypes', mdDayRecordTypes);

                response.setData(responseData)
                        .setStatus(STATUS_SUCCESS);
            } else {
                response.setMessage('One or more parameter values are not valid: ' + mdDayRecordTypesFilterJSON)
                        .setStatus(STATUS_ERROR);
            }
        } catch (Exception e) {
            response.setMessage(CLASS_NAME + ': ' + e.getMessage())
                    .setStatus(STATUS_ERROR);
            System.debug(e.getStackTraceString());
        }

        return JSON.serializePretty(response.build(), true);
    }

    private static List<Map<String, Object>> getMdDayRecordTypeValues(Map<String, Object> mdDayRecordTypesFilter) {
        List<Map<String, Object>> mdDayRecordTypes = new List<Map<String, Object>>();

        if (mdDayRecordTypesFilter != null && !mdDayRecordTypesFilter.isEmpty()) {
            Map<String, Schema.RecordTypeInfo> mdDayRecordTypesMap = Schema.SObjectType.MD_Day__c.getRecordTypeInfosByName();

            List<String> mdDayRecordTypeNames = new List<String>(mdDayRecordTypesMap.keySet());
            mdDayRecordTypeNames.sort();

            String sObjectName = String.valueOf(mdDayRecordTypesFilter.get('sObjectName'));

            if (String.isNotBlank(sObjectName)) {
                if (sObjectName == 'MD_Day_Location__c') {
                    Map<String, String> mdDayLocationAssociationMap = new Map<String, String>{
                        'Operation_Location' => 'MD_Operation_Day',
                        'Pre_ex_Location' => 'MD_Pre_Ex_Day'
                    };

                    String recordId = String.valueOf(mdDayRecordTypesFilter.get('recordId'));

                    List<MD_Day_Location__c> mdDayLocations = [
                        SELECT Id,
                               RecordType.DeveloperName
                        FROM MD_Day_Location__c
                        WHERE Id = :recordId
                    ];

                    MD_Day_Location__c mdDayLocation = !mdDayLocations.isEmpty()
                            ? mdDayLocations.get(0)
                            : null;

                    for (String mdDayRecordTypeName : mdDayRecordTypeNames) {
                        Schema.RecordTypeInfo mdDayRecordTypeInfo = mdDayRecordTypesMap.get(mdDayRecordTypeName);

                        if (mdDayRecordTypeInfo.isActive() && mdDayRecordTypeInfo.isAvailable() && !mdDayRecordTypeInfo.isMaster()) {
                            Map<String, Object> mdDayRecordType = new Map<String, Object>();
                            mdDayRecordType.put('label', mdDayRecordTypeInfo.getName());
                            mdDayRecordType.put('value', mdDayRecordTypeInfo.getRecordTypeId());
                            mdDayRecordType.put('developerName', mdDayRecordTypeInfo.getDeveloperName());
                            mdDayRecordType.put(
                                'selected',
                                mdDayLocation != null && mdDayLocationAssociationMap.get(mdDayLocation.RecordType.DeveloperName) == mdDayRecordTypeInfo.getDeveloperName()
                            );

                            mdDayRecordTypes.add(mdDayRecordType);
                        }
                    }
                } else if (sObjectName == 'Account') {
                    for (String mdDayRecordTypeName : mdDayRecordTypeNames) {
                        Schema.RecordTypeInfo mdDayRecordTypeInfo = mdDayRecordTypesMap.get(mdDayRecordTypeName);

                        if (mdDayRecordTypeInfo.isActive() && mdDayRecordTypeInfo.isAvailable() && !mdDayRecordTypeInfo.isMaster()) {
                            Map<String, Object> mdDayRecordType = new Map<String, Object>();
                            mdDayRecordType.put('label', mdDayRecordTypeInfo.getName());
                            mdDayRecordType.put('value', mdDayRecordTypeInfo.getRecordTypeId());
                            mdDayRecordType.put('developerName', mdDayRecordTypeInfo.getDeveloperName());
                            mdDayRecordType.put('selected', mdDayRecordTypeNames.indexOf(mdDayRecordTypeName) == 0);

                            mdDayRecordTypes.add(mdDayRecordType);
                        }
                    }
                }
            }
        }

        return mdDayRecordTypes;
    }

}