({
	handleInitCmp: function(component, event, helper) {
        helper.initCmp(component);
    },

    handleSaveRecord: function(component, event, helper) {
        helper.saveRecord(component, event);
    },

    handleValidateForm: function(component, event, helper) {
        return helper.validateFields(component);
    },

    handleOnChangeRepetition: function(component, event, helper) {
        console.log('handleOnChangeRepetition');
        helper.onChangeRepetition(component, event);
    },

    handleOnChangeDate: function(component, event, helper) {
        console.log('handleOnChangeDate');
        helper.onChangeDate(component, event);
    },

    handleOnChangeCheckbox: function(component, event, helper) {
        console.log('handleOnChangeCheckbox');
        helper.onChangeCheckbox(component, event);
    }
})