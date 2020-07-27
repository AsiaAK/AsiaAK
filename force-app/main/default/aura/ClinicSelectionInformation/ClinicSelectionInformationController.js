({
    doInit: function(component, event, helper) {
        helper.getInformation(component, event);
    },
    clickHideMsg: function(component, event, helper) {
        helper.hideBlock(component, "msgCont");
    },
    checkDateofBirth: function(component, event, helper) {
        helper.checkDateofBirth(component);
    },
    doSave: function(component, event, helper) {        
        helper.handleUploadAction(component, event);
        helper.doSave(component, event);
	}
})