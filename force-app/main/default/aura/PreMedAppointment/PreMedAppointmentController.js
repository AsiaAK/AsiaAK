({
	handleInitCmp: function(component, event, helper) {
        helper.initCmp(component);
    },

    handlePageReferenceChange: function(component, event, helper) {
        helper.pageReferenceChange(component);
    },

    handleGetAvailabilities: function(component, event, helper) {
        helper.getAvailabilities(component);
    },

    handleAction: function(component, event, helper) {
        helper.action(component, event);
    },

    handleDateRangeChange: function(component, event, helper) {
        helper.dateRangeChange(component, event);
    },

    handleAvailabilityClick: function(component, event, helper) {
        helper.availabilityClick(component, event);
    },

    handleOnLoading: function(component, event, helper) {
        helper.onLoading(component, event);
    }
})