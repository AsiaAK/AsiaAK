public with sharing class MDDayRepetitionRuleTriggerService {

	public static void createMdDaysOnInsert(List<MDDayRepetitionRule__c> newMDDayRepetitionRules, Map<Id, MDDayRepetitionRule__c> newMDDayRepetitionRulesMap) {
        Map<Id, MDDayRepetitionRule__c> mdDayRepetitionRulesMap = new Map<Id, MDDayRepetitionRule__c>();

        for (MDDayRepetitionRule__c newMDDayRepetitionRule : newMDDayRepetitionRules) {
            if (!mdDayRepetitionRulesMap.containsKey(newMDDayRepetitionRule.MDDay__c)) {
                mdDayRepetitionRulesMap.put(newMDDayRepetitionRule.MDDay__c, newMDDayRepetitionRule);
            }
        }
        System.debug(JSON.serializePretty(mdDayRepetitionRulesMap));

        Map<Id, MD_Day__c> mdDaysMap = new Map<Id, MD_Day__c>([
                SELECT Id,
                    Date__c,
                    Operation_Day_Start_Time__c,
                    Operation_Day_End_Time__c,
                    MD_Day_Location__c,
                    Surgeon_Clinic__c,
                    Total_available_Operation_Time_Minutes__c,
                    RecordTypeId,
                    RecordType.DeveloperName
                FROM MD_Day__c
                WHERE Id IN :mdDayRepetitionRulesMap.keySet()
        ]);
        System.debug(JSON.serializePretty(mdDaysMap));

        Map<Id, List<MD_Day__c>> mdDayRepetitionDaysMap = new Map<Id, List<MD_Day__c>>();

        for (MD_Day__c mdDay : mdDaysMap.values()) {
            if (mdDayRepetitionRulesMap.containsKey(mdDay.Id)) {
                MDDayRepetitionRule__c mdDayRepetitionRule = mdDayRepetitionRulesMap.get(mdDay.Id);
                System.debug(JSON.serializePretty(mdDayRepetitionRule));

                mdDayRepetitionDaysMap.put(mdDayRepetitionRule.Id, new List<MD_Day__c>());

                Set<String> repetionDaysOfWeek = new Set<String>{
                    mdDayRepetitionRule.Monday__c ? '1' : '',
                    mdDayRepetitionRule.Tuesday__c ? '2' : '',
                    mdDayRepetitionRule.Wednesday__c ? '3' : '',
                    mdDayRepetitionRule.Thursday__c ? '4' : '',
                    mdDayRepetitionRule.Friday__c ? '5' : '',
                    mdDayRepetitionRule.Saturday__c ? '6' : '',
                    mdDayRepetitionRule.Sunday__c ? '7' : ''
                };
                repetionDaysOfWeek.remove('');
                System.debug(JSON.serializePretty(repetionDaysOfWeek));

                if (!repetionDaysOfWeek.isEmpty()) {
                    Integer frequency = String.isNotBlank(mdDayRepetitionRule.RepeatEvery__c)
                            ? Integer.valueOf(mdDayRepetitionRule.RepeatEvery__c)
                            : 0;

                    if (frequency > 0) {
                        Date startDate = mdDay.Date__c
                                .addDays(8 - Integer.valueOf(((DateTime) mdDay.Date__c).format('u')))
                                .addDays(7 * (frequency - 1));

                        while (startDate < mdDayRepetitionRule.RepeatTill__c) {
                            DateTime startDateTime = startDate;
                            String dayOfWeek = startDateTime.format('u');

                            if (repetionDaysOfWeek.contains(dayOfWeek)) {
                                MD_Day__c newMdDay = new MD_Day__c();
                                newMdDay.Date__c = startDate;
                                newMdDay.Operation_Day_Start_Time__c = DateTime.newInstance(
                                        startDate,
                                        Time.newInstance(
                                                mdDay.Operation_Day_Start_Time__c.hour(),
                                                mdDay.Operation_Day_Start_Time__c.minute(),
                                                mdDay.Operation_Day_Start_Time__c.second(),
                                                mdDay.Operation_Day_Start_Time__c.millisecond()
                                        )
                                );
                                newMdDay.Operation_Day_End_Time__c = DateTime.newInstance(
                                        startDate,
                                        Time.newInstance(
                                                mdDay.Operation_Day_End_Time__c.hour(),
                                                mdDay.Operation_Day_End_Time__c.minute(),
                                                mdDay.Operation_Day_End_Time__c.second(),
                                                mdDay.Operation_Day_End_Time__c.millisecond()
                                        )
                                );
                                newMdDay.MD_Day_Location__c = mdDay.MD_Day_Location__c;
                                newMdDay.Surgeon_Clinic__c = mdDay.Surgeon_Clinic__c;
                                newMdDay.Total_available_Operation_Time_Minutes__c = mdDay.Total_available_Operation_Time_Minutes__c;
                                newMdDay.RecordTypeId = mdDay.RecordTypeId;

                                mdDayRepetitionDaysMap.get(mdDayRepetitionRule.Id).add(newMdDay);

                                if (mdDayRepetitionDaysMap.get(mdDayRepetitionRule.Id).size() > 20) {
                                    mdDayRepetitionRule.addError(
                                            'You are trying to insert more than 20 md days!'
                                    );
                                }
                            }

                            if (dayOfWeek == '7') {
                                startDate = frequency == 1
                                        ? startDate.addDays(1)
                                        : startDate.addDays(1).addDays(7 * (frequency - 1));
                            } else {
                                startDate = startDate.addDays(1);
                            }
                        }
                    }
                }
            }
        }
        System.debug(JSON.serializePretty(mdDayRepetitionDaysMap));

        List<MD_Day__c> newMDDays = new List<MD_Day__c>();

        for (List<MD_Day__c> mdDayRepetitionDays : mdDayRepetitionDaysMap.values()) {
            newMDDays.addAll(mdDayRepetitionDays);
        }

        insert newMDDays;
	}

}