@isTest(SeeAllData=true)
public class LeadConvertClass_Test {
    
    public static testmethod void LeadCreation () {
    List<String> LeadIds = new List<String>();
    
    // Create a new lead
    Lead NewLead = new Lead ();
    NewLead.FirstName = 'Mika';
    NewLead.LastName = 'Mikic';
    NewLead.Email = 'tisisis@tetet.com';
    insert NewLead;

    // Add id of newly created lead to string list 
    LeadIds.add(NewLead.id);
    
    // Call for the invocable class
    LeadConvertClass.ConvertLead(LeadIds);
    
    
    }
}