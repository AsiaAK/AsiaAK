({
	handleInitCmp: function(component, event, helper) {
        helper.initCmp(component);
    },

    handleValidateForm: function(component, event, helper) {
        return helper.validateFields(component);
    },

    handleOnBlurDate: function(component, event, helper) {
        helper.onBlurDate(component, event);
    }
})