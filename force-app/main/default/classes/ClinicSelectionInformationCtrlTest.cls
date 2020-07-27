@IsTest
private class ClinicSelectionInformationCtrlTest {

	@IsTest
	private static void checkGetInformation() {
        Account acc = initPersonAccount();
		Opportunity opp = initOpportunity(acc.Id);
		Lead lead = initLead(acc.Id);

		System.assertNotEquals(ClinicSelectionInformationController.getInformation(opp.Id), null);
		System.assertNotEquals(ClinicSelectionInformationController.getInformation(lead.Id), null);
	}

	@IsTest
	private static void checkSetInformation() {
        Account acc = initPersonAccount();
		Opportunity opp = initOpportunity(acc.Id);
		Lead lead = initLead(acc.Id);
		ClinicSelectionInformationController.Information  infOpp = new ClinicSelectionInformationController.Information(opp);
		ClinicSelectionInformationController.Information  infLead = new ClinicSelectionInformationController.Information(lead);
		ClinicSelectionInformationController.setInformation(opp.Id, JSON.serialize(infOpp));
		ClinicSelectionInformationController.setInformation(lead.Id, JSON.serialize(infLead));
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

	private static Opportunity initOpportunity(String clinicId) {
		Opportunity opportunity = new Opportunity(
			Name = 'Test1',
			StageName = 'Open',
			CloseDate = Date.today().addDays(3),
			Accountid = clinicId
		);
		insert opportunity;
		opportunity = selectOpportunity(opportunity.Id);
		return opportunity;
	}

	private static Lead initLead(String clinicId) {
		Id recordTypeId = Lead.getSObjectType().getDescribe().getRecordTypeInfosById().values()[0].getRecordTypeId();
		Lead lead = new Lead(
			LastName = 'leadToInsert',
			Email = 'test@test.de',
			RecordTypeId = recordTypeId,
			Company = 'Test',
            Account__c = clinicId,
			Date_of_Birth__c = Date.today());
		insert lead;
		return lead;
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
}