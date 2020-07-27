@isTest
private class AppointmentBookingCtrlTest {
    
    @testSetup
    private static void prepareTestData() {
        List<Account> accounts = new List<Account>();
        Account personAccount = new Account();
        personAccount.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('PersonAccount').getRecordTypeId();
        personAccount.LastName = 'Mike Black';
        personAccount.CurrencyIsoCode = 'EUR';
        accounts.add(personAccount);

        Account clinicAccount = new Account();
        clinicAccount.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('ClinicsRecordType').getRecordTypeId();
        clinicAccount.Name = 'Doctor Star';
        clinicAccount.CurrencyIsoCode = 'EUR';
        accounts.add(clinicAccount);

        insert accounts;

        List<MD_Day_Location__c> mdDayLocations = new List<MD_Day_Location__c>();
        MD_Day_Location__c mdLocation = new MD_Day_Location__c();
        mdLocation.Name = 'md location1';
        mdLocation.RecordTypeId = Schema.SObjectType.MD_Day_Location__c.getRecordTypeInfosByDeveloperName().get('Operation_Location').getRecordTypeId();
        mdLocation.City__c = 'Paris';
        mdLocation.Street__c = 'Bush';
        mdLocation.Post_code__c ='3434';
        mdLocation.Additional_Address_Information__c = 'additional';
        mdLocation.Comments__c = 'comments';
        mdLocation.Overnight_Invoice_issued_by__c = 'Medidate';
        mdLocation.Room_Fee_Model__c = 'Flat Fee per Surgery';
        mdLocation.Anesthesia_Fee_Model__c = 'Fixed Fee for some time + Fee per Time Unit';
        mdLocation.ClinicLocation__c = 'MD clinic';
        mdLocation.Email__c = '235423efew@erge.rthrt';
        mdLocation.Price_Per_Hour__c = 34;
        mdLocation.Overtime_Penalty__c = 3;
        mdLocation.bernachtungskosten__c = 'we';
        mdLocation.Materiallager__c = 'material';
        mdLocation.Anesthesia_Information_for_Clinics__c = 'Anesthesia Information';
        mdDayLocations.add(mdLocation);

        MD_Day_Location__c moLocation = new MD_Day_Location__c();
        moLocation.Name = 'mo location1';
        moLocation.RecordTypeId = Schema.SObjectType.MD_Day_Location__c.getRecordTypeInfosByDeveloperName().get('Operation_Location').getRecordTypeId();
        moLocation.City__c = 'Brest';
        moLocation.Street__c = 'Privet';
        moLocation.Post_code__c ='5050';
        moLocation.Additional_Address_Information__c = 'additional2';
        moLocation.Comments__c = 'comments2';
        moLocation.Overnight_Invoice_issued_by__c = 'Medidate';
        moLocation.Room_Fee_Model__c = 'Flat Fee per Surgery';
        moLocation.Anesthesia_Fee_Model__c = 'Fixed Fee for some time + Fee per Time Unit';
        moLocation.ClinicLocation__c = 'MO clinic';
        moLocation.Email__c = '101020efew@erge.rthrt';
        moLocation.Price_Per_Hour__c = 30;
        moLocation.Overtime_Penalty__c = 2;
        moLocation.bernachtungskosten__c = 'he';
        moLocation.Materiallager__c = 'material2';
        moLocation.Anesthesia_Information_for_Clinics__c = 'Anesthesia Information2';
        mdDaylocations.add(moLocation);

        MD_Day_Location__c preExLocation = new MD_Day_Location__c();
        preExLocation.Name = 'preEx location';
        preExLocation.RecordTypeId = Schema.SObjectType.MD_Day_Location__c.getRecordTypeInfosByDeveloperName().get('Pre_ex_Location').getRecordTypeId();
        preExLocation.City__c = 'Amsterdam';
        preExLocation.Street__c = 'Green';
        preExLocation.Post_code__c ='2029';
        preExLocation.Additional_Address_Information__c = 'additional3';
        preExLocation.Comments__c = 'comments3';
        preExLocation.Overnight_Invoice_issued_by__c = 'Medidate';
        preExLocation.Room_Fee_Model__c = 'Flat Fee per Surgery';
        preExLocation.Anesthesia_Fee_Model__c = 'Fixed Fee for some time + Fee per Time Unit';
        preExLocation.ClinicLocation__c = 'MD clinic';
        preExLocation.Email__c = '60605efew@erge.rthrt';
        preExLocation.Price_Per_Hour__c = 33;
        preExLocation.Overtime_Penalty__c = 9;
        preExLocation.bernachtungskosten__c = 'he3';
        preExLocation.Materiallager__c = 'material3';
        preExLocation.Anesthesia_Information_for_Clinics__c = 'Anesthesia Information3';
        mdDaylocations.add(preExLocation);

        insert mdDaylocations;

        List<MD_Day__c> mdDays = new List<MD_Day__c>();
        MD_Day__c preExMdDay = new MD_Day__c();
        preExMdDay.RecordTypeId = Schema.SObjectType.MD_Day__c.getRecordTypeInfosByDeveloperName().get('MD_Pre_Ex_Day').getRecordTypeId();
        preExMdDay.MD_Day_Location__c = preExLocation.Id;
        DateTime day7 = DateTime.now().addDays(7);
        preExMdDay.Operation_Day_Start_Time__c = DateTime.newInstance(day7.year(), day7.month(), day7.day(), 8, 0, 0);
        preExMdDay.Operation_Day_End_Time__c = DateTime.newInstance(day7.year(), day7.month(), day7.day(), 17, 0, 0);
        preExMdDay.Date__c = Date.newInstance(day7.year(), day7.month(), day7.day());
        preExMdDay.Total_available_Operation_Time_Minutes__c  = 300;
        preExMdDay.Surgeon_Clinic__c = clinicAccount.Id;
        mdDays.add(preExMdDay);

        MD_Day__c mdOperationDay = new MD_Day__c();
        mdOperationDay.RecordTypeId = Schema.SObjectType.MD_Day__c.getRecordTypeInfosByDeveloperName().get('MD_Operation_Day').getRecordTypeId();
        mdOperationDay.MD_Day_Location__c = mdLocation.Id;
        DateTime day6 = DateTime.now().addDays(6);
        mdOperationDay.Operation_Day_Start_Time__c = DateTime.newInstance(day6.year(), day6.month(), day6.day(), 8, 0, 0);
        mdOperationDay.Operation_Day_End_Time__c = DateTime.newInstance(day6.year(), day6.month(), day6.day(), 17, 0, 0);
        mdOperationDay.Date__c = Date.newInstance(day6.year(), day6.month(), day6.day());
        mdOperationDay.Total_available_Operation_Time_Minutes__c  = 200;
        mdOperationDay.Surgeon_Clinic__c = clinicAccount.Id;
        mdDays.add(mdOperationDay); 

        insert mdDays;

        List<Clinic_Appointment__c> additionalAppointments = new List<Clinic_Appointment__c>();
        Clinic_Appointment__c appointmentWithPreExLocation = [SELECT Id, RecordTypeId, Operation_Day_Start_Time__c, Clinic__c, MD_Day__c, Appointment_Counter__c, Appointment_Date__c FROM Clinic_Appointment__c WHERE MD_Day__c IN (SELECT Id FROM MD_Day__c WHERE MD_Day_Location__r.Name = 'preEx location')].get(0);
        Clinic_Appointment__c preMedAppointment = new Clinic_Appointment__c();
        preMedAppointment.Clinic__c = appointmentWithPreExLocation.Clinic__c;
        preMedAppointment.MD_Day__c = appointmentWithPreExLocation.MD_Day__c;
        preMedAppointment.Appointment_Counter__c = appointmentWithPreExLocation.Appointment_Counter__c;
        preMedAppointment.Appointment_Date__c = appointmentWithPreExLocation.Appointment_Date__c;
        preMedAppointment.Apppointment_Type__c = 'Surgery Preparation Appointment';
        preMedAppointment.CS_Start_Date__c = appointmentWithPreExLocation.Operation_Day_Start_Time__c;
        preMedAppointment.CS_End_Date__c = (preMedAppointment.CS_Start_Date__c).addHours(1);
        preMedAppointment.Appointment_Status__c = 'Available';
        preMedAppointment.Name = 'preMed Appointment';
        preMedAppointment.RecordTypeId = appointmentWithPreExLocation.RecordTypeId;
        additionalAppointments.add(preMedAppointment);

        Clinic_Appointment__c afterCareAppointment = new Clinic_Appointment__c();
        afterCareAppointment.Clinic__c = appointmentWithPreExLocation.Clinic__c;
        afterCareAppointment.MD_Day__c = appointmentWithPreExLocation.MD_Day__c;
        afterCareAppointment.Appointment_Counter__c = appointmentWithPreExLocation.Appointment_Counter__c;
        afterCareAppointment.Appointment_Date__c = appointmentWithPreExLocation.Appointment_Date__c;
        afterCareAppointment.Apppointment_Type__c = 'Aftercare Appointment';
        afterCareAppointment.CS_Start_Date__c = appointmentWithPreExLocation.Operation_Day_Start_Time__c;
        afterCareAppointment.CS_End_Date__c = (afterCareAppointment.CS_Start_Date__c).addHours(1);
        afterCareAppointment.Appointment_Status__c = 'Available';
        afterCareAppointment.Name = 'afterCare Appointment';
        afterCareAppointment.RecordTypeId = appointmentWithPreExLocation.RecordTypeId;
        additionalAppointments.add(afterCareAppointment);

        insert additionalAppointments;

        List<Opportunity> opportunities = new List<Opportunity>();
        Opportunity opportunity = new Opportunity();
        opportunity.Name = 'Andrey Sidorov';
        opportunity.RecordTypeId =  Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('Body').getRecordTypeId();
        opportunity.CloseDate = System.today() + 14;
        opportunity.StageName = 'Interested in Financing';
        opportunity.PaymentType__c = 'Pre-Payment';
        opportunity.AccountId =  personAccount.Id;
        opportunity.Clinic__c = clinicAccount.Id;
        opportunity.VU_OP_Caretaker__c  = UserInfo.getUserId();
        opportunity.Show_Up_Control__c = true;
        opportunity.Operation_Duration_Minutes__c = 60;
        opportunities.add(opportunity);
        insert opportunities;
    }

