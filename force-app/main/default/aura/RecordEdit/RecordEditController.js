({
	handleInitCmp: function(component, event, helper) {
        helper.initCmp(component);
    },

    handleSave: function(component, event, helper) {
        helper.save(component, event);
    },

    handleSaveRecord: function(component, event, helper) {
        helper.saveRecord(component, event);
    },

    handleValidateForm: function(component, event, helper) {
        return helper.validateFields(component);
    }
})