public class PaymentHelper {
    public static void generatePaymentLinks(Map<Id, Payment__c> newMap) {
        //maximum 200 records will be processed at the same time
        //if there are more than 100 split between 2 chunck to avoid callout limit(100 per transaction)
        List<Payment__c> chunk1 = new List<Payment__c>();
        List<Payment__c> chunk2 = new List<Payment__c>();
        for(Integer i = 0; i < newMap.values().size(); i++) {
            Payment__c tempPayment = newMap.values()[i].clone();
            tempPayment.Id = newMap.values()[i].Id;
            if(newMap.values()[i].PaymentMethod__c != 'test' && newMap.values()[i].TransactionStatus__c !='Credit note') {
                if(i < 100) {
                    chunk1.add(tempPayment);
                } else {
                    chunk2.add(tempPayment);
                }
            }
        }
        if(!chunk1.isEmpty()){
            System.enqueueJob(new SaferpayQueueable(chunk1));
        }
        if(!chunk2.isEmpty()) {
            System.enqueueJob(new SaferpayQueueable(chunk2));
        }
    }
    
    public static void generatePaymentLinks(Map<Id, Payment__c> newMap, Map<Id, Payment__c> oldMap) {
        Map<Id, Payment__c> filteredMap = new Map<Id, Payment__c>();
        Payment__c oldPaymentRecord;
        for(Payment__c newPaymentRecord :newMap.values()) {
            oldPaymentRecord = oldMap.get(newPaymentRecord.Id);
            if(newPaymentRecord.GenerateNewPaymentLink__c && !oldPaymentRecord.GenerateNewPaymentLink__c) {
                filteredMap.put(newPaymentRecord.Id, newPaymentRecord);
            }
        }
        generatePaymentLinks(filteredMap);
    }
    
     public static void sendInvoices(Map<Id, Payment__c> newMap, Map<Id, Payment__c> oldMap) {
     List<Payment__c> updatednewPaymentRecords = new List<Payment__c>();
        Payment__c oldPaymentRecord;
        for(Payment__c newPaymentRecord :newMap.values()) {
            oldPaymentRecord = oldMap.get(newPaymentRecord.Id);
            Payment__c record1 = new Payment__c(id=newPaymentRecord.id);
            
            //for post payment the letter is sent to oekopost once the payment has a payment link
            //after the payment id confirmed (invoice id generated) the invoice and letter (letter is sent only if it was not sent before) are sent to oekopost
            //controll of the pages in document is made in the VF components
            if((newPaymentRecord.PaymentType__c == 'Post-Payment'  && newPaymentRecord.TransactionStatus__c == 'Paid' && newPaymentRecord.Create_and_send_Oekopost_Invoice__c=='Yes' && ((newPaymentRecord.PaymentLink__c != null && newPaymentRecord.PaymentLink__c != oldPaymentRecord.PaymentLink__c) ||
             (newPaymentRecord.LegacyPaymentLink__c != null && newPaymentRecord.LegacyPaymentLink__c != oldPaymentRecord.LegacyPaymentLink__c)))
             
             || (newPaymentRecord.InvoiceNumberAuto__c != null && newPaymentRecord.InvoiceNumberAuto__c != oldPaymentRecord.InvoiceNumberAuto__c && newPaymentRecord.Create_and_send_Oekopost_Invoice__c=='Yes' && newPaymentRecord.TransactionStatus__c == 'Paid')
            ) {
                //send to oekopost
                createPaymentDocuments(newPaymentRecord.Id);
                record1.Create_and_send_Oekopost_Invoice__c='Oekopost document created and sent';
                updatednewPaymentRecords.add(record1);
            }
        }
        update updatednewPaymentRecords;
        
    }
    
    @future (callout=true)
    public static void createPaymentDocuments(Id paymentId) {
        Attachment attchment = createPDF(paymentId, Page.InvoicePDF, 'OekopostDocument');
        oekopostHandler.sendPdf(attchment.body, paymentId);
        insert attchment;
    }
    
