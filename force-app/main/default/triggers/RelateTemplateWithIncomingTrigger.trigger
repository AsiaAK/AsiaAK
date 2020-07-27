trigger RelateTemplateWithIncomingTrigger on tdc_tsw__Message__c (before insert) {
    
    if(Trigger.isBefore && Trigger.isInsert)
    {
        tdc_tsw__Message__c objMessage = Trigger.new[0]; // Always 1 incoming once so no problem.
      
            if(objMessage.name == 'Incoming')
            {       
                  List<tdc_tsw__Message__c> lstOutgoingMessage =  [Select Id,Name, OwnerId,tdc_tsw__SMS_Template__c, tdc_tsw__Related_Object__c, tdc_tsw__Related_Object_Id__c from tdc_tsw__Message__c where tdc_tsw__Related_Object__c =: objMessage.tdc_tsw__Related_Object__c and tdc_tsw__Related_Object_Id__c =: objMessage.tdc_tsw__Related_Object_Id__c Order By CreatedDate Desc Limit 1 ];
                  
                  if(lstOutgoingMessage.size () >0 ){
                        if(lstOutgoingMessage[0].Name == 'Outgoing'){
    
                             objMessage.tdc_tsw__SMS_Template__c = lstOutgoingMessage[0].tdc_tsw__SMS_Template__c;
                        }
                   }
            }
    }    
}