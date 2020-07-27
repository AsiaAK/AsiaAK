@RestResource(urlMapping='/SaferpayResult/*')
global with sharing class SaferpayService {
    @HttpGet
    global static void doGet() {
        String paymentId = RestContext.request.params.get('paymentId');
        Payment__c record = SaferpayUtils.getPaymentByPaymentId(paymentId);
        if(record != null) {
            Saferpay.assertPayment(record);
        }
    }
}