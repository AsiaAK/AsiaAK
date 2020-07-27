@RestResource(urlMapping='/Five9AddCall')
global class Five9Calls{
    @HttpGet
    @HttpPost

    global static String addCallTask() {
                
        String logintoken= RestContext.request.params.get('logintoken');
              if (logintoken!='jhhu58oih050p!'){
               return 'Invalid Token';
           }

        String userId = UserInfo.getUserId();
        DateTime dt = DateTime.now();
        String formattedDt = dt.format('MM/dd/yyyy hh:mma');
        formattedDt =formattedDt.toLowerCase() + ' GMT'; 
    
    
        Task t = new Task();
        t.OwnerId = userId;
        t.Priority = 'Normal';
        t.Five9__Five9Agent__c= RestContext.request.params.get('Five9Agent');
        t.Five9__Five9AgentName__c= RestContext.request.params.get('Five9AgentName');
        t.Five9__Five9AgentExtension__c= RestContext.request.params.get('Five9AgentExtension');
        t.Five9__Five9ANI__c= RestContext.request.params.get('Five9ANI');
        t.CallDisposition= RestContext.request.params.get('CallDisposition');
        t.Five9__Five9Campaign__c= RestContext.request.params.get('Five9Campaign');
        t.Five9__Five9DNIS__c= RestContext.request.params.get('Five9DNIS'); 
        t.Five9__Five9HandleTime__c= RestContext.request.params.get('Five9HandleTime');
        t.Five9__Five9SessionId__c= RestContext.request.params.get('Five9SessionId');
        t.Subject= RestContext.request.params.get('Subject') + ' ' + formattedDt;
        t.Five9__Five9WrapTime__c= RestContext.request.params.get('Five9WrapTime');
        
        Decimal callDurationDecimal=Decimal.valueof(RestContext.request.params.get('CallDurationInSeconds'))/1000;
        t.CallDurationInSeconds= Integer.valueof(callDurationDecimal.round(System.RoundingMode.UP));
        String theWhoID= RestContext.request.params.get('salesforce_id');
        
        if(theWhoID!=''){

        t.WhoId= theWhoID;
        
        }
        t.Status='Abgeschlossen';
        t.CallType= RestContext.request.params.get('CallType');
        t.ActivityDate= Date.today();
        t.Five9__Five9CallType__c= RestContext.request.params.get('Five9CallType');
                
        insert t;
        return 'Inserted Call Id = ' + t.Id;

 }



}