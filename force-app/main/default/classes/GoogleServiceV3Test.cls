@isTest
private class GoogleServiceV3Test {
    static testmethod void controllerTest() {
        System.Test.setMock(HttpCalloutMock.class, new GoogleServiceV3HttpMockup(true));
        JWT jwtInstance = new JWT('iss');
        jwtInstance.prn = 'prn';
        System.Test.startTest();
            GoogleServiceV3 controller = new GoogleServiceV3();
            controller.authenticate(jwtInstance);
            controller.getTOken();
            GoogleServiceV3.AuthResponse response = new GoogleServiceV3.AuthResponse();
            String refreshToken = response.refresh_token;
            Long expiresIn = response.expires_in;
        System.Test.stopTest();
    }
}