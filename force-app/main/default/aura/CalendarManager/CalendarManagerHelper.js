({
    initCmp: function(component) {
        this.getClinicAppointmentRecordTypes(component);
    },

    getClinicAppointmentRecordTypes: function(component) {
        this.addAsyncProcess(component);

        var action = component.get("c.getClinicAppointmentRecordTypes");
        action.setCallback(this, function(data) {
            if (component.isValid()) {
                var response = JSON.parse(data.getReturnValue());

                if (response.status === "success") {
                    var clinicAppointmentRecordTypes = response.data.clinicAppointmentRecordTypes;

                    component.set("v.clinicAppointmentRecordTypes", clinicAppointmentRecordTypes);
                } else if (response.status === "warning") {
                    this.showToast(component, response.status, "Warning", response.message);
                } else if (response.status === "error") {
                    this.showToast(component, response.status, "Error", response.message);
                }

                this.removeAsyncProcess(component);
            }
        });
        $A.enqueueAction(action); 
    },

    getActivities: function(component) {
        var range = component.get("v.range");

        if (!$A.util.isEmpty(range)) {
            this.addAsyncProcess(component);

            var selectedDoctors = component.get("v.selectedDoctors");

            var selectedLocations = component.get("v.selectedLocations");

            var selectedRecordTypes = component.get("v.selectedRecordTypes");

            var activitiesFilter = {
                range: {
                    start: range.start.utc().format(),
                    end: range.end.utc().format()
                },
                groupBy: component.get("v.groupBy"),
                selectedDoctors: !$A.util.isEmpty(selectedDoctors) ? selectedDoctors.split(';') : [],
                selectedLocations: !$A.util.isEmpty(selectedLocations) ? selectedLocations.split(';') : [],
                selectedRecordTypes: !$A.util.isEmpty(selectedRecordTypes) ? selectedRecordTypes.split(';') : []
            };

            var action = component.get("c.getActivities");
            action.setParams({
                activitiesFilterJSON: JSON.stringify(activitiesFilter)
            });
            action.setCallback(this, function(data) {
                if (component.isValid()) {
                    var response = JSON.parse(data.getReturnValue());

                    if (response.status === "success") {
                        var events = response.data.events;

                        events.forEach(function(event) {
                            event.start = moment.tz(event.start, $A.get("$Locale.timezone"));
                            event.end = moment.tz(event.end, $A.get("$Locale.timezone"));
                        });

                        component.set("v.events", events);

                        component.set("v.resources", response.data.resources);
                    } else if (response.status === "warning") {
                        this.showToast(component, response.status, "Warning", response.message);
                    } else if (response.status === "error") {
                        this.showToast(component, response.status, "Error", response.message);
                    }

                    this.removeAsyncProcess(component);
                }
            });
            $A.enqueueAction(action);
        }
    },

    toggleGroupBy: function(component, event) {
        var checked = event.getSource().get("v.checked");

        component.set("v.groupBy", checked ? 'Doctor' : 'Location');
    },

    dateRangeChange: function(component, event) {
		event.stopPropagation();
        var intervalStart = event.getParam("data").intervalStart;
        var intervalEnd = event.getParam("data").intervalEnd;
        var range = component.get("v.range");
		if ($A.util.isEmpty(range) || !intervalStart.isBetween(range.start, range.end, null, '[]') || !intervalEnd.isBetween(range.start, range.end, null, '[]')) {
			component.set("v.range", {
				start: moment(intervalStart),
				end: moment(intervalEnd)
			});
        }
        
    },

    activityClick: function(component, event) {
        event.stopPropagation();       
    },

    dayClick: function(component, event) {
        event.stopPropagation();

    }, 

    onLoading: function(component, event) {
        event.stopPropagation();

        var eventData = event.getParam("data");

        if (!$A.util.isEmpty(eventData)) {
            var isLoading = eventData.isLoading;

            if (isLoading) {
                this.addAsyncProcess(component);
            } else {
                this.removeAsyncProcess(component);
            }
        }
    },

    getEditActivityFields: function() {
        var fields = [];

        fields.push({
            value: null,
            name: "Name",
            label: "Clinic Appointment Name",
            type: "STRING",
            required: true,
            placeholder: "",
            disabled: false
        });

        fields.push({
            value: null,
            name: "CS_Start_Date__c",
            label: "Start Date",
            type: "DATETIME",
            required: false,
            placeholder: "",
            disabled: false
        });

        fields.push({
            value: null,
            name: "CS_End_Date__c",
            label: "End Date",
            type: "DATETIME",
            required: false,
            placeholder: "",
            disabled: false
        });

        return fields;
    },

    getCreateActivityFields: function(eventData) {
        var fields = [];

        fields.push({
            value: null,
            name: "Name",
            label: "Clinic Appointment Name",
            type: "STRING",
            required: true,
            placeholder: "",
            disabled: false
        });

        fields.push({
            value: eventData.date,
            name: "CS_Start_Date__c",
            label: "Start Date",
            type: "DATETIME",
            required: false,
            placeholder: "",
            disabled: false
        });

        fields.push({
            value: eventData.date,
            name: "CS_End_Date__c",
            label: "End Date",
            type: "DATETIME",
            required: false,
            placeholder: "",
            disabled: false
        });

        return fields;
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