({
	initCmp: function(component) {
        this.getFormData(component);
    },

    getFormData: function(component) {
        var sectionFields = component.get("v.sectionFields");

        if (!$A.util.isEmpty(sectionFields)) {
            this.addAsyncProcess(component);

            var objectFields = {};

            sectionFields.forEach(function(section) {
                section.rows.forEach(function(row) {
                    row.fields.forEach(function(field) {
                        if (field.hasOwnProperty("sourceObjectName")) {
                            if (!$A.util.isEmpty(field.sourceRecordId)) {
                                if (!objectFields.hasOwnProperty(field.sourceObjectName)) {
                                    objectFields[field.sourceObjectName] = {};
                                }
    
                                if (!objectFields[field.sourceObjectName].hasOwnProperty("recordId")) {
                                    objectFields[field.sourceObjectName]["recordId"] = field.sourceRecordId;
                                }
    
                                if (!objectFields[field.sourceObjectName].hasOwnProperty("fields")) {
                                    objectFields[field.sourceObjectName]["fields"] = [];
                                }
    
                                objectFields[field.sourceObjectName]["fields"].push(field.sourceFieldName);
                            }
                        } else {
                            if (!$A.util.isEmpty(field.recordId)) {
                                if (!objectFields.hasOwnProperty(field.objectName)) {
                                    objectFields[field.objectName] = {};
                                }
    
                                if (!objectFields[field.objectName].hasOwnProperty("recordId")) {
                                    objectFields[field.objectName]["recordId"] = field.recordId;
                                }
    
                                if (!objectFields[field.objectName].hasOwnProperty("fields")) {
                                    objectFields[field.objectName]["fields"] = [];
                                }
    
                                objectFields[field.objectName]["fields"].push(field.name);
                            }
                        }
                    });
                });
            });

            if (!$A.util.isEmpty(objectFields)) {
                var formDataFilter = {
                    objectFields: objectFields
                };

                var action = component.get("c.getFormData");
                action.setParams({
                    formDataFilterJSON: JSON.stringify(formDataFilter)
                });
                action.setCallback(this, function(data) {
                    if (component.isValid()) {
                        var response = JSON.parse(data.getReturnValue());

                        if (response.status === "success") {
                            sectionFields.forEach(function(section) {
                                section.rows.forEach(function(row) {
                                    row.fields.forEach(function(predefinedField) {
                                        if (predefinedField.hasOwnProperty("sourceObjectName")) {
                                            if (response.data.formData.hasOwnProperty(predefinedField.sourceObjectName)) {
                                                var object = response.data.formData[predefinedField.sourceObjectName];
    
                                                if (object.hasOwnProperty("fields") && object.fields.hasOwnProperty(predefinedField.sourceFieldName)) {
                                                    var field = object.fields[predefinedField.sourceFieldName];
    
                                                    if ($A.util.isEmpty(predefinedField.value)) {
                                                        predefinedField.value = field.value;
                                                    }
                    
                                                    if (field.type === "PICKLIST"
                                                            || field.type === "COMBOBOX"
                                                            || field.type === "MULTIPICKLIST") {
                                                        predefinedField.options = field.options;
                                                    }
                                                }
                                            }
                                        } else {
                                            if (response.data.formData.hasOwnProperty(predefinedField.objectName)) {
                                                var object = response.data.formData[predefinedField.objectName];
    
                                                if (object.hasOwnProperty("fields") && object.fields.hasOwnProperty(predefinedField.name)) {
                                                    var field = object.fields[predefinedField.name];
    
                                                    if ($A.util.isEmpty(predefinedField.value)) {
                                                        predefinedField.value = field.value;
                                                    }
                    
                                                    if (field.type === "PICKLIST"
                                                            || field.type === "COMBOBOX"
                                                            || field.type === "MULTIPICKLIST") {
                                                        predefinedField.options = field.options;
                                                    }
                                                }
                                            }
                                        }
                                    });
                                });
                            });

                            component.set("v.sectionFields", sectionFields);             
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

    validateForm: function(component) {
        var isValidForm = false;

        var formValidation = component.get("v.formValidation");

        var sectionFields = component.get("v.sectionFields");

        sectionFields.forEach(function(section) {
            section.rows.forEach(function(row) {
                row.fields.forEach(function(formField) {
                    if (formValidation.hasOwnProperty(formField.name)) {
                        formValidation[formField.name].field = formField;
                    }
                });
            });
        });
        formValidation.init();

        function validateField(previousValue, field) {
            var valid = true;
    
            if (!$A.util.isEmpty(field)) {
                var fieldName = getFieldName(field);


                if (formValidation.hasOwnProperty(fieldName)) {
                    var fieldStatus = formValidation[fieldName].validate();

                    if (!fieldStatus.isValid) {
                        showFieldError(field, fieldStatus.message);
                        valid = false;
                    } else {
                        hideFieldError(field);
                        valid = true;
                    }
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

        function showToast(component, variant, title, message) {
            var notifLib = component.find("notifLib");

            if (!$A.util.isEmpty(notifLib)) {
                var toast = {
                    variant: variant,
                    title: title,
                    message: message
                };

                notifLib.showToast(toast);
            }
        }

        function showFieldError(field, message) {
            if (typeof field.reportValidity !== typeof undefined) {
                if (field.get("v.disabled") || field.get("v.readonly")) {
                    showToast(component, "error", "Error", message);
                    component.find("overlayLib").notifyClose();
                } else {
                    field.setCustomValidity(message);
                    field.reportValidity();
                }
            } else if (typeof field.showError !== typeof undefined) {
                field.showError(message);
            } else if (typeof field.get("v.errors") !== typeof undefined) {
                field.set("v.errors", [{message: message}]);
            }
        }

        function hideFieldError(field) {
            if (typeof field.reportValidity !== typeof undefined) {
                field.setCustomValidity("");
                field.reportValidity();
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
        var enableInnerSpinner = component.get("v.enableInnerSpinner");

        if (enableInnerSpinner === true) {
            var asyncProcesses = component.get("v.asyncProcesses");
            asyncProcesses += 1;
            component.set("v.asyncProcesses", asyncProcesses);
        } else {
            component.getEvent("onaction").fire({
                data: {
                    action: "addAsyncProcess"
                }
            });
        }
    },

    removeAsyncProcess: function(component) {
        var enableInnerSpinner = component.get("v.enableInnerSpinner");

        if (enableInnerSpinner === true) {
            var asyncProcesses = component.get("v.asyncProcesses");
            asyncProcesses -= 1;
            component.set("v.asyncProcesses", asyncProcesses);
        } else {
            component.getEvent("onaction").fire({
                data: {
                    action: "removeAsyncProcess"
                }
            });
        }
    }
})