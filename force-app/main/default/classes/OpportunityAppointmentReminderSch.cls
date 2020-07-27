global class OpportunityAppointmentReminderSch implements Schedulable {
    public static final String CRON_EXPRESSION = '0 0 10 * * ? *';
    global void execute(SchedulableContext sc) {
        OpportunityAppointmentReminderBatch batchObject = new OpportunityAppointmentReminderBatch();
        Database.executeBatch(batchObject, 20);
    }
}