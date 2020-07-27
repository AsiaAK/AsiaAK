({
	doReserve : function(component, event, helper) {
        component.set("v.showSpinner", true);
		component.find("details").doSave();
        component.find("events").doSave();
	},
    endEvent : function(component, event, helper) {
        component.set("v.showSpinner", false);
    }
})