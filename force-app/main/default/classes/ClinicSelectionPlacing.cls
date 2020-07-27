public with sharing class ClinicSelectionPlacing {
    public String baseUrl { get; private set; }
    private Map<String, String> quesrySortValueMap = new Map<String, String>{
            'MD_Day_Location__c' => 'MD_Day__r.MD_Day_Location__c',
            'Surgeon_Clinic__c' => 'Clinic__r.Name',
            'Priority__c' => 'Clinic__r.Priority__c',
            'OP_Standorte__c' => 'Clinic__r.OP_Standorte__c',
            'Date' => 'MD_Day__r.Date__c',
            //'Distance' => 'DISTANCE(Clinic__r.ShippingAddress, GEOLOCATION(:latitude, :longitude), \'km\')',
            'Distance' => 'DISTANCE(MD_Day__r.MD_Day_Location__r.Location__c, GEOLOCATION(:latitude, :longitude), \'km\')',
            'Medidate_Rented_Space__c' => 'MD_Day__r.MD_Day_Location__r.Medidate_Rented_Space__c'
    };
    private Map<String, Boolean> sortWrapperMap = new Map<String, Boolean>{
            'distance' => false,
            'priority' => false,
            'doctorName' => false,
            'mDDayLocationName' => false,
            'price' => false,
            'Date' => true,
            'productName' => false,
            'oPLocations' => false,
            'availableAppointments' => false
    };
    public SelectedObject obj { get; set; }
    public String sortKey {
        get {
            return sortKey;
        }
        set {
            //if the column is clicked on then switch between Ascending and Descending modes
           
            if (value != null) {
                if (value == sortKey)
                    sortDirection = (sortDirection == 'ASC') ? 'DESC' : 'ASC'; else sortDirection = 'ASC';
            }
            sortKey = value;
        }
    }
    private String sortDirection = 'ASC';
    private String sortExp = 'Distance';
    public String sortExpression {
        get {
            return sortExp;
        }
        set {
            //if the column is clicked on then switch between Ascending and Descending modes
            if (value == sortExp)
                sortDirection = (sortDirection == 'ASC') ? 'DESC' : 'ASC'; else sortDirection = 'ASC';
            sortKey = null;
            sortExp = value;
        }
    }
    public String getSortDirection() {
        if (sortExpression == null || sortExpression == '')
            return 'ASC'; else return sortDirection;
    }

    public void setSortDirection(String value) {
        sortDirection = value;
    }

    static final String JWTACCOUNT = '259361316346-j6g8e0ij1e379c2q2kot9cce1d4u5ad1@developer.gserviceaccount.com';
//    public String accessToken { get; set; }
    public String redirect { get; set; }

    public ClinicSelectionPlacing() {
        BaseDomain__mdt BaseDomain = [SELECT Url__c From BaseDomain__mdt Where DeveloperName = 'base'][0];
        baseUrl = BaseDomain.Url__c;
        String objId = ApexPages.currentPage().getParameters().get('id');
        String objType = ApexPages.currentPage().getParameters().get('objType');
        System.debug('*************objId***************   ' + objId);
        if (objType == 'Opportunity') {
            setOpportunity(objId);
        } else if (objType == 'Lead') {
            setLead(objId);
        }
        this.redirect = '';
//        GoogleServiceV3 service = new GoogleServiceV3();
//        JWT jwt = new JWT(JWTACCOUNT);
//        service.authenticate(jwt);
//        accessToken = service.getToken();
    }

    private void setOpportunity(String objId) {
        Opportunity opp = [
                SELECT Id, Name, AccountId, ClinicProduct__c, OPFilter__c,ProductType__c,
                        Account.BillingLatitude, Account.BillingLongitude, Surgery__c, Brand__c
                FROM Opportunity
                WHERE Id = :objId
                LIMIT 1
        ];
        this.obj = new SelectedObject(
                opp.Name,
                opp.ClinicProduct__c,
                opp.Account.BillingLatitude,
                opp.Account.BillingLongitude,
                opp.Surgery__c,
                opp.ProductType__c,
                opp.Brand__c
        );
    }

    private void setLead(String objId) {
        Lead l = [
                SELECT Id, Name, Clinic__c, ClinicProduct__c, OPFilter__c, ProductType__c,
                        Latitude, Longitude, Surgery__c, Brand__c
                FROM Lead
                WHERE Id = :objId
                LIMIT 1
        ];
        this.obj = new SelectedObject(
                l.Name,
                l.ClinicProduct__c,
                l.Latitude,
                l.Longitude,
                l.Surgery__c,
                l.ProductType__c,
                l.Brand__c
        );
    }

    // Get product to match clinics selection for
    private List<ClinicProduct__c> getClinicProducts() {

        String whereQueryPart = '';
        String oPfiller = '';
        String productType = '';
        String recordId = '';
        String brand = this.obj.brand;
        if (this.obj.clinicProduct != null) {
            recordId = this.obj.clinicProduct;
            whereQueryPart = 'WHERE Id = :recordId';            
        } else {
            oPfiller = obj.oPFilter;
            productType = obj.productType;
            whereQueryPart += 'WHERE (Product__r.Category__c = \'Body\' OR Product__r.Category__c = \'Lasik\') ';
            whereQueryPart += 'AND Product__r.Surgery__c != \'\' ';
            whereQueryPart += 'AND Product__r.Surgery__c = :oPfiller ';
            whereQueryPart += 'AND ProductType__c = :productType';            
        }
        if (brand == 'MO') {
            whereQueryPart += ' AND Clinic__r.Brand__c like \'%' + brand + '%\'';
        }
        return Database.query(
                'SELECT  Id, Clinic__c, ClinicOperationMedidatePrice__c, Product__c, Product__r.Name, Name FROM ClinicProduct__c '
                        + whereQueryPart + ' AND Clinic__r.INAKTIV_Clinic__c  = false ' + ' AND INAKTIV_Clinic_Product__c = false '
        );

    }

    public List<SelectedClinic> getSelectedClinics() {
        List<SelectedClinic> result = new List<SelectedClinic>();
        // Select Clinic Products that links needed product and clinics
        // Also retrieve stored info
        List<ClinicProduct__c> clinicProducts = getClinicProducts();
        // Get needed clinics
        // We put the linicProduct for each clinic, because it contains needed information
        Map<Id, ClinicProduct__c> clinicIdAndProductMap = new Map<Id, ClinicProduct__c>();
        for (ClinicProduct__c clinicProduct : clinicProducts) {
            clinicIdAndProductMap.put(clinicProduct.Clinic__c, clinicProduct);
        }
        // Getfilter record type by name
        Id recordTypeId = [SELECT id from RecordType where DeveloperName = 'Pre_ex_Location' and sObjectType = 'MD_Day_Location__c'].Id;
        // Select Clinic Appointments with needed data from both sides (MD Day Location and Clinic)
        List<Clinic_Appointment__c> clinicAppointments = getApointments(clinicIdAndProductMap.keySet(), recordTypeId, obj.latitude, obj.longitude);
        /*------------------------*/
        
        Map<Id, Map<Id, Integer>> avaliableAppointmentsMap = new Map<Id, Map<Id, Integer>>();
        Map<Id, Map<Id, Date>> mdDatesMap = new Map<Id, Map<Id, Date>>();
       
        Datetime dateFrom = Datetime.now();
        Date dateTo = Date.today().addDays(21);
        for (AggregateResult availableAppointment : [SELECT COUNT(Id)appCount, MD_Day_Location__c, Clinic__c 
                                                  FROM Clinic_Appointment__c 
                                                  WHERE CS_Start_Date__c >= :dateFrom 
                                                    AND DAY_ONLY(CS_Start_Date__c) <= :dateTo
                                                    AND Appointment_Status__c = 'Available' 
                                                    AND RecordType.DeveloperName = 'Pre_Ex_Appointment'
                                                    AND Clinic__c IN :clinicIdAndProductMap.keySet()
                                                  GROUP BY Clinic__c, MD_Day_Location__c
                                                  LIMIT 200]) {
            
            if (availableAppointment.get('Clinic__c') != null && availableAppointment.get('MD_Day_Location__c') != null) {
                
                Id clinicId = (Id)availableAppointment.get('Clinic__c'); 
                Map<Id, Integer> clinicByCount = avaliableAppointmentsMap.get(clinicId);
            
                if (clinicByCount == null) clinicByCount = new Map<Id, Integer>();
                
                clinicByCount.put((Id)availableAppointment.get('MD_Day_Location__c'), (Integer)availableAppointment.get('appCount'));
                avaliableAppointmentsMap.put(clinicId, clinicByCount);                                            
            }                                     
        }
        
        for (AggregateResult mdDate : [
                                        SELECT  Clinic__c, MD_Day_Location__c, MIN(MD_Day__r.Date__c) minDate
                                        FROM Clinic_Appointment__c 
                                        WHERE (MD_Day__c != null AND MD_Day__r.Date__c >= TODAY)  
                                            AND Appointment_Status__c = 'Available' 
                                            AND Clinic__c IN :clinicIdAndProductMap.keySet()
                                        GROUP BY Clinic__c, MD_Day_Location__c
                                        LIMIT 200]) {
            
            if (mdDate.get('Clinic__c') != null && mdDate.get('MD_Day_Location__c') != null) {
                
                Id clinicId = (Id)mdDate.get('Clinic__c'); 
                Map<Id, Date> mdDatesByLocation = mdDatesMap.get(clinicId);
            
                if (mdDatesByLocation == null) mdDatesByLocation = new Map<Id, Date>();
                
                mdDatesByLocation.put((Id)mdDate.get('MD_Day_Location__c'), (Date)mdDate.get('minDate'));
                mdDatesMap.put(clinicId, mdDatesByLocation);                                            
            }                                     
        }
    
        /*---------------------------*/
        // Fill wrapper with needed info
        Set<String> addedMDDayLocations = new Set<String>();
        for (Clinic_Appointment__c clinicAppointment : clinicAppointments) {
            ClinicProduct__c clinicProduct = clinicIdAndProductMap.get(clinicAppointment.Clinic__c);
            // Do not add a MD Day Location if it already added
            String appointmentKey = String.valueOf(clinicAppointment.Clinic__c) + String.valueOf(clinicAppointment.MD_Day__r.MD_Day_Location__c);
            if (!addedMDDayLocations.contains(appointmentKey)) {
//                Decimal distance = (obj.noLocation
//                        ? 99999.99
//                        : Location.newInstance(obj.latitude, obj.longitude).getDistance(clinicAppointment.Clinic__r.ShippingAddress, 'km'));
                Decimal distance = (obj.noLocation ? 99999.99 : Location.newInstance(obj.latitude, obj.longitude).getDistance(clinicAppointment.MD_Day__r.MD_Day_Location__r.Location__c, 'km'));
                /*------------------------*/
                Integer availableAppointments = 0;
                Date minDate;
                
                Map<Id, Date> mdDatesByLocation = mdDatesMap.get(clinicAppointment.Clinic__c);
                if (mdDatesByLocation != null) minDate = mdDatesByLocation.get(clinicAppointment.MD_Day__r.MD_Day_Location__c);
                
                Map<Id, Integer> appointmentsByLocation = avaliableAppointmentsMap.get(clinicAppointment.Clinic__c);
                if (appointmentsByLocation != null) {
                    availableAppointments = appointmentsByLocation.get(clinicAppointment.MD_Day__r.MD_Day_Location__c);
                    if (availableAppointments == null) availableAppointments = 0;
                }
                
                /*-----------------------------*/
                result.add(new SelectedClinic(
                    clinicAppointment.MD_Day__r.MD_Day_Location__c, 
                    clinicAppointment.MD_Day__r.MD_Day_Location__r.Name, 
                    clinicAppointment.Clinic__c, 
                    clinicAppointment.Clinic__r.Name, 
                    clinicAppointment.Clinic__r.Priority__c, 
                    clinicAppointment.Clinic__r.OP_Standorte__c, 
                    clinicAppointment.MD_Day__r.MD_Day_Location__r.Location__Latitude__s, 
                    clinicAppointment.MD_Day__r.MD_Day_Location__r.Location__Longitude__s, 
                    distance, 
                    clinicProduct.ClinicOperationMedidatePrice__c, 
                    clinicProduct.Id, 
                    clinicProduct.Name, 
                    clinicProduct.Product__c, 
                    clinicProduct.Product__r.Name, 
                    clinicAppointment.MD_Day__r.MD_Day_Location__r.Medidate_Rented_Space__c, 
                    minDate == null ? '' : minDate.day() + '.' + minDate.month() + '.' + minDate.year(),
                    availableAppointments
                ));
                addedMDDayLocations.add(appointmentKey);
            }
        }
        if (sortKey != null && sortWrapperMap.containsKey(sortKey)) {
            result = sortClinics(result);
        }
        return result;
    }

    private List<Clinic_Appointment__c> getApointments(Set<Id> productSet, String recordTypeId, Decimal latitude, Decimal longitude) {
        String fullSortExpression = quesrySortValueMap.get(sortExp) + ' ' + sortDirection;
        system.debug(fullSortExpression);
        system.debug(sortExp);
        system.debug(sortDirection);
        String query = 'SELECT Id, MD_Day__r.Available__c, MD_Day__r.MD_Day_Location__c,MD_Day__r.MD_Day_Location__r.Name, ';
        query += 'MD_Day__r.MD_Day_Location__r.Medidate_Rented_Space__c, MD_Day__r.MD_Day_Location__r.Location__c, ';
        query += 'MD_Day__r.MD_Day_Location__r.Location__Latitude__s ,MD_Day__r.MD_Day_Location__r.Location__Longitude__s, ';
        query += 'Clinic__c, Clinic__r.Name, Clinic__r.Priority__c, Clinic__r.OP_Standorte__c, MD_Day__r.Date__c, ';
        query += 'Clinic__r.ShippingAddress, Clinic__r.ShippingLatitude, Clinic__r.ShippingLongitude ';
        query += 'FROM Clinic_Appointment__c ';
        query += 'WHERE MD_Day__r.Date__c >= TODAY AND Clinic__c IN :productSet AND MD_Day__r.MD_Day_Location__r.RecordTypeId = :recordTypeId ';
        //query += 'GROUP BY Clinic__r.Priority__c';
        if (sortKey == null) query += ' ORDER BY ' + fullSortExpression;
        
        List<Clinic_Appointment__c> clinicAppointments = new List<Clinic_Appointment__c>();

        for (Clinic_Appointment__c app:Database.query(query)) {
            //Filter here as there is no ability to use GEolocation field on WHERE clause
            if (app.MD_Day__r != null && app.MD_Day__r.Available__c > 0 && app.MD_Day__r.MD_Day_Location__r != null  && app.MD_Day__r.MD_Day_Location__r.Location__c != null) {
                clinicAppointments.add(app);
            }
        }
        return clinicAppointments;
    }
    
    @TestVisible
    private List<SelectedClinic> sortClinics(List<SelectedClinic> Clinics) {
        List<SelectedClinic> sortedList = new List<SelectedClinic>();
        List<CustomSorter> sortableCLinics = new List<CustomSorter>();
        Integer orderMultiplyer = 1;
        
        if (sortDirection == 'ASC') {
            orderMultiplyer = 1;
        } else {
            orderMultiplyer = -1;
        }
        //Boolean isDate = sortWrapperMap.get(sortKey);
        String valueType;
        
        for (SelectedClinic clinic : Clinics) {
            Object comparableValue;
            Decimal secondComparableValue = clinic.priority;
            if (sortKey == 'price' && clinic.price != null) comparableValue = Decimal.valueOf(clinic.price.replaceAll('[^0-9]', ''));
            
            if (sortKey == 'productName' && clinic.productName != null) comparableValue = clinic.clinicProductName;
            
            if (sortKey == 'mDDayLocationName' && clinic.mDDayLocationName != null) comparableValue = clinic.mDDayLocationName;
            
            if (sortKey == 'doctorName' && clinic.doctorName != null) comparableValue = clinic.doctorName;
            
            if (sortKey == 'priority' && clinic.priority != null) comparableValue = clinic.priority;
            
            if (sortKey == 'oPLocations' && clinic.oPLocations != null) comparableValue = clinic.oPLocations;
            
            if (sortKey == 'distance' && clinic.distance != null) comparableValue = clinic.distance;
            
            if (sortKey == 'availableAppointments' && clinic.availableAppointments != null) comparableValue = Decimal.valueOf(clinic.availableAppointments);
            
            if (sortKey == 'Date') comparableValue = String.isNotBlank(clinic.mdDate) ? Date.parse(clinic.mdDate) : Date.today().addDays(-1);            
          
            sortableCLinics.add(new CustomSorter(clinic, orderMultiplyer, comparableValue, secondComparableValue));
        }
        sortableCLinics.sort();
        for (CustomSorter sortedObj : sortableCLinics) {
            sortedList.add((SelectedClinic) sortedObj.obj);
            System.debug((SelectedClinic) sortedObj.obj);
        }
        return sortedList;
    }
    // A wrapper to carry unified Opportunity/Lead data
    public class SelectedObject {
        public String name { get; set; }
        public Id clinicProduct { get; set; }
        public Decimal latitude { get; set; }
        public Decimal longitude { get; set; }
        public String oPFilter { get; set; }
        public String productType { get; set; }
        public String brand { get; set; }
        public Boolean noLocation;

        public SelectedObject(String name,
                Id clinicProduct,
                Decimal latitude,
                Decimal longitude,
                String oPFilter,
                String productType,
                String brand) {
            this.name = name;
            this.clinicProduct = clinicProduct;
            this.latitude = latitude;
            this.longitude = longitude;
            this.oPFilter = oPFilter;
            this.productType = productType;
            this.brand = brand;
            this.noLocation = false;
            if (this.latitude == null || this.longitude == null) {
                this.latitude = 0;
                this.longitude = 0;
                noLocation = true;
            }
        }
    }

    // A wrapper for a selected clinic data
    // We use a wrapper, because data from multiple objects should be associated
    public class SelectedClinic {
        public Id mDDayLocationId { get; set; }
        public String mDDayLocationName { get; set; }
        public Id doctorId { get; set; }
        public String doctorName { get; set; }
        public Decimal priority { get; set; }
        public String oPLocations { get; set; }
        public Decimal latitude { get; set; }
        public Decimal longitude { get; set; }
        public Decimal distance { get; set; }
        public String price { get; set; }
        public Id productId { get; set; }
        public String productName { get; set; }
        public Boolean rentedSpace { get; set; }
        public String mdDate { get; set; }
        public String clinicProductRecId { get; set; }
        public String clinicProductName { get; set;}
        public Integer availableAppointments { get; set;}

        public SelectedClinic(Id mDDayLocationId,
                String mDDayLocationName,
                Id doctorId,
                String doctorName,
                Decimal priority,
                String oPLocations,
                Decimal latitude,
                Decimal longitude,
                Decimal distance,
                String price,
                Id clinicProductRecId,
                String clinicProductName,
                Id productId,
                String productName,
                Boolean rentedSpace,
                String mdDate,
                Integer availableAppointments) {
            this.mDDayLocationId = mDDayLocationId;
            this.mDDayLocationName = mDDayLocationName;
            this.doctorId = doctorId;
            this.doctorName = doctorName;
            this.priority = priority;
            this.oPLocations = oPLocations;
            this.latitude = latitude;
            this.longitude = longitude;
            this.distance = distance.setScale(2);
            this.price = price;
            this.mdDate = mdDate;
            this.productId = productId;
            this.productName = productName;
            this.rentedSpace = rentedSpace;
            this.clinicProductName = clinicProductName;
            this.clinicProductRecId = clinicProductRecId;
            this.availableAppointments = availableAppointments;
        }
    }
}