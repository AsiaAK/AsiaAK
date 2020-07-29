public with sharing class DropController {
    
    @AuraEnabled
    public static void updateOnDrop(Id recordId, String csStartDate, String csEndDate){
       System.debug('RecordId: ' + recordId +' - start: ' + csStartDate + ' - end: '+ csEndDate);
       String startDate = csStartDate.replace('T', ' ').substringBeforeLast('.');
       String endDate = csEndDate.replace('T', ' ').substringBeforeLast('.');
       String startClinicAppointment = String.valueOf(DateTime.valueOfGmt(startDate)).replace('.', '-');
        System.debug(startClinicAppointment);
       Clinic_Appointment__c clinicAppointment = [SELECT Id, CS_Start_Date__c, CS_End_Date__c, Name FROM Clinic_Appointment__c WHERE ID =: recordId LIMIT 1][0];
       clinicAppointment.CS_Start_Date__c = DateTime.valueOfGmt(startDate);
       clinicAppointment.CS_End_Date__c = DateTime.valueOfGmt(endDate);
       clinicAppointment.Name = clinicAppointment.Name.substringAfter('- -') + startClinicAppointment;
       update clinicAppointment;
    }
}