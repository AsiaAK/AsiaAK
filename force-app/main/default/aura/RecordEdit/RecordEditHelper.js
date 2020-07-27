({
	initCmp: function(component) {
        var formFields = component.get("v.formFields");

        if ($A.util.isEmpty(formFields)) {
            this.getFormData(component);
        }
    },

    save: function(component, event) {
        var formFields = component.get("v.formFields");

        var params = event.getParam("arguments");
        var callback;
        if (!$A.util.isEmpty(params)) {
            callback = params.callback;
        }

        if (!$A.util.isEmpty(formFields) && this.validateFields(component)) {
            this.addAsyncProcess(component);

            var recordId = component.get("v.recordId");
            var recordTypeId = component.get("v.recordType");

            var record = {};

            formFields.forEach(function(formField) {
                record[formField.name] = this.getFieldValue(formField);
            }, this);

            if (!$A.util.isEmpty(recordId)) {
                record["Id"] = recordId;
            }

            if (!$A.util.isEmpty(recordTypeId)) {
                record["RecordTypeId"] = recordTypeId;
            }

            var formData = {
                record: record,
                objectType: component.get("v.objectType")
            };

            var action = component.get("c.save");
            action.setParams({
                formDataJSON: JSON.stringify(formData)
            });
            action.setCallback(this, function(data) {
                if (component.isValid()) {
                    var response = JSON.parse(data.getReturnValue());

                    if (response.status === "success") {
                        component.getEvent("onsave").fire({
                            data: {
                                action: "save"
                            }
                        });

                        if (!$A.util.isEmpty(callback)) {
                            callback(response);
                        }
                    } else if (response.status === "warning") {
                        this.showToast(component, response.status, "Warning", response.message);
                    } else if (response.status === "error") {
                        this.showToast(component, response.status, "Error", response.message);
                    }

                    this.removeAsyncProcess(component);
                }
            });
            $A.enqueueAction(action);
        } else {
            if (!$A.util.isEmpty(callback)) {
                callback(formFields);
            }
        }
    },

    saveRecord: function(component, event) {
        var params = event.getParam("arguments");

        if (!$A.util.isEmpty(params)) {
            var callback = params.callback;

            var formFields = params.fields;

            if (!$A.util.isEmpty(formFields)) {
                this.addAsyncProcess(component);
    
                var recordId = params.recordId;
                var recordTypeId = params.recordType;
    
                var record = {};
    
                formFields.forEach(function(formField) {
                    record[formField.name] = this.getFieldValue(formField);
                }, this);
    
                if (!$A.util.isEmpty(recordId)) {
                    record["Id"] = recordId;
                }
    
                if (!$A.util.isEmpty(recordTypeId)) {
                    record["RecordTypeId"] = recordTypeId;
                }
    
                var formData = {
                    record: record,
                    objectType: params.objectType
                };
    
                var action = component.get("c.save");
                action.setParams({
                    formDataJSON: JSON.stringify(formData)
                });
                action.setCallback(this, function(data) {
                    if (component.isValid()) {
                        this.removeAsyncProcess(component);

                        var response = JSON.parse(data.getReturnValue());
    
                        if (response.status === "success") {
                            component.getEvent("onsave").fire({
                                data: {
                                    action: "save"
                                }
                            });
    
                            if (!$A.util.isEmpty(callback)) {
                                callback(response);
                            }
                        } else if (response.status === "warning") {
                            this.showToast(component, response.status, "Warning", response.message);
                        } else if (response.status === "error") {
                            this.showToast(component, response.status, "Error", response.message);
                        }
                    }
                });
                $A.enqueueAction(action);
            } else {
                if (!$A.util.isEmpty(callback)) {
                    callback(formFields);
                }
            }
        }
    },

    validateFields: function(component) {
        var valid = true;

        function validateField(previousValue, field) {
            var valid = true;
    
            if (!$A.util.isEmpty(field)) {
                if (typeof field.showHelpMessageIfInvalid !== typeof undefined) {
                    field.showHelpMessageIfInvalid();
                    valid = field.get("v.validity").valid;
                } else if (typeof field.showError !== typeof undefined) {
                    if (field.get("v.required") && $A.util.isEmpty(field.get("v.value"))) {
                        field.showError("This required field must be completed");
                        valid = false;
                    } else {
                        field.hideError();
                        valid = true;
                    }
                } else if (typeof field.get("v.errors") !== typeof undefined) {
                    if (field.get("v.required") && $A.util.isEmpty(field.get("v.value"))) {
                        field.set("v.errors", [{
                            message: "This required field must be completed"
                        }]);
                        valid = false;
                    } else {
                        field.set("v.errors", []);
                        valid = true;
                    }
                }
            }
    
            return previousValue && valid;
        }

        var fields = component.find("field");
        if (!$A.util.isEmpty(fields)) {
            if (Object.prototype.toString.call(fields) === "[object Array]") {
				valid = fields.reduce(function(valid, field) {
					return validateField(valid, field);
				}, true);
            } else {
                valid = validateField(true, fields);
            }
        }

        return valid;
    },

    getFieldValue: function(formField) {
        var result = null;

        if ($A.util.isEmpty(formField.value)) {
            if (formField.type === "BOOLEAN") {
                result = false;
            }
        } else {
            result = formField.value;
        }

        return result;
    },

    getFormData: function(component) {
        var predefinedFields = component.get("v.predefinedFields");

        if (!$A.util.isEmpty(predefinedFields)) {
            this.addAsyncProcess(component);

            var fields = [];

            predefinedFields.forEach(function(predefinedField) {
                fields.push(predefinedField.name);
            });

            var formDataFilter = {
                objectType: component.get("v.objectType"),
                recordType: component.get("v.recordType"),
                recordId: component.get("v.recordId"),
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