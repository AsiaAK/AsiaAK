trigger Five9LSP_Clinic_Appointment_Trigger on Clinic_Appointment__c (before update, after update, before insert, after insert, before delete)
{
if(Trigger.isAfter && Trigger.isUpdate) {
Five9LSP.F9LSTriggerHandler.afterUpdate('Clinic_Appointment__c'); }
else if(Trigger.isAfter && Trigger.isInsert) {
Five9LSP.F9LSTriggerHandler.afterInsert(); }
else if(Trigger.isBefore && Trigger.isUpdate) {
Five9LSP.F9LSTriggerHandler.beforeUpdate(); }
else if(Trigger.isBefore && Trigger.isInsert) {
Five9LSP.F9LSTriggerHandler.beforeInsert(); }
 
else if (Trigger.isDelete) {
Five9LSP.F9LSTriggerHandler.beforeDelete('Clinic_Appointment__c'); }
}