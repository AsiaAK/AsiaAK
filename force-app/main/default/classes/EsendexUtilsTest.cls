@isTest
private class EsendexUtilsTest {
    static testmethod void stripPhoneNumberTest() {
        System.Test.startTest();
            EsendexUtils.stripPhoneNumber('');
            EsendexUtils.stripPhoneNumber('449299922');
        System.Test.stopTest();
    }
}