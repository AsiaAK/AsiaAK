({
	handleInitCmp: function(component, event, helper) {
        helper.initCmp(component);
    },

    handleValidateForm: function(component, event, helper) {
        return helper.validateForm(component);
    }
})