@isTest
private class JWTTest {
    static testmethod void controllerTest() {
        System.Test.startTest();
            JWT controller = new JWT();
            controller = new JWT('iss');
            controller.iss = controller.iss;
            controller.prn = 'prn';
            controller.prn = controller.prn;
            controller.scope = 'scope';
            controller.scope = controller.scope;
            controller.addScope('scope');
            controller.aud = 'aud';
            controller.aud = controller.aud;
            controller.iat = System.now();
            controller.iat = controller.iat;
            controller.exp = System.now();
            controller.exp = controller.exp;
            controller.toString();
            controller.getEncodedString();
            
            controller.sign(EncodingUtil.base64Decode(GoogleServiceV3.PRIVATE_KEY));
            controller.prn = null;
            controller.toString();
        System.Test.stopTest();
    }
}