({
	initCmp: function(component) {
        console.log("initCmp MDDayRepetitionRule");

        var formFields = component.get("v.formFields");
        console.log("formFields", formFields);

        if ($A.util.isEmpty(formFields)) {
            /* set up record edit form */
            this.getFormData(component);
        } else {
            var config = {
                mode: "RecordEdit"
            };

            component.set("v.config", config);
        }
    },

    onChangeRepetition: function(component, event) {
        console.log(JSON.parse(JSON.stringify(component.get("v.formFields"))));
        var formFields = component.get("v.formFields");
        var name = event.getSource().get("v.name");
        console.log(name);
        var value = event.getSource().get("v.value");
        console.log(value);
        if (name == 'RepeatEvery__c') {
            if (value != '0') {
                console.log('not 0');
                formFields.forEach(function(formField) {
                    if (!$A.util.isEmpty(formField.name)) {
                        if (formField.name == 'Monday__c'
                                || formField.name == 'Tuesday__c'
                                || formField.name == 'Wednesday__c'
                                || formField.name == 'Thursday__c'
                                || formField.name == 'Friday__c'
                                || formField.name == 'Saturday__c'
                                || formField.name == 'Sunday__c') {
                            formField.disabled = false;
                            console.log(formField.value);
                            console.log(formField);
                        }
                        if (formField.name == 'RepeatTill__c') {
                           
                            formField.disabled = false;
                        }  
                    }       
                });
            } else if (value == '0') {
                console.log('the 0');
                formFields.forEach(function(formField) {
                    if (!$A.util.isEmpty(formField.name)) {
                        if (formField.name == 'Monday__c'
                                || formField.name == 'Tuesday__c'
                                || formField.name == 'Wednesday__c'
                                || formField.name == 'Thursday__c'
                                || formField.name == 'Friday__c'
                                || formField.name == 'Saturday__c'
                                || formField.name == 'Sunday__c') {
                            formField.disabled = true;
                            formField.value = false;
                            console.log(formField.value);
                            console.log(formField);               
                        }   
                        if (formField.name == 'RepeatTill__c') {
                            formField.disabled = true;
                            formField.value = null;
                            formField.required = false;
                        }   
                    }
                });
            }
            component.set("v.formFields", formFields);
            console.log(JSON.parse(JSON.stringify(component.get("v.formFields"))));
            this.validateFields(component);
        }
    },

    onChangeCheckbox: function(component, event) {
        this.validateFields(component);
    },

    onChangeDate: function(component, event) {
        this.validateFields(component);
    


    },

    getFormData: function(component) {
        var predefinedFields = this.getCreateMDDayRepetitionRuleFields(component);
        console.log("predefinedFields", JSON.parse(JSON.stringify(predefinedFields)));

        if (!$A.util.isEmpty(predefinedFields)) {
            /* add async process to watcher */
            this.addAsyncProcess(component);

            console.log("getFormData MDDay");

            var fields = [];

            predefinedFields.forEach(function(predefinedField) {
                if (!$A.util.isEmpty(predefinedField.name)) {
                    fields.push(predefinedField.name);
                }
            });
            console.log(fields);

            /* create filter */
            var formDataFilter = {
                objectType: "MDDayRepetitionRule__c",
                recordType: null,
                recordId: null,
                fields: fields
            };
            console.log(formDataFilter);

            var action = component.get("c.getFormData");
            action.setParams({
                formDataFilterJSON: JSON.stringify(formDataFilter)
            });
            action.setCallback(this, function(data) {
                if (component.isValid()) {
                    var response = JSON.parse(data.getReturnValue());
                    console.log("response", JSON.parse(JSON.stringify(response)));

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
                            } else {
                                if (predefinedField.type == "SPACER") {
                                    formFields.push(predefinedField);
                                }
                            }
                        });
                        console.log("formFields", JSON.parse(JSON.stringify(formFields)));
                        component.set("v.formFields", formFields);

                        /* set up record edit form */
                        var config = {
                            mode: "RecordEdit"
                        };

                        component.set("v.config", config);
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
    },

    saveRecord: function(component, event) {
        var recordEditComponent = component.find("RecordEdit");

        var params = event.getParam("arguments");

        if (!$A.util.isEmpty(params)) {
            var callback = params.callback;

            if (!$A.util.isEmpty(recordEditComponent)) {
                recordEditComponent.saveRecord(params.fields, params.recordId, params.recordType, params.objectType, function(result) {
                    if (!$A.util.isEmpty(callback)) {
                        callback(result);
                    }
                });
            } else {
                callback(recordEditComponent);
            }
        }
    },

    validateFields: function(component, event, helper) {
        var isValidForm = false;

        /* get form validation */
        var formValidation = this.getFormValidation(component);

        /* get form fields */
        var formFields = component.get("v.formFields");

        formFields.forEach(function(formField) {
            if (formValidation.hasOwnProperty(formField.name)) {
                formValidation[formField.name].field = formField;
            }
        });
        console.log(formValidation);

        function validateField(previousValue, field) {
            var valid = true;
    
            if (!$A.util.isEmpty(field)) {
                /* get field name */
                var fieldName = getFieldName(field);
                console.log(fieldName);
                console.log(field.get("v.label"));

                /* validate field */
                var fieldStatus = formValidation[fieldName].validate();
                console.log(fieldStatus);

                if (!fieldStatus.isValid) {
                    console.log('error!!!');
                    showFieldError(field, fieldStatus.message);
                    valid = false;
                } else {
                    console.log('not error!!!');
                    hideFieldError(field);
                    valid = true;
                }
            }
    
            return previousValue && valid;
        }

        function getFieldName(field) {
            var fieldName = "";

            /* get name */
            var name = field.get("v.name");

            if (!$A.util.isEmpty(name)) {
                fieldName = name.indexOf("-") !== -1
                        ? name.substring(0, name.indexOf("-"))
                        : name;
            } else {
                /* get class */
                var className = field.get("v.class");
                fieldName = className;
            }

            return fieldName;
        }

        function showFieldError(field, message) {
            if (typeof field.reportValidity !== typeof undefined) {
                field.setCustomValidity(message);
                //field.showHelpMessageIfInvalid();
                field.reportValidity();
            } else if (typeof field.showError !== typeof undefined) {
                field.showError(message);
            } else if (typeof field.get("v.errors") !== typeof undefined) {
                field.set("v.errors", [{message: message}]);
            }
        }

        function hideFieldError(field) {
            if (typeof field.reportValidity !== typeof undefined) {
                field.setCustomValidity("");
                //field.showHelpMessageIfInvalid();
                field.reportValidity();
                console.log('not error 1!!!');
                console.log(field.get('v.required'));
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

    getCreateMDDayRepetitionRuleFields: function(component) {
        var fields = [];

        /* get sobject name */
        var sObjectName = component.get("v.sObjectName");

        fields.push({
            value: null,
            name: "RepeatEvery__c",
            label: "Repeat Every Week",
            type: "PICKLIST",
            required: false,
            placeholder: "Select an Option",
            disabled: false,
            options: [],
            largeDeviceSize: 6,
            mediumDeviceSize: 6
        });

        fields.push({
            value: null,
            name: "RepeatTill__c",
            label: "Repeat Till",
            type: "DATE",
            required: false,
            placeholder: "",
            //disabled: false,
            disabled: true,
            inputName: "RepeatTill__c-" + Date.now(),
            largeDeviceSize: 6,
            mediumDeviceSize: 6
        });

        fields.push({
            value: null,
            name: "Monday__c",
            label: "Monday",
            type: "BOOLEAN",
            required: false,
            placeholder: "",
            //disabled: false,
            disabled: true,
            largeDeviceSize: 6,
            mediumDeviceSize: 6
        });

        fields.push({
            value: null,
            name: "Tuesday__c",
            label: "Tuesday",
            type: "BOOLEAN",
            required: false,
            placeholder: "",
            //disabled: false,
            disabled: true,
            largeDeviceSize: 6,
            mediumDeviceSize: 6
        });

        fields.push({
            value: null,
            name: "Wednesday__c",
            label: "Wednesday",
            type: "BOOLEAN",
            required: false,
            placeholder: "",
            //disabled: false,
            disabled: true,
            largeDeviceSize: 6,
            mediumDeviceSize: 6
        });

        fields.push({
            value: null,
            name: "Thursday__c",
            label: "Thursday",
            type: "BOOLEAN",
            required: false,
            placeholder: "",
            //disabled: false,
            disabled: true,
            largeDeviceSize: 6,
            mediumDeviceSize: 6
        });

        fields.push({
            value: null,
            name: "Friday__c",
            label: "Friday",
            type: "BOOLEAN",
            required: false,
            placeholder: "",
            //disabled: false,
            disabled: true,
            largeDeviceSize: 6,
            mediumDeviceSize: 6
        });

        fields.push({
            value: null,
            name: "Saturday__c",
            label: "Saturday",
            type: "BOOLEAN",
            required: false,
            placeholder: "",
            //disabled: false,
            disabled: true,
            largeDeviceSize: 6,
            mediumDeviceSize: 6
        });

        fields.push({
            value: null,
            name: "Sunday__c",
            label: "Sunday",
            type: "BOOLEAN",
            required: false,
            placeholder: "",
            //disabled: false,
            disabled: true,
            largeDeviceSize: 6,
            mediumDeviceSize: 6
        });

        fields.push({
            type: "SPACER",
            largeDeviceSize: 6,
            mediumDeviceSize: 6
        });

        return fields;
    },

    getFormValidation: function(component) {
        var formValidation = {};

        formValidation.Monday__c = {
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

        formValidation.Tuesday__c = {
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

        formValidation.Wednesday__c = {
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

        formValidation.Thursday__c = {
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

        formValidation.Friday__c = {
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

        formValidation.Saturday__c = {
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

        formValidation.Sunday__c = {
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

        formValidation.RepeatEvery__c = {
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

                if (!$A.util.isEmpty(this.field.value) 
                        && formValidation.RepeatEvery__c.field.value != '0' 
                        && formValidation.Monday__c.field.value == false
                        && formValidation.Tuesday__c.field.value == false
                        && formValidation.Wednesday__c.field.value == false
                        && formValidation.Thursday__c.field.value == false
                        && formValidation.Friday__c.field.value == false
                        && formValidation.Saturday__c.field.value == false
                        && formValidation.Sunday__c.field.value == false) {
                    status.isValid = false;
                    status.message = "Choose day of week for Repetition Day or change to Do not Repeat option"
                    return status;
                }

                return status;
            }
        };

        formValidation.RepeatTill__c = {
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

                if ($A.util.isEmpty(this.field.value) 
                        && formValidation.RepeatEvery__c.field.value != '0') {
                    status.isValid = false;
                    status.message = "This field should be completed!"
                    return status;
                }

                if (!$A.util.isEmpty(this.field.value)) {
                    var mdDayformFields = component.get("v.mdDayformFields");
                    console.log(mdDayformFields);
                    mdDayformFields.forEach(function(mdDayformField) {
                        if (!$A.util.isEmpty(mdDayformField.name) 
                                && mdDayformField.name == 'Date__c'
                                && (mdDayformField.value > formValidation.RepeatTill__c.field.value)) {
                            console.log('!!!!');
                            console.log(mdDayformField.value > formValidation.RepeatTill__c.field.value);
                            status.isValid = false;
                            status.message = "Repeat Till field contains the date earlier than MD Day itself!"
                            return status;
                        }
                    });
                }

                return status;
            }
        };

        console.log(formValidation);

        return formValidation;
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
        console.log("innerSpinner");
        component.getEvent("onaction").fire({
            data: {
                action: "addAsyncProcess"
            }
        });
    },

    removeAsyncProcess: function(component) {
        console.log("outerSpinner");
        component.getEvent("onaction").fire({
            data: {
                action: "removeAsyncProcess"
            }
        });
    }
})