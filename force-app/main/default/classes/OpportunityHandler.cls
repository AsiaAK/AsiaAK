public class OpportunityHandler {    
    public static final string key='m87jx29gt43qz56dr53sy84ck97of62n';
    public static final string url = 'https://www.trustpilot.de/evaluate/medidate.de';
    public  static string email='';
    public static string fullname='';
    
    public void beforeInsert(List<Opportunity> newList) {
        OpportunityHelper.updateRecordType(newList);
    }
    
    public static void afterInsert(List<Opportunity> newList) {
        OpportunityHandler.trustpilot(newList);
    }
      public static void afterUpdate(List<Opportunity> newList,Map<Id, Opportunity> oldMap) {
       Opportunity oldOppRecord;
        if(checkRecursive.runOnce == true){
            for(Opportunity opp : newList){
                oldOppRecord = oldMap.get(opp.Id);
                if(opp.stagename!=null && ( (opp.stagename=='Lost' && opp.stagename != oldOppRecord.stagename) || (opp.stagename=='Open' && opp.Pre_Ex_appointment_status__c=='Patient reschedule request' && opp.stagename != oldOppRecord.stagename) || ((opp.stagename=='Pre-Ex Paid' || opp.stagename=='Reserved' || opp.stagename=='Clinic Confirmed Pre-Ex' || opp.stagename=='Lost') && opp.Pre_Ex_appointment_status__c=='Rejected' )||(opp.stagename=='Pre-Ex Paid' && opp.Pre_Ex_appointment_status__c=='Open')||(opp.stagename=='Reserved' )||(opp.stagename=='Clinic Confirmed Pre-Ex' && opp.stagename != oldOppRecord.stagename))){
                    system.debug('i am in');
                    OpportunityHandler.updateGoogleCalenderEventTitle(opp.id);
                }
                
               
            }
        }
    }
    
    public static void trustpilot(List<Opportunity> newList) {
    system.debug('List of opps are: ' + newList);    
        List<Opportunity> listopp=new List<Opportunity>();
        List<Feedback__c> lstFeedbackCreate = new List<Feedback__c>();
        Feedback__c objFeedback;
        string strReviewURL = '';
        string strParamA = '';
        string strParamB = '';
        string strParamC = '';
        string strParamE = '';
        string hash='';
        
        
        for(Opportunity opp:[select id, name, accountid, account.firstname,account.lastname,account.PersonEmail from opportunity where id in:newList]){
        System.debug('Opp ID: ' + opp);
            // sample URL
            // https://www.trustpilot.com/evaluate/meinedomain.de?a=A1B2C3&b={BASE64(Max@beispiel.de)}&c={encodeURI(Max Mustermann)}&e={SHA1(TrustpilotSecretMax@beispiel.deA1B2C3)}
            strParamA = opp.id;
            if(opp.account.PersonEmail!=null)
            email=opp.account.PersonEmail;
            system.debug('11email '+email); 
            strParamB = EncodingUtil.base64Encode(Blob.valueOf(email));
            system.debug('11strParamB '+strParamB ); 
            if(opp.account.firstname!=null)
            fullname=String.valueOf(opp.account.firstname);
            if(opp.account.lastname!=null)
            fullname=String.valueOf(fullname+opp.account.lastname);
            system.debug('11fullname '+fullname); 
            strParamC =EncodingUtil.URLENCODE(fullname,'UTF-8');
            system.debug('11strParamC '+strParamC );
            //strParamB = '{BASE64(Max@beispiel.de)}';
            //strParamC = '{encodeURI(Max Mustermann)}';
            //strParamE = '{SHA1(TrustpilotSecretMax@beispiel.deA1B2C3)}';
            hash = key+email+opp.id;
            system.debug('11hash '+hash );
            strParamE = EncodingUtil.convertToHex(Crypto.generateDigest('SHA1',Blob.valueOf(hash)));
            system.debug('11strParamE '+strParamE );
            strReviewURL = 'https://www.trustpilot.de/evaluate/medidate.de?a=' + strParamA + '&b=' + strParamB + '&c=' + strParamC + '&e=' + strParamE;
            system.debug('11strReviewURL'+strReviewURL);
            listopp.add(opp);
            
            // Create Feedback record
            objFeedback = new Feedback__c();
            objFeedback.Account__c = opp.Accountid;
            objFeedback.Opportunity__c = opp.id;
            objFeedback.TrustPilotLink__c=strReviewURL;
            system.debug('11trustpilot link is'+objFeedback.TrustPilotLink__c);
            lstFeedbackCreate.add(objFeedback);
        }
        update listopp;
        
        if(!lstFeedbackCreate.isEmpty()){
            insert lstFeedbackCreate;
            system.debug('11record is'+lstFeedbackCreate[0].id);
        }
    }
    
@Future(callout=true)
     public static void updateGoogleCalenderEventTitle(Id OppId) {
     system.debug('i am in method');
    List<Opportunity> opplist= new list<Opportunity>();
    Opportunity opp1 = new Opportunity ();
    string eventstarttime='';
    string eventendtime='';
    string CalenderEventTitle='';
    for(Opportunity opp:[select id, name, accountid,stagename,Pre_Ex_appointment_status__c,Reason_lost__c,Account.Referral_Payment_Transaction_Status__c ,Clinic_Calendar_Event_Title__c,AppointmentCancelDate__c,Appointment_Confirmation_Date__c  ,ClinicCalendarIdAuto__c ,ClinicCalendarEventId__c ,clinic__r.ClinicCalendarKeyword__c,AppointmentDateCET__c,AppointmentDate__c,(select id,TransactionStatus__c from Payments__r ) from opportunity where id =:OppId])
    {
         CalenderEventTitle=opp.clinic__r.ClinicCalendarKeyword__c;
            if(opp.stagename=='Clinic Confirmed Pre-Ex')
                CalenderEventTitle=opp.clinic__r.ClinicCalendarKeyword__c + '_C_' + opp.Id;
            else if((opp.stagename=='Pre-Ex Paid' || opp.stagename=='Reserved' || opp.stagename=='Clinic Confirmed Pre-Ex' || opp.stagename=='Lost' )&& opp.Pre_Ex_appointment_status__c=='Rejected')
                CalenderEventTitle=opp.clinic__r.ClinicCalendarKeyword__c + '_NC_' + opp.Id;
           else if(opp.stagename=='Reserved')
                CalenderEventTitle=opp.clinic__r.ClinicCalendarKeyword__c + '_R_' + opp.Id;
          else if(opp.stagename=='Pre-Ex Paid' && opp.Pre_Ex_appointment_status__c=='Open')
                 CalenderEventTitle=opp.clinic__r.ClinicCalendarKeyword__c + '_B_' + opp.Id;   
          else if(opp.stagename=='Open' && opp.Pre_Ex_appointment_status__c=='Patient reschedule request')
                CalenderEventTitle=opp.clinic__r.ClinicCalendarKeyword__c;
          
        system.debug('@@@@@@@CalenderEventTitle is'+opp.Clinic_Calendar_Event_Title__c);
        system.debug('@@@@@@@CalenderEventTitle1 is'+CalenderEventTitle);
         GoogleServiceV3 service = new GoogleServiceV3();
    JWT jwt = new JWT('259361316346-j6g8e0ij1e379c2q2kot9cce1d4u5ad1@developer.gserviceaccount.com');
    service.authenticate(jwt);
    string accessToken = service.getToken();
    HttpRequest req = new HttpRequest();
    system.debug('@@@@@@@ClinicCalendarIdAuto__c is'+opp.ClinicCalendarIdAuto__c);
        system.debug('@@@@@@@ClinicCalendarEventId__c is'+opp.ClinicCalendarEventId__c);
        system.debug('@@@@@@@clinic__r.ClinicCalendarKeyword__c is'+opp.clinic__r.ClinicCalendarKeyword__c);
        system.debug('@@@@@@@AppointmentDateCET__c is'+opp.AppointmentDateCET__c);
        
        //req.setEndpoint('https://www.googleapis.com/calendar/v3/calendars/89gp1cto04hfl9j3jl3saukd58@group.calendar.google.com/events/6ikj8heiumkla826p75pccclt8?access_token='+accessToken);
        req.setEndpoint('https://www.googleapis.com/calendar/v3/calendars/' + opp.ClinicCalendarIdAuto__c + '/events/' + opp.ClinicCalendarEventId__c + '?access_token='+accessToken);
        req.setMethod('PUT');
        req.setHeader('content-type', 'application/json; charset=UTF-8');
        //system.debug('@@@@@@@' +opp.Clinic_Calendar_Event_Title__c);
        Datetime Date2017W = Datetime.newInstance(2017, 03, 26, 02, 00, 00);
        Datetime Date2017S = Datetime.newInstance(2017, 10, 29, 03, 00, 00);
        Datetime Date2018W = Datetime.newInstance(2018, 03, 25, 02, 00, 00);
        Datetime Date2018S = Datetime.newInstance(2018, 10, 28, 03, 00, 00);
        Datetime Date2019W = Datetime.newInstance(2019, 03, 31, 02, 00, 00);
        Datetime Date2019S = Datetime.newInstance(2019, 10, 27, 03, 00, 00);
        Datetime Date2020W = Datetime.newInstance(2020, 03, 29, 02, 00, 00);
        Datetime Date2020S = Datetime.newInstance(2020, 10, 25, 03, 00, 00);
        
        if(opp.AppointmentDate__c!=null && opp.AppointmentDate__c <= Date2017W){
            DateTime newDateTime = opp.AppointmentDate__c.addHours(-1);
            eventstarttime=newDateTime.format('yyyy-MM-dd\'T\'HH:mm:ss\'z\'');
            eventendtime=opp.AppointmentDate__c.format('yyyy-MM-dd\'T\'HH:mm:ss\'z\'');
            
        }
        else if(opp.AppointmentDate__c!=null && opp.AppointmentDate__c <= Date2017S && opp.AppointmentDate__c >= Date2017W){
            DateTime newDateTime = opp.AppointmentDate__c.addHours(-2);
            eventstarttime=newDateTime.format('yyyy-MM-dd\'T\'HH:mm:ss\'z\'');
            eventendtime=opp.AppointmentDate__c.addHours(-1).format('yyyy-MM-dd\'T\'HH:mm:ss\'z\'');
            
        
    }else if(opp.AppointmentDate__c!=null && opp.AppointmentDate__c <= Date2018W && opp.AppointmentDate__c >= Date2017S){
            DateTime newDateTime = opp.AppointmentDate__c.addHours(-1);
            eventstarttime=newDateTime.format('yyyy-MM-dd\'T\'HH:mm:ss\'z\'');
            eventendtime=opp.AppointmentDate__c.format('yyyy-MM-dd\'T\'HH:mm:ss\'z\'');
                        
    }else if(opp.AppointmentDate__c!=null && opp.AppointmentDate__c <= Date2018S && opp.AppointmentDate__c >= Date2018W){
            DateTime newDateTime = opp.AppointmentDate__c.addHours(-2);
            eventstarttime=newDateTime.format('yyyy-MM-dd\'T\'HH:mm:ss\'z\'');
            eventendtime=opp.AppointmentDate__c.addHours(-1).format('yyyy-MM-dd\'T\'HH:mm:ss\'z\'');
        
    }else if(opp.AppointmentDate__c!=null && opp.AppointmentDate__c <= Date2019W && opp.AppointmentDate__c >= Date2018S){
            DateTime newDateTime = opp.AppointmentDate__c.addHours(-1);
            eventstarttime=newDateTime.format('yyyy-MM-dd\'T\'HH:mm:ss\'z\'');
            eventendtime=opp.AppointmentDate__c.format('yyyy-MM-dd\'T\'HH:mm:ss\'z\'');
        
    }else if(opp.AppointmentDate__c!=null && opp.AppointmentDate__c <= Date2019S && opp.AppointmentDate__c >= Date2019W){
            DateTime newDateTime = opp.AppointmentDate__c.addHours(-2);
            eventstarttime=newDateTime.format('yyyy-MM-dd\'T\'HH:mm:ss\'z\'');
            eventendtime=opp.AppointmentDate__c.addHours(-1).format('yyyy-MM-dd\'T\'HH:mm:ss\'z\'');
            
    }else if(opp.AppointmentDate__c!=null && opp.AppointmentDate__c <= Date2020W && opp.AppointmentDate__c >= Date2019S){
            DateTime newDateTime = opp.AppointmentDate__c.addHours(-1);
            eventstarttime=newDateTime.format('yyyy-MM-dd\'T\'HH:mm:ss\'z\'');
            eventendtime=opp.AppointmentDate__c.format('yyyy-MM-dd\'T\'HH:mm:ss\'z\'');
        
    }else if(opp.AppointmentDate__c!=null && opp.AppointmentDate__c <= Date2020S && opp.AppointmentDate__c >= Date2020W){
            DateTime newDateTime = opp.AppointmentDate__c.addHours(-2);
            eventstarttime=newDateTime.format('yyyy-MM-dd\'T\'HH:mm:ss\'z\'');
            eventendtime=opp.AppointmentDate__c.addHours(-1).format('yyyy-MM-dd\'T\'HH:mm:ss\'z\'');
    }
        //req.setHeader('access_token', accessToken);
        //string strbody = '{ "summary": "Test Berlin Body", "end": { "dateTime": "2017-03-04T10:00:00-07:00" }, "start": { "dateTime": "2017-03-04T10:00:00-06:00" } }';
        //string keyword=opp.clinic__r.ClinicCalendarKeyword__c+opp.Clinic_Calendar_Event_Title__c
        //string strbody = '{ "summary": "' + opp.Clinic_Calendar_Event_Title__c+ '", "start": { "dateTime": "' + eventstarttime+ '" }, "end": { "dateTime": "' + eventendtime+ '" } }';
        string strbody = '{ "summary": "' + CalenderEventTitle + '", "start": { "dateTime": "' + eventstarttime+ '" }, "end": { "dateTime": "' + eventendtime+ '" } }';
        //string strbody = '{ "summary": ' + opp.clinic__r.ClinicCalendarKeyword__c + ', "start": { "dateTime": "' + opp.AppointmentDateCET__c  + '" }, "end": { "dateTime": "' + opp.AppointmentDateCET__c  + '" } }';
       
        system.debug('############'+strbody);
        req.setBody(strbody);
        Http http = new Http();
        HttpResponse res = new HttpResponse();
        if(Test.isRunningTest() == false){
            res = http.send(req);
        }
        system.debug('@@@@@@@output is'+res);
        system.debug('@@@@@@@output1 is'+res.getbody());
        
        opplist.add(opp);
      
      checkRecursive.runOnce = false;
   // update opplist;
    
 }  
 } 


}