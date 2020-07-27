public class LeadConvertClass {
    
    @InvocableMethod
    public static List<string> ConvertLead (List<String> LeadIds) {
      string accountid;
      Integer i;
      string leadid;
      List<String> AccIds = new List<String>(); 
        /*Get lead id from LeadsIds string list. It will always be one value in the list since on the other side flow needs to iterate trhrough each record in
         * with manual interaction*/ 
        For (i=0;i<LeadIds.size();i++){
            leadid = LeadIds.get(i);
            Database.LeadConvert lc = new Database.LeadConvert();
            lc.setLeadId(leadid);
            
            LeadStatus convertStatus = [SELECT Id,MasterLabel FROM LeadStatus WHERE IsConverted = true LIMIT 1];
            lc.setconvertedstatus(convertStatus.MasterLabel);
            
            Database.LeadConvertResult lcr = Database.convertLead(lc);
            System.assert(lcr.isSuccess());
            
            accountid = lcr.accountid;
            AccIds.add(accountid);
            
            
            
        }
        
        //Pass account id of the newly created account back to the flow
        return AccIds;
        
        
    }

}