trigger CountTask on Task ( after insert, after update) {
    
    public List<Task> ltask1 = new List<Task>();
    public id oppid;
    public integer inp=0;   
    public integer inr=0;
    for(Task t:Trigger.New){
        oppid = t.WhatId;
        system.debug('oppid'+oppid);
        
    }
    ltask1 = [select id,Status from task where whatid=:oppid];
    system.debug('oppsize'+ltask1.size());
    
    
    for(task t:ltask1){
        if(t.Status!='Abgeschlossen'){
            inp = inp+1;
        } else{
            inr = inr +1;
        }                
    }
    List<Opportunity> opp = new List<opportunity>();    
    List<opportunity> op = [select id from Opportunity where id = :oppid];
    system.debug('oppsize'+op.size());
    for(opportunity o: op){
        o.Open_Tasks__c = inp;
        o.Closed_Tasks__c = inr;
        opp.add(o);  
    }
    if(opp.size()>0){
        update opp;
    }        
    system.debug('No of Tasks'+inp+inr);       
}