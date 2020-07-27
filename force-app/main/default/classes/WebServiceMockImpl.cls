@isTest
global class WebServiceMockImpl {
    global class oekopostMock1 implements WebServiceMock{
        global void doInvoke(Object stub, Object request, Map<String, Object> response, String endpoint, String soapAction, String requestName, String responseNS, String responseName, String responseType) {
            response.put('response_x', new oekopostwebservice.submitPDFLetterResponse_element()); 
        }
    }
    global class oekopostMock2 implements WebServiceMock{
        global void doInvoke(Object stub, Object request, Map<String, Object> response, String endpoint, String soapAction, String requestName, String responseNS, String responseName, String responseType) {
            response.put('response_x', new oekopostwebservice.getAccountBalanceResponse_element()); 
        }
    }
    global class oekopostMock3 implements WebServiceMock{
        global void doInvoke(Object stub, Object request, Map<String, Object> response, String endpoint, String soapAction, String requestName, String responseNS, String responseName, String responseType) {
            response.put('response_x', new oekopostwebservice.checkAccountLoginResponse_element()); 
        }
    }
    global class oekopostMock4 implements WebServiceMock{
        global void doInvoke(Object stub, Object request, Map<String, Object> response, String endpoint, String soapAction, String requestName, String responseNS, String responseName, String responseType) {
            response.put('response_x', new oekopostwebservice.submitSMSResponse_element()); 
        }
    }
}