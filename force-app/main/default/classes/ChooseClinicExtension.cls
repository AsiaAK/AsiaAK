public with sharing class ChooseClinicExtension {
    public Opportunity opp {get; set;}
    public Account oppAccount {get; set;}
    public Map<Id, List<ClinicProduct__c>> clinicProductsByClinicId {get;set;}
    public String accessToken {get; set;}
    public String redirect{get;set;}
    
    public ChooseClinicExtension(ApexPages.StandardController stdController) {
        this.redirect = '';
        this.opp = [SELECT Id, Name, AccountId, ProductType__c,CalendarTimeZone__c ,AppointmentDate__c , CurrencyIsoCode, OPFilter__c, Surgery__c, PaymentType__c, Test_Opportunity__c,Clinic__c, ClinicProduct__c, ClinicCalendarEventId__c, EmailBrochure__c, MedidateComments__c, AppointmentBookingDate__c,StageName  FROM Opportunity WHERE Id = :stdController.getId()];//
        if(opp.Test_Opportunity__c ==false)
        {
            this.oppAccount = [SELECT Id, isPersonAccount, FirstName, LastName, INAKTIV_Clinic__c,Salutation, Profession__pc, Phone, PersonEmail, PersonMobilePhone, PatientContactAgree__pc, PatientContactAgreeDetails__pc, PatientDateofBirth__pc, PatientHealthInsurance__pc, PatientWaitingForClinic__pc, PatientWhatsappAgree__pc, BillingStreet, BillingCity, BillingState, BillingStateCode , BillingCountry, BillingCountryCode,  BillingLatitude, BillingPostalCode, BillingLongitude, ClinicCalendarKeyword__c FROM Account WHERE isPersonAccount = true and Id =: opp.AccountId and INAKTIV_Clinic__c = false];
        this.clinicProductsByClinicId = new Map<Id, List<ClinicProduct__c>>();
        
        String clinicProductQuery = 'SELECT Id, Name, ClinicOperationPostPackage__c, ClinicOperationsAppointmentType__c, ClinicOperationInformation__c, ClinicOperationPrepaymentPrice__c, ' +
                                    'BrochureURL__c, ClinicOpDriving__c, ClinicOperationInfoLink__c, ClinicOperationMaterial__c, ClinicOperationName__c, ClinicOperationOneEyePrice__c, ClinicOperationPostCheckup__c, ' +
                                    'ClinicOperationPostLaser__c, ClinicOperationPostpaymentPrice__c, ClinicOperationsAppointmentDuration__c, ClinicOperationsAppointment_Price__c, ClinicOperationsAvailable__c, ' +
                                    'ClinicOperationSurgeonName__c, DaysNoContactHard__c, DaysNoContactSoft__c, OffsetAgainstSurgeryPrice__c, Product__c, ProductType__c, INAKTIV_Clinic_Product__c,' + 
                                    'ClinicOperationNormalPrice__c, ClinicOperationMedidatePrice__c, Clinic__c, Clinic__r.isPersonAccount, Clinic__r.Name, Clinic__r.Phone, Clinic__r.ClinicCalendarID__c, ' +
                                    'Clinic__r.FullRevAccount__c, Clinic__r.ShippingCity, Clinic__r.ClinicCalendarKeyword__c ' +
                                    'FROM ClinicProduct__c';
        if(this.opp.ClinicProduct__c != null) {
            this.clinicProductsByClinicId.put(this.opp.Clinic__c, (Database.query(clinicProductQuery + ' WHERE Id = \'' + this.opp.ClinicProduct__c +'\' AND INAKTIV_Clinic_Product__c = false')));
        } else {
            for(ClinicProduct__c clinicProduct :Database.query(clinicProductQuery + ' WHERE (Product__r.Category__c = \'Body\' OR Product__r.Category__c = \'Lasik\') AND Product__r.Surgery__c != \'\' AND Product__r.Surgery__c = \'' + opp.Surgery__c + '\' AND Clinic__r.ShippingCountry = \'' + oppAccount.BillingCountry + '\' AND ProductType__c = \'' + opp.ProductType__c + '\' AND INAKTIV_Clinic_Product__c = false order by Clinic__r.Name')) {
                if(!clinicProductsByClinicId.containsKey(clinicProduct.Clinic__c)) {
                    clinicProductsByClinicId.put(clinicProduct.Clinic__c, new List<ClinicProduct__c>());
                }
                clinicProductsByClinicId.get(clinicProduct.Clinic__c).add(clinicProduct);
            }
            
            if(clinicProductsByClinicId.isEmpty()) {
                for(ClinicProduct__c clinicProduct :Database.query(clinicProductQuery + ' WHERE (Product__r.Category__c = \'Body\' OR Product__r.Category__c = \'Lasik\') AND Product__r.OPFilter__c != \'\' AND Product__r.OPFilter__c = \'' + opp.OPFilter__c + '\' AND Clinic__r.ShippingCountry = \'' + oppAccount.BillingCountry + '\' AND ProductType__c = \'' + opp.ProductType__c + '\' AND INAKTIV_Clinic_Product__c = false order by Clinic__r.Name')) {
                    if(!clinicProductsByClinicId.containsKey(clinicProduct.Clinic__c)) {
                        clinicProductsByClinicId.put(clinicProduct.Clinic__c, new List<ClinicProduct__c>());
                    }
                    clinicProductsByClinicId.get(clinicProduct.Clinic__c).add(clinicProduct);
                }
            }
        }
        }
        else
        {
            this.oppAccount = [SELECT Id, isPersonAccount, FirstName, LastName, INAKTIV_Clinic__c,Salutation, Profession__pc, Phone, PersonEmail, PersonMobilePhone, PatientContactAgree__pc, PatientContactAgreeDetails__pc, PatientDateofBirth__pc, PatientHealthInsurance__pc, PatientWaitingForClinic__pc, PatientWhatsappAgree__pc, BillingStreet, BillingCity, BillingState, BillingStateCode , BillingCountry, BillingCountryCode,  BillingLatitude, BillingPostalCode, BillingLongitude, ClinicCalendarKeyword__c FROM Account WHERE isPersonAccount = true and Id =: opp.AccountId];
        this.clinicProductsByClinicId = new Map<Id, List<ClinicProduct__c>>();
        
        String clinicProductQuery = 'SELECT Id, Name, ClinicOperationPostPackage__c, ClinicOperationsAppointmentType__c, ClinicOperationInformation__c, ClinicOperationPrepaymentPrice__c, ' +
                                    'BrochureURL__c, ClinicOpDriving__c, ClinicOperationInfoLink__c, ClinicOperationMaterial__c, ClinicOperationName__c, ClinicOperationOneEyePrice__c, ClinicOperationPostCheckup__c, ' +
                                    'ClinicOperationPostLaser__c, ClinicOperationPostpaymentPrice__c, ClinicOperationsAppointmentDuration__c, ClinicOperationsAppointment_Price__c, ClinicOperationsAvailable__c, ' +
                                    'ClinicOperationSurgeonName__c, DaysNoContactHard__c, DaysNoContactSoft__c, OffsetAgainstSurgeryPrice__c, Product__c, ProductType__c, INAKTIV_Clinic_Product__c,' + 
                                    'ClinicOperationNormalPrice__c, ClinicOperationMedidatePrice__c, Clinic__c, Clinic__r.isPersonAccount, Clinic__r.Name, Clinic__r.Phone, Clinic__r.ClinicCalendarID__c, ' +
                                    'Clinic__r.FullRevAccount__c, Clinic__r.ShippingCity, Clinic__r.ClinicCalendarKeyword__c ' +
                                    'FROM ClinicProduct__c';
        if(this.opp.ClinicProduct__c != null) {
            this.clinicProductsByClinicId.put(this.opp.Clinic__c, (Database.query(clinicProductQuery + ' WHERE Id = \'' + this.opp.ClinicProduct__c +'\'')));
        } else {
            for(ClinicProduct__c clinicProduct :Database.query(clinicProductQuery + ' WHERE (Product__r.Category__c = \'Body\' OR Product__r.Category__c = \'Lasik\') AND Product__r.Surgery__c != \'\' AND Product__r.Surgery__c = \'' + opp.Surgery__c + '\' AND Clinic__r.ShippingCountry = \'' + oppAccount.BillingCountry + '\' AND ProductType__c = \'' + opp.ProductType__c + '\' order by Clinic__r.Name')) {
                if(!clinicProductsByClinicId.containsKey(clinicProduct.Clinic__c)) {
                    clinicProductsByClinicId.put(clinicProduct.Clinic__c, new List<ClinicProduct__c>());
                }
                clinicProductsByClinicId.get(clinicProduct.Clinic__c).add(clinicProduct);
            }
            
            if(clinicProductsByClinicId.isEmpty()) {
                for(ClinicProduct__c clinicProduct :Database.query(clinicProductQuery + ' WHERE (Product__r.Category__c = \'Body\' OR Product__r.Category__c = \'Lasik\') AND Product__r.OPFilter__c != \'\' AND Product__r.OPFilter__c = \'' + opp.OPFilter__c + '\' AND Clinic__r.ShippingCountry = \'' + oppAccount.BillingCountry + '\' AND ProductType__c = \'' + opp.ProductType__c + '\' order by Clinic__r.Name')) {
                    if(!clinicProductsByClinicId.containsKey(clinicProduct.Clinic__c)) {
                        clinicProductsByClinicId.put(clinicProduct.Clinic__c, new List<ClinicProduct__c>());
                    }
                    clinicProductsByClinicId.get(clinicProduct.Clinic__c).add(clinicProduct);
                }
            }
        }
        }
        
        GoogleServiceV3 service = new GoogleServiceV3();
        JWT jwt = new JWT('259361316346-j6g8e0ij1e379c2q2kot9cce1d4u5ad1@developer.gserviceaccount.com');
        service.authenticate(jwt);
        accessToken = service.getToken();
    }
    
    public List<Account> getClinics() {
        List<Account> clinics = new List<Account>();
        Set<Id> matchedClinicsId = clinicProductsByClinicId.keySet();
        if(opp.Test_Opportunity__c ==false && oppAccount != null && !matchedClinicsId.isEmpty()) {
            String query = 'SELECT Id, IsPersonAccount, Name, ClinicCalendarID__c, INAKTIV_Clinic__c,ShippingCity, ShippingStreet, ShippingLatitude, ShippingLongitude,ClinicCalendarKeyword__c FROM Account WHERE Id IN :matchedClinicsId AND ShippingLongitude != null AND ShippingLatitude != null AND INAKTIV_Clinic__c = false ';
            if(this.oppAccount.BillingLatitude != null && this.oppAccount.BillingLongitude != null) {
                query += ' order by DISTANCE(ShippingAddress, GEOLOCATION(' + oppAccount.BillingLatitude + ',' + oppAccount.BillingLongitude + '), \'km\')';
            }
           // query += ' limit 5';
            
            try {
                clinics = Database.query(query);
            }catch (Exception e) {}
        }else if (opp.Test_Opportunity__c == true && oppAccount != null && !matchedClinicsId.isEmpty()) {
            String query = 'SELECT Id, IsPersonAccount, Name, ClinicCalendarID__c, INAKTIV_Clinic__c,ShippingCity, ShippingStreet, ShippingLatitude, ShippingLongitude,ClinicCalendarKeyword__c FROM Account WHERE Id IN :matchedClinicsId AND ShippingLongitude != null AND ShippingLatitude != null ';
            if(this.oppAccount.BillingLatitude != null && this.oppAccount.BillingLongitude != null) {
                query += ' order by DISTANCE(ShippingAddress, GEOLOCATION(' + oppAccount.BillingLatitude + ',' + oppAccount.BillingLongitude + '), \'km\')';
            }
           // query += ' limit 5';
            
            try {
                clinics = Database.query(query);
            }catch (Exception e) {}
        }
        return clinics;
    }
    
    public PageReference confirmAppointment() {
        String selectedProductId = Apexpages.currentPage().getParameters().get('clinicProductId');
        String eventId = Apexpages.currentPage().getParameters().get('EventId');
        String appointmentDate = Apexpages.currentPage().getParameters().get('appointmentDate');
        String calendarTimeZone = Apexpages.currentPage().getParameters().get('calendarTimeZone');
        
        system.debug('selectedProductId is' +selectedProductId);
        system.debug('eventId is' +eventId);
        system.debug('appointmentDate is' +appointmentDate);
        system.debug('calendarTimeZone is' +calendarTimeZone);
        
        //create savepoint; if any error is thrown then we should roll back any updates
        Savepoint sp = Database.setSavepoint();
        
        if(opp.PaymentType__c == null) {
            ApexPages.addmessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Data cannot be saved. Please select Payment Type.'));
            return null;
        }
        
        try {
            update oppAccount;
        } catch (Exception e) {
            ApexPages.addmessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Account information could not be saved, please contact the administrator for more details.'));
            return null;
        }
        
        PriceBook2 priceBook = null;
        try {
            priceBook = [SELECT Id from PriceBook2 where isStandard = true and isActive = true];
        } catch (Exception e){
            ApexPages.addmessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'There is no active PriceBook. Please contact your administrator.'));
            Database.rollback(sp);
            return null;
        }
        
        ClinicProduct__c clinicProduct = null;
        try {
            clinicProduct = [SELECT Id, Name, ClinicOperationsAppointment_Price__c, Product__c, Clinic__c, ClinicOperationsAppointmentType__c , ClinicOperationPrepaymentPrice__c, ClinicOperationPostpaymentPrice__c FROM ClinicProduct__c WHERE Id = :selectedProductId];
        } catch (Exception e){
            ApexPages.addmessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Please choose a product before saving the changes.'));
            Database.rollback(sp);
            return null;
        }
        if(clinicProduct.ClinicOperationsAppointmentType__c == null) {
            ApexPages.addmessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'The clinic product is not proparly set. Please contact your administrator to set up the Clinic Operation Type field.'));
            Database.rollback(sp);
            return null;
        }
        
        PriceBookEntry pbe =  null;
        
        try {
            pbe = [SELECT Id from PriceBookEntry where Product2Id = :clinicProduct.Product__c and PriceBook2Id = :priceBook.Id and CurrencyIsoCode = :opp.CurrencyIsoCode];
        } catch (Exception e){
            ApexPages.addmessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'The product should have price book entry defined. Please contact your administrator.'));
            Database.rollback(sp);
            return null;
        }
        
        //check if there is a payment made already
        Integer paidPayments = 0;
        try {
            List<Payment__c> payments = [SELECT Id from Payment__c where Opportunity__c =: opp.Id and TransactionStatus__c = :System.Label.PaymentStatusPaid];
            paidPayments = payments.size();
        } catch (Exception e){}
        
        opp.PriceBook2Id = priceBook.Id;
        opp.ClinicProduct__c = clinicProduct.Id;
        system.debug('opp.ClinicCalendarEventId__c is' +opp.ClinicCalendarEventId__c);
        if(eventid != null && eventid != ''&& (opp.ClinicCalendarEventId__c==null || opp.ClinicCalendarEventId__c!=eventid))
        {
            system.debug('I am In');
            opp.ClinicCalendarEventId__c = eventId;
        }
        opp.Clinic__c = clinicProduct.Clinic__c;
        if(calendarTimeZone!=null && calendarTimeZone!=''&&  (opp.CalendarTimeZone__c==null || opp.CalendarTimeZone__c!= calendarTimeZone))
        {
            system.debug('I am In1');
            opp.CalendarTimeZone__c = calendarTimeZone;
        }
       // opp.StageName = (paidPayments == 0) ? System.Label.OpportunitStageReserved : System.Label.OpportunitStageClosedWon;
          opp.StageName = (paidPayments == 0) ? System.Label.OpportunitStageReserved : System.Label.OpportunityStagePreExPaid;
        if(appointmentDate != '') {
            List<String> dateFields = appointmentDate.split('/');
            opp.AppointmentDate__c = DateTime.newInstance(Integer.valueOf(dateFields[0]), Integer.valueOf(dateFields[1]), Integer.valueOf(dateFields[2]), Integer.valueOf(dateFields[3]), Integer.valueOf(dateFields[4]), 0);
           
        }
        if(opp.AppointmentBookingDate__c == null && opp.AppointmentDate__c !=null) {
                opp.AppointmentBookingDate__c = System.now();
                opp.AppointmentBookingAgentName__c = UserInfo.getName();
            }

        try {
            update opp;
        } catch (Exception e) {
            //ApexPages.addmessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Opportunity information could not be saved, please contact the administrator for more details.'));
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, e.getDmlMessage(0)));
            Database.rollback(sp);
            return null;
        }
        

        try {
            //clenup existing products
            List<OpportunityLineItem> existingProducts = [select Id from OpportunityLineItem where OpportunityId =: opp.Id];
            delete existingProducts;
        } catch (Exception e) {
            ApexPages.addmessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Existing products could not be removed from the opportunity, please contact the administrator for more details.'));
            Database.rollback(sp);
            return null;
        }
            
        //add new product
        OpportunityLineItem oppProd = new OpportunityLineItem();
        oppProd.OpportunityId = opp.Id;
        oppProd.PriceBookEntryId = pbe.Id;
        oppProd.Quantity = 1;
        oppProd.TotalPrice = (opp.PaymentType__c == System.label.OpportunityPaymentType_QuickCheck) ? 0 : ((opp.PaymentType__c == System.label.OpportunityPaymentType_PrePayment) ? clinicProduct.ClinicOperationPrepaymentPrice__c : clinicProduct.ClinicOperationPostpaymentPrice__c); 
        if(oppProd.TotalPrice == null) {
            ApexPages.addmessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Please make sure that Operation prices are set on clinic product. Please contact your administrator.'));
            Database.rollback(sp);
            return null;
        }
        try {
            insert oppProd;
        } catch (Exception e) {
            ApexPages.addmessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Product could not be added to the opportunity, please contact the administrator for more details.'));
            Database.rollback(sp);
            return null;
        }
        this.redirect = 'redirect';
        return null;
    }
}