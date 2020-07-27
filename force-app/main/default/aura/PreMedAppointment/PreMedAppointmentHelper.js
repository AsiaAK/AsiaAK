({
	initCmp: function(component) {
        var pageReference = component.get("v.pageReference");

        component.set("v.opportunityId", pageReference.state.c__opportunityId);

        component.set("v.clinicId", pageReference.state.c__clinicId);
    },

    pageReferenceChange: function(component) {
        $A.get("e.force:refreshView").fire();
    },

    getAvailabilities: function(component) {
        var clinicId = component.get("v.clinicId");

        var range = component.get("v.range");

        if (!$A.util.isEmpty(clinicId) && !$A.util.isEmpty(range)) {
            var tomorrow = moment().utc().startOf("day").add(1, "days");

            if (range.end.isSameOrAfter(tomorrow, "day")) {
                this.addAsyncProcess(component);

                var availabilitiesFilter = {
                    clinicId: clinicId,
                    range: {
                        start: range.start.isSameOrAfter(tomorrow, "day")
                                ? range.start.utc().format()
                                : tomorrow.utc().format(),
                        end: range.end.utc().format()
                    },
                    appointmentRecordTypeName: "Pre_Ex_Appointment",
                    appointmentType: "Regular Appointment Type",
                    additionalAppointmentTypes: ["Aftercare Appointment", "Surgery Preparation Appointment"]
                };

                var action = component.get("c.getPreexAvailabilities");
                action.setParams({
                    availabilitiesFilterJSON: JSON.stringify(availabilitiesFilter)
                });
                action.setCallback(this, function(data) {
                    if (component.isValid()) {
                        var response = JSON.parse(data.getReturnValue());

                        if (response.status === "success") {
                            var availabilities = response.data.availabilities;

                            availabilities.forEach(function(availability) {
                                availability.start = moment.tz(availability.start, $A.get("$Locale.timezone"));
                                availability.end = moment.tz(availability.end, $A.get("$Locale.timezone"));
                            });

                            component.set("v.events", availabilities);

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
        }
    },

    action: function(component, event) {

        event.stopPropagation();

        if (event.getParams().hasOwnProperty("data")) {
            var eventData = event.getParam("data");
			
            if (!$A.util.isEmpty(eventData)) {
                var eventAction = eventData.action;

                if (eventAction === "ok") {
                    
                    this.savePreMedAppointment(component, event);
                }
            }
        }
    },

    savePreMedAppointment: function(component, event) {
        var formRecordId = component.get("v.formRecordId");

        var opportunityId = component.get("v.opportunityId");
        var fields = component.get("v.predefinedFields");
		
        console.log("Piotres test");
        console.log(fields[2].value);
      
        if (!$A.util.isEmpty(formRecordId) && !$A.util.isEmpty(opportunityId)) {
            this.addAsyncProcess(component);

            var preMedAppointmentData = {
                recordId: formRecordId,
                predefinedFields: [
                    {
                        value: "Reserved",
                        name: "Appointment_Status__c"
                    },
                    {
                        value: opportunityId,
                        name: "Opportunity__c"
                    },
                   
                  //  {
                    //    value: "test", 
                     //   name: "CS_End_Date__c"
                   // },
                    {
                        value: "Surgery Preparation Appointment",
                        name: "Apppointment_Type__c"
                    }
                ]
            };

            var action = component.get("c.savePreMedAppointment");
            action.setParams({
                preMedAppointmentDataJSON: JSON.stringify(preMedAppointmentData)
            });
            action.setCallback(this, function(data) {
                if (component.isValid()) {
                    this.removeAsyncProcess(component);

                    var response = JSON.parse(data.getReturnValue());
                    
                    if (response.status === "success") {
                        this.navigateToRecordPage(
                            component,
                            component.get("v.opportunityId"),
                            "Opportunity",
                            "view"
                        );
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

    availabilityClick: function(component, event) {
        event.stopPropagation();

        var eventData = event.getParam("data");

        if (!$A.util.isEmpty(eventData)) {
            component.set("v.formRecordId", eventData.calEvent.id);
			component.set("v.predefinedFields", this.getEditAvailabilityFields(eventData.calEvent, component));
            var modalDialog = component.find("overlayLib");700
            if (!$A.util.isEmpty(modalDialog)) {
                $A.createComponents(
                    [
                        [
                            "c:RecordEdit",
                            {
                                recordId: eventData.calEvent.id,
                                recordType: null,
                                objectType: "Clinic_Appointment__c",
                                predefinedFields: component.get("v.predefinedFields")
                            }
                        ],
                        [
                            "c:OverlayLibraryModalFooter",
                            {
                                cancelButtonLabel: "Cancel",
                                okButtonLabel: "Book",
                                onaction: component.getReference("c.handleAction")
                            }
                        ]
                    ],
                    function(createdComponents, status) {
                        if (status === "SUCCESS") {
                            modalDialog.showCustomModal({
                                header: "Book Pre-Med Appointment",
                                body: createdComponents[0], 
                                footer: createdComponents[1],
                                showCloseButton: true
                            });
                        }
                    }
                );
            }
        }
    },

    getEditAvailabilityFields: function(calEvent, component) {
        var fields = [];
      
        fields.push({
            value: null,
            name: "Name",
            label: "Clinic Appointment Name",
            type: "STRING",
            required: false,
            placeholder: "",
            disabled: true,
            render: true,
            largeDeviceSize: 12,
            mediumDeviceSize: 12
        });

        fields.push({
            value: null,
            name: "CS_Start_Date__c",
            label: "Start Date",
            type: "DATETIME",
            required: false,
            placeholder: "",
            disabled: false,
            render: true,
            largeDeviceSize: 6,
            mediumDeviceSize: 6
        });

        calEvent.start.add(15, 'minutes');

        fields.push({
            value: moment.tz(calEvent.start.format("YYYY-MM-DD HH:mm"), $A.get("$Locale.timezone")).toJSON(),
            name: "CS_End_Date__c",
            label: "End Date",
            type: "DATETIME",
            required: false,
            placeholder: "",
            disabled: false,
            render: true,
            largeDeviceSize: 6,
            mediumDeviceSize: 6
        });

        fields.push({
            value: "Reserved",
            name: "Appointment_Status__c",
            label: "Appointment Status",
            type: "STRING",
            required: false,
            placeholder: "",
            disabled: false,
            render: false,
            largeDeviceSize: 12,
            mediumDeviceSize: 12
        });
        component.set("v.endDate", fields);
        return fields;
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

    navigateToRecordPage: function(component, recordId, objectApiName, actionName) {
        var navService = component.find("navService");

        if (!$A.util.isEmpty(navService)) {
            var pageReference = {
                type: "standard__recordPage",
                attributes: {
                    recordId: recordId,
                    objectApiName: objectApiName,
                    actionName: actionName
                }
            };

            navService.navigate(pageReference);
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