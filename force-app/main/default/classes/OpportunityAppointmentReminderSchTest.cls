@isTest
private class OpportunityAppointmentReminderSchTest {
    
    private static testmethod void testScheduledJob() {
        System.Test.startTest();
            String jobId = System.schedule('Test Appointment Reminder', OpportunityAppointmentReminderSch.CRON_EXPRESSION, new OpportunityAppointmentReminderSch());
        System.Test.stopTest();
        System.assertNotEquals(jobId, null);
    }
}