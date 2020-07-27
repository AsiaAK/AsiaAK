trigger DeletedOrderReview on Order_review__c (before delete) {
List<ID> AllPrIDs = new List<ID>();
List<Ordered_medical_product__c> NonParentedOrders = new List<Ordered_medical_product__c>();
ID Pr1;
ID Pr2;
ID Pr3;
ID Pr4;
ID Pr5;
    
    For (Order_review__c DelOrder: Trigger.Old) {
        Pr1 = DelOrder.Product_1__c;
        Pr2 = DelOrder.Product_2__c;
        Pr3 = DelOrder.Product_3__c;
        Pr4 = DelOrder.Product_4__c;
        Pr5 = DelOrder.Product_5__c;
        AllPrIDs.add(Pr1);
        AllPrIDs.add(Pr2);
        AllPrIDs.add(Pr3);
        AllPrIDs.add(Pr4);
        AllPrIDs.add(Pr5);
                     
                     For(ID OneID:AllPrIDs){
                         If (OneID!=Null){
                         Ordered_medical_product__c ToBeDeletedOMP = new Ordered_medical_product__c();
                         ToBeDeletedOMP.id = OneID;
                         NonParentedOrders.add(ToBeDeletedOMP);
                             
                         }
                        
                     }
                  
    }

delete NonParentedOrders;

}