@IsTest
private class ClinicSelectionPlacingTest {

    @IsTest
    private static void checkInitPageOpportunity() {
        Account acc = initClinic();
        initClinicAppointment(acc.Id);
        Opportunity opp = initOpportunity();
        System.currentPageReference().getParameters().put('id', opp.Id);
        System.currentPageReference().getParameters().put('objType', 'Opportunity');
        ClinicSelectionPlacing clSP = new ClinicSelectionPlacing();
        clSP.sortExpression = 'Distance';
        clSP.sortKey = 'price';
        System.assertEquals(clSP.sortKey, 'price');
        System.assertEquals(clSP.sortExpression, 'Distance');
        System.assertEquals(clSP.getSortDirection(), 'ASC');
        System.assertEquals(clSP.getSelectedClinics().size(), 0);
        System.assert(clSP.obj != null);
    }

    @IsTest
    private static void checkInitPageLead() {
        Lead lead = initLead();

        System.currentPageReference().getParameters().put('id', lead.Id);
        System.currentPageReference().getParameters().put('objType', 'Lead');
        ClinicSelectionPlacing clSP = new ClinicSelectionPlacing();
        clSP.sortExpression = 'Distance';
        clSP.sortKey = 'price';
        System.assertEquals(clSP.sortKey, 'price');
        System.assertEquals(clSP.sortExpression, 'Distance');
        System.assertEquals(clSP.getSortDirection(), 'ASC');
        System.assertEquals(clSP.getSelectedClinics().size(), 0);
        System.assert(clSP.obj != null);
        clSP.sortExpression = 'Distance';
        clSP.sortKey = 'price';
        System.assertEquals(clSP.sortKey, 'price');
        System.assertEquals(clSP.sortExpression, 'Distance');
        System.assertEquals(clSP.getSortDirection(), 'ASC');
        System.assertEquals(clSP.getSelectedClinics().size(), 0);
        System.assert(clSP.obj != null);
        clSP.setSortDirection('DESC');
        System.assertEquals(clSP.getSortDirection(), 'DESC');
    }

    @IsTest
    private static void checkCustomSorterByString() {
        Opportunity opp = initOpportunity();
        List<ClinicSelectionPlacing.SelectedClinic> clinics = new List<ClinicSelectionPlacing.SelectedClinic>();
        List<CustomSorter> sortableCLinics = new List<CustomSorter>();
        ClinicSelectionPlacing.SelectedClinic clinic;
        for(integer i = 0; i < 100; ++i) {
            clinic = new ClinicSelectionPlacing.SelectedClinic(
                opp.Id,
                'mDDayLocationName',
                opp.Id,
                'doctorName' + i,
                50.0,
                'oPLocations',
                123.12,
                123.12,
                123.12,
                'price',
                opp.Id,
                'clinicProductName',
                opp.Id,
                generateRandomString(10),
                true,
                String.valueOf(Date.today()),
                20
            );
            sortableCLinics.add(new CustomSorter(clinic, 1, clinic.doctorName, clinic.priority));
        }
        sortableCLinics.sort();
    }
    
    @IsTest
    private static void checkCustomSorterByNumber() {
        Opportunity opp = initOpportunity();
        List<ClinicSelectionPlacing.SelectedClinic> clinics = new List<ClinicSelectionPlacing.SelectedClinic>();
        List<CustomSorter> sortableCLinics = new List<CustomSorter>();
        ClinicSelectionPlacing.SelectedClinic clinic;
        for(integer i = 0; i < 100; ++i) {
            clinic = new ClinicSelectionPlacing.SelectedClinic(
                opp.Id,
                'mDDayLocationName',
                opp.Id,
                'doctorName',
                50.0,
                'oPLocations',
                123.12,
                123.12,
                123.12,
                String.valueOf(Math.round(Math.random()*1000)),
                opp.Id,
                'clinicProductName',
                opp.Id,
                generateRandomString(10),
                true,
                String.valueOf(Date.today()),
                20
            );
            sortableCLinics.add(new CustomSorter(clinic, 1, Decimal.valueOf(clinic.price), clinic.priority));
        }
        sortableCLinics.sort();
    }
    
    @IsTest
    private static void checkCustomSorterByDate() {
        Opportunity opp = initOpportunity();
        List<ClinicSelectionPlacing.SelectedClinic> clinics = new List<ClinicSelectionPlacing.SelectedClinic>();
        List<CustomSorter> sortableCLinics = new List<CustomSorter>();
        ClinicSelectionPlacing.SelectedClinic clinic;
        for(integer i = 0; i < 100; ++i) {
            clinic = new ClinicSelectionPlacing.SelectedClinic(
                opp.Id,
                'mDDayLocationName',
                opp.Id,
                'doctorName',
                i,
                'oPLocations',
                123.12,
                123.12,
                123.12,
                String.valueOf(Math.round(Math.random()*1000)),
                opp.Id,
                'clinicProductName',
                opp.Id,
                generateRandomString(10),
                true,
                '30.11.2018',
                20
            );
            sortableCLinics.add(new CustomSorter(clinic, 1, Date.parse(clinic.mdDate), clinic.priority));
        }
        sortableCLinics.sort();
    }
    
