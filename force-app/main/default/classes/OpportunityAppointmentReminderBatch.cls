global class OpportunityAppointmentReminderBatch implements Database.Batchable<sObject>, Database.AllowsCallouts {
    
    global Database.QueryLocator start(Database.BatchableContext BC) {
        return Database.getQueryLocator(
            'SELECT Account.Id, Account.Phone, LastSmsSentAt__c, LastSMSStatus__c,' + 
            ' ReminderSMSTextAuto__c FROM Opportunity' +
            ' WHERE AppointmentDate__c = TOMORROW AND StageName = \'Clinic Confirmed Pre-Ex\''
        );
    }
    
    global void execute(Database.BatchableContext BC, List<sObject> scope) {
        EsendexHelper.sObjects = scope;
        EsendexHelper.execute('message dispatcher');
    }
    
    global void finish(Database.BatchableContext BC) {
        
    }
}