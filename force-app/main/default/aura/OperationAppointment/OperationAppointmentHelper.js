({
	initCmp: function(component) {
        console.log("initCmp MOOperationAppointment");
        var pageReference = component.get("v.pageReference");
        console.log("pageReference", JSON.parse(JSON.stringify(pageReference)));

        /* set opportunity id */
        component.set("v.opportunityId", pageReference.state.c__opportunityId);

        /* set clinic id */
        component.set("v.clinicId", pageReference.state.c__clinicId);
    },

    pageReferenceChange: function(component) {
        console.log("pageReferenceChange MOOperationAppointment");

        /* refresh component */
        $A.get("e.force:refreshView").fire();
    },

    getAvailabilities: function(component) {
        /* get clinic id */
        var clinicId = component.get("v.clinicId");

        /* get range */
        var range = component.get("v.range");
        console.log("range", JSON.parse(JSON.stringify(range)));

        if (!$A.util.isEmpty(clinicId) && !$A.util.isEmpty(range)) {
            /* get tomorrow date */
            var tomorrow = moment().utc().startOf("day").add(1, "days");

            if (range.end.isSameOrAfter(tomorrow, "day")) {
                /* add async process to watcher */
                this.addAsyncProcess(component);

                console.log("getOperationAvailabilities MOOperationAppointment");

                /* create filter */
                var availabilitiesFilter = {
                    clinicId: clinicId,
                    range: {
                        start: range.start.isSameOrAfter(tomorrow, "day")
                                ? range.start.utc().format()
                                : tomorrow.utc().format(),
                        end: range.end.utc().format()
                    },
                    appointmentRecordTypeName: "Operation_Date"
                };

                console.log("availabilitiesFilter", JSON.parse(JSON.stringify(availabilitiesFilter)));

                var action = component.get("c.getOperationAvailabilities");
                action.setParams({
                    availabilitiesFilterJSON: JSON.stringify(availabilitiesFilter)
                });
                action.setCallback(this, function(data) {
                    if (component.isValid()) {
                        console.log('return value', data.getReturnValue());
                        var response = JSON.parse(data.getReturnValue());
                        console.log("response", JSON.parse(JSON.stringify(response)));

                        if (response.status === "success") {
                            var availabilities = response.data.availabilities;

                            availabilities.forEach(function(availability) {
                                availability.start = moment.tz(availability.start, $A.get("$Locale.timezone"));
                                availability.end = moment.tz(availability.end, $A.get("$Locale.timezone"));
                            });

                            /* set availabilities */
                            component.set("v.events", availabilities);

                            /* set resources */
                            component.set("v.resources", response.data.resources);
                        } else if (response.status === "warning") {
                            this.showToast(component, response.status, "Warning", response.message);
                        } else if (response.status === "error") {
                            this.showToast(component, response.status, "Error", response.message);
                        }

                        /* remove async process from watcher */
                        this.removeAsyncProcess(component);
                    }
                });
                $A.enqueueAction(action);
            }
        }
    },

    action: function(component, event) {
        console.log("action MOOperationAppointment");

        /* stop the event propagating to other components */
        event.stopPropagation();

        if (event.getParams().hasOwnProperty("data")) {
            /* get event data */
            var eventData = event.getParam("data");

            if (!$A.util.isEmpty(eventData)) {
                /* get event action */
                var eventAction = eventData.action;

                if (eventAction === "ok") {
                    console.log("ok", JSON.parse(JSON.stringify(eventData)));

                    if (eventData.data.appointmentType === "mo") {
                        this.saveMOOperationAppointment(component);
                    } else if (eventData.data.appointmentType === "md") {
                        this.saveMDOperationAppointment(component);
                    }
                }
            }
        }
    },

    saveMOOperationAppointment: function(component) {
        /* get form components */
        var formComponents = component.get("v.formComponents");
        console.log(formComponents);

        if (!$A.util.isEmpty(formComponents)) {
            /* get record form component */
            var recordFormComponent = formComponents[0];

            if (!$A.util.isEmpty(recordFormComponent) && typeof recordFormComponent.validateForm !== "undefined") {
                /* validate form */
                var isValidForm = recordFormComponent.validateForm();
                console.log("isValidForm", isValidForm);

                if (isValidForm) {
                    /* close modal edit component */
                    formComponents[1].close();

                    /* add async process to watcher */
                    this.addAsyncProcess(component);

                    console.log("saveMOOperationAppointment MOOperationAppointment");

                    /* create mo operation appointment data */
                    var moOperationAppointmentData = {};

                    /* get section fields */
                    var sectionFields = component.get("v.sectionFields");
                    console.log("sectionFields", sectionFields);

                    sectionFields.forEach(function(section) {
                        section.rows.forEach(function(row) {
                            row.fields.forEach(function(formField) {
                                if (!formField.readonly) {
                                    if (!moOperationAppointmentData.hasOwnProperty(formField.objectName)) {
                                        moOperationAppointmentData[formField.objectName] = {};
                                    }

                                    if (!moOperationAppointmentData[formField.objectName].hasOwnProperty("recordId")) {
                                        moOperationAppointmentData[formField.objectName]["recordId"] = formField.recordId;
                                    }

                                    if (!moOperationAppointmentData[formField.objectName].hasOwnProperty("fields")) {
                                        moOperationAppointmentData[formField.objectName]["fields"] = [];
                                    }

                                    moOperationAppointmentData[formField.objectName]["fields"].push({
                                        name: formField.name,
                                        value: formField.value
                                    });
                                }
                            });
                        });
                    });

                    console.log(JSON.parse(JSON.stringify(moOperationAppointmentData)));

                    var action = component.get("c.saveMOOperationAppointment");
                    action.setParams({
                        moOperationAppointmentDataJSON: JSON.stringify(moOperationAppointmentData)
                    });
                    action.setCallback(this, function(data) {
                        if (component.isValid()) {
                            /* remove async process from watcher */
                            this.removeAsyncProcess(component);

                            var response = JSON.parse(data.getReturnValue());
                            console.log("response", JSON.parse(JSON.stringify(response)));

                            if (response.status === "success") {
                                /* navigate to source record */
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
            }
        }
    },

    saveMDOperationAppointment: function(component) {
        /* get form components */
        var formComponents = component.get("v.formComponents");
        console.log(formComponents);

        if (!$A.util.isEmpty(formComponents)) {
            /* get record form component */
            var recordFormComponent = formComponents[0];

            if (!$A.util.isEmpty(recordFormComponent) && typeof recordFormComponent.validateForm !== "undefined") {
                /* validate form */
                var isValidForm = recordFormComponent.validateForm();
                console.log("isValidForm", isValidForm);

                if (isValidForm) {
                    /* close modal edit component */
                    formComponents[1].close();

                    /* add async process to watcher */
                    this.addAsyncProcess(component);

                    console.log("saveMDOperationAppointment MDOperationAppointment");

                    /* create md operation appointment data */
                    var mdOperationAppointmentData = {};

                    /* get section fields */
                    var sectionFields = component.get("v.sectionFields");
                    console.log("sectionFields", sectionFields);

                    sectionFields.forEach(function(section) {
                        section.rows.forEach(function(row) {
                            row.fields.forEach(function(formField) {
                                if (!formField.readonly) {
                                    if (!mdOperationAppointmentData.hasOwnProperty(formField.objectName)) {
                                        mdOperationAppointmentData[formField.objectName] = {};
                                    }

                                    if (!mdOperationAppointmentData[formField.objectName].hasOwnProperty("recordId")) {
                                        mdOperationAppointmentData[formField.objectName]["recordId"] = formField.recordId;
                                    }

                                    if (!mdOperationAppointmentData[formField.objectName].hasOwnProperty("fields")) {
                                        mdOperationAppointmentData[formField.objectName]["fields"] = [];
                                    }

                                    mdOperationAppointmentData[formField.objectName]["fields"].push({
                                        name: formField.name,
                                        value: formField.value
                                    });
                                }
                            });
                        });
                    });

                    console.log(JSON.parse(JSON.stringify(mdOperationAppointmentData)));

                    var action = component.get("c.saveMDOperationAppointment");
                    action.setParams({
                        mdOperationAppointmentDataJSON: JSON.stringify(mdOperationAppointmentData)
                    });
                    action.setCallback(this, function(data) {
                        if (component.isValid()) {
                            /* remove async process from watcher */
                            this.removeAsyncProcess(component);

                            var response = JSON.parse(data.getReturnValue());
                            console.log("response", JSON.parse(JSON.stringify(response)));

                            if (response.status === "success") {
                                /* navigate to source record */
                                this.navigateToRecordPage(
                                    component,
                                    response.data.mdOperationAppointment.id,
                                    "Clinic_Appointment__c",
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
            }
        }
    },

    dateRangeChange: function(component, event) {
        console.log("dateRangeChange MOOperationAppointment");

        event.stopPropagation();

        console.log("interval", JSON.parse(JSON.stringify(event.getParam("data"))));
        var intervalStart = event.getParam("data").intervalStart;
        var intervalEnd = event.getParam("data").intervalEnd;

        var range = component.get("v.range");
        console.log("range", JSON.parse(JSON.stringify(range)));

		if ($A.util.isEmpty(range) || !intervalStart.isBetween(range.start, range.end, null, '[]') || !intervalEnd.isBetween(range.start, range.end, null, '[]')) {
			component.set("v.range", {
				start: moment(intervalStart),
				end: moment(intervalEnd)
			});
        }
    },

    availabilityClick: function(component, event) {
        console.log("availabilityClick MOOperationAppointment");

        event.stopPropagation();

        /* get event data */
        var eventData = event.getParam("data");
        console.log("eventData", JSON.parse(JSON.stringify(eventData)));

        if (!$A.util.isEmpty(eventData)) {
            /* get modal edit component */
            var modalDialog = component.find("overlayLib");

            if (!$A.util.isEmpty(modalDialog)) {
                /* get section fields */
                var sectionFields = eventData.calEvent.type === "mo"
                        ? this.getEditMOAvailabilitySectionFields(eventData.calEvent, component.get("v.opportunityId"))
                        : this.getEditMDAvailabilitySectionFields(eventData.calEvent, component.get("v.opportunityId"))

                /* set section fields */
                component.set("v.sectionFields", sectionFields);
                console.log("sectionFields", component.get("v.sectionFields"));

                /* get form validation */
                var formValidation = eventData.calEvent.type === "mo"
                        ? this.getMOFormValidation(eventData.calEvent)
                        : this.getMDFormValidation();
                console.log("formValidation", formValidation);

                $A.createComponents(
                    [
                        [
                            "c:RecordForm",
                            {
                                "aura:id": "RecordForm",
                                sectionFields: component.getReference("v.sectionFields"),
                                formValidation: formValidation
                            }
                        ],
                        [
                            "c:OverlayLibraryModalFooter",
                            {
                                cancelButtonLabel: "Cancel",
                                okButtonLabel: "Book",
                                data: {
                                    appointmentType: eventData.calEvent.type
                                },
                                onaction: component.getReference("c.handleAction")
                            }
                        ]
                    ],
                    function(createdComponents, status) {
                        if (status === "SUCCESS") {
                            component.set("v.formComponents", createdComponents);
                            modalDialog.showCustomModal({
                                header: eventData.calEvent.type === "mo" ? "Book MO Operation Appointment" : "Book MD Operation Appointment",
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

    getEditMOAvailabilitySectionFields: function(availability, opportunityId) {
        var sectionFields = [];

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
                            value: availability.start.toISOString(),
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
                        }
                    ]
                },
                {
                    render: false,
                    fields: [
                        {
                            value: null,
                            name: "Dummynumber__c",
                            label: "Operation Duration (Minutes)",
                            type: "INTEGER",
                            required: false,
                            placeholder: "",
                            disabled: false,
                            render: false,
                            readonly: false,
                            objectName: "Clinic_Appointment__c",
                            recordId: availability.id,
                            sourceObjectName: "Opportunity",
                            sourceFieldName: "Operation_Duration_Minutes__c",
                            sourceRecordId: opportunityId
                        },
                        {
                            value: availability.id,
                            name: "MOAvailability__c",
                            label: "MO Availability",
                            type: "REFERENCE",
                            required: false,
                            searchField: "Name",
                            subtitleField: "",
                            filter: "",
                            placeholder: "Search MO Availabilities...",
                            iconName: "standard:opportunity",
                            disabled: false,
                            render: false,
                            readonly: false,
                            objectName: "Clinic_Appointment__c",
                            recordId: availability.id
                        },
                        /*{
                            value: "Reserved",
                            name: "Appointment_Status__c",
                            label: "Appointment Status",
                            type: "PICKLIST",
                            required: false,
                            placeholder: "Select an Option",
                            disabled: false,
                            options: [],
                            render: false,
                            readonly: false,
                            objectName: "Clinic_Appointment__c",
                            recordId: availability.id
                        },*/
                        {
                            value: null,
                            name: "CS_End_Date__c",
                            label: "End Date",
                            type: "DATETIME",
                            inputName: "CS_End_Date__c-" + Date.now(),
                            required: false,
                            placeholder: "",
                            disabled: false,
                            render: false,
                            readonly: false,
                            objectName: "Clinic_Appointment__c",
                            recordId: availability.id
                        },
                        {
                            value: null,
                            name: "Appointment_Date__c",
                            label: "Appointment Date",
                            type: "DATETIME",
                            inputName: "Appointment_Date__c-" + Date.now(),
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

        sectionFields.push({
            label: "Opportunity",
            render: true,
            rows: [
                {
                    render: true,
                    fields: [
                        {
                            value: null,
                            name: "Operation_Duration_Minutes__c",
                            label: "Operation Duration (Minutes)",
                            type: "INTEGER",
                            inputName: "Operation_Duration_Minutes__c-" + Date.now(),
                            required: true,
                            placeholder: "",
                            disabled: true,
                            render: true,
                            readonly: false,
                            objectName: "Opportunity",
                            recordId: opportunityId
                        },
                        {
                            value: null,
                            name: "RevisionSurgery__c",
                            label: "Revision Surgery",
                            type: "BOOLEAN",
                            inputName: "RevisionSurgery__c",
                            required: false,
                            placeholder: "",
                            disabled: false,
                            render: true,
                            readonly: false,
                            objectName: "Opportunity",
                            recordId: opportunityId
                        },
                        
                    ]
                },
                {
                    render:false,
                    fields: [
                        {
                            value: availability.id,
                            name: "Operation_Appointment__c",
                            label: "Operation Appointment",
                            type: "REFERENCE",
                            required: false,
                            searchField: "Name",
                            subtitleField: "",
                            filter: "",
                            placeholder: "Search Operation Appointments...",
                            iconName: "custom:custom53",
                            disabled: false,
                            render: false,
                            readonly: false,
                            objectName: "Opportunity",
                            recordId: opportunityId
                        },
                        {
                            value: null,
                            name: "Revision_Operation_Appointment__c",
                            label: "Revision Operation Appointment",
                            type: "REFERENCE",
                            required: false,
                            searchField: "Name",
                            subtitleField: "",
                            filter: "",
                            placeholder: "Search Operation Appointments...",
                            iconName: "custom:custom53",
                            disabled: false,
                            render: false,
                            readonly: false,
                            objectName: "Opportunity",
                            recordId: opportunityId
                        },
                    ]
                }
            ]
        });

        sectionFields.push({
            label: "MD Day",
            render: true,
            rows: [
                {
                    render: true,
                    fields: [
                        {
                            value: null,
                            name: "Total_available_Operation_Time_Minutes__c",
                            label: "Total available Operation Time (Minutes)",
                            type: "INTEGER",
                            inputName: "Total_available_Operation_Time_Minutes__c-" + Date.now(),
                            required: false,
                            placeholder: "",
                            disabled: true,
                            render: true,
                            readonly: false,
                            objectName: "MD_Day__c",
                            recordId: availability.mdDayId
                        },
                        {
                            value: null,
                            name: "Operation_Duration_scheduled_Minutes__c",
                            label: "Operation Duration scheduled (Minutes)",
                            type: "INTEGER",
                            inputName: "Operation_Duration_scheduled_Minutes__c-" + Date.now(),
                            required: false,
                            placeholder: "",
                            disabled: true,
                            render: true,
                            readonly: false,
                            objectName: "MD_Day__c",
                            recordId: availability.mdDayId
                        }
                    ]
                }
            ]
        });

        return sectionFields;
    },

    getEditMDAvailabilitySectionFields: function(availability, opportunityId) {
        var sectionFields = [];

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
                            disabled: true,
                            render: true,
                            readonly: false,
                            objectName: "Clinic_Appointment__c",
                            recordId: availability.id
                        },
                        {
                            value: null,
                            name: "CS_End_Date__c",
                            label: "End Date",
                            type: "DATETIME",
                            inputName: "CS_End_Date__c-" + Date.now(),
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
                    render: false,
                    fields: [
                        {
                            value: null,
                            name: "Dummynumber__c",
                            label: "Operation Duration (Minutes)",
                            type: "INTEGER",
                            required: false,
                            placeholder: "",
                            disabled: false,
                            render: false,
                            readonly: false,
                            objectName: "Clinic_Appointment__c",
                            recordId: availability.id,
                            sourceObjectName: "Opportunity",
                            sourceFieldName: "Operation_Duration_Minutes__c",
                            sourceRecordId: opportunityId
                        },
                       /* {
                            value: "Reserved",
                            name: "Appointment_Status__c",
                            label: "Appointment Status",
                            type: "PICKLIST",
                            required: false,
                            placeholder: "Select an Option",
                            disabled: false,
                            options: [],
                            render: false,
                            readonly: false,
                            objectName: "Clinic_Appointment__c",
                            recordId: availability.id
                        }, */
                        {
                            value: availability.start.toISOString(),
                            name: "Appointment_Date__c",
                            label: "Appointment Date",
                            type: "DATETIME",
                            inputName: "Appointment_Date__c-" + Date.now(),
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

        sectionFields.push({
            label: "Opportunity",
            render: true,
            rows: [
                {
                    render: true,
                    fields: [
                        {
                            value: null,
                            name: "Operation_Duration_Minutes__c",
                            label: "Operation Duration (Minutes)",
                            type: "INTEGER",
                            inputName: "Operation_Duration_Minutes__c-" + Date.now(),
                            required: false,
                            placeholder: "",
                            disabled: true,
                            render: true,
                            readonly: false,
                            objectName: "Opportunity",
                            recordId: opportunityId
                        },
                        {
                            value: null,
                            name: "RevisionSurgery__c",
                            label: "Revision Surgery",
                            type: "BOOLEAN",
                            inputName: "RevisionSurgery__c",
                            required: false,
                            placeholder: "",
                            disabled: false,
                            render: true,
                            readonly: false,
                            objectName: "Opportunity",
                            recordId: opportunityId
                        }
                    ]
                },
                {
                    render:false,
                    fields: [
                        {
                            value: availability.id,
                            name: "Operation_Appointment__c",
                            label: "Operation Appointment",
                            type: "REFERENCE",
                            required: false,
                            searchField: "Name",
                            subtitleField: "",
                            filter: "",
                            placeholder: "Search Operation Appointments...",
                            iconName: "custom:custom53",
                            disabled: false,
                            render: false,
                            readonly: false,
                            objectName: "Opportunity",
                            recordId: opportunityId
                        },
                        {
                            value: null,
                            name: "Revision_Operation_Appointment__c",
                            label: "Revision Operation Appointment",
                            type: "REFERENCE",
                            required: false,
                            searchField: "Name",
                            subtitleField: "",
                            filter: "",
                            placeholder: "Search Operation Appointments...",
                            iconName: "custom:custom53",
                            disabled: false,
                            render: false,
                            readonly: false,
                            objectName: "Opportunity",
                            recordId: opportunityId
                        },
                    ]
                }
            ]
        });

        sectionFields.push({
            label: "MD Day",
            render: true,
            rows: [
                {
                    render: true,
                    fields: [
                        {
                            value: null,
                            name: "Total_available_Operation_Time_Minutes__c",
                            label: "Total available Operation Time (Minutes)",
                            type: "INTEGER",
                            inputName: "Total_available_Operation_Time_Minutes__c-" + Date.now(),
                            required: false,
                            placeholder: "",
                            disabled: true,
                            render: true,
                            readonly: false,
                            objectName: "MD_Day__c",
                            recordId: availability.mdDayId
                        },
                        {
                            value: null,
                            name: "Operation_Duration_scheduled_Minutes__c",
                            label: "Operation Duration scheduled (Minutes)",
                            type: "INTEGER",
                            inputName: "Operation_Duration_scheduled_Minutes__c-" + Date.now(),
                            required: false,
                            placeholder: "",
                            disabled: true,
                            render: true,
                            readonly: false,
                            objectName: "MD_Day__c",
                            recordId: availability.mdDayId
                        }
                    ]
                }
            ]
        });

        return sectionFields;
    },

    getMOFormValidation: function(availability) {
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
                var CS_Start_Date__c = moment(this.field.value);
                console.log(this.availability);

                if (!moment(CS_Start_Date__c).isBetween(this.availability.start, this.availability.end, null, '[]')) {
                    status.isValid = false;
                    status.message = "Appointment start datetime should be between availability start and end datetime!"
                    return status;
                }

                /* check that appointment end datetime is between availability start and end datetime */
                var operationDuration = this.parent.Operation_Duration_Minutes__c.field.value;
                var CS_End_Date__c = CS_Start_Date__c.add(operationDuration, "m");
                if (!moment(CS_End_Date__c).isBetween(this.availability.start, this.availability.end, null, '[]')) {
                    status.isValid = false;
                    status.message = "Appointment end datetime should be between availability start and end datetime!"
                    return status;
                } else {
                    this.parent.CS_End_Date__c.field.value = CS_End_Date__c;
                    this.parent.Appointment_Date__c.field.value = moment(this.field.value);
                }

                return status;
            }
        };

        formValidation.CS_End_Date__c = {
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

        formValidation.Appointment_Date__c = {
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

        formValidation.Operation_Duration_Minutes__c = {
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
                    status.message = "This required Operation Duration Minutes field must be completed!"
                    return status;
                }

                /* validate form field */
                if (!$A.util.isEmpty(this.field.value) && this.field.value == '0') {
                    status.isValid = false;
                    status.message = "Operation Duration Minutes field must be not equal to 0!"
                    return status;
                }

                /* validate form field */
                if (!$A.util.isEmpty(this.field.value) && this.field.value < '0') {
                    status.isValid = false;
                    status.message = "Operation Duration Minutes field must be greater than  0!"
                    return status;
                }

                /* check available operation time */
                var total = this.parent.Total_available_Operation_Time_Minutes__c.field.value;
                var scheduled = this.parent.Operation_Duration_scheduled_Minutes__c.field.value;
                var left = total - scheduled;

                if (left < this.field.value) {
                    status.isValid = false;
                    status.message = "There is no time left!"
                    return status;
                }

                return status;
            }
        };

        formValidation.Operation_Appointment__c = {
            field: null,
            validate: function() {
                var status = {
                    isValid: true,
                    message: ""
                };

                return status;
            }
        };

        formValidation.Revision_Operation_Appointment__c = {
            field: null,
            validate: function() {
                var status = {
                    isValid: true,
                    message: ""
                };

                return status;
            }
        };

        formValidation.RevisionSurgery__c = {
            field: null,
            validate: function() {
                var status = {
                    isValid: true,
                    message: ""
                };

                var Operation_Appointment__c = this.parent.Operation_Appointment__c.field.value;

                console.log('RevisionSurgery__c', this.field.value);
                console.log('Operation_Appointment__c', Operation_Appointment__c);

                if (this.field.value == true && !$A.util.isEmpty(Operation_Appointment__c)) {
                    this.parent.Revision_Operation_Appointment__c.field.value = Operation_Appointment__c;
                    this.parent.Operation_Appointment__c.field.value = null;
                }

                return status;
            }
        };

        formValidation.Total_available_Operation_Time_Minutes__c = {
            field: null,
            validate: function() {
                var status = {
                    isValid: true,
                    message: ""
                };

                console.log('!!!!11');

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

        formValidation.Operation_Duration_scheduled_Minutes__c = {
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

        console.log(formValidation);

        return formValidation;
    },

    getMDFormValidation: function() {
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

        formValidation.CS_End_Date__c = {
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

        formValidation.Operation_Duration_Minutes__c = {
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

                /* check available operation time */
                console.log(this);
                var total = this.parent.Total_available_Operation_Time_Minutes__c.field.value;
                var scheduled = this.parent.Operation_Duration_scheduled_Minutes__c.field.value;
                var left = total - scheduled;

                if (left < this.field.value) {
                    status.isValid = false;
                    status.message = "There is no time left!"
                    return status;
                }

                return status;
            }
        };

        formValidation.Operation_Appointment__c = {
            field: null,
            validate: function() {
                var status = {
                    isValid: true,
                    message: ""
                };

                return status;
            }
        };

        formValidation.Revision_Operation_Appointment__c = {
            field: null,
            validate: function() {
                var status = {
                    isValid: true,
                    message: ""
                };

                return status;
            }
        };

        formValidation.RevisionSurgery__c = {
            field: null,
            validate: function() {
                var status = {
                    isValid: true,
                    message: ""
                };

                var Operation_Appointment__c = this.parent.Operation_Appointment__c.field.value;

                console.log('RevisionSurgery__c', this.field.value);
                console.log('Operation_Appointment__c', Operation_Appointment__c);

                if (this.field.value == true && !$A.util.isEmpty(Operation_Appointment__c)) {
                    this.parent.Revision_Operation_Appointment__c.field.value = Operation_Appointment__c;
                    this.parent.Operation_Appointment__c.field.value = null;
                }

                return status;
            }
        };

        formValidation.Total_available_Operation_Time_Minutes__c = {
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

        formValidation.Operation_Duration_scheduled_Minutes__c = {
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

        console.log(formValidation);

        return formValidation;
    },

    onLoading: function(component, event) {
        event.stopPropagation();

        /* get event data */
        var eventData = event.getParam("data");

        if (!$A.util.isEmpty(eventData)) {
            var isLoading = eventData.isLoading;

            if (isLoading) {
                /* add async process to watcher */
                this.addAsyncProcess(component);
            } else {
                /* remove async process from watcher */
                this.removeAsyncProcess(component);
            }
        }
    },

    navigateToRecordPage: function(component, recordId, objectApiName, actionName) {
        /* get navigation service */
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

            /* navigate to page reference */
            navService.navigate(pageReference);
        }
    },

    showToast: function(component, variant, title, message) {
        /* get notification library */
        var notifLib = component.find("notifLib");

        if (!$A.util.isEmpty(notifLib)) {
            var toast = {
                variant: variant,
                title: title,
                message: message
            };

            /* show toast */
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