({
	initCmp: function(component) {
        var pageReference = component.get("v.pageReference");

        component.set("v.recordId", pageReference.state.c__recordId);
        component.set("v.sObjectName", pageReference.state.c__sObjectName);
        component.set("v.mdDayRecordTypeId", pageReference.state.c__mdDayRecordTypeId);
        component.set("v.mdDayRecordTypeName", pageReference.state.c__mdDayRecordTypeName);
        component.set("v.step", "mdDay");
	},

    pageReferenceChange: function(component) {
        $A.get("e.force:refreshView").fire();
    },

    action: function(component, event, helper) {
        event.stopPropagation();

        if (event.getParams().hasOwnProperty("data")) {
            var eventData = event.getParam("data");

            if (!$A.util.isEmpty(eventData)) {
                var eventAction = eventData.action;

                if (eventAction === "changeStep") {
                    this.changeStep(component, eventData, helper);
                } else if (eventAction === "addAsyncProcess") {
                    this.addAsyncProcess(component);
                } else if (eventAction === "removeAsyncProcess") {
                    this.removeAsyncProcess(component);
                }
            }
        }
    },

    changeStep: function(component, eventData, helper) {
        if (!$A.util.isEmpty(eventData)) {
            var initialStep = eventData.initialStep;

            if (!$A.util.isEmpty(initialStep)) {
                if (initialStep === "mdDay") {
                    var actionClicked = eventData.actionClicked;

                    if (actionClicked === "BACK") {
                        helper.navigateToRecordPage(
                            component,
                            component.get("v.recordId"),
                            component.get("v.sObjectName"),
                            "view"
                        );
                    } else {
                        var screenComponent = component.find(initialStep);

                        if (!$A.util.isEmpty(screenComponent)) {
                            var isValidForm = screenComponent.validateForm();

                            if (isValidForm) {
                                helper.setStep(component, eventData);
                            }
                        }
                    }
                } else if (initialStep === "mdDayRepetitionRule") {
                    var actionClicked = eventData.actionClicked;

                    if (actionClicked === "FINISH") {
                        var screenComponent = component.find(initialStep);

                        if (!$A.util.isEmpty(screenComponent)) {
                            var isValidForm = screenComponent.validateForm();

                            if (isValidForm) {
                                helper.saveMDDay(component, helper);
                            }
                        }
                    } else {
                        helper.setStep(component, eventData);
                    }
                } else if (initialStep === "error") {
                    var actionClicked = eventData.actionClicked;

                    if (actionClicked === "ERRORBACK") {
                        helper.navigateToRecordPage(
                            component,
                            component.get("v.recordId"),
                            component.get("v.sObjectName"),
                            "view"
                        );
                    }
                }
            }
        }
    },

    saveMDDay: function(component, helper) {
        var mdDayformFields = component.get("v.mdDayformFields");

        var isMdDayPopulated = helper.isRecordPopulated(mdDayformFields, helper);

        var mdDayRepetitionRuleFormFields = component.get("v.mdDayRepetitionRuleFormFields");

        var isMdDayRepetitionRulePopulated = helper.isRecordPopulated(mdDayRepetitionRuleFormFields, helper);

        if (isMdDayPopulated) {
            var mdDayRecordTypeId = component.get("v.mdDayRecordTypeId");

            this.addAsyncProcess(component);

            var mdDayRecord = {};

            mdDayformFields.forEach(function(formField) {
                if (!$A.util.isEmpty(formField.name)) {
                    mdDayRecord[formField.name] = this.getFieldValue(formField);
                }
            }, this);

            if (!$A.util.isEmpty(mdDayRecordTypeId)) {
                mdDayRecord["RecordTypeId"] = mdDayRecordTypeId;
            }

            var formData = {
                mdDay: {
                    record: mdDayRecord,
                    objectType: "MD_Day__c"
                }
            };

            if (isMdDayRepetitionRulePopulated) {
                var mdDayRepetitionRuleRecord = {};

                mdDayRepetitionRuleFormFields.forEach(function(formField) {
                    if (!$A.util.isEmpty(formField.name)) {
                        mdDayRepetitionRuleRecord[formField.name] = this.getFieldValue(formField);
                    }
                }, this);

                formData.mdDayRepetitionRule = {
                    record: mdDayRepetitionRuleRecord,
                    objectType: "MDDayRepetitionRule__c"
                };
            }

            var action = component.get("c.saveMDDay");
            action.setParams({
                mdDayDataJSON: JSON.stringify(formData)
            });
            action.setCallback(this, function(data) {
                if (component.isValid()) {
                    this.removeAsyncProcess(component);

                    var response = JSON.parse(data.getReturnValue());

                    if (response.status === "success") {
                        helper.navigateToRecordPage(
                            component,
                            component.get("v.recordId"),
                            component.get("v.sObjectName"),
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
        } else {
            helper.navigateToRecordPage(
                component,
                component.get("v.recordId"),
                component.get("v.sObjectName"),
                "view"
            );
        }
    },

    isRecordPopulated: function(formFields, helper) {
        var isRecordPopulated = false;

        if (!$A.util.isEmpty(formFields)) {
            function getValue(formField) {
                var result = null;

                if (!$A.util.isEmpty(formField.value)) {
                    if (formField.type === "BOOLEAN") {
                        if (formField.value === true) {
                            result = formField.value;
                        }
                    } else {
                        result = formField.value;
                    }
                }
        
                return result;
            }

            formFields.forEach(function(formField) {
                if (!$A.util.isEmpty(getValue(formField))) {
                    isRecordPopulated = true;
                }
            });
        }

        return isRecordPopulated;
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

    setStep: function(component, eventData) {
        var step = eventData.step;

        if (!$A.util.isEmpty(step)) {
            component.set("v.step", step);
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