    @isTest
    private static void testGetOpportunity() {
        String opportunityId = [SELECT Id FROM Opportunity].get(0).Id;
        Map<String, String> opportunityFilter = new Map<String, String>{
            'recordId' => opportunityId
        };

        Test.startTest();

        String response = AppointmentBookingCtrl.getOpportunity(JSON.serialize(opportunityFilter));
        
        Test.stopTest();
        
        Map<String, Object> responseMap = (Map<String, Object>) JSON.deserializeUntyped(response);
        Map<String, Object> responseDataMap = (Map<String, Object>) responseMap.get('data');
        Map<String, Object> responseOpportunity = (Map<String, Object>) responseDataMap.get('opportunity');
        Id responseId = (Id) responseOpportunity.get('Id');
        System.assertNotEquals(responseId, null);   
    } 

       
    @isTest
    private static void testGetPreexAvailabilities() {
        Date dateTomorrow = Date.today() + 1;
        Date dateMonth = dateTomorrow.addMonths(1);
        String clinicId = [SELECT Id FROM Account WHERE Name = 'Doctor Star'].get(0).Id;
        Map<String, Object> availabilitiesFilter = new Map<String, Object>{
            'appointmentRecordTypeName' => 'Pre_Ex_Appointment',
            'appointmentType' => 'Regular Appointment Type',
            'additionalAppointmentTypes' => new List<String>{'Aftercare Appointment', 'Surgery Preparation Appointment'},
            'clinicId' => clinicId,
            'range' => new Map<String, Object>{
                'start' => DateTime.newInstance(dateTomorrow.year(), dateTomorrow.month(), dateTomorrow.day(), 0, 0, 0),
                'end' => DateTime.newInstance(dateMonth.year(), dateMonth.month(), dateMonth.day(), 0, 0, 0)
            }
        };
        Test.startTest();

        String response = AppointmentBookingCtrl.getPreexAvailabilities(JSON.serialize(availabilitiesFilter));

        Test.stopTest();

        Map<String, Object> responseMap = (Map<String, Object>) JSON.deserializeUntyped(response);
        String status = (String) responseMap.get('status');
        System.assert(status == 'success');
    }

