({
	initCmp: function(component) {
        this.getMdDayRecordTypes(component);
    },

    getMdDayRecordTypes: function(component) {
        var recordId = component.get("v.recordId");

        var sObjectName = component.get("v.sObjectName");

        if (!$A.util.isEmpty(recordId) && !$A.util.isEmpty(sObjectName)) {

            var mdDayRecordTypesFilter = {
                recordId: recordId,
                sObjectName: sObjectName
            };

            var action = component.get("c.getMdDayRecordTypes");
            action.setParams({
                mdDayRecordTypesFilterJSON: JSON.stringify(mdDayRecordTypesFilter)
            });
            action.setCallback(this, function(data) {
                if (component.isValid()) {
                    var response = JSON.parse(data.getReturnValue());

                    if (response.status === "success") {
                        var mdDayRecordTypes = response.data.mdDayRecordTypes
                        component.set("v.mdDayRecordTypes", mdDayRecordTypes);

                        mdDayRecordTypes.forEach(function(mdDayRecordType) {
                            if (mdDayRecordType.selected) {
                                component.set("v.selectedMdDayRecordType", mdDayRecordType.value);
                            }
                        });
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

    next: function(component) {
        var selectedMdDayRecordType = component.get("v.selectedMdDayRecordType");

        if (!$A.util.isEmpty(selectedMdDayRecordType)) {
            var navService = component.find("navService");

            if (!$A.util.isEmpty(navService)) {
                var pageReference = {
                    type: "standard__component",
                    attributes: {
                        componentName: "c__MDDayWizard"
                    }, 
                    state: {
                        c__recordId: component.get("v.recordId"),
                        c__sObjectName: component.get("v.sObjectName"),
                        c__mdDayRecordTypeId: selectedMdDayRecordType,
                        c__mdDayRecordTypeName: this.getMdDayRecordTypeName(component, selectedMdDayRecordType)
                    }
                };

                navService.navigate(pageReference);
            }
        } else {
            this.showToast(component, "error", "Error", "Please select a record type!");
        }
    },

    getMdDayRecordTypeName: function(component, selectedMdDayRecordType) {
        var mdDayRecordTypeName = "";

        var mdDayRecordTypes = component.get("v.mdDayRecordTypes");

        if (!$A.util.isEmpty(mdDayRecordTypes) && !$A.util.isEmpty(selectedMdDayRecordType)) {
            for (var i = 0; i < mdDayRecordTypes.length; i++) {
                var mdDayRecordType = mdDayRecordTypes[i];

                if (selectedMdDayRecordType === mdDayRecordType.value) {
                    mdDayRecordTypeName = mdDayRecordType.developerName;

                    break;
                }
            }
        }

        return mdDayRecordTypeName;
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
    }
})