public class SaferpayResultController {
    private String paymentId;
    private String message;
    private ApexPages.Severity severity;
    public String paidSuccessfully {get; set;}
    public String tranzactionSucceded {get; set;}
    public String accessToken {get; set;}
    public Opportunity opportunity {get; set;}
    public String clinicKeyword {get;set;}
    
    public SaferpayResultController() {
        if(SaferpayUtils.config.UseHttpsInterface__c) {
            system.debug(ApexPages.currentPage().getParameters());
            //check doc
            String dataString = ApexPages.currentPage().getParameters().get('DATA');
            paymentId = dataString.substringAfter('ORDERID="').substringBefore('"');
            paymentId = paymentId.replaceAll('"', '');
            System.debug('paymentId::' + paymentId);
        } else {
            paymentId = ApexPages.currentPage().getParameters().get('paymentId');
        }
        this.paidSuccessfully = 'NO';
        this.tranzactionSucceded = 'NO';
        
        try {
            this.opportunity = [SELECT Id, CalendarTimeZone__c, AppointmentDate__c, Clinic__r.ClinicCalendarKeyword__c, ClinicCalendarIdAuto__c, ClinicCalendarEventId__c FROM Opportunity where id in (select Opportunity__c from Payment__c WHERE Id = :paymentId OR PaymentID__c = :paymentId)];
            clinicKeyword = opportunity.Clinic__r.ClinicCalendarKeyword__c;
        } catch (Exception e) {}
        
        GoogleServiceV3 service = new GoogleServiceV3();
        JWT jwt = new JWT('259361316346-j6g8e0ij1e379c2q2kot9cce1d4u5ad1@developer.gserviceaccount.com');
        service.authenticate(jwt);
        accessToken = service.getToken();
    }
    
    public void checkPayment() {
        Payment__c record = SaferpayUtils.getPaymentByPaymentId(paymentId);
        record.PaymentDate__c = System.today();
        if(record != null) {
            if(SaferpayUtils.config.UseHttpsInterface__c) {
                system.debug(ApexPages.currentPage().getParameters());
                
                //update record fields
                String dataString = ApexPages.currentPage().getParameters().get('DATA');
                String dataSignature = ApexPages.currentPage().getParameters().get('SIGNATURE');
                //verify payment
                String saferpayVerify = Saferpay.httpsVerify(dataString, dataSignature, record);
                if(saferpayVerify != '') {
                    String verifyID = saferpayVerify.substringAfter('ID=').substringBefore('&TOKEN');
                    //confirm payment 
                    if(Saferpay.httpsConfirm(verifyID, record)) {
                        String msgType = dataString.substringAfter('MSGTYPE="').substringBefore('"');
                        if(String.isNotBlank(msgType)) {
                            this.tranzactionSucceded = 'YES';
                            String paymentMethodCode = dataString.substringAfter('PAYMENTMETHOD="').substringBefore('"');
                            if(msgType.equals('PayConfirm')){
                                record.TransactionStatus__c = 'Paid';
                                record.PaymentMethodCode__c = Integer.valueOf(paymentMethodCode);
                                SaferpayHelper.recordsToUpdate.add(record);
                                message = 'The transaction was captured';
                                severity = ApexPages.Severity.CONFIRM;
                                this.paidSuccessfully = 'YES';
                            }else if(msgType.equals('AuthorizationResponse')){
                                record.TransactionStatus__c = 'Pending';
                                record.PaymentMethodCode__c = Integer.valueOf(paymentMethodCode);
                                SaferpayHelper.recordsToUpdate.add(record);
                                message = 'The transaction was authorized';
                                severity = ApexPages.Severity.CONFIRM;
                            }
                        } else {
                            message = 'An error has occured. The details were saved and will be processed by an agent as soon as possible.';
                            severity = ApexPages.Severity.ERROR;
                        }
                    } else {
                        message = 'An error has occured. The details were saved and will be processed by an agent as soon as possible.';
                        severity = ApexPages.Severity.ERROR;
                    }
                } else {
                    message = 'An error has occured. The details were saved and will be processed by an agent as soon as possible.';
                    severity = ApexPages.Severity.ERROR;
                }
            } else {
                Saferpay.assertPayment(record);
                if(SaferpayHelper.recordsToUpdate[0].TransactionStatus__c == 'Pending') {
                    message = 'The transaction was authorized';
                    severity = ApexPages.Severity.CONFIRM;
                    Saferpay.captureTransaction(SaferpayHelper.recordsToUpdate[0]);
                }
                if(SaferpayHelper.recordsToUpdate[0].TransactionStatus__c == 'Paid') {
                    message = 'The transaction was captured';
                    severity = ApexPages.Severity.CONFIRM;
                    this.paidSuccessfully = 'YES';
                }
                if(!SaferpayHelper.errorList.isEmpty()) {
                    if(SaferpayHelper.errorList[0].Behavior__c == 'ABORT') {
                        message = 'The transaction was aborted';
                    } else {
                        message = 'An error has occured. The details were saved and will be processed by an agent as soon as possible.';
                    }
                    severity = ApexPages.Severity.ERROR;
                }
            }
            SaferpayHelper.performDML();
            //return new PageReference('https://my.medidate.de/register');
        } else {
            message = 'Incorrect payment id: ' + paymentId;
            severity = ApexPages.Severity.ERROR;
        }
        displayMessage(severity, message);
        //return null;
    }
    
    private void displayMessage(ApexPages.Severity severity, String message) {
        ApexPages.addMessage(new ApexPages.Message(severity, message));
    }
}