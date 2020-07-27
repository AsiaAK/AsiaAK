({
	handleInitCmp : function(component, event, helper) {
		helper.initCmp(component);
	},

	handleGetActivities: function(component, event, helper) {
        helper.getActivities(component);
	},
	
	handleDateRangeChange: function(component, event, helper) {
        helper.dateRangeChange(component, event);
    },

    handleActivityClick: function(component, event, helper) {
        helper.activityClick(component, event);
    },

    handleDayClick: function(component, event, helper) {
        helper.dayClick(component, event);
    },

    handleOnLoading: function(component, event, helper) {
        helper.onLoading(component, event);
    }
})