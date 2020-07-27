({
	handleInitCmp: function(component, event, helper) {
        helper.initCmp(component);
    },

    handlePageReferenceChange: function(component, event, helper) {
        helper.pageReferenceChange(component);
    },

    handleAction: function(component, event, helper) {
        helper.action(component, event, helper);
    }
})