global class ClinicAppointmentArchivingBatch implements Database.Batchable<sObject>, Schedulable {
	private List<String> FIELDS_FOR_SELECT = new List<String> { 'Id' };
	private String SOBJECT_NAME = Clinic_Appointment__c.sObjectType.getDescribe().getName();
	private String query = 'SELECT {0} FROM {1} WHERE {2}';
	private static ClinicAppointmentBatch__c APPBATCH = ClinicAppointmentBatch__c.getOrgDefaults();
	private static String SCHEDULE_NAME = 'Clinic Appointment Archiving';

	global static void startScheduler() {
		String runScheduleTime = APPBATCH.Schedule_Time__c;
		System.debug(System.schedule(SCHEDULE_NAME, runScheduleTime, new ClinicAppointmentArchivingBatch()));
	}

	global static void stopScheduler() {
		CronTrigger existSchedule = [
			SELECT Id, CronJobDetailId
			FROM CronTrigger 
			WHERE CronJobDetailId IN (SELECT Id FROM CronJobDetail WHERE Name =:SCHEDULE_NAME ) LIMIT 1];
		System.abortJob(existSchedule.Id);
	}

	global void execute(SchedulableContext scMain){
		Database.executeBatch(new ClinicAppointmentArchivingBatch(),100);
	}

	global Database.QueryLocator start(Database.BatchableContext BC){
		Datetime startDateTime = APPBATCH.Start_Date__c;
		Datetime endDateTime = APPBATCH.End_Date__c;
		String conditions = 'CreatedDate >= :startDateTime AND CreatedDate <= :endDateTime';
		query = String.format(query, new List<String> { String.join(FIELDS_FOR_SELECT, ', '), SOBJECT_NAME, conditions });
		return Database.getQueryLocator(query);
	}

	global void execute(Database.BatchableContext BC, List<sObject> scope){
		delete scope;
		DataBase.emptyRecycleBin(scope);
	}

	global void finish(Database.BatchableContext BC){}
}