    @isTest
    private static void testCheckNumberOfPreMedAppointments() {
        Opportunity opportunity = [SELECT Id FROM Opportunity WHERE Name = 'Andrey Sidorov'].get(0);
        Map<String, Object> opportunityFilter = new Map<String, Object>{
            'recordId' => opportunity.Id
        };
        Test.startTest();
        String response = AppointmentBookingCtrl.checkNumberOfPreMedAppointments(JSON.serialize(opportunityFilter));
        Test.stopTest();
        Map<String, Object> responseMap = (Map<String, Object>) JSON.deserializeUntyped(response);
        String status = (String) responseMap.get('status');
        System.assert(status == 'success');
    
    }

    @isTest
    private static void testSaveMOOperationAppointment() {
        Opportunity opportunity = [SELECT Id FROM Opportunity WHERE Name = 'Andrey Sidorov'].get(0);

        MD_Day__c moOperationDay = new MD_Day__c();
        moOperationDay.RecordTypeId = Schema.SObjectType.MD_Day__c.getRecordTypeInfosByDeveloperName().get('MD_Operation_Day').getRecordTypeId();
        moOperationDay.MD_Day_Location__c = [SELECT Id FROM MD_Day_Location__c WHERE name = 'mo location1'].get(0).Id;
        DateTime day5 = DateTime.now().addDays(5);
        moOperationDay.Operation_Day_Start_Time__c = DateTime.newInstance(day5.year(), day5.month(), day5.day(), 8, 0, 0);
        moOperationDay.Operation_Day_End_Time__c = DateTime.newInstance(day5.year(), day5.month(), day5.day(), 17, 0, 0);
        moOperationDay.Date__c = Date.newInstance(day5.year(), day5.month(), day5.day());
        moOperationDay.Total_available_Operation_Time_Minutes__c  = 120;
        moOperationDay.Surgeon_Clinic__c = [SELECT Id FROM Account WHERE Name = 'Doctor Star'].get(0).Id;
        insert moOperationDay;

        Clinic_Appointment__c appointment = [
            SELECT Id,
                   Appointment_Date__c,
                   Operation_Day_Start_Time__c,
                   MOAvailability__c,
                   MOClinicAppointment__c,
                   MD_Day__c,
                   Clinic__c,
                   Appointment_Counter__c,
                   RecordTypeId,
                   CS_Start_Date__c,
                   CS_End_Date__c
            FROM Clinic_Appointment__c
            WHERE MD_Day__c IN (
                SELECT Id 
                FROM MD_Day__c 
                WHERE MD_Day_Location__r.Name = 'mo location1'
                )
                    AND (Apppointment_Type__c != 'Surgery Preparation Appointment'
                            OR Apppointment_Type__c != 'Aftercare Appointment'
                        )
        ].get(0);
        Map<String, Object> mdOperationAppointmentData = new Map<String, Object>{
            'Clinic_Appointment__c' => new Map<String, Object>{
                'fields' => new List<Map<String, Object>>{
                    new Map<String, Object>{
                        'name' => 'Name',
                        'value' => 'Operation Date'
                    },
                    new Map<String, Object>{
                        'name' => 'CS_Start_Date__c',
                        'value' => (appointment.Operation_Day_Start_Time__c).addHours(1)
                    },
                    new Map<String, Object>{
                        'name' => 'Dummynumber__c',
                        'value' => 60
                    },
                    new Map<String, Object>{
                        'name' => 'MOAvailability__c',
                        'value' => appointment.Id
                    },
                    new Map<String, Object>{
                        'name' => 'Appointment_Status__c',
                        'value' => 'Available'
                    },
                    new Map<String, Object>{
                        'name' => 'CS_End_Date__c',
                        'value' => (appointment.Operation_Day_Start_Time__c).addHours(2)
                    },
                    new Map<String, Object>{
                        'name' => 'Appointment_Date__c',
                        'value' => appointment.Appointment_Date__c
                    }
                },
                'recordId' => appointment.Id
            },
            'MD_Day__c' => new Map<String, Object>{
                'fields' => new List<Map<String, Object>>{
                    new Map<String, Object>{
                        'name' => 'Total_available_Operation_Time_Minutes__c',
                        'value' => 200
                    },
                    new Map<String, Object>{
                        'name' => 'Operation_Duration_scheduled_Minutes__c',
                        'value' => 60
                    }
                },
                'recordId' => appointment.MD_Day__c
            },
            'Opportunity' => new Map<String, Object>{
                'fields' => new List<Map<String, Object>>{
                    new Map<String, Object>{
                        'name' => 'Operation_Duration_Minutes__c',
                        'value' => 30
                    },
                    new Map<String, Object>{
                        'name' => 'RevisionSurgery__c',
                        'value' => false
                    },
                    new Map<String, Object>{
                        'name' => 'Operation_Appointment__c',
                        'value' => appointment.Id
                    },
                    new Map<String, Object>{
                        'name' => 'Revision_Operation_Appointment__c',
                        'value' => null
                    }
                },
                'recordId' => opportunity.Id
            }
        };

        Test.startTest();

        String response = AppointmentBookingCtrl.saveMOOperationAppointment(JSON.serialize(mdOperationAppointmentData));

        Clinic_Appointment__c apointmentError = new Clinic_Appointment__c();
        apointmentError.Name = 'Test app';
        apointmentError.Clinic__c = appointment.Clinic__c;
        apointmentError.MD_Day__c = appointment.MD_Day__c;
        apointmentError.Appointment_Status__c = 'Available';
        apointmentError.Appointment_Counter__c = appointment.Appointment_Counter__c;
        apointmentError.RecordTypeId = appointment.RecordTypeId;
        apointmentError.CS_Start_Date__c = appointment.CS_Start_Date__c;
        apointmentError.CS_End_Date__c = appointment.CS_End_Date__c;

        String errorMessage;
        try {
            insert apointmentError;
        } catch (Exception e) {
            errorMessage = e.getMessage();
        }
        Test.stopTest();

        Map<String, Object> responseMap = (Map<String, Object>) JSON.deserializeUntyped(response);
        String status = (String) responseMap.get('status');

        System.assert(status == 'success');
        System.assert(String.isNotBlank(errorMessage));

    }

