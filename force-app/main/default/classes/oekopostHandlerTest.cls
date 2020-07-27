@IsTest (seeAllData=false)
public class oekopostHandlerTest {
    static testMethod void oekopostTest1() {
        oekopostwebservice.OekopostWebServicePort serviceObj = new oekopostwebservice.OekopostWebServicePort();
        Test.startTest();
        Test.setMock(WebServiceMock.class, new WebServiceMockImpl.oekopostMock1());
        serviceObj.submitPDFLetter(null,null,null,null,null,null,null,null,null,null);
        Test.stopTest();
    }
    static testMethod void oekopostTest2() {
        oekopostwebservice.OekopostWebServicePort serviceObj = new oekopostwebservice.OekopostWebServicePort();
        Test.startTest();
        Test.setMock(WebServiceMock.class, new WebServiceMockImpl.oekopostMock2());
        serviceObj.getAccountBalance(null,null,null);
        Test.stopTest();
    }
    static testMethod void oekopostTest3() {
        oekopostwebservice.OekopostWebServicePort serviceObj = new oekopostwebservice.OekopostWebServicePort();
        Test.startTest();
        Test.setMock(WebServiceMock.class, new WebServiceMockImpl.oekopostMock3());
        serviceObj.checkAccountLogin(null,null,null);
        Test.stopTest();
    }
    static testMethod void oekopostTest4() {
        oekopostwebservice.OekopostWebServicePort serviceObj = new oekopostwebservice.OekopostWebServicePort();
        Test.startTest();
        Test.setMock(WebServiceMock.class, new WebServiceMockImpl.oekopostMock4());
        serviceObj.submitSMS(null,null,null,null,null,null,null,null);
        Test.stopTest();
    }
    static testMethod void oekopostTest5() {
        oekopostwebservice.getAccountBalanceRequest_element obj1 = new oekopostwebservice.getAccountBalanceRequest_element();
        oekopostwebservice.checkAccountLoginResponse_element obj2 = new oekopostwebservice.checkAccountLoginResponse_element();
        oekopostwebservice.getAccountBalanceResponse_element obj3 = new oekopostwebservice.getAccountBalanceResponse_element();
        oekopostwebservice.checkAccountLoginRequest_element obj4 = new oekopostwebservice.checkAccountLoginRequest_element();
        oekopostwebservice.submitPDFLetterRequest_element obj5 = new oekopostwebservice.submitPDFLetterRequest_element();
        oekopostwebservice.submitSMSRequest_element obj6 = new oekopostwebservice.submitSMSRequest_element();
        oekopostwebservice.submitSMSResponse_element obj7 = new oekopostwebservice.submitSMSResponse_element();
        oekopostwebservice.submitPDFLetterResponse_element obj8 = new oekopostwebservice.submitPDFLetterResponse_element();
    }
    
    static testMethod void oekopostTest6() {
        Oekopost__c credentials = TestObjectFactory.getOekopostCredentials(); insert credentials;
        Account customer = TestObjectFactory.getPersonAccount(); insert customer;
        Opportunity opportunity = TestObjectFactory.getOpportunity(customer.Id); insert opportunity;
        Payment__c payment = TestObjectFactory.getPayment(opportunity.Id); insert payment;
        
        oekopostHandler oh = new oekopostHandler();
        Test.startTest();
        oekopostHandler.sendPdf(Blob.valueOf('test'), payment.Id);
        Test.stopTest();
    }
    
    public static oekopostwebservice.submitPDFLetterResponse_element getResponse() {
        oekopostwebservice.submitPDFLetterResponse_element resp = new oekopostwebservice.submitPDFLetterResponse_element();
        resp.Status = 'Error';
        return resp;
    }
}