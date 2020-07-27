@IsTest(SeeAllData=True)
public class RecordCounter_Test {
    
    @IsTest
    Public static void RecordCounting_test () {
    Paid_invoice__c NewPI= new Paid_invoice__c ();
    List<KVA__c> KVAExample = [Select ID from KVA__c WHERE Name <> '' LIMIT 1];    
    String OneID = KVAExample.get(0).id;
    system.debug('KVA id: ' + OneID);
        
        
    NewPI.Name = 'Test PI';
    NewPI.KVA__c = OneID;
    Insert NewPI;
        
    List<Paid_invoice__c> BrandsRecords = [Select MD_MO_invoice_counting_brand__c FROM Paid_invoice__c where ID = :NewPI.id]; 
    List<String> BrandsStg = new List<String> ();
    system.debug('New Paid invoice record ID: ' + Brandsrecords.get(0).MD_MO_invoice_counting_brand__c);
    
    BrandsStg.add(String.valueof(Brandsrecords.get(0)));
        
    RecordCounter.RecordsCounting(BrandsStg);
        
    }
    
}