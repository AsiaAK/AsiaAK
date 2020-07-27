({
    created : function(component, event, helper) {
        helper.created(component, event);
    },
    doSave : function (component, event, helper) {
        helper.createRecord(component, event);
    },
    renderCalendar : function(component, event, helper) {
        helper.renderCalendar(component);
    },
    deleteRecord : function(component, event, helper) {
        helper.deleteRecord(component, event);
    },
    openModal : function(component, event, helper) {
        helper.openModal(component, event);
    },
    closeModal : function(component, event, helper) {
        helper.closeModal(component, event);
    },
    setModalWidowData : function(component, event, helper) {
        helper.setModalWidowData(component, event);
    }
})