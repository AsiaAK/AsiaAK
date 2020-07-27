trigger PaymentTrigger on Payment__c (after delete, after insert, after undelete, after update, before delete, before insert, before update) {
    PaymentHandler handler = new PaymentHandler();
    if(Trigger.isBefore) {
        if(Trigger.isUpdate) {
            handler.beforeUpdate(Trigger.newMap, Trigger.oldMap);
        }
    }
    if(Trigger.isAfter) {
        if(Trigger.isInsert) {
            handler.afterInsert(Trigger.newMap);
        }
        if(Trigger.isUpdate) {
            handler.afterUpdate(Trigger.newMap, Trigger.oldMap);
        }
    }
}