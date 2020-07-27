({
    doInit : function(component) {
        // HARDCODE vfOrigin
        var vfOrigin = "https://" + component.get("v.vfHost");
        window.addEventListener("message", function(event) {
            if (event.origin !== vfOrigin) {
                // Not the expected origin: Reject the message!
                return;
            }
            console.log(event.data);
            component.set("v.filterFields", {
                "MD_Day_Location__c": event.data.split(';')[0] ,
                "Clinic__c": event.data.split(';')[1],
                "CustomCondition": " (((Lead__c = '" + component.get("v.recordId")
                + "' OR Opportunity__c = '" + component.get("v.recordId")
                + "') AND Appointment_Status__c = 'Reserved')"
                + " OR (Appointment_Status__c = 'Available' AND CS_Start_Date__c >= :currentTime))"
            });
            component.set("v.clinicProduct", event.data.split(';')[2]);
            
            console.log("Filter fields: " + component.get("v.filterFields"));
            
        }, false);
    },
    scriptsLoaded : function(component, event, helper) {
        helper.getEvents(component, event);
    },
    doSave : function (component, event, helper) {
        component.find("EventCalendar").doSave();
    }
})