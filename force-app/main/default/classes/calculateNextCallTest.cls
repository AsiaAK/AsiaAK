@isTest (seeAllData=true)
private class calculateNextCallTest {
    static testmethod void createNewLeadWithTime09() {
        System.Test.startTest();
        Lead le = new Lead();
        le.lastName='Test';
        le.PatientCallTimeFrom__c='09:00';
        le.PatientCallTimeTo__c='11:00';
        insert le;
        
        le.LeadCallCounterAuto__c=3;
        update le;
        
        
        Lead leAfter = [SELECT id, LeadCallTime__c FROM Lead WHERE id=:le.Id LIMIT 1];
       
        system.assertNotEquals(leAfter.LeadCallTime__c,null);
        System.Test.stopTest();
    }
    
    static testmethod void createNewLeadWithTime18() {
        System.Test.startTest();
        Lead le = new Lead();
        le.lastName='Test';
        le.PatientCallTimeFrom__c='16:00';
        le.PatientCallTimeTo__c='18:00';
        insert le;
        
        le.LeadCallCounterAuto__c=3;
        update le;
        
        
        Lead leAfter = [SELECT id, LeadCallTime__c FROM Lead WHERE id=:le.Id LIMIT 1];
       
        system.assertNotEquals(leAfter.LeadCallTime__c,null);
        System.Test.stopTest();
    }
    
    static testmethod void createNewLeadWithoutTime() {
        System.Test.startTest();
        Lead le = new Lead();
        le.lastName='Test2';
        
        insert le;
        
        le.LeadCallCounterAuto__c=3;
        update le;
        
        Lead leAfter = [SELECT id, LeadCallTime__c FROM Lead WHERE id=:le.Id LIMIT 1];
        
        system.assertNotEquals(leAfter.LeadCallTime__c,null);
        System.Test.stopTest();
    }
    
    static testmethod void createNewLeadWithoutTime1() {
   
    
    list<lead> lstlead = new list<lead>();
        System.Test.startTest();
        Lead le1 = new Lead();
        le1.lastName='Test3';
        
        Lead le2 = new Lead();
        le2.lastName='Test4';
        
        Lead le3 = new Lead();
        le3.lastName='Test5';
        
        Lead le4 = new Lead();
        le4.lastName='Test6';
        
        Lead le5 = new Lead();
        le5.lastName='Test7';
        
        Lead le6 = new Lead();
        le6.lastName='Test8';
        
        Lead le7 = new Lead();
        le7.lastName='Test9';
        
        lstlead.add(le1);
        lstlead.add(le2);
        lstlead.add(le3);
        lstlead.add(le4);
        lstlead.add(le5);
        lstlead.add(le6);
        lstlead.add(le7);
        
        
        insert lstlead;
        
        lstlead[0].LeadCallCounterAuto__c=4;
        lstlead[1].LeadCallCounterAuto__c=5;
        lstlead[2].LeadCallCounterAuto__c=6;
        lstlead[3].LeadCallCounterAuto__c=7;
        lstlead[4].LeadCallCounterAuto__c=8;
        lstlead[5].LeadCallCounterAuto__c=9;
        lstlead[6].LeadCallCounterAuto__c=10;
        
        update lstlead;
        
        Lead leAfter = [SELECT id, LeadCallTime__c FROM Lead WHERE id=:lstlead[0].Id LIMIT 1];
        
        system.assertNotEquals(leAfter.LeadCallTime__c,null);
        System.Test.stopTest();
    }
}