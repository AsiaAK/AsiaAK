/**
 * MdDayTriggerService class 1.0.0
 *
 * @description This class represents a MdDayTriggerService.
 *
 * @author Nadezhda Podobed
 * @date 19.03.2019
 */
public with sharing class MdDayTriggerService {

    private static Map<String, Set<Id>> processedRecordIds = new Map<String, Set<Id>>();

	public static void createAvailabilitiesOnInsert(List<MD_Day__c> newMdDays, Map<Id, MD_Day__c> newMdDaysMap) {
        if (Userinfo.getUserName() != CalendarManagerSetting__c.getOrgDefaults().IgnoredUserName__c) {
            List<Clinic_Appointment__c> availabilities = new List<Clinic_Appointment__c>();

            List<Clinic_Appointment__c> preExAvailabilities = createPreExAvailabilities(newMdDays, newMdDaysMap);

            List<Clinic_Appointment__c> operationAvailabilities = createOperationAvailabilities(newMdDays, newMdDaysMap);

            availabilities.addAll(removeAvailabilityDuplicates(preExAvailabilities, operationAvailabilities));

            TriggerFactory.disable(Clinic_Appointment__c.sObjectType);

            insert availabilities;

            TriggerFactory.enable(Clinic_Appointment__c.sObjectType);
        }
	}

    public static void checkPreExDaysLocation(List<MD_Day__c> newMdDays) {
        if (Userinfo.getUserName() != CalendarManagerSetting__c.getOrgDefaults().IgnoredUserName__c) {
            Id preExMdDateRecordtypeId = Schema.SObjectType.MD_Day__c.getRecordTypeInfosByDeveloperName().get('MD_Pre_Ex_Day').getRecordTypeId();
            Id mdDateRecordtypeId = Schema.SObjectType.MD_Day__c.getRecordTypeInfosByDeveloperName().get('MD_Operation_Day').getRecordTypeId();
    
            System.debug(preExMdDateRecordtypeId);
            System.debug(mdDateRecordtypeId);
            for (MD_Day__c mdDay : newMdDays) {
                if (mdDay.RecordTypeId == preExMdDateRecordtypeId
                        && mdDay.Operation_Day_Start_Time__c != null
                        && mdDay.Operation_Day_End_Time__c != null          
                        && mdDay.Operation_Day_Start_Time__c.date() == mdDay.Date__c
                        && mdDay.Operation_Day_End_Time__c.date() ==  mdDay.Date__c
                        && mdDay.MD_Day_Location__c == null) {
                    mdDay.addError('Location should be specified on Pre-Ex Md Day!');
                }
                if ((mdDay.RecordTypeId == preExMdDateRecordtypeId) || (mdDay.RecordTypeId == mdDateRecordtypeId)
                    && mdDay.Operation_Day_Start_Time__c != null
                    && mdDay.Operation_Day_End_Time__c != null
                    && mdDay.Operation_Day_Start_Time__c.date() == mdDay.Date__c
                    && mdDay.Operation_Day_End_Time__c.date() ==  mdDay.Date__c) {
                        mdDay.Status__c = 'Open';
                }
            }    
        }
    }

    public static void checkDuplicatesOnInsert(List<MD_Day__c> newMdDays) {
        if (Userinfo.getUserName() != CalendarManagerSetting__c.getOrgDefaults().IgnoredUserName__c) {
            List<MD_Day__c> validMdDays = new List<MD_Day__c>();

            for (MD_Day__c newMdDay : newMdDays) {
                if (!isRecordProcessed('checkDuplicatesOnInsert', newMdDay.Id)) {
                    if (newMdDay.Operation_Day_Start_Time__c != null && newMdDay.Operation_Day_End_Time__c != null) {
                        validMdDays.add(newMdDay);
                    }
                }
            }
            System.debug(JSON.serializePretty(validMdDays));

            checkDuplicates(validMdDays);
        }
    }

    private static void checkDuplicates(List<MD_Day__c> validMdDays) {
        Id preExMdDayId = Schema.SObjectType.MD_Day__c.getRecordTypeInfosByDeveloperName().get('MD_Pre_Ex_Day').getRecordTypeId();
        System.debug('test');

        if (!validMdDays.isEmpty()) {
            Set<Id> clinicIds = new Set<Id>();

            Set<Date> operationDates = new Set<Date>();

            for (MD_Day__c validMdDay : validMdDays) {
                clinicIds.add(validMdDay.Surgeon_Clinic__c);

                operationDates.add(validMdDay.Operation_Day_Start_Time__c.date());
                operationDates.add(validMdDay.Operation_Day_End_Time__c.date());
            }

            List<MD_Day__c> existedMdDays = getExistedMdDays(clinicIds, operationDates);
            System.debug(JSON.serializePretty(existedMdDays));

            Map<Id, Map<Date, List<MD_Day__c>>> existedClinicDateMdDaysMap = new Map<Id, Map<Date, List<MD_Day__c>>>();

            for (MD_Day__c existedMdDay : existedMdDays) {
                if (!existedClinicDateMdDaysMap.containsKey(existedMdDay.Surgeon_Clinic__c)) {
                    existedClinicDateMdDaysMap.put(
                        existedMdDay.Surgeon_Clinic__c,
                        new Map<Date, List<MD_Day__c>>()
                    );
                }

                if (!existedClinicDateMdDaysMap.get(existedMdDay.Surgeon_Clinic__c).containsKey(existedMdDay.Operation_Day_Start_Time__c.date())) {
                    existedClinicDateMdDaysMap.get(existedMdDay.Surgeon_Clinic__c).put(
                        existedMdDay.Operation_Day_Start_Time__c.date(),
                        new List<MD_Day__c>()
                    );
                }

                existedClinicDateMdDaysMap.get(existedMdDay.Surgeon_Clinic__c)
                        .get(existedMdDay.Operation_Day_Start_Time__c.date())
                        .add(existedMdDay);
            }
            
            for (MD_Day__c validMdDay : validMdDays) {
                if (existedClinicDateMdDaysMap.containsKey(validMdDay.Surgeon_Clinic__c)
                        && preExMdDayId != validMdDay.RecordTypeId
                        && existedClinicDateMdDaysMap.get(validMdDay.Surgeon_Clinic__c).containsKey(validMdDay.Operation_Day_Start_Time__c.date())) {
                    List<MD_Day__c> existedClinicDateMdDays = existedClinicDateMdDaysMap.get(validMdDay.Surgeon_Clinic__c)
                            .get(validMdDay.Operation_Day_Start_Time__c.date());
                    System.debug(JSON.serializePretty(existedClinicDateMdDays));

                    Map<Id, MD_Day__c> duplicates = getDuplicates(validMdDay, existedClinicDateMdDays);

                    if (!duplicates.isEmpty()) {
                        for (Id duplicateId : duplicates.keySet()) {
                            validMdDay.addError('You have duplicates for Md day starting from ' + (duplicates.get(duplicateId).Operation_Day_Start_Time__c).format('dd.MM.yyyy h:mm a') + ' till ' + (duplicates.get(duplicateId).Operation_Day_End_Time__c).format('dd.MM.yyyy h:mm a'));
                        }
                    }
                }
            }
        }
    }

    private static Map<Id, MD_Day__c> getDuplicates(MD_Day__c validMdDay, List<MD_Day__c> existedClinicDateMdDays) {
        Map<Id, MD_Day__c> duplicates = new Map<Id, MD_Day__c>();

        if (validMdDay != null && !existedClinicDateMdDays.isEmpty()) {
            for (MD_Day__c existedClinicDateMdDay : existedClinicDateMdDays) {
                if (validMdDay.Id != existedClinicDateMdDay.Id) {
                    if (validMdDay.Operation_Day_Start_Time__c == existedClinicDateMdDay.Operation_Day_Start_Time__c
                            || validMdDay.Operation_Day_End_Time__c == existedClinicDateMdDay.Operation_Day_End_Time__c) {
                        duplicates.put(existedClinicDateMdDay.Id, existedClinicDateMdDay);
                    }

                    if (validMdDay.Operation_Day_Start_Time__c > existedClinicDateMdDay.Operation_Day_Start_Time__c
                            && validMdDay.Operation_Day_Start_Time__c < existedClinicDateMdDay.Operation_Day_End_Time__c) {
                        duplicates.put(existedClinicDateMdDay.Id, existedClinicDateMdDay);
                    }

                    if (validMdDay.Operation_Day_End_Time__c > existedClinicDateMdDay.Operation_Day_Start_Time__c
                            && validMdDay.Operation_Day_End_Time__c < existedClinicDateMdDay.Operation_Day_End_Time__c) {
                        duplicates.put(existedClinicDateMdDay.Id, existedClinicDateMdDay);
                    }

                    if (validMdDay.Operation_Day_Start_Time__c < existedClinicDateMdDay.Operation_Day_Start_Time__c
                            && validMdDay.Operation_Day_End_Time__c > existedClinicDateMdDay.Operation_Day_End_Time__c) {
                        duplicates.put(existedClinicDateMdDay.Id, existedClinicDateMdDay);
                    }
                }
            }
        }

        return duplicates;
    }

    private static List<MD_Day__c> getExistedMdDays(Set<Id> clinicIds, Set<Date> operationDates) {
        List<MD_Day__c> existedMdDays = new List<MD_Day__c>();

        if (!clinicIds.isEmpty() && !operationDates.isEmpty()) {
            Set<String> recordQueryFields = new Set<String>{
                    SObjectType.MD_Day__c.fields.Id.Name,
                    SObjectType.MD_Day__c.fields.Surgeon_Clinic__c.Name,
                    SObjectType.MD_Day__c.fields.Operation_Day_Start_Time__c.Name,
                    SObjectType.MD_Day__c.fields.Operation_Day_End_Time__c.Name
            };

            List<String> conditions = new List<String>();

            conditions.add(QueryService.getCondition(
                    SObjectType.MD_Day__c.fields.Surgeon_Clinic__c.Name,
                    'IN',
                    ':clinicIds',
                    false
            ));

            conditions.add(QueryService.getCondition(
                    'DAY_ONLY(' + SObjectType.MD_Day__c.fields.Operation_Day_Start_Time__c.Name + ')',
                    'IN',
                    ':operationDates',
                    false
            ));

            conditions.add(QueryService.getCondition(
                    'DAY_ONLY(' + SObjectType.MD_Day__c.fields.Operation_Day_End_Time__c.Name + ')',
                    'IN',
                    ':operationDates',
                    false
            ));

            String whereConditions = String.join(conditions, ' AND ');

            String recordsQueryString = new SOQLQuery.Builder()
                    .setSelectToken(
                            new SOQLSelect.Builder()
                                    .setObject(SObjectType.MD_Day__c.Name)
                                    .setRequiredFields(recordQueryFields)
                                    .build()
                    )
                    .setObject(SObjectType.MD_Day__c.Name)
                    .setWhereConditions(whereConditions)
                    .setQueryLimit(String.valueOf(50000))
                    .build()
                    .toString();
            System.debug(recordsQueryString);

            if (String.isNotBlank(recordsQueryString)) {
                existedMdDays = Database.query(recordsQueryString);
            }
        }

        return existedMdDays;
    }

    private static List<Clinic_Appointment__c> createPreExAvailabilities(List<MD_Day__c> newMdDays, Map<Id, MD_Day__c> newMdDaysMap) {
        List<Clinic_Appointment__c> preExClinicAppointments = new List<Clinic_Appointment__c>();

		Map<Id, MD_Day__c> preExMdDatesMap = new Map<Id, MD_Day__c>();

        Map<Id, List<MD_Day__c>> accountPreExMdDates = new Map<Id, List<MD_Day__c>>();

        List<Date> preExMdDateMonths = new List<Date>();

		Id preExMdDateRecordtypeId = Schema.SObjectType.MD_Day__c.getRecordTypeInfosByDeveloperName().get('MD_Pre_Ex_Day').getRecordTypeId();

        Id preExAppointmentCounter = Schema.SObjectType.Appointment_Counter__c.getRecordTypeInfosByDeveloperName().get('Pre_Ex_Counter').getRecordTypeId();

        for (MD_Day__c mdDay : newMdDays) {
			if (mdDay.RecordTypeId == preExMdDateRecordtypeId 
                    && mdDay.Surgeon_Clinic__c != null
                    && mdDay.Operation_Day_Start_Time__c != null
                    && mdDay.Operation_Day_End_Time__c != null
                    && mdDay.Operation_Day_Start_Time__c.date() ==  mdDay.Date__c
                    && mdDay.Operation_Day_End_Time__c.date() ==  mdDay.Date__c) {
				preExMdDatesMap.put(mdDay.Id, mdDay);

                if (!accountPreExMdDates.containsKey(mdDay.Surgeon_Clinic__c)) {
                    accountPreExMdDates.put(mdDay.Surgeon_Clinic__c, new List<MD_Day__c>());
                }

                accountPreExMdDates.get(mdDay.Surgeon_Clinic__c).add(mdDay);

                preExMdDateMonths.add(mdDay.Date__c);
			}
		}

        if (!preExMdDatesMap.isEmpty()) {
            Map<Id, Account> preExMdDateAccountsMap = new Map<Id, Account>([
                SELECT PreExAppointmentsDuration__c,
                       GhostingFrequency__c,
                       Name
                FROM Account 
                WHERE Id IN :accountPreExMdDates.keySet()
            ]);
            System.debug(JSON.serializePretty(preExMdDateAccountsMap));

            preExMdDateMonths.sort();

            Date minMonth = preExMdDateMonths.get(0).toStartOfMonth();

            Date maxMonth = preExMdDateMonths.get(preExMdDateMonths.size() - 1).toStartOfMonth().addMonths(1);

            List<Appointment_Counter__c> preExMdDateAccountCounters = [
                SELECT Id,
                       Surgeon__c,
                       Appointment_Month__c
                FROM Appointment_Counter__c
                WHERE Surgeon__c IN :accountPreExMdDates.keySet()
                    AND Appointment_Month__c >= :minMonth
                    AND Appointment_Month__c < :maxMonth
                    AND RecordTypeId = :preExAppointmentCounter
            ];
            System.debug(JSON.serializePretty(preExMdDateAccountCounters));

            Map<Id, Map<Date, Appointment_Counter__c>> preExMdDateAccountCountersInBaseMap = new Map<Id, Map<Date, Appointment_Counter__c>>();

            for (Appointment_Counter__c preExMdDateAccountCounterInBase : preExMdDateAccountCounters) {
                if (!preExMdDateAccountCountersInBaseMap.containsKey(preExMdDateAccountCounterInBase.Surgeon__c)) {
                    preExMdDateAccountCountersInBaseMap.put(preExMdDateAccountCounterInBase.Surgeon__c, new Map<Date, Appointment_Counter__c>());
                }

                preExMdDateAccountCountersInBaseMap.get(preExMdDateAccountCounterInBase.Surgeon__c).put(
                    preExMdDateAccountCounterInBase.Appointment_Month__c.toStartOfMonth(),
                    preExMdDateAccountCounterInBase
                );
            }
            System.debug(JSON.serializePretty(preExMdDateAccountCountersInBaseMap));

            Map<Id, Set<Date>> newPreExMdDateAccountCounterMonths = new Map<Id, Set<Date>>();

            List<Appointment_Counter__c> newPreExMdDateAccountCounters = new List<Appointment_Counter__c>();

            Id preExMdDateAccountCounterRecordtypeId = Schema.SObjectType.Appointment_Counter__c.getRecordTypeInfosByDeveloperName().get('Pre_Ex_Counter').getRecordTypeId();

            for (Id accountId : accountPreExMdDates.keySet()) {
                for (MD_Day__c preExMdDate : accountPreExMdDates.get(accountId)) {
                    if (!preExMdDateAccountCountersInBaseMap.containsKey(accountId)) {
                        preExMdDateAccountCountersInBaseMap.put(accountId, new Map<Date, Appointment_Counter__c>());
                    }

                    if (!newPreExMdDateAccountCounterMonths.containsKey(accountId)) {
                        newPreExMdDateAccountCounterMonths.put(accountId, new Set<Date>());
                    }

                    if (!preExMdDateAccountCountersInBaseMap.get(accountId).containsKey(preExMdDate.Date__c.toStartOfMonth())
                            && !newPreExMdDateAccountCounterMonths.get(accountId).contains(preExMdDate.Date__c.toStartOfMonth())) {
                        Appointment_Counter__c newPreExMdDateAccountCounter = new Appointment_Counter__c();
                        newPreExMdDateAccountCounter.Surgeon__c = accountId;
                        newPreExMdDateAccountCounter.Name = 'Pre-Ex - ' +  preExMdDateAccountsMap.get(preExMdDate.Surgeon_Clinic__c).Name + ' - ' + preExMdDate.Date__c.month() + '.' + preExMdDate.Date__c.year();
                        newPreExMdDateAccountCounter.Appointment_Month__c = preExMdDate.Date__c.toStartOfMonth();
                        newPreExMdDateAccountCounter.Appointment_Counter_Matching__c = newPreExMdDateAccountCounter.Name + ' ' + String.valueOf(DateTime.now().getTime());
                        newPreExMdDateAccountCounter.RecordTypeId = preExMdDateAccountCounterRecordtypeId;
                        newPreExMdDateAccountCounters.add(newPreExMdDateAccountCounter);
                        newPreExMdDateAccountCounterMonths.get(accountId).add(preExMdDate.Date__c.toStartOfMonth());
                    }
                }
            }

            if (!newPreExMdDateAccountCounters.isEmpty()) {
                System.debug(JSON.serializePretty(newPreExMdDateAccountCounters));
                insert newPreExMdDateAccountCounters;

                for (Appointment_Counter__c newPreExMdDateAccountCounter : newPreExMdDateAccountCounters) {
                    preExMdDateAccountCountersInBaseMap.get(newPreExMdDateAccountCounter.Surgeon__c).put(
                        newPreExMdDateAccountCounter.Appointment_Month__c.toStartOfMonth(),
                        newPreExMdDateAccountCounter
                    );
                }
            }

            for (MD_Day__c preExMdDate : preExMdDatesMap.values()) {
                preExClinicAppointments.addAll(createPreExMdDateClinicAppointments(
                    preExMdDate,
                    preExMdDateAccountsMap.get(preExMdDate.Surgeon_Clinic__c),
                    preExMdDateAccountCountersInBaseMap.get(preExMdDate.Surgeon_Clinic__c).get(preExMdDate.Date__c.toStartOfMonth())
                ));
            }
            System.debug(JSON.serializePretty(preExClinicAppointments));
            System.debug(preExClinicAppointments.size());
        }

        return preExClinicAppointments;
    }

    private static List<Clinic_Appointment__c> createOperationAvailabilities(List<MD_Day__c> newMdDays, Map<Id, MD_Day__c> newMdDaysMap) {
		List<Clinic_Appointment__c> operationClinicAppointments = new List<Clinic_Appointment__c>();

		Map<Id, MD_Day__c> operationMdDatesMap = new Map<Id, MD_Day__c>();

        Map<Id, List<MD_Day__c>> accountOperationMdDates = new Map<Id, List<MD_Day__c>>();

        Map<Id, List<MD_Day__c>> locationTypesMdDates = new Map<Id, List<MD_Day__c>>();

        List<Date> operationMdDateMonths = new List<Date>();

		Id operationMdDateRecordtypeId = Schema.SObjectType.MD_Day__c.getRecordTypeInfosByDeveloperName().get('MD_Operation_Day').getRecordTypeId();

		Id operationMdDateLocationRecordtypeId = Schema.SObjectType.MD_Day_Location__c.getRecordTypeInfosByDeveloperName().get('Operation_Location').getRecordTypeId();

        Id operationAppointmentCounter = Schema.SObjectType.Appointment_Counter__c.getRecordTypeInfosByDeveloperName().get('Operation_Appointment_Counter').getRecordTypeId();

        for (MD_Day__c mdDay : newMdDays) {
			if (mdDay.RecordTypeId == operationMdDateRecordtypeId 
                    && mdDay.Surgeon_Clinic__c != null
                    && mdDay.Operation_Day_Start_Time__c != null
                    && mdDay.Operation_Day_End_Time__c != null
                    && mdDay.Operation_Day_End_Time__c.date() ==  mdDay.Date__c
                    && mdDay.Operation_Day_Start_Time__c.date() == mdDay.Date__c
                    && mdDay.MD_Day_Location__c != null) {
				operationMdDatesMap.put(mdDay.Id, mdDay);

                if (!accountOperationMdDates.containsKey(mdDay.Surgeon_Clinic__c)) {
                    accountOperationMdDates.put(mdDay.Surgeon_Clinic__c, new List<MD_Day__c>());
                }

                accountOperationMdDates.get(mdDay.Surgeon_Clinic__c).add(mdDay);

                operationMdDateMonths.add(mdDay.Date__c);

                if (!locationTypesMdDates.containsKey(mdDay.MD_Day_Location__c)) {
                    locationTypesMdDates.put(mdDay.MD_Day_Location__c, new List<MD_Day__c>());
                }
                
                locationTypesMdDates.get(mdDay.MD_Day_Location__c).add(mdDay);
			}
		}

        if (!operationMdDatesMap.isEmpty()) {
            Map<Id, Account> operationMdDateAccountsMap = new Map<Id, Account>([
                SELECT Id,
                       Name
                FROM Account 
                WHERE Id IN :accountOperationMdDates.keySet()
            ]);
            System.debug(JSON.serializePretty(operationMdDateAccountsMap));

            operationMdDateMonths.sort();

            Date minMonth = operationMdDateMonths.get(0).toStartOfMonth();

            Date maxMonth = operationMdDateMonths.get(operationMdDateMonths.size() - 1).toStartOfMonth().addMonths(1);

            Map<Id, MD_Day_Location__c> mdDateLocationTypesMap = new Map<Id, MD_Day_Location__c>([
                SELECT Id,
                       ClinicLocation__c
                FROM MD_Day_Location__c
                WHERE Id IN :locationTypesMdDates.keySet()
            ]);
            System.debug(JSON.serializePretty(mdDateLocationTypesMap));

            List<Appointment_Counter__c> operationMdDateAccountCounters = [
                SELECT Id,
                       Surgeon__c,
                       Appointment_Month__c
                FROM Appointment_Counter__c
                WHERE Surgeon__c IN :accountOperationMdDates.keySet()
                    AND Appointment_Month__c >= :minMonth
                    AND Appointment_Month__c < :maxMonth
                    AND RecordTypeId = :operationAppointmentCounter
            ];
            System.debug(JSON.serializePretty(operationMdDateAccountCounters));

            Map<Id, Map<Date, Appointment_Counter__c>> operationMdDateAccountCountersInBaseMap = new Map<Id, Map<Date, Appointment_Counter__c>>();

            for (Appointment_Counter__c operationMdDateAccountCounterInBase : operationMdDateAccountCounters) {
                if (!operationMdDateAccountCountersInBaseMap.containsKey(operationMdDateAccountCounterInBase.Surgeon__c)) {
                    operationMdDateAccountCountersInBaseMap.put(operationMdDateAccountCounterInBase.Surgeon__c, new Map<Date, Appointment_Counter__c>());
                }

                operationMdDateAccountCountersInBaseMap.get(operationMdDateAccountCounterInBase.Surgeon__c).put(
                    operationMdDateAccountCounterInBase.Appointment_Month__c.toStartOfMonth(),
                    operationMdDateAccountCounterInBase
                );
            }
            System.debug(JSON.serializePretty(operationMdDateAccountCountersInBaseMap));

            List<Appointment_Counter__c> newOperationMdDateAccountCounters = new List<Appointment_Counter__c>();

            Id operationMdDateAccountCounterRecordtypeId = Schema.SObjectType.Appointment_Counter__c.getRecordTypeInfosByDeveloperName().get('Operation_Appointment_Counter').getRecordTypeId();

            for (Id accountId : accountOperationMdDates.keySet()) {
                for (MD_Day__c operationMdDate : accountOperationMdDates.get(accountId)) {
                    if (!operationMdDateAccountCountersInBaseMap.containsKey(accountId)) {
                        operationMdDateAccountCountersInBaseMap.put(accountId, new Map<Date, Appointment_Counter__c>());
                    }

                    if (!operationMdDateAccountCountersInBaseMap.get(accountId).containsKey(operationMdDate.Date__c.toStartOfMonth())) {
                        Appointment_Counter__c newOperationMdDateAccountCounter = new Appointment_Counter__c();
                        newOperationMdDateAccountCounter.Surgeon__c = accountId;
                        newOperationMdDateAccountCounter.Name = 'Operation - ' +  operationMdDateAccountsMap.get(operationMdDate.Surgeon_Clinic__c).Name + ' - ' + operationMdDate.Date__c.month() + '.' + operationMdDate.Date__c.year();
                        newOperationMdDateAccountCounter.Appointment_Month__c = operationMdDate.Date__c.toStartOfMonth();
                        newOperationMdDateAccountCounter.Appointment_Counter_Matching__c = String.valueOf(DateTime.now().getTime());
                        newOperationMdDateAccountCounter.RecordTypeId = operationMdDateAccountCounterRecordtypeId;

                        newOperationMdDateAccountCounters.add(newOperationMdDateAccountCounter);
                    }
                }
            }

            if (!newOperationMdDateAccountCounters.isEmpty()) {
                System.debug(newOperationMdDateAccountCounters);
                insert newOperationMdDateAccountCounters;

                for (Appointment_Counter__c newOperationMdDateAccountCounter : newOperationMdDateAccountCounters) {
                    operationMdDateAccountCountersInBaseMap.get(newOperationMdDateAccountCounter.Surgeon__c).put(
                        newOperationMdDateAccountCounter.Appointment_Month__c.toStartOfMonth(),
                        newOperationMdDateAccountCounter
                    );
                }
            }

            for (MD_Day__c operationMdDate : operationMdDatesMap.values()) {
                operationClinicAppointments.addAll(createOperationMdDateClinicAppointments(
                    operationMdDate,
                    operationMdDateAccountsMap.get(operationMdDate.Surgeon_Clinic__c),
                    mdDateLocationTypesMap.get(operationMdDate.MD_Day_Location__c),
                    operationMdDateAccountCountersInBaseMap.get(operationMdDate.Surgeon_Clinic__c).get(operationMdDate.Date__c.toStartOfMonth())
                ));
            }
            System.debug(JSON.serializePretty(operationClinicAppointments));
            System.debug(operationClinicAppointments.size());        
        }

        return operationClinicAppointments;
    }

    private static List<Clinic_Appointment__c> removeAvailabilityDuplicates(List<Clinic_Appointment__c> preExAvailabilities, List<Clinic_Appointment__c> operationAvailabilities) {
        List<Clinic_Appointment__c> availabilities = new List<Clinic_Appointment__c>();

        List<Clinic_Appointment__c> newAvailabilities = new List<Clinic_Appointment__c>();
        newAvailabilities.addAll(preExAvailabilities);
        newAvailabilities.addAll(operationAvailabilities);
        System.debug(JSON.serializePretty(newAvailabilities));

        if (!newAvailabilities.isEmpty()) {
            Set<Id> clinicIds = new Set<Id>();

            Set<Date> availabilityDates = new Set<Date>();

            for (Clinic_Appointment__c newAvailability : newAvailabilities) {
                clinicIds.add(newAvailability.Clinic__c);

                availabilityDates.add(newAvailability.CS_Start_Date__c.date());
                availabilityDates.add(newAvailability.CS_End_Date__c.date());
            }

            List<Clinic_Appointment__c> existedAvailabilities = getExistedAvailabilities(clinicIds, availabilityDates);
            System.debug(JSON.serializePretty(existedAvailabilities));

            Map<Id, Map<Date, List<Clinic_Appointment__c>>> existedClinicDateAvailabilitiesMap = new Map<Id, Map<Date, List<Clinic_Appointment__c>>>();

            for (Clinic_Appointment__c existedAvailability : existedAvailabilities) {
                if (!existedClinicDateAvailabilitiesMap.containsKey(existedAvailability.Clinic__c)) {
                    existedClinicDateAvailabilitiesMap.put(existedAvailability.Clinic__c, new Map<Date, List<Clinic_Appointment__c>>());
                }

                if (!existedClinicDateAvailabilitiesMap.get(existedAvailability.Clinic__c).containsKey(existedAvailability.CS_Start_Date__c.date())) {
                    existedClinicDateAvailabilitiesMap.get(existedAvailability.Clinic__c).put(existedAvailability.CS_Start_Date__c.date(), new List<Clinic_Appointment__c>());
                }

                existedClinicDateAvailabilitiesMap.get(existedAvailability.Clinic__c).get(existedAvailability.CS_Start_Date__c.date()).add(existedAvailability);
            }
            System.debug(JSON.serializePretty(existedClinicDateAvailabilitiesMap));

            List<Clinic_Appointment__c> newAvailabilitiesWithoutDuplicates = new List<Clinic_Appointment__c>();

            for (Clinic_Appointment__c newAvailability : newAvailabilities) {
                if (!existedClinicDateAvailabilitiesMap.containsKey(newAvailability.Clinic__c)) {
                    newAvailabilitiesWithoutDuplicates.add(newAvailability);
                } else {
                    if (!existedClinicDateAvailabilitiesMap.get(newAvailability.Clinic__c).containsKey(newAvailability.CS_Start_Date__c.date())) {
                        newAvailabilitiesWithoutDuplicates.add(newAvailability);
                    } else {
                        List<Clinic_Appointment__c> existedClinicDateAvailabilities = existedClinicDateAvailabilitiesMap.get(newAvailability.Clinic__c).get(newAvailability.CS_Start_Date__c.date());

                        Boolean hasDuplicates = checkDuplicates(newAvailability, existedClinicDateAvailabilities);

                        if (!hasDuplicates) {
                            newAvailabilitiesWithoutDuplicates.add(newAvailability);
                        }
                    }
                }
            }
            System.debug(JSON.serializePretty(newAvailabilitiesWithoutDuplicates));

            availabilities = newAvailabilitiesWithoutDuplicates;
        }

        return availabilities;
    }

    private static Boolean checkDuplicates(Clinic_Appointment__c newAvailability, List<Clinic_Appointment__c> existedClinicDateAvailabilities) {
        Boolean hasDuplicates = false;

        if (newAvailability != null && !existedClinicDateAvailabilities.isEmpty()) {
            for (Clinic_Appointment__c existedClinicDateAvailability : existedClinicDateAvailabilities) {
                if (newAvailability.CS_Start_Date__c == existedClinicDateAvailability.CS_Start_Date__c
                        || newAvailability.CS_End_Date__c == existedClinicDateAvailability.CS_End_Date__c) {
                    hasDuplicates = true;
                }

                if (newAvailability.CS_Start_Date__c > existedClinicDateAvailability.CS_Start_Date__c
                        && newAvailability.CS_Start_Date__c < existedClinicDateAvailability.CS_End_Date__c) {
                    hasDuplicates = true;
                }

                if (newAvailability.CS_End_Date__c > existedClinicDateAvailability.CS_Start_Date__c
                        && newAvailability.CS_End_Date__c < existedClinicDateAvailability.CS_End_Date__c) {
                    hasDuplicates = true;
                }

                if (newAvailability.CS_Start_Date__c < existedClinicDateAvailability.CS_Start_Date__c
                        && newAvailability.CS_End_Date__c > existedClinicDateAvailability.CS_End_Date__c) {
                    hasDuplicates = true;
                }
            }
        }

        return hasDuplicates;
    }

    private static List<Clinic_Appointment__c> getExistedAvailabilities(Set<Id> clinicIds, Set<Date> availabilityDates) {
        List<Clinic_Appointment__c> existedAvailabilities = new List<Clinic_Appointment__c>();

        if (!clinicIds.isEmpty() && !availabilityDates.isEmpty()) {
            Set<String> recordQueryFields = new Set<String>{
                    SObjectType.Clinic_Appointment__c.fields.Id.Name,
                    SObjectType.Clinic_Appointment__c.fields.Clinic__c.Name,
                    SObjectType.Clinic_Appointment__c.fields.CS_Start_Date__c.Name,
                    SObjectType.Clinic_Appointment__c.fields.CS_End_Date__c.Name
            };

            List<String> conditions = new List<String>();

            conditions.add(QueryService.getCondition(
                    SObjectType.Clinic_Appointment__c.fields.Clinic__c.Name,
                    'IN',
                    ':clinicIds',
                    false
            ));

            Set<Id> recordTypeIds = new Set<Id>{
                    Schema.SObjectType.Clinic_Appointment__c.getRecordTypeInfosByDeveloperName().get('Pre_Ex_Appointment').getRecordTypeId(),
                    Schema.SObjectType.Clinic_Appointment__c.getRecordTypeInfosByDeveloperName().get('Operation_Date').getRecordTypeId()
            };

            conditions.add(QueryService.getCondition(
                    SObjectType.Clinic_Appointment__c.fields.RecordTypeId.Name,
                    'IN',
                    ':recordTypeIds',
                    false
            ));

            conditions.add(QueryService.getCondition(
                    'DAY_ONLY(' + SObjectType.Clinic_Appointment__c.fields.CS_Start_Date__c.Name + ')',
                    'IN',
                    ':availabilityDates',
                    false
            ));

            conditions.add(QueryService.getCondition(
                    'DAY_ONLY(' + SObjectType.Clinic_Appointment__c.fields.CS_End_Date__c.Name + ')',
                    'IN',
                    ':availabilityDates',
                    false
            ));

            Set<String> bookedStatuses = new Set<String>{'Not Booked', 'Booked'};

            conditions.add(QueryService.getCondition(
                    SObjectType.Clinic_Appointment__c.fields.BookedStatus__c.Name,
                    'IN',
                    ':bookedStatuses',
                    false
            ));

            conditions.add(QueryService.getCondition(
                    SObjectType.Clinic_Appointment__c.fields.Ghost_Appointment__c.Name,
                    '!=',
                    'True',
                    true
            ));

            String whereConditions = String.join(conditions, ' AND ');

            String recordsQueryString = new SOQLQuery.Builder()
                    .setSelectToken(
                            new SOQLSelect.Builder()
                                    .setObject(SObjectType.Clinic_Appointment__c.Name)
                                    .setRequiredFields(recordQueryFields)
                                    .build()
                    )
                    .setObject(SObjectType.Clinic_Appointment__c.Name)
                    .setWhereConditions(whereConditions)
                    .setQueryLimit(String.valueOf(50000))
                    .build()
                    .toString();
            System.debug(recordsQueryString);

            if (String.isNotBlank(recordsQueryString)) {
                existedAvailabilities = Database.query(recordsQueryString);
            }
        }

        return existedAvailabilities;
    }

    private static List<Clinic_Appointment__c> createPreExMdDateClinicAppointments(MD_Day__c preExMdDate, Account preExMdDateAccount, Appointment_Counter__c preExMdDateAccountCounter) {
        List<Clinic_Appointment__c> preExClinicAppointments = new List<Clinic_Appointment__c>();

		Id preExAppointmentRecordtypeId = Schema.SObjectType.Clinic_Appointment__c.getRecordTypeInfosByDeveloperName().get('Pre_Ex_Appointment').getRecordTypeId();

        Datetime startDateTime = preExMdDate.Operation_Day_Start_Time__c;
        Datetime endDateTime = preExMdDate.Operation_Day_End_Time__c;
        Integer preExAppointmentDuration = preExMdDateAccount.PreExAppointmentsDuration__c > 0
                ? preExMdDateAccount.PreExAppointmentsDuration__c.intValue()
                : 60;

        List<Clinic_Appointment__c> guestingClinicAppointments = new List<Clinic_Appointment__c>();

        while (startDateTime.addMinutes(preExAppointmentDuration) <= endDateTime) {
            Clinic_Appointment__c preExClinicAppointment = new Clinic_Appointment__c();
            System.debug(startDateTime);
            System.debug(startDateTime.time());
            System.debug(endDateTime);
            preExClinicAppointment.CS_Start_Date__c = startDateTime;

            startDateTime = startDateTime.addMinutes(preExAppointmentDuration);
            preExClinicAppointment.CS_End_Date__c = startDateTime;

            preExClinicAppointment.Name = 'Pre-Ex Clinic Appointment';
            preExClinicAppointment.Appointment_Status__c = 'Available';
            preExClinicAppointment.Clinic__c = preExMdDateAccount.Id;
            preExClinicAppointment.MD_Day__c = preExMdDate.Id;
            preExClinicAppointment.Appointment_Counter__c = preExMdDateAccountCounter.Id;
            preExClinicAppointment.RecordTypeId = preExAppointmentRecordtypeId;

            preExClinicAppointments.add(preExClinicAppointment);

            System.debug(preExClinicAppointments.size());
            if (preExMdDateAccount.GhostingFrequency__c != null && Math.mod(preExClinicAppointments.size(), Integer.valueOf(preExMdDateAccount.GhostingFrequency__c)) == 0) {
                Clinic_Appointment__c guestingClinicAppointment = new Clinic_Appointment__c();
                guestingClinicAppointment.Name = 'Pre-Ex Guesting Clinic Appointment';
                guestingClinicAppointment.Appointment_Status__c = 'Available';
                guestingClinicAppointment.Clinic__c = preExMdDateAccount.Id;
                guestingClinicAppointment.MD_Day__c = preExMdDate.Id;
                guestingClinicAppointment.Appointment_Counter__c = preExMdDateAccountCounter.Id;
                guestingClinicAppointment.RecordTypeId = preExAppointmentRecordtypeId;
                guestingClinicAppointment.Ghost_Appointment__c = 'true';
                guestingClinicAppointment.CS_Start_Date__c = startDateTime.addMinutes(-preExAppointmentDuration/2);
                guestingClinicAppointment.CS_End_Date__c = startDateTime.addMinutes(preExAppointmentDuration/2);

                if (guestingClinicAppointment.CS_End_Date__c <= endDateTime) {
                    guestingClinicAppointments.add(guestingClinicAppointment);
                    System.debug(preExClinicAppointment);
                }
            }
        }

        preExClinicAppointments.addAll(guestingClinicAppointments);

        return preExClinicAppointments;
    }

    private static List<Clinic_Appointment__c> createOperationMdDateClinicAppointments(MD_Day__c operationMdDate, Account operationMdDateAccount, MD_Day_Location__c mdDateLocationType,  Appointment_Counter__c operationMdDateAccountCounter) {
        List<Clinic_Appointment__c> operationClinicAppointments = new List<Clinic_Appointment__c>();

		Id operationAppointmentRecordtypeId = Schema.SObjectType.Clinic_Appointment__c.getRecordTypeInfosByDeveloperName().get('Operation_Date').getRecordTypeId();

        Datetime startDateTime = operationMdDate.Operation_Day_Start_Time__c;
        Datetime endDateTime = operationMdDate.Operation_Day_End_Time__c;
        Integer operationExAppointmentDuration = 60;

        if (mdDateLocationType.ClinicLocation__c == 'MD Clinic') {
            while (startDateTime.addMinutes(operationExAppointmentDuration) <= endDateTime) {
                Clinic_Appointment__c operationClinicAppointment = new Clinic_Appointment__c();
                operationClinicAppointment.CS_Start_Date__c = startDateTime;
                operationClinicAppointment.Appointment_Date__c = startDateTime;
                if (operationMdDate.PreliminaryAppointment__c == true) {
                    operationClinicAppointment.Preliminary_appointment__c = true;
                }

                startDateTime = startDateTime.addMinutes(operationExAppointmentDuration);
                operationClinicAppointment.CS_End_Date__c = startDateTime;
                operationClinicAppointment.Appointment_Status__c = 'Available';
                operationClinicAppointment.Name = 'Operation MD Clinic Appointment';
                operationClinicAppointment.Clinic__c = operationMdDateAccount.Id;
                operationClinicAppointment.MD_Day__c = operationMdDate.Id;
                operationClinicAppointment.Appointment_Counter__c = operationMdDateAccountCounter.Id;
                operationClinicAppointment.RecordTypeId = operationAppointmentRecordtypeId;

                operationClinicAppointments.add(operationClinicAppointment);
            }
        } else if (mdDateLocationType.ClinicLocation__c == 'MO Clinic') {
            Clinic_Appointment__c operationClinicAppointment = new Clinic_Appointment__c();
            operationClinicAppointment.CS_Start_Date__c = startDateTime;
            operationClinicAppointment.CS_End_Date__c = endDateTime;
            if (operationMdDate.PreliminaryAppointment__c == true) {
                operationClinicAppointment.Preliminary_appointment__c = true;
            }
            operationClinicAppointment.Appointment_Status__c = 'Available';
            operationClinicAppointment.Name = 'Operation MO Clinic Appointment';
            operationClinicAppointment.Clinic__c = operationMdDateAccount.Id;
            operationClinicAppointment.MD_Day__c = operationMdDate.Id;
            operationClinicAppointment.Appointment_Counter__c = operationMdDateAccountCounter.Id;
            operationClinicAppointment.RecordTypeId = operationAppointmentRecordtypeId;
            operationClinicAppointment.MOClinicAppointment__c = true;

            operationClinicAppointments.add(operationClinicAppointment);
        }

        return operationClinicAppointments;
    }

    private static Boolean isRecordProcessed(String operationName, Id recordId) {
        Boolean isRecordProcessed = false;

        if (String.isNotBlank(operationName) && recordId != null) {
            if (!processedRecordIds.containsKey(operationName)) {
                processedRecordIds.put(operationName, new Set<Id>());
            }

            if (!processedRecordIds.get(operationName).contains(recordId)) {
                isRecordProcessed = false;

                processedRecordIds.get(operationName).add(recordId);
            } else {
                isRecordProcessed = true;
            }
        }

        return isRecordProcessed;
    }

}