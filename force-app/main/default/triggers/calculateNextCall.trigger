trigger calculateNextCall on Lead (before update, before insert) {

    BusinessHours bh = [SELECT Id FROM BusinessHours WHERE IsDefault=true];
    LeadCallFrequency__c objLeadFrequency = LeadCallFrequency__c.getValues('callcounter');
    if(trigger.isUpdate)
    {
        for(Lead le : trigger.new)
        {
            if(le.LeadCallCounterAuto__c!= trigger.oldmap.get(le.id).LeadCallCounterAuto__c && le.PatientCallTimeFrom__c==null && le.Call_Back_Flag__c!=true )
            {
                //le.LeadCallTime__c = BusinessHours.add(bh.id, system.now() , 3600*1000*Integer.valueOf(le.LeadCallCounterAuto__c)); 
                if(le.LeadCallCounterAuto__c == 1)
                le.LeadCallTime__c = BusinessHours.add(bh.id, system.now() , 3600*1000*Integer.valueOf(objLeadFrequency.Call2__c)); 
                else if(le.LeadCallCounterAuto__c == 2)
                le.LeadCallTime__c = BusinessHours.add(bh.id, system.now() , 3600*1000*Integer.valueOf(objLeadFrequency.Call3__c));
                else if(le.LeadCallCounterAuto__c == 3)
                le.LeadCallTime__c = BusinessHours.add(bh.id, system.now() , 3600*1000*Integer.valueOf(objLeadFrequency.Call4__c)); 
                else if(le.LeadCallCounterAuto__c == 4)
                le.LeadCallTime__c = BusinessHours.add(bh.id, system.now() , 3600*1000*Integer.valueOf(objLeadFrequency.Call5__c));
                else if(le.LeadCallCounterAuto__c == 5)
                le.LeadCallTime__c = BusinessHours.add(bh.id, system.now() , 3600*1000*Integer.valueOf(objLeadFrequency.Call6__c));
                else if(le.LeadCallCounterAuto__c == 6)
                le.LeadCallTime__c = BusinessHours.add(bh.id, system.now() , 3600*1000*Integer.valueOf(objLeadFrequency.Call7__c));
                else if(le.LeadCallCounterAuto__c == 7)
                le.LeadCallTime__c = BusinessHours.add(bh.id, system.now() , 3600*1000*Integer.valueOf(objLeadFrequency.Call8__c));
                else if(le.LeadCallCounterAuto__c == 8)
                le.LeadCallTime__c = BusinessHours.add(bh.id, system.now() , 3600*1000*Integer.valueOf(objLeadFrequency.Call9__c));
                else if(le.LeadCallCounterAuto__c == 9)
                le.LeadCallTime__c = BusinessHours.add(bh.id, system.now() , 3600*1000*Integer.valueOf(objLeadFrequency.Call10__c));
                
            }
            else if(le.LeadCallCounterAuto__c!= trigger.oldmap.get(le.id).LeadCallCounterAuto__c && le.PatientCallTimeTo__c!=null && le.PatientCallTimeFrom__c!=null && le.Call_Back_Flag__c!=true)
            {
                Integer hour = Integer.valueOf(le.PatientCallTimeFrom__c.substring(0,2));
                Integer hourTo = Integer.valueOf(le.PatientCallTimeTo__c.substring(0,2));
                
                if(system.now().hour() < hour)
                {
                    Datetime nextStart = Datetime.newInstance(system.today().year(), 
                                                              system.today().month(), 
                                                              system.today().day(), 
                                                              hour, 
                                                              0, 
                                                              0);
                                                              
                    le.LeadCallTime__c  = BusinessHours.nextStartDate(bh.id, nextStart);                                        
                }
                else
                {
                    if(system.now().addHours(1).hour() <= hourTo)
                    {
                        Datetime nextStart = Datetime.newInstance(system.today().year(), 
                                                                  system.today().month(), 
                                                                  system.today().day(), 
                                                                  hourTo, 
                                                                  0, 
                                                                  0);
                        le.LeadCallTime__c  = BusinessHours.nextStartDate(bh.id, nextStart);                                          
                    }
                    else
                    {
                        Datetime nextStart = Datetime.newInstance(system.today().year(), 
                                                                  system.today().month(), 
                                                                  system.today().addDays(1).day(), 
                                                                  hour, 
                                                                  0, 
                                                                  0);
                        le.LeadCallTime__c  = BusinessHours.nextStartDate(bh.id, nextStart);
                    }
                }
                
            }
        }
    }
    
    else if(trigger.isInsert)
    {
        for(Lead le : trigger.new)
        {
            if(le.PatientCallTimeFrom__c!=null && le.Call_Back_Flag__c!=true)
            {
                Integer hour = Integer.valueOf(le.PatientCallTimeFrom__c.substring(0,2));
                if(system.now().hour() < hour)
                {
                    Datetime nextStart = Datetime.newInstance(system.today().year(), 
                                                              system.today().month(), 
                                                              system.today().day(), 
                                                              hour, 
                                                              0, 
                                                              0);
                                                              
                    le.LeadCallTime__c  = BusinessHours.nextStartDate(bh.id, nextStart);                                        
                }
                else
                {
                    Datetime nextStart = Datetime.newInstance(system.today().year(), 
                                                              system.today().month(), 
                                                              system.today().addDays(1).day(), 
                                                              hour, 
                                                              0, 
                                                              0);
                    le.LeadCallTime__c  = BusinessHours.nextStartDate(bh.id, nextStart);                                          
                }
            }
            else
            {
                le.LeadCallTime__c  = BusinessHours.nextStartDate(bh.id, system.now());
            }
            
            le.LeadCallCounterAuto__c=0;
        }
    
    }     

}