    public static Attachment createPDF(Id paymentId, Pagereference pageName, String documentName) {
        Attachment att = new Attachment(name = documentName + '.pdf');
        Pagereference pdf = pageName;
        pdf.getParameters().put('id',paymentId);
        pdf.setRedirect(true);
        if (Test.IsRunningTest()) {
            att.body = Blob.valueOf('UNIT.TEST');
        } else {
            att.body = pdf.getContentAsPDF();
        }
        att.parentid = paymentId;
        return att;
    }
    //before update
    public static void generateInvoiceIds(Map<Id, Payment__c> newMap, Map<Id, Payment__c> oldMap) {
        List<Payment__c> updatedRecords = new List<Payment__c>();
        Payment__c oldPaymentRecord;
        for(Payment__c newPaymentRecord :newMap.values()) {
            if(trigger.isUpdate){
                oldPaymentRecord = oldMap.get(newPaymentRecord.Id);
               if(newPaymentRecord.TransactionStatus__c == 'Paid' ||newPaymentRecord.TransactionStatus__c == 'Credit note' ) {
                    updatedRecords.add(newPaymentRecord);
                }
            }
        }
        generateInvoiceIds(updatedRecords);
    }
    //after insert
    public static void generateInvoiceIds(Map<Id, Payment__c> newMap) {
    
        List<Payment__c> updatednewPaymentRecords = new List<Payment__c>();
         for(Payment__c record :newMap.values()) {
            if((record.TransactionStatus__c == 'Credit note'||record.TransactionStatus__c == 'Paid' )  && record.InvoiceNumberAuto__c == null){
                Payment__c record1 = new Payment__c(id=record.id);
                record1.InvoiceDate__c = System.today();
           // system.debug('CLINIC ID - ' + newPaymentRecord.ClinicIdAuto__c + ' --- APPOINTMENT MONTH - ' + newPaymentRecord.OpportunityAppointmentMonthAuto__c);
           // Integer numberOfInvoices = [select count() from Payment__c where Opportunity__r.Clinic__c = :record.ClinicIdAuto__c and InvoiceNumberAuto__c != null and (TransactionStatus__c = 'Paid' OR  TransactionStatus__c = 'Credit note') and OpportunityAppointmentMonthAuto__c = :record.OpportunityAppointmentMonthAuto__c];
            if(record.TransactionStatus__c == 'Credit note')
            //record1.InvoiceNumberAuto__c = 'G-VU-' + record.OpportunityAppointmentDate__c.format('MMYY') + '-' + record.ClinicInvoiceCodeAuto__c + '-' + (numberOfInvoices + 1);
            record1.InvoiceNumberAuto__c = 'G-VU-' + record.OpportunityAppointmentDate__c.format('MMYY') + '-' + record.ClinicInvoiceCodeAuto__c + '-' + record.PatientCode__c + '-' + record.name;
            else if(record.TransactionStatus__c == 'Paid' && record.Invoice_on_behalf_of__c!='MediDate'){
                //record1.Create_and_send_Oekopost_Invoice__c='Yes'; 
                record1.InvoiceNumberAuto__c = 'TR-VU-' + record.OpportunityAppointmentDate__c.format('MMYY') + '-' + record.ClinicInvoiceCodeAuto__c + '-' + record.PatientCode__c + '-' + record.name;
            }    
            else if(record.TransactionStatus__c == 'Paid' && record.Invoice_on_behalf_of__c=='MediDate'){
                //record1.Create_and_send_Oekopost_Invoice__c='Yes'; 
                record1.InvoiceNumberAuto__c = 'R-VU-' + record.OpportunityAppointmentDate__c.format('MMYY') + '-' + record.ClinicInvoiceCodeAuto__c + '-' + record.PatientCode__c + '-' + record.name;
            }
            updatednewPaymentRecords.add(record1);
        }
            
        }
        update updatednewPaymentRecords;
    }
        //generateInvoiceIds(updatedRecords);
  
