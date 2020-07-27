@isTest
private class SaferpayTCaptureRequestTest {
    static testmethod void controllerTest() {
        System.Test.startTest();
            SaferpayTCaptureRequest obj = new SaferpayTCaptureRequest();
            obj.RequestHeader = new SaferpayTCaptureRequest.RequestHeader();
            obj.TransactionReference = new SaferpayTCaptureRequest.TransactionReference();
        System.Test.stopTest();
    }
}