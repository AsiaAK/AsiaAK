({
	initCmp: function(component) {
        
        var pageReference = component.get("v.pageReference");

        component.set("v.opportunityId", pageReference.state.c__opportunityId);

        component.set("v.clinicId", pageReference.state.c__clinicId);
        
        component.set("v.applicationType", pageReference.state.c__applicationType);
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
                    this.saveAfterCareAppointment(component);
                }
            }
        }
    },

    saveAfterCareAppointment: function(component) {
        /* get form components */
        var formComponents = component.get("v.formComponents");

        if (!$A.util.isEmpty(formComponents)) {
            /* get record form component */
            var recordFormComponent = formComponents[0];

            if (!$A.util.isEmpty(recordFormComponent) && typeof recordFormComponent.validateForm !== "undefined") {
                /* validate form */
                var isValidForm = recordFormComponent.validateForm();

                if (isValidForm) {
                    /* close modal edit component */
                    formComponents[1].close();

                    /* add async process to watcher */
                    this.addAsyncProcess(component);

                    /* create after care appointment data */
                    var afterCareAppointmentData = {};

                    /* get section fields */
                    var sectionFields = component.get("v.sectionFields");

                    sectionFields.forEach(function(section) {
                        section.rows.forEach(function(row) {
                            row.fields.forEach(function(formField) {
                                if (!formField.readonly) {
                                    if (!afterCareAppointmentData.hasOwnProperty(formField.objectName)) {
                                        afterCareAppointmentData[formField.objectName] = {};
                                    }

                                    if (!afterCareAppointmentData[formField.objectName].hasOwnProperty("recordId")) {
                                        afterCareAppointmentData[formField.objectName]["recordId"] = formField.recordId;
                                    }

                                    if (!afterCareAppointmentData[formField.objectName].hasOwnProperty("fields")) {
                                        afterCareAppointmentData[formField.objectName]["fields"] = [];
                                    }

                                    afterCareAppointmentData[formField.objectName]["fields"].push({
                                        name: formField.name,
                                        value: formField.value
                                    });
                                }
                            });
                        });
                    });

                     var action = component.get("c.saveAfterCareAppointment");
                     action.setParams({
                         afterCareAppointmentDataJSON: JSON.stringify(afterCareAppointmentData)
                     });
                     action.setCallback(this, function(data) {
                         if (component.isValid()) {
                             /* remove async process from watcher */
                             this.removeAsyncProcess(component);

                             var response = JSON.parse(data.getReturnValue());

                             if (response.status === "success") {
                                 this.showToast(component, "success", "Success", "Appointment was successfully booked.");
        						this.navigateToRecordPage(
                           				 component,
                            			 component.get("v.opportunityId"),
                            			 "Opportunity",
                            			 "view"
                       		    );
                             //    this.getAvailabilities(component);
                             } else if (response.status === "warning") {
                                 this.showToast(component, response.status, "Warning", response.message);
                             } else if (response.status === "error") {
                                 this.showToast(component, response.status, "Error", response.message);
                             }
                         }
                     });
                     $A.enqueueAction(action);
                }
            }
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
            var modalDialog = component.find("overlayLib");

            if (!$A.util.isEmpty(modalDialog)) {

                var opportunityId = component.get("v.opportunityId");
                
				
                var sectionFields = this.getEditAvailabilitySectionFields(component, eventData.calEvent, opportunityId);

                component.set("v.sectionFields", sectionFields);

                $A.createComponents(
                    [
                        [
                            "c:RecordForm",
                            {
                                "aura:id": "RecordForm",
                                sectionFields: component.getReference("v.sectionFields"),
                                formValidation: this.getFormValidation(eventData.calEvent)
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
                            component.set("v.formComponents", createdComponents);

                            modalDialog.showCustomModal({
                                header: "Book " + component.get("v.applicationType"),
                                body: createdComponents[0], 
                                footer: createdComponents[1],
                                showCloseButton: true,
                                closeCallback: function() {
                                    /* set section fields */
                                    component.set("v.sectionFields", []);
                                }
                            });
                        }
                    }
                );
            }
        }
    },

    getEditAvailabilitySectionFields: function(component, availability, opportunityId) {
        var sectionFields = [];

        var availabilityStart = availability.start.clone();
        availabilityStart.add(15, 'minutes');

        sectionFields.push({
            label: "Clinic Appointment",
            render: true,
            rows: [
                {
                    render: true,
                    fields: [
                        {
                            value: null,
                            name: "Name",
                            label: "Clinic Appointment Name",
                            type: "STRING",
                            required: false,
                            placeholder: "",
                            disabled: true,
                            render: true,
                            readonly: false,
                            objectName: "Clinic_Appointment__c",
                            recordId: availability.id
                        }
                    ]
                },
                {
                    render: true,
                    fields: [
                        {
                            value: null,
                            name: "CS_Start_Date__c",
                            label: "Start Date",
                            type: "DATETIME",
                            inputName: "CS_Start_Date__c-" + Date.now(),
                            required: false,
                            placeholder: "",
                            disabled: false,
                            render: true,
                            readonly: false,
                            objectName: "Clinic_Appointment__c",
                            recordId: availability.id
                        },
                        {
                            value: moment.tz(availabilityStart.format("YYYY-MM-DD HH:mm"), $A.get("$Locale.timezone")).toJSON(),
                            name: "CS_End_Date__c",
                            label: "End Date",
                            type: "DATETIME",
                            inputName: "CS_End_Date__c-" + Date.now(),
                            required: false,
                            placeholder: "",
                            disabled: false,
                            render: true,
                            readonly: false,
                            objectName: "Clinic_Appointment__c",
                            recordId: availability.id
                        }
                    ]
                },
                {
                    render: false,
                    fields: [
                        {
                            value: "Reserved",
                            name: "Appointment_Status__c",
                            label: "Appointment Status",
                            type: "STRING",
                            required: false,
                            placeholder: "",
                            disabled: false,
                            render: false,
                            readonly: false,
                            objectName: "Clinic_Appointment__c",
                            recordId: availability.id
                        },
                        {
                            value: opportunityId,
                            name: "Opportunity__c",
                            label: "Opportunity",
                            type: "REFERENCE",
                            required: false,
                            placeholder: "",
                            disabled: false,
                            render: false,
                            readonly: false,
                            objectName: "Clinic_Appointment__c",
                            recordId: availability.id
                        },
                        {
                            value: component.get("v.applicationType"),
                            name: "Apppointment_Type__c",
                            label: "Appointment Type",
                            type: "STRING",
                            required: false,
                            placeholder: "",
                            disabled: false,
                            render: false,
                            readonly: false,
                            objectName: "Clinic_Appointment__c",
                            recordId: availability.id
                        }
                    ]
                }
            ]
        });

        return sectionFields;
    },

    getFormValidation: function(availability) {
        var formValidation = {
            init: function() {
                for (var property in this) {
                    if (this.hasOwnProperty(property)) {
                        /* it allows inner object to know who its parent is */
                        this[property].parent = this;
                    }
                }

                /* it gives back the object itself to instance it */
                return this; 
            }
        };

        formValidation.Name = {
            field: null,
            validate: function() {
                var status = {
                    isValid: true,
                    message: ""
                };

                /* validate form field */
                if ($A.util.isEmpty(this.field)) {
                    status.isValid = false;
                    status.message = "Form field is not valid!"
                    return status;
                }

                /* validate required */
                if ($A.util.isEmpty(this.field.value) && this.field.required) {
                    status.isValid = false;
                    status.message = "This required field must be completed!"
                    return status;
                }

                return status;
            }
        };

        formValidation.CS_Start_Date__c = {
            field: null,
            availability: availability,
            validate: function() {
                var status = {
                    isValid: true,
                    message: ""
                };

                /* validate form field */
                if ($A.util.isEmpty(this.field)) {
                    status.isValid = false;
                    status.message = "Form field is not valid!"
                    return status;
                }

                /* validate required */
                if ($A.util.isEmpty(this.field.value) && this.field.required) {
                    status.isValid = false;
                    status.message = "This required field must be completed!"
                    return status;
                }

                /* check that appointment start datetime is between availability start and end datetime */
                var CS_Start_Date__c = moment.utc(this.field.value);

                if (!moment(CS_Start_Date__c).isBetween(this.availability.start, this.availability.end, null, '[]')) {
                    status.isValid = false;
                    status.message = "Appointment start datetime should be between availability start and end datetime!"
                    return status;
                }

                var CS_End_Date__c = moment.utc(this.parent.CS_End_Date__c.field.value);
                if (CS_End_Date__c <= CS_Start_Date__c) {
                    status.isValid = false;
                    status.message = "Appointment start datetime should be earlier than end datetime!"
                    return status;
                }

                return status;
            }
        };

        formValidation.CS_End_Date__c = {
            field: null,
            availability: availability,
            validate: function() {
                var status = {
                    isValid: true,
                    message: ""
                };

                /* validate form field */
                if ($A.util.isEmpty(this.field)) {
                    status.isValid = false;
                    status.message = "Form field is not valid!"
                    return status;
                }

                /* validate required */
                if ($A.util.isEmpty(this.field.value) && this.field.required) {
                    status.isValid = false;
                    status.message = "This required field must be completed!"
                    return status;
                }

                var CS_End_Date__c = moment.utc(this.field.value);
                if (!moment(CS_End_Date__c).isBetween(this.availability.start, this.availability.end, null, '[]')) {
                    status.isValid = false;
                    status.message = "Appointment end datetime should be between availability start and end datetime!"
                    return status;
                }

                return status;
            }
        };

        return formValidation;
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