      //before update
     public static void generateInvoiceIds(List<Payment__c> records) {
    Set<id> paymentIds = new Set<id>();
    List<AggregateResult> agResult = new List<AggregateResult>();
     Map<String, Integer> paidPaymentMap = new Map<String, Integer>();
     Integer count =0;
    for(Payment__c record :records) {
        
        paymentIds.add(record.id);
    }
    agResult = [select count(id) cnt,CALENDAR_MONTH(OpportunityAppointmentDate__c) calMonth, CALENDAR_YEAR(OpportunityAppointmentDate__c) calYear,  TransactionStatus__c ts, Opportunity__r.Clinic__r.ClinicInvoiceCode__c cc
                         from Payment__c where InvoiceNumberAuto__c != null  and TransactionStatus__c='Paid'  
                        GROUP BY CALENDAR_MONTH(OpportunityAppointmentDate__c),TransactionStatus__c,CALENDAR_YEAR(OpportunityAppointmentDate__c),Opportunity__r.Clinic__r.ClinicInvoiceCode__c];
                        
    //agResult = [select count(id) cnt,CALENDAR_MONTH(OpportunityAppointmentDate__c) calMonth, CALENDAR_YEAR(OpportunityAppointmentDate__c) calYear,  TransactionStatus__c ts from Payment__c 
               // where InvoiceNumberAuto__c != null  and TransactionStatus__c='Paid' GROUP BY CALENDAR_MONTH(OpportunityAppointmentDate__c),TransactionStatus__c,CALENDAR_YEAR(OpportunityAppointmentDate__c)];                  
                        
                        for(AggregateResult ag: agResult){
            paidPaymentMap.Put(string.valueOf(ag.get('calMonth')) + '_' + ag.get('calYear') + '_' + ag.get('cc'), integer.valueOf(ag.get('cnt')));
        }
        
        for(Payment__c record :records) {
            system.debug('I am in2');
            record.InvoiceDate__c = System.today();
            system.debug('CLINIC ID - ' + record.ClinicIdAuto__c + ' --- APPOINTMENT MONTH - ' + record.OpportunityAppointmentMonthAuto__c);
           // Integer numberOfInvoices = [select count() from Payment__c where Opportunity__r.Clinic__c = :record.ClinicIdAuto__c and InvoiceNumberAuto__c != null and (TransactionStatus__c = 'Paid' OR TransactionStatus__c = 'Credit note') and OpportunityAppointmentMonthAuto__c = :record.OpportunityAppointmentMonthAuto__c];
            if(record.TransactionStatus__c == 'Credit note'){
                system.debug('I am in3');
            record.InvoiceNumberAuto__c = 'G-VU-' + record.OpportunityAppointmentDate__c.format('MMYY') + '-' + record.ClinicInvoiceCodeAuto__c + '-' + record.PatientCode__c + '-' + record.name;
            }
            else if(record.TransactionStatus__c == 'Paid' && record.Invoice_on_behalf_of__c!='MediDate' && record.InvoiceNumberAuto__c==null){
                //record.Create_and_send_Oekopost_Invoice__c='Yes';
            record.InvoiceNumberAuto__c = 'TR-VU-' + record.OpportunityAppointmentDate__c.format('MMYY') + '-' + record.ClinicInvoiceCodeAuto__c + '-' + record.PatientCode__c + '-' + record.name + '-' +paidPaymentMap.get(record.OpportunityAppointmentMonthAuto__c + '_' + record.AppointmentDateYearAuto__c+ '_' +record.ClinicInvoiceCodeAuto__c);
                //record.InvoiceNumberAuto__c = 'TR-VU-' + record.OpportunityAppointmentDate__c.format('MMYY') + '-' + record.ClinicInvoiceCodeAuto__c + '-' + record.PatientCode__c + '-' + record.name + '-' +paidPaymentMap.get(record.OpportunityAppointmentMonthAuto__c + '_' + record.AppointmentDateYearAuto__c);
            }else if(record.TransactionStatus__c == 'Paid' && record.Invoice_on_behalf_of__c=='MediDate' && record.InvoiceNumberAuto__c==null){
            // record.Create_and_send_Oekopost_Invoice__c='Yes';  
             record.InvoiceNumberAuto__c = 'R-VU-' + record.OpportunityAppointmentDate__c.format('MMYY') + '-' + record.ClinicInvoiceCodeAuto__c + '-' + record.PatientCode__c + '-' + record.name + '-' +paidPaymentMap.get(record.OpportunityAppointmentMonthAuto__c + '_' + record.AppointmentDateYearAuto__c + '_' +record.ClinicInvoiceCodeAuto__c);
            }
            
        }
        
        
        
    }
    
}