    @IsTest
    private static void testSortClinics() {
        ClinicSelectionPlacing clSP = new ClinicSelectionPlacing();
        clSP.sortExpression = 'Distance';
        clSP.sortKey = 'price';
        Opportunity opp = initOpportunity();
        List<ClinicSelectionPlacing.SelectedClinic> clinics = new List<ClinicSelectionPlacing.SelectedClinic>();
        ClinicSelectionPlacing.SelectedClinic clinic;
        for(integer i = 0; i < 100; ++i) {
            clinic = new ClinicSelectionPlacing.SelectedClinic(
                opp.Id,
                'mDDayLocationName',
                opp.Id,
                'doctorName',
                50.0,
                'oPLocations',
                123.12,
                123.12,
                123.12,
                'price',
                opp.Id,
                'clinicProductName',
                opp.Id,
                generateRandomString(10),
                true,
                String.valueOf(Date.today()),
                20
            );
            clinics.add(clinic);
        }
        ClinicSelectionPlacing cp = new ClinicSelectionPlacing();
        cp.sortClinics(clinics);
    }
    
    private static String generateRandomString(Integer len) {
        final String chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789abcdefghijklmnopqrstuvwxyz';
        String randStr = '';
        while (randStr.length() < len) {
            Integer idx = Math.mod(Math.abs(Crypto.getRandomInteger()), chars.length());
            randStr += chars.substring(idx, idx+1);
        }
        return randStr;
    }

    private static Account initPersonAccount() {
        Id recordType = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Patient Account').getRecordTypeId();
        Account clinic = new Account(
            LastName = 'TestUser',
            RecordTypeId = recordType,
            PatientDateofBirth__pc = Date.today());
        insert clinic;
        return clinic;
    }

    private static Opportunity initOpportunity() {
        Opportunity opportunity = new Opportunity(
            Name = 'Test1',
            StageName = 'Open',
            CloseDate = Date.today().addDays(3),
            Accountid = initPersonAccount().Id
        );
        insert opportunity;
        return opportunity;
    }

    private static Lead initLead() {
        Id recordTypeId = Lead.getSObjectType().getDescribe().getRecordTypeInfosById().values()[0].getRecordTypeId();
        Lead lead = new Lead(
            LastName = 'leadToInsert',
            Email = 'test@test.de',
            RecordTypeId = recordTypeId,
            Company = 'Test',
            Date_of_Birth__c = Date.today());
        insert lead;
        return lead;
    }

    private static Clinic_Appointment__c initClinicAppointment(String clinicId) {
        //Account clinic = initClinic();
        Id recordType = Schema.SObjectType.Clinic_Appointment__c.getRecordTypeInfosByName().get('Pre-Ex Appointment').getRecordTypeId();
        Clinic_Appointment__c clinicAppointment = new Clinic_Appointment__c(
            Clinic__c = clinicId,
            MD_Day__c = initMDDay().Id,
            RecordTypeId = recordType,
            Appointment_Status__c = 'Available',
            Appointment_Counter__c = initAppointmentCounter(clinicId).Id
        );
        initClinicProduct(clinicId);
        insert clinicAppointment;
        return clinicAppointment;
    }
    
    private static Appointment_Counter__c initAppointmentCounter(Id AccountId) {
        Appointment_Counter__c appointmentCounter = new Appointment_Counter__c(Surgeon__c = AccountId, 
                                                                               Appointment_Counter_Matching__c = 'Test1');  
        insert appointmentCounter;
        return appointmentCounter;
    }
    
    private static MD_Day__c initMDDay() {
        Id recordType = Schema.SObjectType.MD_Day__c.getRecordTypeInfosByName().get('MD Pre-Ex Day').getRecordTypeId();
        MD_Day__c MD_Day = new MD_Day__c(
            RecordTypeId = recordType,
            MD_Day_Location__c = initMDDayLocation().Id,
            Operation_Day_Start_Time__c = SYSTEM.NOW(),
            Operation_Day_End_Time__c = SYSTEM.NOW(),
            Date__c = SYSTEM.TODAY()
        );
        insert MD_Day;
        return MD_Day;
    }

    private static MD_Day_Location__c initMDDayLocation() {
        Id recordType = Schema.SObjectType.MD_Day_Location__c.getRecordTypeInfosByName().get('Pre-ex Location').getRecordTypeId();
        MD_Day_Location__c MD_Day_Location = new MD_Day_Location__c(
            RecordTypeId = recordType,
            Location__Latitude__s = 13.0429,
            Location__Longitude__s = 80.2739
        );
        insert MD_Day_Location;
        return MD_Day_Location;
    }

    private static ClinicProduct__c initClinicProduct(String clinicId) {
        ClinicProduct__c ClinicProduct = new ClinicProduct__c(Clinic__c = clinicId);
        insert ClinicProduct;
        return ClinicProduct;
    }

    private static Account initClinic() {
        Account clinic = new Account(Name = 'TestClinic');
        insert clinic;
        return clinic;
    }
}