public with sharing class ClinicSelectionInformationController {

    @AuraEnabled
    public static Information getInformation(String recordId) {
        if (isOpportunity(recordId)) {
            return new Information(selectOpportunity(recordId));
        } else if (isLead(recordId)) {
            System.debug(new Information(selectLead(recordId)));
            return new Information(selectLead(recordId));
        } else {
            runAuraHandledException(Label.No_data_for_showing);
            return new Information();
        }
    }

    @AuraEnabled
    public static void setInformation(String recordId, String info) {
        if(String.isNotBlank(info)) {
            Map<String, Object> information = (Map<String, Object>) JSON.deserializeUntyped(info);
            if (isOpportunity(recordId)) {
                setOpportunityInformation(recordId, information);
            } else if (isLead(recordId)) {
                setLeadInformation(recordId, information);
            }
        } else {
            System.debug('setInformation error');
            runAuraHandledException(Label.No_data_for_updating);
        }
    }

    private static Boolean isOpportunity(String opportunityId) {
        Boolean isOppId = false;
        if(String.isNotBlank(opportunityId)) {
            try {
                isOppId = Schema.Opportunity.SObjectType == Id.valueOf(opportunityId).getSobjectType();
            } catch (Exception ex) {
                runAuraHandledException(ex.getMessage());
            }
        }
        return isOppId;
    }

    private static Boolean isLead(String leadId) {
        Boolean isLeadId = false;
        if(String.isNotBlank(leadId)) {
            try {
                isLeadId = Schema.Lead.SObjectType == Id.valueOf(leadId).getSobjectType();
            } catch (Exception ex) {
                runAuraHandledException(ex.getMessage());
            }
        }
        return isLeadId;
    }

    private static Opportunity selectOpportunity(Id opportunityId) {
        return [
            SELECT Id, AccountId, PaymentType__c, MedidateComments__c,
                PreviousOrCurrentHealthCondition__c, PreviousSurgeriesInclNHS__c,
                Smoker__c, MedicineInclContraceptiveMed__c, HaveAnesthesiaBefore__c,
            	Account.Haben_Sie_Allergien__c, CopeWellWithAnesthesia__c, Family_Planning__c,
                Account.Salutation, Account.FirstName, Account.LastName,
                Account.Profession__pc, Account.PatientDateofBirth__pc, BMI__c,
                Account.Phone, Account.PersonMobilePhone, Account.PersonEmail,
                Account.BillingStreet, Account.BillingCity, Account.BillingPostalCode,
                Account.BillingCountryCode, Account.PatientContactAgree__pc,
                Account.PatientContactAgreeDetails__pc, Account.PatientHealthInsurance__pc
            FROM Opportunity
            WHERE Id = :opportunityId
        ];
    }

    private static Lead selectLead(Id leadId) {
        return [
            SELECT Id, Salutation, FirstName, LastName,
                Date_of_Birth__c, Smoker__c,
                Phone, MobilePhone, Email, BMI__c,
                Street, City, PostalCode, CountryCode,
                Patient_Contact_Agree__c, Patient_Contact_Agree_Details__c,
                Health_Insurance__c, Payment_Type__c, Profession__c, Medidate_comments__c,
                Previous_or_current_health_condition__c, Medicine_incl_Contraceptive_med__c,
                Previous_surgeries_incl_NHS__c, Have_anesthesia_before__c,
            	Haben_Sie_Allergien__c, Cope_well_with_anaesthesia__c, Family_Planning__c
            FROM Lead
            WHERE Id = :leadId
        ];
    }

    private static void setOpportunityInformation(Id recordId, Map<String, Object> information) {
        Opportunity oppInfo = selectOpportunity(recordId);
        List<SObject> updateSObjects = new List<SObject>();
        if (oppInfo != null && oppInfo.AccountId != null) {

            oppInfo.PaymentType__c = (String) getValue(information.get('paymentType'));
            oppInfo.MedidateComments__c = (String) getValue(information.get('comments'));
            oppInfo.PreviousOrCurrentHealthCondition__c = (String) getValue(information.get('healthCondition'));
            oppInfo.Smoker__c = (Boolean) getValue(information.get('smoker'));
            string aaa;
            /*
            if(!String.isBlank(((String)getValue(information.get('BMI'))))){
                oppInfo.BMI__c = Decimal.valueOf((String) getValue(information.get('BMI')));
            }
            else{
                oppInfo.BMI__c = null;
            }
            */
			if(getValue(information.get('BMI')) instanceof Decimal && (Decimal)getValue(information.get('BMI')) != null){
                oppInfo.BMI__c = Decimal.valueOf((Integer)getValue(information.get('BMI')));
            } else if (getValue(information.get('BMI')) instanceof String && !String.isBlank(((String)getValue(information.get('BMI'))))) {
                oppInfo.BMI__c = Decimal.valueOf((String) getValue(information.get('BMI')));
            }
            else{
                oppInfo.BMI__c = null;
            }            
            
            oppInfo.MedicineInclContraceptiveMed__c = (String) getValue(information.get('contraceptive'));
            oppInfo.PreviousSurgeriesInclNHS__c = (String) getValue(information.get('nhs'));
            oppInfo.HaveAnesthesiaBefore__c = (String) getValue(information.get('anesthesia'));
            
            /*----------------------------*/
            oppInfo.Account.Haben_Sie_Allergien__c = (String) getValue(information.get('allergies'));
            oppInfo.Family_Planning__c = (String) getValue(information.get('familyPlanning'));
            oppInfo.CopeWellWithAnesthesia__c = (String) getValue(information.get('copeWellWithAnaesthesia'));            
            /*----------------------------*/
            updateSObjects.add(oppInfo);

            oppInfo.Account.Salutation = (String) getValue(information.get('salutation'));
            oppInfo.Account.FirstName = (String) getValue(information.get('firstName'));
            oppInfo.Account.LastName = (String) getValue(information.get('lastName'));
            oppInfo.Account.Profession__pc = (String) getValue(information.get('profession'));
            oppInfo.Account.PatientDateofBirth__pc = Date.valueOf((String)getValue(information.get('dateofBirth')));
            oppInfo.Account.Phone = (String) getValue(information.get('phone'));
            oppInfo.Account.PersonMobilePhone = (String) getValue(information.get('mobilePhone'));
            oppInfo.Account.PersonEmail = (String) getValue(information.get('email'));
            oppInfo.Account.BillingStreet = (String) getValue(information.get('street'));
            oppInfo.Account.BillingCity = (String) getValue(information.get('city'));
            oppInfo.Account.BillingPostalCode = (String) getValue(information.get('postalCode'));
            oppInfo.Account.BillingCountryCode = (String) getValue(information.get('countryCode'));
            oppInfo.Account.PatientContactAgree__pc = (String) getValue(information.get('contactAgree'));
            oppInfo.Account.PatientContactAgreeDetails__pc = (String) getValue(information.get('contactAgreeDetails'));
            oppInfo.Account.PatientHealthInsurance__pc = (String) getValue(information.get('healthInsurance'));

            updateSObjects.add(oppInfo.Account);
        }

        updateSObjects(updateSObjects);
    }

    private static void setLeadInformation(Id recordId,  Map<String, Object> information) {
        Lead leadInfo = selectLead(recordId);
        leadInfo.Payment_Type__c = (String) getValue(information.get('paymentType'));
        leadInfo.Salutation = (String) getValue(information.get('salutation'));
        leadInfo.FirstName = (String) getValue(information.get('firstName'));
        leadInfo.LastName = (String) getValue(information.get('lastName'));
        leadInfo.Date_of_Birth__c = Date.valueOf((String)getValue(information.get('dateofBirth')));
        leadInfo.Phone = (String) getValue(information.get('phone'));
        leadInfo.MobilePhone = (String) getValue(information.get('mobilePhone'));
        leadInfo.Email = (String) getValue(information.get('email'));
        leadInfo.Street = (String) getValue(information.get('street'));
        leadInfo.City = (String) getValue(information.get('city'));
        leadInfo.PostalCode = (String) getValue(information.get('postalCode'));
        leadInfo.CountryCode = (String) getValue(information.get('countryCode'));
        leadInfo.Patient_Contact_Agree__c = (String) getValue(information.get('contactAgree'));
        leadInfo.Patient_Contact_Agree_Details__c = (String) getValue(information.get('contactAgreeDetails'));
        leadInfo.Health_Insurance__c = (String) getValue(information.get('healthInsurance'));
        leadInfo.Profession__c = (String) getValue(information.get('profession'));
        leadInfo.Medidate_comments__c = (String) getValue(information.get('comments'));
        leadInfo.Previous_or_current_health_condition__c = (String) getValue(information.get('healthCondition'));
        leadInfo.Smoker__c = (Boolean) getValue(information.get('smoker'));
        leadInfo.Medicine_incl_Contraceptive_med__c = (String) getValue(information.get('contraceptive'));
        leadInfo.Previous_surgeries_incl_NHS__c = (String) getValue(information.get('nhs'));
        leadInfo.Have_anesthesia_before__c = (String) getValue(information.get('anesthesia'));        
        /*------------------------------*/
        leadInfo.Haben_Sie_Allergien__c = (String) getValue(information.get('allergies'));        
        leadInfo.Family_Planning__c = (String) getValue(information.get('familyPlanning'));
        leadInfo.Cope_well_with_anaesthesia__c = (String) getValue(information.get('copeWellWithAnaesthesia'));
        /*------------------------------*/
        /*
        if(!String.isBlank(((String)getValue(information.get('BMI'))))){
                leadInfo.BMI__c = Decimal.valueOf((Integer)getValue(information.get('BMI')));
            }
            else{
                leadInfo.BMI__c = null;
            }
        */
        if(getValue(information.get('BMI')) instanceof Decimal && (Decimal)getValue(information.get('BMI')) != null){
                leadInfo.BMI__c = Decimal.valueOf((Integer)getValue(information.get('BMI')));
            } else if (getValue(information.get('BMI')) instanceof String && !String.isBlank(((String)getValue(information.get('BMI'))))) {
                leadInfo.BMI__c = Decimal.valueOf((String) getValue(information.get('BMI')));
            }
            else{
                leadInfo.BMI__c = null;
            } 
        /*
        if(Decimal.valueOf((Integer)getValue(information.get('BMI'))) != null){
                leadInfo.BMI__c = Decimal.valueOf((Integer)getValue(information.get('BMI')));
            }
            else{
                leadInfo.BMI__c = null;
            }
		*/
        System.debug(leadInfo);
        updateSObjects(new List<SObject> { leadInfo });
    }


    private static Object getValue(Object infoField) {
        return ((Map<String, Object>)infoField).get('value');
    }

    private static void updateSObjects(List<SObject> sObjs) {
        if(sObjs != null && !sObjs.isEmpty()) {
            try {                
                update sObjs;                
            } catch (DmlException dmlExceptionex) {
                runAuraHandledException(dmlExceptionex.getMessage());
            }
        }
    }

    private static void runAuraHandledException(String errorMsg) {
        AuraHandledException e = new AuraHandledException(errorMsg);
        e.setMessage(errorMsg);
        throw e;
    }

    public class Information {
        @AuraEnabled public Boolean isLead {
            get {
                if(isLead == null) {
                    isLead = false;
                }
                return isLead;
            } private set;
        }
        @AuraEnabled public Boolean isOpportunity {
            get {
                if(isOpportunity == null) {
                    isOpportunity = false;
                }
                return isOpportunity;
            } private set;
        }
        @AuraEnabled public InformationItem salutation { get; set; }
        @AuraEnabled public InformationItem firstName { get; set; }
        @AuraEnabled public InformationItem lastName { get; set; }
        @AuraEnabled public InformationItem profession { get; set; }
        @AuraEnabled public InformationItem dateofBirth { get; set; }
        @AuraEnabled public InformationItem phone { get; set; }
        @AuraEnabled public InformationItem mobilePhone { get; set; }
        @AuraEnabled public InformationItem email { get; set; }
        @AuraEnabled public InformationItem street { get; set; }
        @AuraEnabled public InformationItem city { get; set; }
        @AuraEnabled public InformationItem postalCode { get; set; }
        @AuraEnabled public InformationItem countryCode { get; set; }
        @AuraEnabled public InformationItem contactAgree { get; set; }
        @AuraEnabled public InformationItem contactAgreeDetails { get; set; }
        @AuraEnabled public InformationItem healthInsurance { get; set; }
        @AuraEnabled public InformationItem paymentType { get; set; }

        @AuraEnabled public InformationItem comments { get; set; }
        @AuraEnabled public InformationItem healthCondition { get; set; }
        @AuraEnabled public InformationItem smoker { get; set; }
        @AuraEnabled public InformationItem BMI { get; set; }
        @AuraEnabled public InformationItem contraceptive { get; set; }
        @AuraEnabled public InformationItem nhs { get; set; }
        @AuraEnabled public InformationItem anesthesia { get; set; }
        /*-----------------------------*/
        @AuraEnabled public InformationItem allergies { get; set; }
        @AuraEnabled public InformationItem familyPlanning { get; set; }
        @AuraEnabled public InformationItem copeWellWithAnaesthesia { get; set; }
        /*-----------------------------*/

        public Information () {}

        public Information (Lead leadInfo) {
            isLead = true;
            if (leadInfo != null) {
                paymentType = setItem(leadInfo.Payment_Type__c, Lead.Payment_Type__c.getDescribe());
                salutation = setItem(leadInfo.Salutation, Lead.Salutation.getDescribe());
                firstName = setItem(leadInfo.FirstName, Lead.FirstName.getDescribe());
                lastName = setItem(leadInfo.LastName, Lead.LastName.getDescribe());
                dateofBirth = setItem(leadInfo.Date_of_Birth__c, Lead.Date_of_Birth__c.getDescribe());
                phone = setItem(leadInfo.Phone, Lead.Phone.getDescribe());
                mobilePhone = setItem(leadInfo.MobilePhone, Lead.MobilePhone.getDescribe());
                email = setItem(leadInfo.Email, Lead.Email.getDescribe());
                street = setItem(leadInfo.Street, Lead.Street.getDescribe());
                city = setItem(leadInfo.City, Lead.City.getDescribe());
                postalCode = setItem(leadInfo.PostalCode, Lead.PostalCode.getDescribe());
                countryCode = setItem(leadInfo.CountryCode, Lead.CountryCode.getDescribe());
                contactAgree = setItem(leadInfo.Patient_Contact_Agree__c, Lead.Patient_Contact_Agree__c.getDescribe());
                contactAgreeDetails = setItem(leadInfo.Patient_Contact_Agree_Details__c, Lead.Patient_Contact_Agree_Details__c.getDescribe());
                healthInsurance = setItem(leadInfo.Health_Insurance__c, Lead.Health_Insurance__c.getDescribe());
                profession = setItem(leadInfo.Profession__c, Lead.Profession__c.getDescribe());

                comments = setItem(leadInfo.Medidate_comments__c, Lead.Medidate_comments__c.getDescribe());
                healthCondition = setItem(leadInfo.Previous_or_current_health_condition__c, Lead.Previous_or_current_health_condition__c.getDescribe());
                smoker = setItem(leadInfo.Smoker__c, Lead.Smoker__c.getDescribe());
                contraceptive = setItem(leadInfo.Medicine_incl_Contraceptive_med__c, Lead.Medicine_incl_Contraceptive_med__c.getDescribe());
                nhs = setItem(leadInfo.Previous_surgeries_incl_NHS__c, Lead.Previous_surgeries_incl_NHS__c.getDescribe());
                anesthesia = setItem(leadInfo.Have_anesthesia_before__c, Lead.Have_anesthesia_before__c.getDescribe());
                BMI = setItem(leadInfo.BMI__c, Lead.BMI__c.getDescribe());
                
                /*----------------------------*/
                allergies = setItem(leadInfo.Haben_Sie_Allergien__c, Lead.Haben_Sie_Allergien__c.getDescribe());
                familyPlanning = setItem(leadInfo.Family_Planning__c, Lead.Family_Planning__c.getDescribe());
                copeWellWithAnaesthesia = setItem(leadInfo.Cope_well_with_anaesthesia__c, Lead.Cope_well_with_anaesthesia__c.getDescribe());
                /*----------------------------*/
            }
        }

        public Information (Opportunity oppInfo) {
            isOpportunity = true;
            if (oppInfo != null && oppInfo.AccountId != null) {
                paymentType = setItem(oppInfo.PaymentType__c, Opportunity.PaymentType__c.getDescribe());
                salutation = setItem(oppInfo.Account.Salutation, Account.Salutation.getDescribe());
                firstName = setItem(oppInfo.Account.FirstName, Account.FirstName.getDescribe());
                lastName = setItem(oppInfo.Account.LastName, Account.LastName.getDescribe());
                profession = setItem(oppInfo.Account.Profession__pc, Account.Profession__pc.getDescribe());
                dateofBirth = setItem(oppInfo.Account.PatientDateofBirth__pc, Account.PatientDateofBirth__pc.getDescribe());
                phone = setItem(oppInfo.Account.Phone, Account.Phone.getDescribe());
                mobilePhone = setItem(oppInfo.Account.PersonMobilePhone, Account.PersonMobilePhone.getDescribe());
                email = setItem(oppInfo.Account.PersonEmail, Account.PersonEmail.getDescribe());
                street = setItem(oppInfo.Account.BillingStreet, Account.BillingStreet.getDescribe());
                city = setItem(oppInfo.Account.BillingCity, Account.BillingCity.getDescribe());
                postalCode = setItem(oppInfo.Account.BillingPostalCode, Account.BillingPostalCode.getDescribe());
                countryCode = setItem(oppInfo.Account.BillingCountryCode, Account.BillingCountryCode.getDescribe());
                contactAgree = setItem(oppInfo.Account.PatientContactAgree__pc, Account.PatientContactAgree__pc.getDescribe());
                contactAgreeDetails = setItem(oppInfo.Account.PatientContactAgreeDetails__pc, Account.PatientContactAgreeDetails__pc.getDescribe());
                healthInsurance = setItem(oppInfo.Account.PatientHealthInsurance__pc, Account.PatientHealthInsurance__pc.getDescribe());

                comments = setItem(oppInfo.MedidateComments__c, Opportunity.MedidateComments__c.getDescribe());
                healthCondition = setItem(oppInfo.PreviousOrCurrentHealthCondition__c, Opportunity.PreviousOrCurrentHealthCondition__c.getDescribe());
                smoker = setItem(oppInfo.Smoker__c, Opportunity.Smoker__c.getDescribe());
                contraceptive = setItem(oppInfo.MedicineInclContraceptiveMed__c, Opportunity.MedicineInclContraceptiveMed__c.getDescribe());
                nhs = setItem(oppInfo.PreviousSurgeriesInclNHS__c, Opportunity.PreviousSurgeriesInclNHS__c.getDescribe());
                anesthesia = setItem(oppInfo.HaveAnesthesiaBefore__c, Opportunity.HaveAnesthesiaBefore__c.getDescribe());
                BMI = setItem(oppInfo.BMI__c, Opportunity.BMI__c.getDescribe());
                
                /*----------------------*/
                allergies = setItem(oppInfo.Account.Haben_Sie_Allergien__c, Account.Haben_Sie_Allergien__c.getDescribe());
                familyPlanning = setItem(oppInfo.Family_Planning__c, Opportunity.Family_Planning__c.getDescribe());
                copeWellWithAnaesthesia = setItem(oppInfo.CopeWellWithAnesthesia__c, Opportunity.CopeWellWithAnesthesia__c.getDescribe());
                /*----------------------*/
            }
        }

        private InformationItem setItem(Object value, DescribeFieldResult discribeField) {
            return new InformationItem(value, discribeField);
        }
    }
        
    
    public class LabelWrapper {
        @AuraEnabled public String value { get; set; }
        @AuraEnabled public String label { get; set; }
        public LabelWrapper(String value, String label) {
            this.value = value;
            this.label = label;
        }
    }
    
    public class InformationItem {
        @AuraEnabled public Object value { get; set; }
        @AuraEnabled public String label { get; set; }
        @AuraEnabled public List<LabelWrapper> values { get; set; }
        public InformationItem(Object value, DescribeFieldResult discribeField) {
            this.value = value;
            this.label = discribeField.getLabel();
            this.values = new List<LabelWrapper>();
            List<PicklistEntry> entries = discribeField.getPicklistValues();
            if(entries != null && !entries.isEmpty()) {
                for (PicklistEntry entry : entries) {
                    this.values.add(new LabelWrapper (entry.getValue(), entry.getLabel()));
                }
            }
        }
    }
}