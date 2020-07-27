public class RecordCounter {
    
    @InvocableMethod
    public static List<integer> RecordsCounting (List<String> Brands) {
    Integer PaymentCount;
    Integer PreExCCNCount;    
    Integer CCNCount;    
    Integer PaidInvCount;
    Integer RecordsNo;
    Integer MO_PaymentCount;
    Integer MO_PreExCCNCount;    
    Integer MO_CCNCount;    
    Integer MO_PaidInvCount;
    Integer RecordCountAssist = 0;    
     
    List<integer> PassNo = New List<integer>();
    String Brand;
    Integer i;
    Integer j;
    Integer NumberOfMORecords;
    Integer NumberOfMDRecords;
    Integer CurrentStandMO;
    Integer CurrentStandMD;
    Integer BatchSize = Brands.size();
    Integer MDinBrands=0;
    Integer MOinBrands=0;    
        
        For (j=0;j<Brands.size();j++){
            If(Brands.get(j)=='Medidate'){
            MDinBrands = MDinBrands + 1;    
            }
            else {
            MOinBrands = MOinBrands + 1;    
            }
               
        }
        
        
    PaymentCount = [SELECT COUNT() FROM Payment__c WHERE MD_MO_invoice_counting_brand__c = 'Medidate'];
    PreExCCNCount = [SELECT COUNT() FROM Clinic_Credit_Note__c WHERE MD_MO_invoice_counting_brand__c ='Medidate'];    
    CCNCount = [SELECT COUNT() FROM Pre_Ex_Clinic_Credit_Note__c WHERE MD_MO_invoice_counting_brand__c ='Medidate'];  
    PaidInvCount = [SELECT COUNT() FROM Paid_Invoice__c WHERE MD_MO_invoice_counting_brand__c ='Medidate'];
    MO_PaymentCount = [SELECT COUNT() FROM Payment__c WHERE MD_MO_invoice_counting_brand__c ='Medical One'];
    MO_PreExCCNCount = [SELECT COUNT() FROM Clinic_Credit_Note__c WHERE MD_MO_invoice_counting_brand__c ='Medical One'];    
    MO_CCNCount = [SELECT COUNT() FROM Pre_Ex_Clinic_Credit_Note__c WHERE MD_MO_invoice_counting_brand__c ='Medical One'];  
    MO_PaidInvCount = [SELECT COUNT() FROM Paid_Invoice__c WHERE MD_MO_invoice_counting_brand__c ='Medical One'];
    NumberOfMORecords = MO_PaymentCount + MO_PreExCCNCount + MO_CCNCount + MO_PaidInvCount - MOinBrands;
    NumberOfMDRecords = PaymentCount + PreExCCNCount + CCNCount + PaidInvCount - MDinBrands;
        
    System.debug('Number of MO records: ' + NumberOfMORecords);
    System.debug('Number of MD records: ' + NumberOfMDRecords);
    
    For (i=0;i<Brands.size();i++){
        
        IF (Brands.get(i)=='Medidate'){
            CurrentStandMD = NumberOfMDRecords + 1;
            PassNo.add(CurrentStandMD);
            NumberOfMDRecords = CurrentStandMD;
            System.debug('Curent Stand MD:' + CurrentStandMD);
            System.debug('Updated Number of MD Records' + NumberOfMDRecords);
        }
        Else {
        CurrentStandMO = NumberOfMORecords + 1;
        PassNo.add(CurrentStandMO);
        NumberOfMORecords = CurrentStandMO;
        System.debug('Curent Stand MO:' + CurrentStandMO);
        System.debug('Updated Number of MO Records' + NumberOfMORecords);
        }
        
        System.debug('Number of MO records 2: ' + NumberOfMORecords);
        System.debug('Number of MD records 2: ' + NumberOfMDRecords);
        System.debug('Pass No:' + PassNo);
        
    }
    return PassNo;    
    }
    
}