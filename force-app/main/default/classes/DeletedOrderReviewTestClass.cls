@isTest(SeeAllData=True)
Public class DeletedOrderReviewTestClass {
   Public static testmethod void test_DeletedOrderReview () {    
   List<Ordered_medical_product__c> OMPList=new List<Ordered_medical_product__c>();
   Order_review__c NewOR = new Order_review__c ();
   List<Opportunity> OneOpp = [Select Id from opportunity where Test_opportunity__c= True limit 1];
   List<Medical_product__c>  MPr= [Select id from medical_product__c limit 1];
   
   
    
   Ordered_medical_product__c NewOMP1=new Ordered_medical_product__c();
   NewOMP1.Opportunity__c = OneOpp.get(0).id;
   NewOMP1.Medical_product__c = MPr.get(0).id;
   OMPList.add(NewOMP1);
   
   Ordered_medical_product__c NewOMP2=new Ordered_medical_product__c();
   NewOMP2.Opportunity__c = OneOpp.get(0).id;
   NewOMP2.Medical_product__c = MPr.get(0).id;
   OMPList.add(NewOMP2);
   
   Ordered_medical_product__c NewOMP3=new Ordered_medical_product__c();
   NewOMP3.Opportunity__c = OneOpp.get(0).id;
   NewOMP3.Medical_product__c = MPr.get(0).id;
   OMPList.add(NewOMP3);
   system.debug('Opp id: ' + OneOpp.get(0).id + ' And MP id: ' + MPr.get(0).id);
   
   Ordered_medical_product__c NewOMP4=new Ordered_medical_product__c();
   NewOMP4.Opportunity__c = OneOpp.get(0).id;
   NewOMP4.Medical_product__c = MPr.get(0).id;
   OMPList.add(NewOMP4);    
   
   Ordered_medical_product__c NewOMP5=new Ordered_medical_product__c();
   NewOMP5.Opportunity__c = OneOpp.get(0).id;
   NewOMP5.Medical_product__c = MPr.get(0).id;
   OMPList.add(NewOMP5);
   
   insert OMPList;
   
   NewOR.Name = 'Test';
   NewOR.Product_1__c = NewOMP1.id;
   NewOR.Product_2__c = NewOMP2.id;
   NewOR.Product_3__c = NewOMP3.id;
   NewOR.Product_4__c = NewOMP4.id;
   NewOR.Product_5__c = NewOMP5.id;
   insert NewOR;
   
   delete NewOR; 
       
   }   
    
}