    @isTest
    private static void testSaveMDOperationAppointment() {
        Id recordTypeId = Schema.SObjectType.Clinic_Appointment__c.getRecordTypeInfosByDeveloperName().get('Pre_Ex_Appointment').getRecordTypeId();
        Opportunity opportunity = [SELECT Id FROM Opportunity WHERE Name = 'Andrey Sidorov'].get(0);
        Clinic_Appointment__c preExapp = [SELECT Id FROM Clinic_Appointment__c WHERE RecordTypeId = :recordTypeId AND Apppointment_Type__c = 'Regular Appointment Type'].get(0);
        Clinic_Appointment__c appointment = [
            SELECT Id,
                   Appointment_Date__c
            FROM Clinic_Appointment__c
            WHERE MD_Day__c IN (
                SELECT Id 
                FROM MD_Day__c 
                WHERE MD_Day_Location__r.Name = 'md location1'
                )
                    AND (Apppointment_Type__c != 'Surgery Preparation Appointment'
                            OR Apppointment_Type__c != 'Aftercare Appointment'
                        )
        ].get(0);
        Map<String, Object> mdOperationAppointmentData = new Map<String, Object>{
            'Clinic_Appointment__c' => new Map<String, Object>{
                'fields' => new List<Map<String, Object>>{
                    new Map<String, Object>{
                        'name' => 'Dummynumber__c',
                        'value' => 60
                    },
                    new Map<String, Object>{
                        'name' => 'Appointment_Date__c',
                        'value' => appointment.Appointment_Date__c
                    }
                },
                'recordId' => appointment.Id
            },
            'Opportunity' => new Map<String, Object>{
                'fields' => new List<Map<String, Object>>{
                    new Map<String, Object>{
                        'name' => 'Operation_Appointment__c',
                        'value' => appointment.Id
                    }
                },
                'recordId' => opportunity.Id
            }
        };

        Test.startTest();

        String response = AppointmentBookingCtrl.saveMDOperationAppointment(JSON.serialize(mdOperationAppointmentData));

        Map<String, Object> responseMap = (Map<String, Object>) JSON.deserializeUntyped(response);      
        Map<String, Object> responseDataMap = (Map<String, Object>) responseMap.get('data');
        Map<String, Object> mdOperationAppointmentsMap = (Map<String, Object>) responseDataMap.get('mdOperationAppointment');
        Id mdOperationAppointmentId = (Id) mdOperationAppointmentsMap.get('id');

        System.assertNotEquals(mdOperationAppointmentId, null);

        Map<String, Object> predefinedFields = new Map<String, Object>{
            'predefinedFields' => new List<Map<String, Object>>{
                new Map<String, Object>{
                    'value' => 'Reserved',
                    'name' => 'Appointment_Status__c'
                },
                new Map<String, Object>{
                    'value' => opportunity.Id,
                    'name' => 'Opportunity__c'
                },
                new Map<String, Object>{
                    'value' => 'Surgery Preparation Appointment',
                    'name' => 'Apppointment_Type__c'
                }
            },
            'recordId' => preExapp.Id
        };

        response = AppointmentBookingCtrl.savePreMedAppointment(JSON.serialize(predefinedFields));

        Test.stopTest();

        responseMap = (Map<String, Object>) JSON.deserializeUntyped(response);
        Map<String, Object> preMedAppointmentMap = (Map<String, Object>) responseMap.get('data');
        Map<String, Object> preMedAppointment = (Map<String, Object>) preMedAppointmentMap.get('preMedAppointment');
        Id preMedAppointmentId = (Id) preMedAppointment.get('id');
        System.assertNotEquals(preMedAppointmentId, null);
    }

