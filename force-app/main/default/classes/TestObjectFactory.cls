public class TestObjectFactory {

    public static final String DOCTORS_NAME = 'Markus Schultz';
    public static final String PATIENTS_NAME = 'Uwe Mueller';
    public static final String PATIENTS_NAME2 = 'Marion Schieller';
    public static final String MD_DAY_LOCATION_NAME = 'MD Day Location 1';
    /*
    Account accountRecord = TestObjectFactory.getPersonAccount();
    */
    public static Account getPersonAccount() {
        String recordTypeId = [SELECT Id FROM RecordType WHERE SobjectType = 'Account' AND DeveloperName = 'PersonAccount' LIMIT 1].Id;
        Account record = new Account(
            LastName = 'Test',
            RecordTypeId = recordTypeId,
            PersonMobilePhone = '447700900123',
            New_Appointment_System__c =true,
            Pre_Ex_Normal_Price__c=100.00
        );
        return record;
    }
    
    /*
    Account accountRecord = TestObjectFactory.getBusinessAccount();
    */
    public static Account getBusinessAccount() {
        String recordTypeId = [SELECT Id FROM RecordType WHERE SobjectType = 'Account' AND DeveloperName = 'ClinicsRecordType' LIMIT 1].Id;
        Account record = new Account(
            Name = 'Test',
            RecordTypeId = recordTypeId,
            Phone = '447700900123',
            New_Appointment_System__c =true,
            Pre_Ex_Normal_Price__c=100.00
        );
        return record;
    }
    
    /*
    Opportunity opportunityRecord = TestObjectFactory.getOpportunity();
    */
    public static Opportunity getOpportunity() {
        Opportunity record = new Opportunity(
            Name = 'Test',
            CloseDate = System.today(),
            StageName = 'Qualification',
            AppointmentDate__c = System.today().addDays(-1),
            Opportunity_Appointment_Type__c='Clinic Alternative',
            PaymentType__c='Pre-Payment'            
            
        );
        return record;
    }
    
    /*
    Account accountRecord = TestObjectFactory.getPersonAccount();
    insert accountRecord;
    Opportunity opportunityRecord = TestObjectFactory.getOpportunity(accountRecord.Id);
    */
    public static Opportunity getOpportunity(String accountId) {
        Opportunity record = getOpportunity();
        record.AccountId = accountId;
        return record;
    }
    
    /*
    Payment__c paymentRecord = TestObjectFactory.getPayment();
    */
    public static Payment__c getPayment() {
        Payment__c record = new Payment__c(
            PaymentAmount__c = 100,
            PaymentDate__c = System.today(),
            PaymentID__c = 'Test ID',
            PaymentMethod__c = 'VISA',
            TransactionStatus__c='Paid',
            PaidHelper__c=true,
            Generate_Credit_Note__c='Credit note generated'
        );
        return record;
    }
    
    /*
    Account accountRecord = TestObjectFactory.getPersonAccount();
    insert accountRecord;
    Opportunity opportunityRecord = TestObjectFactory.getOpportunity(accountRecord.Id);
    insert opportunityRecord;
    Payment__c paymentRecord = TestObjectFactory.getPayment(opportunityRecord.Id);
    */
    public static Payment__c getPayment(String opportunityId) {
        Payment__c record = getPayment();
        record.Opportunity__c = opportunityId;
        record.PaymentAmount__c = 100;
        record.PaymentDate__c = System.today();
        record.PaymentID__c = 'Test ID';
        record.PaymentMethod__c = 'test';
        record.TransactionStatus__c='Pending';
        record.PaidHelper__c=true;
        record.Generate_Credit_Note__c='Credit note generated';
        return record;
    }
    
    /*
    Account accountRecord = TestObjectFactory.getPersonAccount();
    insert accountRecord;
    Opportunity opportunityRecord = TestObjectFactory.getOpportunity(accountRecord.Id);
    insert opportunityRecord;
    Payment__c paymentRecord = TestObjectFactory.getPayment(opportunityRecord.Id);
    insert paymentRecord;
    String saferpayErrorResponse = TestObjectFactory.getSaferpayErrorResponse(paymentRecord.Id);
    */
    public static String getSaferpayErrorResponse(String paymentId) {
        String response = 
            '{' +
                '"ResponseHeader": {' +
                    '"SpecVersion": "1.2",' +
                    '"RequestId": "' + paymentId + '"' + 
                '},' +
                '"Behavior": "ABORT",' +
                '"ErrorName": "VALIDATION_FAILED",' +
                '"ErrorMessage": "Request validation failed",' +
                '"ErrorDetail": [' +
                    '"PaymentMeans.BankAccount.IBAN: The field IBAN is invalid."' +
                ']' +
            '}';
        return response;
    }
    
    /*
    Account accountRecord = TestObjectFactory.getPersonAccount();
    insert accountRecord;
    Opportunity opportunityRecord = TestObjectFactory.getOpportunity(accountRecord.Id);
    insert opportunityRecord;
    Payment__c paymentRecord = TestObjectFactory.getPayment(opportunityRecord.Id);
    insert paymentRecord;
    String saferpayInitializeResponse = TestObjectFactory.getSaferpayInitializeResponse(paymentRecord.Id);
    */
    public static String getSaferpayInitializeResponse(String paymentId) {
        String response = 
            '{' +
                '"ResponseHeader": {' +
                    '"SpecVersion": "1.2",' +
                    '"RequestId": "' + paymentId + '"' +
                '},' +
                '"Token": "234uhfh78234hlasdfh8234e1234",' +
                '"Expiration": "2015-01-30T12:45:22.258+01:00",' +
                '"RedirectUrl": "https://www.saferpay.com/vt2/api/..."' +
            '}';
        return response;
    }
    
    /*
    Account accountRecord = TestObjectFactory.getPersonAccount();
    insert accountRecord;
    Opportunity opportunityRecord = TestObjectFactory.getOpportunity(accountRecord.Id);
    insert opportunityRecord;
    Payment__c paymentRecord = TestObjectFactory.getPayment(opportunityRecord.Id);
    insert paymentRecord;
    String saferpayAssertResponse = TestObjectFactory.getSaferpayAssertResponse(paymentRecord.Id);
    */
    public static String getSaferpayAssertResponse(String paymentId) {
        String response = 
            '{' +
                '"ResponseHeader": {' +
                    '"SpecVersion": "1.2",' +
                    '"RequestId": "' + paymentId + '"' +
                '},' +
                '"Transaction": {' +
                    '"Type": "PAYMENT",' +
                    '"Status": "AUTHORIZED",' +
                    '"Id": "723n4MAjMdhjSAhAKEUdA8jtl9jb",' +
                    '"Date": "2015-01-30T12:45:22.258+01:00",' +
                    '"Amount": {' +
                       '"Value": "100",' +
                       '"CurrencyCode": "CHF"' +
                    '},' +
                    '"AcquirerName": "Saferpay Test Card",' +
                    '"AcquirerReference": "000000"' +
                '},' +
                '"PaymentMeans": {' +
                    '"Brand": {' +
                        '"PaymentMethod": "SAFERPAYTEST",' +
                        '"Name": "Saferpay Test Card"' +
                    '},' +
                    '"DisplayText": "9123 45xx xxxx 1234",' +
                    '"Card": {' +
                        '"MaskedNumber": "912345xxxxxx1234",' +
                        '"ExpYear": 2015,' +
                        '"ExpMonth": 9,' +
                        '"HolderName": "Max Mustermann",' +
                        '"CountryCode": "CH"' +
                    '}' +
                '}' +
            '}';
        return response;
    }
    
    /*
    Account accountRecord = TestObjectFactory.getPersonAccount();
    insert accountRecord;
    Opportunity opportunityRecord = TestObjectFactory.getOpportunity(accountRecord.Id);
    insert opportunityRecord;
    Payment__c paymentRecord = TestObjectFactory.getPayment(opportunityRecord.Id);
    insert paymentRecord;
    String saferpayCaptureResponse = TestObjectFactory.getSaferpayCaptureResponse(paymentRecord.Id);
    */
    public static String getSaferpayCaptureResponse(String paymentId) {
        String response = 
            '{' +
                '"ResponseHeader": {' +
                    '"SpecVersion": "1.2",' +
                    '"RequestId": "' + paymentId + '"' +
                '},' +
                '"TransactionId": "723n4MAjMdhjSAhAKEUdA8jtl9jb",' +
                '"Date": "2015-01-30T12:45:22.258+01:00"' +
            '}';
        return response;
    }
    
    /*
    EsendexMessageDispatcherRequest esendexMessageDispatcherRequest = TestObjectFactory.getEsendexMessageDispatcherRequest();
    */
    public static EsendexMessageDispatcherRequest getEsendexMessageDispatcherRequest() {
        EsendexMessageDispatcherRequest request = new EsendexMessageDispatcherRequest();
        request.accountreference = 'test';
        request.defaultFrom = 'test';
        request.defaultType = 'SMS';
        request.defaultLang = 'de';
        request.defaultRetries = 1;
        request.defaultValidity = 1;
        request.defaultSendAt = 'test';
        request.defaultCharacterSet = 'GSM';
        EsendexMessageDispatcherRequest.Message message = new EsendexMessageDispatcherRequest.Message();
        message.fromNumber = 'test';
        message.toNumber = 'test';
        message.messageType = 'SMS';
        message.body = 'test';
        message.lang = 'de';
        message.retries = 1;
        message.validity = 1;
        message.characterSet = 'GSM';
        request.messages.add(message);
        return request;
    }
    
    /*
    HttpResponse esendexMessageDispatcherResponse = TestObjectFactory.getEsendexMessageDispatcherResponse();
    */
    public static HttpResponse getEsendexMessageDispatcherResponse() {
        HttpResponse response = new HttpResponse();
        response.setBody(
            '<messageheaders batchid="F8BF9867-FF81-49E4-ACC5-774DE793B776" xmlns="http://api.esendex.com/ns/">' +
                '<messageheader uri="https://api.esendex.com/v1.0/MessageHeaders/1183C73D-2E62-4F60-B610-30F160BDFBD5" id="1183C73D-2E62-4F60-B610-30F160BDFBD5" />' + 
            '</messageheaders>'
        );
        response.setStatusCode(200);
        return response;
    }
    
    /*
    HttpResponse esendexMessageHeaderResponse = TestObjectFactory.getEsendexMessageHeaderResponse();
    */
    public static HttpResponse getEsendexMessageHeaderResponse() {
        HttpResponse response = new HttpResponse();
        response.setBody(
            '<messageheader uri="https://api.esendex.com/v1.0/MessageHeaders/1183C73D-2E62-4F60-B610-30F160BDFBD5" id="1183C73D-2E62-4F60-B610-30F160BDFBD5" >' + 
                '<reference>EX0000000</reference>' +
                '<status>Failed</status>' +
                '<laststatusat>2012-01-01T12:00:05.000</laststatusat>' +
                '<submittedat>2012-01-01T12:00:02.000</submittedat>' +
                '<type>SMS</type>' +
                '<to>' +
                    '<phonenumber>447700900123</phonenumber>' +
                '</to>' +
                '<from>' +
                    '<phonenumber>44123456789</phonenumber>' +
                '</from>' +
                '<summary>Testing REST API</summary>' +
                '<body uri="http://api.esendex.com/v1.0/messageheaders/1B9A0D33-4B76-4A9D-919C-1165A9CF1565/body"/>' +
                '<direction>Outbound</direction>' +
                '<parts>1</parts>' +
                '<username>user@example.com</username>' +
                '<FailureReason>' +
                    '<Code>200</Code>' +
                    '<Detail>Temporary recipient issue (absent/error)</Detail>' +
                    '<PermanentFailure>false</PermanentFailure>' +
                '</FailureReason>' +
            '</messageheader>'
        );
        response.setStatusCode(200);
        return response;
    }
    
    /*
    Product2 productRecord = TestObjectFactory.getProduct();
    */
    public static Product2 getProduct() {
        Product2 record = new Product2(
            Name = 'Test',
            isActive = true
        );
        return record;
    }
    
    /*
    PriceBookEntry priceBookEntryRecord = TestObjectFactory.getPriceBookEntry();
    */
    public static PriceBookEntry getPriceBookEntry(ID productId) {
        String priceBookId = [SELECT Id FROM PriceBook2 WHERE isStandard = true LIMIT 1].Id;
        PriceBookEntry record = new PriceBookEntry(
            Product2ID = productId,
            PriceBook2Id = priceBookId,
            UnitPrice = 10,
            isActive = true
        );
        return record;
    }
    
    /*
    ClinicProduct__c clinicProductRecord = TestObjectFactory.getClinicProduct();
    */
    public static ClinicProduct__c getClinicProduct(ID productId, Id clinicId) {
        String priceBookId = [SELECT Id FROM PriceBook2 WHERE isStandard = true LIMIT 1].Id;
        ClinicProduct__c record = new ClinicProduct__c(
            Product__c = productId,
            Clinic__c = clinicId,
            ClinicOperationPrepaymentPrice__c = 10,
            ClinicOperationsAppointment_Price__c = 10
            
        );
        return record;
    }
    
    /*
    Oekopost__c OekopostCredentialsRecord = TestObjectFactory.getOekopostCredentials();
    */
    public static Oekopost__c getOekopostCredentials() {
        Oekopost__c record = new Oekopost__c(
            Name = 'Credentials',
            Username__c = 'Test',
            Password__c = 'Test'
        );
        return record;
    }
    
    /*
    HttpResponse googleServiceToken = TestObjectFactory.getGoogleServiceToken();
    */
    public static HttpResponse getGoogleServiceToken() {
        HttpResponse response = new HttpResponse();
        response.setBody(
            '{'+
                '"access_token" : "ya29.CjVVAxNQ655Ejx-2zwBZtXheH-mDcJh2O10F2DZ8tpRwEHvfhq8-M4fJSYstuOFP1y9bhX34Tw",'+
                '"token_type" : "Bearer",'+
                '"expires_in" : 3600'+
            '}'
        );
        response.setStatusCode(200);
        return response;
    }

    /*
    Saferpay__c saferpay = TestObjectFactory.getSaferpay();
    */
    public static Saferpay__c getSaferpay(Boolean useHttpsInterface) {
        Saferpay__c response = new Saferpay__c(
            Name = 'Config Sandbox',
            CustomerId__c = '',
            TerminalId__c = '',
            SpecVersion__c = '',
            ResultUrl__c = '',
            NotifyUrl__c = '',
            CssUrl__c = '',
            NotifyAddress__c = '',
            UseHttpsInterface__c = useHttpsInterface
        );
        return response;
    }

    public static Account createDoctor(String docName, String currencyIsoCode, String brand, Boolean toInsert) {
        
        Account doctor = new Account(
            Name = docName,
            RecordTypeId = RecordTypeSelector.getRecordTypeId('Account', RecordTypeSelector.ACCOUNT_DOCTOR),
            CurrencyIsoCode = currencyIsoCode,
            Brand__c = brand
        );

        if(toInsert) {
            insert doctor;
        }

        return doctor;
    }

    public static Account createDoctor(Boolean toInsert) {

        return createDoctor(DOCTORS_NAME, 'EUR', 'MO', toInsert);
    }

    public static Account createPatient(String patientLastName, String currencyIsoCode, String brand, Boolean toInsert) {
        
        Account patient = new Account(
            LastName = patientLastName,
            RecordTypeId = RecordTypeSelector.getRecordTypeId('Account', RecordTypeSelector.PERSON_ACCOUNT_PATIENT),
            CurrencyIsoCode = currencyIsoCode,
            Brand__c = 'MO'
        );

        if(toInsert) {
            insert patient;
        }

        return patient;
    }

    public static Account createPatient(Boolean toInsert) {

        return createPatient(PATIENTS_NAME, 'EUR', 'MO', toInsert);
    }

    public static Account createPatient(String name, Boolean toInsert) {

        return createPatient(name, 'EUR', 'MO', toInsert);
    }

    public static MD_Day_Location__c createMdDayLocation(String locationName, Id recordTypeId, String city, String street, String postalCode, String additionalAddressInfo, String comments, String overnightInvoiceIssuedBy, String roomFeeModel, String anesthesiaFeeModel, String clinicLocation, String email, Integer pricePerHour, Integer overtimePenalty, String bernachtungskosten, String materiallager, String anesthesiaInfoForClinics, Boolean toInsert) {

        MD_Day_Location__c mdDayLocation = new MD_Day_Location__c(
            Name = locationName,
            RecordTypeId = recordTypeId,
            City__c = city,
            Street__c = street,
            Post_code__c = postalCode,
            Additional_Address_Information__c = additionalAddressInfo,
            Comments__c = comments,
            Overnight_Invoice_issued_by__c = overnightInvoiceIssuedBy,
            Room_Fee_Model__c = roomFeeModel,
            Anesthesia_Fee_Model__c = anesthesiaFeeModel,
            ClinicLocation__c = clinicLocation,
            Email__c = email,
            Price_Per_Hour__c = pricePerHour,
            Overtime_Penalty__c = overtimePenalty,
            bernachtungskosten__c = bernachtungskosten,
            Materiallager__c = materiallager,
            Anesthesia_Information_for_Clinics__c = anesthesiaInfoForClinics
        );

        if(toInsert) {
            insert mdDayLocation;
        }
        
        return mdDayLocation;
    }

    public static MD_Day_Location__c createMdDayLocation(String name, Id recordTypeId, String city, Boolean toInsert) {

        return createMdDayLocation(
            name,
            recordTypeId,
            city,
            'Hauptstrasse',
            '02888',
            'Additional address info',
            'Some comments',
            'Medidate',
            'Flat fee per surgery',
            'Fixed Fee for some time + Fee per Time Unit',
            'MO clinic',
            'email@example.com',
            50,
            5,
            'we',
            'Material',
            'Anesthesia Information',
            toInsert
        );
    }

    public static MD_Day_Location__c createPreExMdDayLocation(String name, String city, Boolean toInsert) {

        return createMdDayLocation(
            name,
            RecordTypeSelector.getRecordTypeId('MD_Day_Location__c', RecordTypeSelector.MD_DAY_LOCATION_PRE_EX),
            city,
            toInsert
        );
    }

    public static MD_Day_Location__c createOperationMdDayLocation(String name, String city, Boolean toInsert) {

        return createMdDayLocation(
            name,
            RecordTypeSelector.getRecordTypeId('MD_Day_Location__c', RecordTypeSelector.MD_DAY_LOCATION_OPERATION),
            city,
            toInsert
        );
    }

    public static MD_Day__c createMdDay(Id recordTypeId, Id mdDayLocationId, Id doctorId, Date dateVal, Datetime startTime, Datetime endTime, Integer totalAvailableOperationTimeMinutes, Boolean toInsert) {

        MD_Day__c mdDay = new MD_Day__c(
            RecordTypeId = recordTypeId,
            MD_Day_Location__c = mdDayLocationId,
            Operation_Day_Start_Time__c = startTime,
            Operation_Day_End_Time__c = endTime,
            Date__c = dateVal,
            Total_available_Operation_Time_Minutes__c = totalAvailableOperationTimeMinutes,
            Surgeon_Clinic__c = doctorId
        );

        if(toInsert) {
            insert mdDay;
        }

        return mdDay;
    }

    public static MD_Day__c createPreExMdDay(Id mdDayLocationId, Id doctorId, Date dateVal, Datetime startTime, Datetime endTime, Integer totalAvailableOperationTimeMinutes, Boolean toInsert) {

        return createMdDay(
            RecordTypeSelector.getRecordTypeId('MD_Day__c', RecordTypeSelector.MD_DAY_PRE_EX),
            mdDayLocationId,
            doctorId,
            dateVal,
            startTime,
            endTime,
            totalAvailableOperationTimeMinutes,
            toInsert
        );
    }

    public static MD_Day__c createMdDay(Id recordTypeId, Id mdDayLocationId, Id doctorId, Boolean toInsert) {

        Datetime tomorrow = Datetime.now().addDays(1);

        return createMdDay(
            recordTypeId,
            mdDayLocationId,
            doctorId,
            tomorrow.date(),
            Datetime.newInstance(tomorrow.year(), tomorrow.month(), tomorrow.day(), 7, 0, 0),
            Datetime.newInstance(tomorrow.year(), tomorrow.month(), tomorrow.day(), 12, 0, 0),
            300,
            toInsert
        );
    }

    public static MD_Day__c createPreExMdDay(Id mdDayLocationId, Id doctorId, Boolean toInsert) {

        return createMdDay(
            RecordTypeSelector.getRecordTypeId('MD_Day__c', RecordTypeSelector.MD_DAY_PRE_EX),
            mdDayLocationId,
            doctorId,
            toInsert
        );
    }

    public static MD_Day__c createOperationMdDay(Id mdDayLocationId, Id doctorId, Boolean toInsert) {

        return createMdDay(
            RecordTypeSelector.getRecordTypeId('MD_Day__c', RecordTypeSelector.MD_DAY_OPERATION),
            mdDayLocationId,
            doctorId,
            toInsert
        );
    }

    public static Clinic_Appointment__c createClinicAppointment(Id recordTypeId, String appName, Id doctorId, Id clinicLocationId, Id mdDayId, Id oppId, Id availableSlot, Id appCounterId, Datetime appDate, Datetime startDate, Datetime endDate, String appType, String appStatus, Boolean toInsert) {

        Clinic_Appointment__c clinicAppointment = new Clinic_Appointment__c(
            RecordTypeId = recordTypeId,
            Name = appName,
            Clinic__c = doctorId,
            MD_Day_Location__c = clinicLocationId,
            MD_Day__c = mdDayId,
            Opportunity__c = oppId,
            MOAvailability__c = availableSlot,
            Appointment_Counter__c = appCounterId,
            Appointment_Date__c = appDate,
            CS_Start_Date__c = startDate,
            CS_End_Date__c = endDate,
            Apppointment_Type__c = appType,
            Appointment_Status__c = appStatus
        );

        if(toInsert) {
            insert clinicAppointment;
        }

        return clinicAppointment;
    }

    public static Clinic_Appointment__c createBookedOperationClinicAppointment(Id doctorId, Id clinicLocationId, Id mdDayId, Id oppId, Id availableSlotId, Id appCounterId, Datetime appDate, Datetime startDate, Datetime endDate, String appType, String appStatus, Boolean toInsert) {

        return createClinicAppointment(
            RecordTypeSelector.getRecordTypeId('Clinic_Appointment__c', RecordTypeSelector.CLINIC_APP_OPERATION_DATE),
            'Operation appointment',
            doctorId,
            clinicLocationId,
            mdDayId,
            oppId,
            availableSlotId,
            appCounterId,
            appDate,
            startDate,
            endDate,
            null,
            'Reserved',
            toInsert
        );
    }

    public static Clinic_Appointment__c insertBookedOperationClinicAppointment(Id doctorId, Id clinicLocationId, Id mdDayId, Id oppId, Id availableSlotId, Id appCounterId, Datetime appDate, Datetime startDate, Datetime endDate, String appType, String appStatus) {

        Clinic_Appointment__c operationAppointment = createBookedOperationClinicAppointment(
            doctorId,
            clinicLocationId,
            mdDayId,
            oppId,
            availableSlotId,
            appCounterId,
            appDate,
            startDate,
            endDate,
            null,
            'Reserved',
            true
        );

        return operationAppointment;
    }

    public static Opportunity createOpportunity(String oppName, Id recordTypeId, Id patientId, Id doctorId, Integer operationDuration, Id caretaker,
                                                Date closeDate, String stage, String paymentType, Boolean showUpControl, Datetime appointmentDate,
                                                String brand, Boolean toInsert) {

        Opportunity opportunity = new Opportunity(
            Name = oppName,
            RecordTypeId = recordTypeId,
            AccountId = patientId,
            Clinic__c = doctorId,
            Operation_Duration_Minutes__c = operationDuration,
            VU_OP_Caretaker__c = caretaker,
            CloseDate = closeDate,
            StageName = stage,
            PaymentType__c = paymentType,    
            Show_Up_Control__c = showUpControl,
            AppointmentDate__c = appointmentDate,
            Brand__c = brand
        );
        
        if(toInsert) {
            insert opportunity;
        }

        return opportunity;
    }

    public static Opportunity createOpportunity(String oppName, Id recordTypeId, Id patientId, Id doctorId, Integer operationDuration, Boolean toInsert) {

        return createOpportunity(
            oppName,
            recordTypeId,
            patientId,
            doctorId,
            operationDuration,
            (Id) UserInfo.getUserId(),
            Date.today().addDays(7),
            'Open',
            'Pre-Payment',
            true,
            System.now().addDays(1),
            'MO',
            toInsert
        );
    }

    public static Appointment_Counter__c createAppointmentCounter(Id accId, String appCounterMatching, Boolean toInsert) {

    	Appointment_Counter__c appointmentCounter = new Appointment_Counter__c(
            Surgeon__c = accId, 
            Appointment_Counter_Matching__c = appCounterMatching
        );  
        
        if(toInsert) {
            insert appointmentCounter;
        }
        
        return appointmentCounter;
    }

    public static Appointment_Counter__c createAppointmentCounter(Id accId, Boolean toInsert) {

        return createAppointmentCounter(accId, 'Test1', toInsert);
    }

    public static Product2 createProduct(String productName, Boolean isActive, Boolean toInsert) {
        
        Product2 product = new Product2(
            Name = productName,
            isActive = isActive
        );

        if(toInsert) {
            insert product;
        }

        return product;
    }
    
    public static PriceBookEntry createPriceBookEntry(Id productId, Id pricebookId, Integer unitPrice, Boolean isActive, Boolean toInsert) {

        PriceBookEntry pricebookEntryRecord = new PriceBookEntry(
            Product2Id = productId,
            Pricebook2Id = priceBookId,
            UnitPrice = unitPrice,
            isActive = isActive
        );

        if(toInsert) {
            insert pricebookEntryRecord;
        }

        return pricebookEntryRecord;
    }
    
    public static ClinicProduct__c createClinicProduct(String name, Id productId, Id clinicId, String clinicOpDriving, String clinicOperationInfo, String clinicOperationMDPrice, String clinicOperationName, String clinicOperationSurgeonName, String clinicOperationAppDuration, Decimal clinicOperationPrepaymentPrice, String clinicOperationsAppointmentType, Boolean isInactive, Decimal averageOpPrice, Boolean toInsert) {
        
        ClinicProduct__c clinicProduct = new ClinicProduct__c(
            Name = name,
            Product__c = productId,
            Clinic__c = clinicId,
            ClinicOpDriving__c = clinicOpDriving,
            ClinicOperationInformation__c = clinicOperationInfo,
            ClinicOperationMedidatePrice__c = clinicOperationMDPrice,
            ClinicOperationName__c = clinicOperationName,
            ClinicOperationSurgeonName__c = clinicOperationSurgeonName,
            ClinicOperationsAppointmentDuration__c = clinicOperationAppDuration,
            ClinicOperationPrepaymentPrice__c = clinicOperationPrepaymentPrice,
            ClinicOperationsAppointmentType__c = clinicOperationsAppointmentType,
            INAKTIV_Clinic_Product__c = isInactive,
            AverageOPPrice__c = averageOpPrice
        );

        if(toInsert) {
            insert clinicProduct;
        }

        return clinicProduct;
    }

    public static ClinicProduct__c createClinicProduct(String name, Id productId, Id clinicId, Boolean toInsert) {

        return createClinicProduct(
            name,
            productId,
            clinicId,
            'in Begleitung erscheinen',
            'Additional information',
            'ab 1000 Euro',
            'Vertical Facelift',
            'Dr. Markus Schultz',
            '30 min',
            39.0,
            'Voruntersuchung',
            false,
            2500.0,
            toInsert
        );
    }

    public static Payment__c createPayment(String name, Id oppId, Decimal paymentAmount, Date paymentDate, Date paymentDueDate, Date invoiceDate, String transactionStatus,
                                            String type, String brand, String paymentId, Boolean paidHelper, String paymentMethod, Boolean toInsert) {

        Payment__c payment = new Payment__c(
            Name = name,
            Opportunity__c = oppId,
            PaymentAmount__c = paymentAmount,
            PaymentDate__c = paymentDate,
            PaymentDueDate__c = paymentDueDate,
            InvoiceDate__c = invoiceDate,
            TransactionStatus__c = transactionStatus,
            Type__c = type,
            Brand__c = brand,
            PaymentID__c = paymentId,
            PaidHelper__c = paidHelper,
            PaymentMethod__c = paymentMethod    // PaymentMethod__c = 'test' skips a Webservice call so no mock is needed
        );

        if(toInsert) {
            insert payment;
        }

        return payment;
    }

    public static Payment__c createPayment(Id oppId, Boolean toInsert) {

        return createPayment(
            'paymentName',
            oppId,
            39.0,
            Date.today(),
            Date.today() + 1,
            Date.today(),
            'Paid',
            'Patient invoice',
            'MO',
            'paymentUniqueId',
            true,
            'test',
            toInsert
        );
    }

    public static Medical_product__c createMedicalProduct(String productName, Id accId, String orderNo, String color, String provider, String mainCategory,
                                                             Decimal price, String productArt, String productSubart, String size, Boolean isInactive,
                                                             Boolean toInsert) {

        Medical_product__c medicalProduct = new Medical_product__c(
            Name = productName,
            Account__c = accId,
            Bestellnummer__c = orderNo,
            Color__c = color,
            Hersteller__c = provider, 
            Oberkategorie__c = mainCategory,
            Preis__c = price,
            Productart__c = productArt,
            Produkt_Subart__c = productSubart,
            Size__c = size,
            Inactive__c = isInactive
        );

        if(toInsert) {
            insert medicalProduct;
        }

        return medicalProduct;
    }

    public static Medical_product__c createMedicalProduct(Id accId, Boolean toInsert) {

        return createMedicalProduct(
            'Test Medical Product',
            accId,
            '123465789',
            'Schwarz',
            'Lipoelastic',
            'Comfort',
            60.0,
            'Mieder',
            'Herrenwäsche',
            '-L',
            false,
            toInsert
        );
    }

    public static Order_review__c createOrderReview(String name, Id product1, Id product2, Id product3, Id product4, Id product5, Boolean toInsert) {

        Order_review__c orderReview = new Order_review__c(
            Name = name,
            Product_1__c = product1,
            Product_2__c = product2,
            Product_3__c = product3,
            Product_4__c = product4,
            Product_5__c = product5
        );

        if(toInsert) {
            insert orderReview;
        }

        return orderReview;
    }

    public static Surgery_controlling__c createSurgeryControlling(String name, Id oppId, Decimal noOfSurgeriesPerDay, Date scCreationDate, String status,
                                                                    Boolean toInsert) {

        Surgery_controlling__c surgeryControlling = new Surgery_controlling__c(
            Name = name,
            Opportunity__c = oppId,
            Number_of_Surgeries_on_Day__c = noOfSurgeriesPerDay,
            SC_Creation_date__c = scCreationDate,
            Status__c = status
        );

        if(toInsert) {
            insert surgeryControlling;
        }

        return surgeryControlling;
    }

    public static Surgery_controlling__c createSurgeryControlling(Id oppId, Boolean toInsert) {

        return createSurgeryControlling(
            'K-1219-0005',
            oppId,
            1.0,
            Date.today(),
            'Active',
            toInsert
        );
    }

    public static KVA__c createKVA(String name, Id surgeryControlling, Id oppId, Boolean bhvSent, Date operationDateBooked, Decimal operationPriceBooked,
                                    String paymentStatus, String paymentType, String productBooked, Decimal receivedAmount, String status,
                                    Boolean faqSent, Boolean moAppointment, String insuranceCostShow, Boolean resendKVA, Boolean include5Discount,
                                    Boolean dontTriggerKvaProcess, Boolean cancellationToBillingRequested, Boolean toInsert) {

        KVA__c kva = new KVA__c(
            Name = name,
            Surgery_controlling__c = surgeryControlling,
            Opportunity__c = oppId,
            BHV_sent__c = bhvSent,
            Operation_date_booked__c = operationDateBooked,
            Operation_price_booked__c = operationPriceBooked,
            Payment_status__c = paymentStatus,
            Payment_type__c = paymentType,
            Product_booked__c = productBooked,
            Received_amount__c = receivedAmount,
            Status__c = status,
            FAQ_sent__c = faqSent,
            MO_Appointment__c = moAppointment,
            Insurance_cost_show__c = insuranceCostShow,
            Resend_KVA__c = resendKVA,
            Include_5_discount__c = include5Discount,
            Do_not_trigger_KVA_process__c = dontTriggerKvaProcess,
            Cancellation_to_Billing_requested__c = cancellationToBillingRequested
        );

        if(toInsert) {
            insert kva;
        }

        return kva;
    }

    public static KVA__c createKVA(Id surgeryControlling, Id oppId, Boolean toInsert) {

        return createKVA(
            'K-1219-0005-12',
            surgeryControlling,
            oppId,
            false,
            Date.today() + 1,
            1000.0,
            'Completed',
            'Full payment',
            'A product booked',
            1000.0,
            'Active',
            true,
            false,
            'No',
            false,
            false,
            false,
            false,
            toInsert
        );
    }

    public static Paid_invoice__c createPaidInvoice(String name, Id kvaId, String invoiceType, Id oppId, String status, Decimal invoiceValFinanceDept,
                                                    String newInvoiceId, Boolean toInsert) {

        Paid_invoice__c paidInvoice = new Paid_invoice__c(
            Name = name,
            KVA__c = kvaId,
            Invoice_type__c = invoiceType,
            Opportunity__c = oppId,
            Status__c = status,
            Invoice_value_Finance_dept__c = invoiceValFinanceDept,
            New_Invoice_ID__c = newInvoiceId
        );

        if(toInsert) {
            insert paidInvoice;
        }

        return paidInvoice;
    }

    public static Paid_invoice__c createPaidInvoice(Id kvaId, Id oppId, Boolean toInsert) {

        return createPaidInvoice(
            'R-1219-405040',
            kvaId,
            'Rechnung',
            oppId,
            'Active',
            199.0,
            '35600MD',
            toInsert
        );
    }

    public static EmailTemplate createEmailTemplate(String name, String developerName, String type, Id folderId, String subject, String htmlBody, Boolean toInsert) {

        EmailTemplate template = new EmailTemplate(
            Name = name,
            DeveloperName = developerName,
            TemplateType = type,
            FolderId = folderId,
            Subject = subject,
            HtmlValue = htmlBody
        );

        if(toInsert) {
            insert template;
        }

        return template;
    }

    public static EmailTemplate createEmailTemplate(String devName, Boolean toInsert) {

        return createEmailTemplate(
            devName,
            devName,
            'custom',
            UserInfo.getOrganizationId(),
            'Email template subject test',
            '<html><head></head><body>Email template body</body></html>',
            toInsert
        );
    }
}