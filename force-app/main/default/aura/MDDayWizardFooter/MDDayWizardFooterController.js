({
    handleInitCmp: function(component, event, helper) {
        helper.initCmp(component);
    },

    handleStepChange: function(component, event, helper) {
        helper.stepChange(component, event);
    },

    handleActionButtonClick: function(component, event, helper) {
        helper.actionButtonClick(component, event);
	}
})