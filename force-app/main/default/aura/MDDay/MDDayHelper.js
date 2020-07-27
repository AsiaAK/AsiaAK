({
	initCmp: function(component) {
        var formFields = component.get("v.formFields");

        if ($A.util.isEmpty(formFields)) {
            this.getFormData(component);
        } else {
            var config = {
                mode: "RecordEdit"
            };

            component.set("v.config", config);
        }
    },

    getFormData: function(component) {
        var predefinedFields = this.getCreateMDDayFields(component);

        if (!$A.util.isEmpty(predefinedFields)) {
            this.addAsyncProcess(component);

            var fields = [];

            predefinedFields.forEach(function(predefinedField) {
                fields.push(predefinedField.name);
            });

            var formDataFilter = {
                objectType: "MD_Day__c",
                recordType: component.get("v.mdDayRecordTypeId"),
                recordId: null,
                fields: fields
            };

            var action = component.get("c.getFormData");
            action.setParams({
                formDataFilterJSON: JSON.stringify(formDataFilter)
            });
            action.setCallback(this, function(data) {
                if (component.isValid()) {
                    var response = JSON.parse(data.getReturnValue());

                    if (response.status === "success") {
                        component.set("v.formRecordTypes", response.data.formData.recordTypes);

                        var formFields = [];

                        predefinedFields.forEach(function(predefinedField) {
                            if (response.data.formData.fields.hasOwnProperty(predefinedField.name)) {
                                var field = response.data.formData.fields[predefinedField.name];

                                if ($A.util.isEmpty(predefinedField.value)) {
                                    predefinedField.value = field.value;
                                }

                                if (field.type === "PICKLIST" || field.type === "COMBOBOX" || field.type === "MULTIPICKLIST") {
                                    predefinedField.options = field.options;
                                }

                                formFields.push(predefinedField);
                            }
                        });
                        component.set("v.formFields", formFields);

                        var config = {
                            mode: "RecordEdit"
                        };

                        component.set("v.config", config);
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

    validateFields: function(component, event, helper) {
        var isValidForm = false;

        var formValidation = this.getFormValidation(component);

        var formFields = component.get("v.formFields");

        formFields.forEach(function(formField) {
            if (formValidation.hasOwnProperty(formField.name)) {
                formValidation[formField.name].field = formField;
            }
        });

        function validateField(previousValue, field) {
            var valid = true;
    
            if (!$A.util.isEmpty(field)) { 
                var fieldName = getFieldName(field);

                var fieldStatus = formValidation[fieldName].validate();

                if (!fieldStatus.isValid) {
                    showFieldError(field, fieldStatus.message);
                    valid = false;
                } else {
                    hideFieldError(field);
                    valid = true;
                }
            }
    
            return previousValue && valid;
        }

        function getFieldName(field) {
            var fieldName = "";

            var name = field.get("v.name");

            if (!$A.util.isEmpty(name)) {
                fieldName = name.indexOf("-") !== -1
                        ? name.substring(0, name.indexOf("-"))
                        : name;
            } else {
                var className = field.get("v.class");
                fieldName = className;
            }

            return fieldName;
        }

        function showFieldError(field, message) {
            if (typeof field.showHelpMessageIfInvalid !== typeof undefined) {
                field.setCustomValidity(message);
                field.showHelpMessageIfInvalid();
            } else if (typeof field.showError !== typeof undefined) {
                field.showError(message);
            } else if (typeof field.get("v.errors") !== typeof undefined) {
                field.set("v.errors", [{message: message}]);
            }
        }

        function hideFieldError(field) {
            if (typeof field.showHelpMessageIfInvalid !== typeof undefined) {
                field.setCustomValidity("");
                field.showHelpMessageIfInvalid();
            } else if (typeof field.showError !== typeof undefined) {
                field.hideError();
            } else if (typeof field.get("v.errors") !== typeof undefined) {
                field.set("v.errors", []);
            }
        }

        var fields = component.find("field");
        if (!$A.util.isEmpty(fields)) {
            if (Object.prototype.toString.call(fields) === "[object Array]") {
				isValidForm = fields.reduce(function(valid, field) {
					return validateField(valid, field);
				}, true);
            } else {
                isValidForm = validateField(true, fields);
            }
        }

        return isValidForm;
    },

    getCreateMDDayFields: function(component) {
        var fields = [];

        var sObjectName = component.get("v.sObjectName");

        var mdDayRecordTypeName = component.get("v.mdDayRecordTypeName");

        var mdDayLocationRecordTypeName = this.getMDDayLocationRecordTypeName(mdDayRecordTypeName);

        fields.push({
            value: null,
            name: "Date__c",
            label: "Date",
            type: "DATE",
            required: true,
            render: true,
            placeholder: "",
            disabled: false,
            inputName: "Date__c-" + Date.now(),
            largeDeviceSize: 12,
            mediumDeviceSize: 12
        });

        fields.push({
            value: null,
            name: "Operation_Day_Start_Time__c",
            label: "Operation Day Start Time",
            type: "DATETIME",
            required: true,
            render: true,
            placeholder: "",
            disabled: false,
            inputName: "Operation_Day_Start_Time__c-" + Date.now(),
            largeDeviceSize: 6,
            mediumDeviceSize: 6
        });

        fields.push({
            value: null,
            name: "Operation_Day_End_Time__c",
            label: "Operation Day End Time",
            type: "DATETIME",
            required: true,
            render: true,
            placeholder: "",
            disabled: false,
            inputName: "Operation_Day_End_Time__c-" + Date.now(),
            largeDeviceSize: 6,
            mediumDeviceSize: 6
        });

        fields.push({
            value: sObjectName === "MD_Day_Location__c" ? component.get("v.recordId") : null,
            name: "MD_Day_Location__c",
            label: "MD Day Location",
            type: "REFERENCE",
            objectName: "MD_Day_Location__c",
            required: mdDayRecordTypeName === "MD_Pre_Ex_Day",
            render: true,
            searchField: "Name",
            subtitleField: "",
            filter: (!$A.util.isEmpty(mdDayLocationRecordTypeName) ? "RecordType.DeveloperName = \'" + mdDayLocationRecordTypeName + "\'" : ""),
            placeholder: "Search Locations...",
            iconName: "standard:location",
            class: "MD_Day_Location__c",
            disabled: sObjectName === "MD_Day_Location__c",
            largeDeviceSize: 6,
            mediumDeviceSize: 6
        });

        if (mdDayRecordTypeName === "MD_Operation_Day") {
            fields.push({
                value: null,
                name: "PreliminaryAppointment__c",
                label: "Preliminary Appointment",
                type: "BOOLEAN",
                required: false,
                render: true,
                placeholder: "",
                disabled: false,
                inputName: "PreliminaryAppointment__c-" + Date.now(),
                largeDeviceSize: 6,
                mediumDeviceSize: 6
            });
        }

        fields.push({
            value: sObjectName === "Account" ? component.get("v.recordId") : null,
            name: "Surgeon_Clinic__c",
            label: "Surgeon/Clinic",
            type: "REFERENCE",
            objectName: "Account",
            required: false,
            render: true,
            searchField: "Name",
            subtitleField: "",
            filter: "RecordType.DeveloperName = \'ClinicsRecordType\'",
            placeholder: "Search Accounts...",
            iconName: "standard:account",
            class: "Surgeon_Clinic__c",
            disabled: sObjectName === "Account",
            largeDeviceSize: 6,
            mediumDeviceSize: 6
        });

        if (mdDayRecordTypeName === "MD_Operation_Day") {
            fields.push({
                value: null,
                name: "Total_available_Operation_Time_Minutes__c",
                label: "Total available Operation Time (Minutes)",
                type: "INTEGER",
                required: false,
                render: false,
                placeholder: "",
                disabled: true,
                inputName: "Total_available_Operation_Time_Minutes__c-" + Date.now(),
                largeDeviceSize: 6,
                mediumDeviceSize: 6
            });
        }

        return fields;
    },

    getMDDayLocationRecordTypeName: function(mdDayRecordTypeName) {
        var mdDayLocationRecordTypeName = "";

        if (!$A.util.isEmpty(mdDayRecordTypeName)) {
            if (mdDayRecordTypeName === "MD_Operation_Day") {
                mdDayLocationRecordTypeName = "Operation_Location";
            } else if (mdDayRecordTypeName === "MD_Pre_Ex_Day") {
                mdDayLocationRecordTypeName = "Pre_ex_Location";
            }
        }

        return mdDayLocationRecordTypeName;
    },

    onBlurDate: function(component, event) {
        var formFields = component.get("v.formFields");
        var name = event.getSource().get("v.name");
        var value = event.getSource().get("v.value");
        if (name.split('-')[0] == 'Date__c') {
            if (!$A.util.isEmpty(value)) {
                formFields.forEach(function(formField) {
                    if (!$A.util.isEmpty(formField.name)) {
                        if (formField.name == 'Operation_Day_Start_Time__c'
                                || formField.name == 'Operation_Day_End_Time__c') {
                            formField.value = value + 'T06:00:00.000Z';
                        }
                    }       
                });
            } 
            component.set("v.formFields", formFields);
        }
    },

    getFormValidation: function(component) {
        var formValidation = {};

        var mdDayRecordTypeName = component.get("v.mdDayRecordTypeName");

        formValidation.Date__c = {
            field: null,
            validate: function() {
                var status = {
                    isValid: true,
                    message: ""
                };

                if ($A.util.isEmpty(this.field)) {
                    status.isValid = false;
                    status.message = "Form field is not valid!"
                    return status;
                }

                if ($A.util.isEmpty(this.field.value) && this.field.required) {
                    status.isValid = false;
                    status.message = "This required field must be completed!"
                    return status;
                }

                var Date__c = new Date(formValidation.Date__c.field.value).getTime();
                var tomorrowDay = new Date();
                tomorrowDay.setHours(24, 0, 0, 0);

                if (tomorrowDay >  Date__c) {
                    status.isValid = false
                    status.message = "Date should start only from tomorrow!"
                    return status;
                }

                if (mdDayRecordTypeName === "MD_Operation_Day") { 
                    var startDateTime = new Date(formValidation.Operation_Day_Start_Time__c.field.value).getTime();
                    var endDateTime = new Date(formValidation.Operation_Day_End_Time__c.field.value).getTime();
                    var durationTime = ((endDateTime - startDateTime)/60000);
    
                    if (durationTime > 0) {
                        formValidation.Total_available_Operation_Time_Minutes__c.field.value = durationTime;
                    }
                }

                return status;
            }
        };

        formValidation.PreliminaryAppointment__c = {
            field: null,
            validate: function() {
                var status = {
                    isValid: true,
                    message: ""
                };

                if ($A.util.isEmpty(this.field)) {
                    status.isValid = false;
                    status.message = "Form field is not valid!"
                    return status;
                }

                if ($A.util.isEmpty(this.field.value) && this.field.required) {
                    status.isValid = false;
                    status.message = "This required field must be completed!"
                    return status;
                }
                
                return status;
            }
        };

        formValidation.Operation_Day_Start_Time__c = {
            field: null,
            validate: function() {
                var status = {
                    isValid: true,
                    message: ""
                };

                if ($A.util.isEmpty(this.field)) {
                    status.isValid = false;
                    status.message = "Form field is not valid!"
                    return status;
                }

                if ($A.util.isEmpty(this.field.value) && this.field.required) {
                    status.isValid = false;
                    status.message = "This required field must be completed!"
                    return status;
                }

                var Date__c = new Date(formValidation.Date__c.field.value).getTime();
                var Operation_Day_Start_Time__c = new Date(this.field.value.split("T")[0]).getTime();

                var tomorrowDay = new Date();
                tomorrowDay.setHours(0, 0, 0, 0);
                
                if (tomorrowDay > Operation_Day_Start_Time__c) {
                    status.isValid = false
                    status.message = "Date should start only from tomorrow!"
                    return status;
                }

                if (Date__c !== Operation_Day_Start_Time__c) {
                    status.isValid = false
                    status.message = "Date values should be equal!"
                    return status;
                }

                var Operation_Day_Start_Time__c = new Date(this.field.value).getTime();
                var Operation_Day_End_Time__c = new Date(formValidation.Operation_Day_End_Time__c.field.value).getTime();

                if (Operation_Day_Start_Time__c >= Operation_Day_End_Time__c) {
                    status.isValid = false
                    status.message = "Start time should be earlier than End time!"
                    return status; 
                }

                return status;
            }
        };

        formValidation.Operation_Day_End_Time__c = {
            field: null,
            validate: function() {
                var status = {
                    isValid: true,
                    message: ""
                };

                if ($A.util.isEmpty(this.field)) {
                    status.isValid = false;
                    status.message = "Form field is not valid!"
                    return status;
                }

                if ($A.util.isEmpty(this.field.value) && this.field.required) {
                    status.isValid = false;
                    status.message = "This required field must be completed!"
                    return status;
                }

                var Date__c = new Date(formValidation.Date__c.field.value).getTime();
                var Operation_Day_End_Time__c = new Date(this.field.value.split("T")[0]).getTime();

                if (Date__c !== Operation_Day_End_Time__c) {
                    status.isValid = false
                    status.message = "Date values should be equal!"
                    return status;
                }

                var tomorrowDay = new Date();
                tomorrowDay.setHours(0, 0, 0, 0);

                if (tomorrowDay > Operation_Day_End_Time__c) {
                    status.isValid = false
                    status.message = "Date should start only from tomorrow!"
                    return status;
                }

                return status;
            }
        };

        formValidation.MD_Day_Location__c = {
            field: null,
            validate: function() {
                var status = {
                    isValid: true,
                    message: ""
                };

                if ($A.util.isEmpty(this.field)) {
                    status.isValid = false;
                    status.message = "Form field is not valid!"
                    return status;
                }

                if ($A.util.isEmpty(this.field.value) && this.field.required) {
                    status.isValid = false;
                    status.message = "This required field must be completed!"
                    return status;
                }

                return status;
            }
        };

        formValidation.Surgeon_Clinic__c = {
            field: null,
            validate: function() {
                var status = {
                    isValid: true,
                    message: ""
                };

                if ($A.util.isEmpty(this.field)) {
                    status.isValid = false;
                    status.message = "Form field is not valid!"
                    return status;
                }

                if ($A.util.isEmpty(this.field.value) && this.field.required) {
                    status.isValid = false;
                    status.message = "This required field must be completed!"
                    return status;
                }

                return status;
            }
        };

        if (mdDayRecordTypeName === "MD_Operation_Day") {
            formValidation.Total_available_Operation_Time_Minutes__c = {
                field: null,
                validate: function() {
                    var status = {
                        isValid: true,
                        message: ""
                    };

                   

                    return status;
                }
            };
        }

        return formValidation;
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
        component.getEvent("onaction").fire({
            data: {
                action: "addAsyncProcess"
            }
        });
    },

    removeAsyncProcess: function(component) {
        component.getEvent("onaction").fire({
            data: {
                action: "removeAsyncProcess"
            }
        });
    }
})