@isTest
public class RelateTemplateWithIncomingTriggerTest
{
    static testMethod void show()
    {
        Contact objContact = new Contact(lastName = 'test');
        insert objContact;
        
        tdc_tsw__Message_Template__c obj = new tdc_tsw__Message_Template__c(name = 'test');
        insert obj;
        
        tdc_tsw__Message__c  objMessage = new tdc_tsw__Message__c(name = 'Outgoing');
        objMessage.tdc_tsw__Related_Object__c = 'Contact';
        objMessage.tdc_tsw__Related_Object_Id__c = objContact.id;
        objMessage.tdc_tsw__SMS_Template__c = obj.id;
        insert objMessage;
        
        tdc_tsw__Message__c  objMessage1 = new tdc_tsw__Message__c(name = 'Incoming');
        objMessage1.tdc_tsw__Related_Object__c = 'Contact';
        objMessage1.tdc_tsw__Related_Object_Id__c = objContact.id;
        insert objMessage1;
        
    }
}