    @isTest
    private static void testGetOperationAvailabilities() {
        Date dateTomorrow = Date.today() + 1;
        Date dateMonth = dateTomorrow.addMonths(1);
        String clinicId = [SELECT Id FROM Account WHERE Name = 'Doctor Star'].get(0).Id;
        Map<String, Object> availabilitiesFilter = new Map<String, Object>{
            'clinicId' => clinicId,
            'range' => new Map<String, Object>{
                'start' => DateTime.newInstance(dateTomorrow.year(), dateTomorrow.month(), dateTomorrow.day(), 0, 0, 0),
                'end' => DateTime.newInstance(dateMonth.year(), dateMonth.month(), dateMonth.day(), 0, 0, 0)
            },
            'appointmentRecordTypeName' => 'Operation_Date'

        };

        Test.startTest();

        String response = AppointmentBookingCtrl.getOperationAvailabilities(JSON.serialize(availabilitiesFilter));

        Test.stopTest();

        Map<String, Object> responseMap = (Map<String, Object>) JSON.deserializeUntyped(response);
        String status = (String) responseMap.get('status');
        System.assert(status == 'success');
    }

    @isTest
    private static void testSaveMDOperationAppointment2() {
        Id recordTypeId = Schema.SObjectType.Clinic_Appointment__c.getRecordTypeInfosByDeveloperName().get('Pre_Ex_Appointment').getRecordTypeId();
        Opportunity opportunity = [SELECT Id FROM Opportunity WHERE Name = 'Andrey Sidorov'].get(0);
        Clinic_Appointment__c preExapp = [SELECT Id, Name, CS_Start_Date__c, CS_End_Date__c  FROM Clinic_Appointment__c WHERE RecordTypeId = :recordTypeId AND Apppointment_Type__c = 'Regular Appointment Type'].get(0);
        Clinic_Appointment__c appointment = [
            SELECT Id,
                   Appointment_Date__c,
                   CS_Start_Date__c,
                   CS_End_Date__c,
                   Apppointment_Type__c
            FROM Clinic_Appointment__c
            WHERE MD_Day__c IN (
                SELECT Id
                FROM MD_Day__c 
                WHERE MD_Day_Location__r.Name = 'md location1'
                )
                    AND (
                        Apppointment_Type__c != 'Surgery Preparation Appointment'
                            OR
                             Apppointment_Type__c != 'Aftercare Appointment'
                        )
        ].get(0);
        System.debug(JSON.serializePretty(appointment));
        Map<String, Object> mdOperationAppointmentData = new Map<String, Object>{
            'Clinic_Appointment__c' => new Map<String, Object>{
                'fields' => new List<Map<String, Object>>{
                    new Map<String, Object>{
                        'name' => 'Dummynumber__c',
                        'value' => 60
                    },
                    new Map<String, Object>{
                        'name' => 'Appointment_Date__c',
                        'value' => appointment.Appointment_Date__c
                    }
                },
                'recordId' => appointment.Id
            },
            'Opportunity' => new Map<String, Object>{
                'fields' => new List<Map<String, Object>>{
                    new Map<String, Object>{
                        'name' => 'Operation_Appointment__c',
                        'value' => appointment.Id
                    }
                },
                'recordId' => opportunity.Id
            }
        };

        Test.startTest();

        String response = AppointmentBookingCtrl.saveMDOperationAppointment(JSON.serialize(mdOperationAppointmentData));

        Map<String, Object> responseMap = (Map<String, Object>) JSON.deserializeUntyped(response);      
        Map<String, Object> responseDataMap = (Map<String, Object>) responseMap.get('data');
        Map<String, Object> mdOperationAppointmentsMap = (Map<String, Object>) responseDataMap.get('mdOperationAppointment');
        Id mdOperationAppointmentId = (Id) mdOperationAppointmentsMap.get('id');

        System.assertNotEquals(mdOperationAppointmentId, null);

        Map<String, Object> predefinedFields = new Map<String, Object>{
            'Clinic_Appointment__c' => new Map<String, Object>{
                'fields' => new List<Map<String, Object>>{
                    new Map<String, Object>{
                        'name' => 'Name',
                        'value' => 'Pre-Ex Appointment'
                    },
                    new Map<String, Object>{
                        'name' => 'CS_Start_Date__c',
                        'value' => appointment.CS_Start_Date__c
                    },
                    new Map<String, Object>{
                        'name' => 'CS_End_Date__c',
                        'value' => appointment.CS_End_Date__c
                    },
                    new Map<String, Object>{
                        'name' => 'Appointment_Status__c',
                        'value' => 'Reserved'
                    },
                    new Map<String, Object>{
                        'name' => 'Opportunity__c',
                        'value' => opportunity.Id
                    },
                    new Map<String, Object>{
                        'name' => 'Apppointment_Type__c',
                        'value' => 'Aftercare Appointment'
                    }
                },
                'recordId' => preExapp.Id
            }
        };

        response = AppointmentBookingCtrl.saveAfterCareAppointment(JSON.serialize(predefinedFields));

        Test.stopTest();

        responseMap = (Map<String, Object>) JSON.deserializeUntyped(response);
        Map<String, Object> preMedAppointmentMap = (Map<String, Object>) responseMap.get('data');
        System.debug(JSON.serializePretty(responseMap));
        Map<String, Object> preMedAppointment = (Map<String, Object>) preMedAppointmentMap.get('afterCareAppointment');
        Id preMedAppointmentId = (Id) preMedAppointment.get('id');
        System.assertNotEquals(preMedAppointmentId, null);
    }
           
}