public with sharing class RecordTypeSelector {

    public final static String ACCOUNT_DOCTOR = 'ClinicsRecordType';
    public final static String PERSON_ACCOUNT_PATIENT = 'PersonAccount';
    
    public final static String CLINIC_APP_OPERATION_DATE = 'Operation_Date';
    public final static String CLINIC_APP_PRE_EX_APP = 'Pre_Ex_Appointment';

    public final static String MD_DAY_LOCATION_OPERATION = 'Operation_Location';
    public final static String MD_DAY_LOCATION_PRE_EX = 'Pre_ex_Location';

    public final static String MD_DAY_PRE_EX = 'MD_Pre_Ex_Day';
    public final static String MD_DAY_OPERATION = 'MD_Operation_Day';

    public final static String OPPORTUNITY_BODY = 'Body';


    private static Map<String, Map<String, Id>> recordTypesIds;

    static {
        recordTypesIds = new Map<String, Map<String, Id>>();
    }
    
    public static Id getRecordTypeId(String objDevName, String recordTypeDevName) {
        
        if(recordTypesIds.get(objDevName) != null && recordTypesIds.get(objDevName).get(recordTypeDevName) != null) {

            return recordTypesIds.get(objDevName).get(recordTypeDevName);
        }
        else {
            Map<String, Schema.SObjectType> globalDesc = Schema.getGlobalDescribe();
            Id recordTypeId = globalDesc.get(objDevName).getDescribe().getRecordTypeInfosByDeveloperName().get(recordTypeDevName).getRecordTypeId();
            recordTypesIds.put(objDevName, new Map<String, Id>{recordTypeDevName => recordtypeId});

            return recordTypeId;
        }
    }
}