({
	initCmp: function(component) {
       // this.checkNumberOfPreMedAppointments(component);
       this.getOpportunity(component);
    },
    
    checkNumberOfPreMedAppointments: function(component) {
        var recordId = component.get("v.recordId");

        if (!$A.util.isEmpty(recordId)) {

            this.addAsyncProcess(component);

            var opportunityFilter = {
                recordId: recordId
            };

            var action = component.get("c.checkNumberOfPreMedAppointments");
            action.setParams({
                opportunityFilterJSON: JSON.stringify(opportunityFilter)
            });
            action.setCallback(this, function(data) {
                if (component.isValid()) {
                    this.removeAsyncProcess(component);

                    var response = JSON.parse(data.getReturnValue());

                    if (response.status === "success") {
                        var appointmentNumber = response.data.appointmentNumber

                        if (appointmentNumber == 0) {
                                this.getOpportunity(component);
                        } else {
                            this.showToast(component, "error", "Error", "There is already a pre-med appointment booked!");
                            $A.get("e.force:closeQuickAction").fire() ;
                        }
                    } else if (response.status === "warning") {
                        this.showToast(component, response.status, "Warning", response.message);
                    } else if (response.status === "error") {
                        this.showToast(component, response.status, "Error", response.message);
                    }
                }
            });
            $A.enqueueAction(action);
        }

    },

    getOpportunity: function(component) {
        var recordId = component.get("v.recordId");

        if (!$A.util.isEmpty(recordId)) {
            this.addAsyncProcess(component);

            var opportunityFilter = {
                recordId: recordId
            };

            var action = component.get("c.getOpportunity");
            action.setParams({
                opportunityFilterJSON: JSON.stringify(opportunityFilter)
            });
            action.setCallback(this, function(data) {
                if (component.isValid()) {
                    this.removeAsyncProcess(component);

                    var response = JSON.parse(data.getReturnValue());

                    if (response.status === "success") {
                        var opportunity = response.data.opportunity

                        if (!$A.util.isEmpty(opportunity)) {
                            var navService = component.find("navService");

                            if (!$A.util.isEmpty(navService)) {
                                var pageReference = {
                                    type: "standard__component",
                                    attributes: {
                                        componentName: "c__AfterCareAppointment"
                                    }, 
                                    state: {
                                        c__opportunityId: recordId,
                                        c__clinicId: opportunity.Clinic__c,
                                        c__applicationType: "Surgery Preparation Appointment"
                                    }
                                };

                                navService.navigate(pageReference);
                            }
                        } else {
                            this.showToast(component, "error", "Error", "Opportunity is not available!");
                        }
                    } else if (response.status === "warning") {
                        this.showToast(component, response.status, "Warning", response.message);
                    } else if (response.status === "error") {
                        this.showToast(component, response.status, "Error", response.message);
                    }
                }
            });
            $A.enqueueAction(action);
        }
    },

    showToast: function(component, variant, title, message) {
        var notifLib = component.find("notifLib");

        if (!$A.util.isEmpty(notifLib)) {
            var toast = {
                variant: variant,
                title: title,
                message: message
            };

            notifLib.showToast(toast);
        }
    },

    addAsyncProcess: function(component) {
        var asyncProcesses = component.get("v.asyncProcesses");
        asyncProcesses += 1;
        component.set("v.asyncProcesses", asyncProcesses);
    },

    removeAsyncProcess: function(component) {
        var asyncProcesses = component.get("v.asyncProcesses");
        asyncProcesses -= 1;
        component.set("v.asyncProcesses", asyncProcesses);
    }
})