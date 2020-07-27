public class wrapperclass {

public decimal sum{get;set;} 
public decimal netamount{get;set;}
public decimal vatamount{get;set;}
public integer count{get;set;} 
public string transactionstatus{get;set;} 
public string cliniccode{get;set;} 
public integer month{get;set;} 
public string monthname{get;set;}
public string year{get;set;} 
public string year1{get;set;}
public string ClinicName{get;set;}
public string ClinicBillingStreet{get;set;}
public string ClinicBillingPostalCode{get;set;}
public string ClinicBillingCity{get;set;}
//Map<String, String> monthMap= new Map<String, String>{'1' => 'Jan', '2' => 'Feb','3' => 'Mar', '4' => 'Apr','5' => 'May', '6' => 'Jun','7' => 'Jul', '8' => 'Aug','9' => 'Sep', '10' => 'Oct','11' => 'Nov', '12' => 'Dec'};
Map<Integer, String> monthMap= new Map<Integer, String>{1 => 'Jan', 2 => 'Feb',3 => 'Mar', 4 => 'Apr',5 => 'May', 6 => 'Jun',7 => 'Jul', 8 => 'Aug',9 => 'Sep', 10 => 'Oct',11 => 'Nov', 12 => 'Dec'};
public wrapperclass(AggregateResult ag) {


            count=integer.valueOf(ag.get('cnt'));
            month= integer.valueOf(ag.get('calMonth'));
            monthname= monthMap.get(month);
            year1=string.valueOf(ag.get('calYear'));
            year=year1.right(2);
            sum= (decimal)ag.get('totalamount');
            netamount=(decimal)ag.get('netamount');
            vatamount=(decimal)ag.get('vatamount');
            cliniccode=string.valueOf(ag.get('cc'));
            transactionstatus=string.valueOf(ag.get('ts'));
            ClinicName=string.valueOf(ag.get('clname'));
            ClinicBillingStreet=string.valueOf(ag.get('street'));
            ClinicBillingPostalCode=string.valueOf(ag.get('postcode'));
            ClinicBillingCity=string.valueOf(ag.get('city'));
}


}