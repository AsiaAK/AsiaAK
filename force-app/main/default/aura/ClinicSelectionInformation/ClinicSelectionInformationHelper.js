({
    getInformation: function(component, event) {
        var info = [];
        var action = component.get("c.getInformation");
        action.setParams({
            recordId : component.get("v.recordId")
        });

        action.setCallback(this, function(response) {
            var state = response.getState();

            if (state === "SUCCESS") {
                info = response.getReturnValue();
                component.set("v.info", info);
            } else if (state === "ERROR") {
                if (response.getError()) {
                    this.addMsg(component, "Error", "Error: " + response.getError()[0].message);
                } else {
                    console.log("Unknown error");
                }
            }
        });

        $A.enqueueAction(action);
    },
    doSave: function(component, event) {
        var action = component.get("c.setInformation");
        if(component.get("v.allValid")) {
            action.setParams({
                recordId: component.get("v.recordId"),
                info: JSON.stringify(component.get("v.info"))
            });
            console.log('*************************');
            console.log(component.get("v.recordId"));
            console.log(component.get("v.info"));

            action.setCallback(this, function (response) {
                var state = response.getState();                
                if (state === "SUCCESS") {
                    this.addMsg(component, "Success", "success");
                } else if (state === "ERROR") {
                    if (response.getError()) {
                        this.addMsg(component, "Error", "Error: " + response.getError()[0].message);
                    } else {
                        console.log("Unknown error");
                    }
                }
                component.getEvent("endUpdateEvent").fire();
            });

            $A.enqueueAction(action);
        }
    },
    handleUploadAction : function(component, event) {
        var allValid = component.find('fieldId').reduce(function (validSoFar, inputCmp) {
            inputCmp.showHelpMessageIfInvalid();
            return validSoFar && !inputCmp.get('v.validity').valueMissing;
        }, true);
        if(this.checkDateofBirth(component)) {
            allValid = false;
        }
        if(!allValid) {
            component.getEvent("endUpdateEvent").fire();
        }
        component.set("v.allValid", allValid);
    },
    checkDateofBirth : function (component) {
        var allValid,
            inputField,
            value;
        inputField = component.find("dateofBirth");
        value = component.get("v.info").dateofBirth.value;
        allValid = !value;
        if(allValid) {
            inputField.set("v.errors",[{message:'Complete this field'}]);
        } else {
            inputField.set("v.errors",[]);
        }
        return allValid;
    },
    addMsg: function (component, nameType, value) {
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            "title": nameType,
            "message": value,
            "type": nameType
        });
        toastEvent.fire();
    },
    showBlock: function (component, nameTag) {
        var block;
        if (component && component.isValid()) {
            block = component.find(nameTag);
            if (block) {
                $A.util.removeClass(block, "slds-hide");
            }
        }
    },
    hideBlock: function (component, nameTag) {
        var block;
        if (component && component.isValid()) {
            block = component.find(nameTag);
            if (block) {
                $A.util.addClass(block, "slds-hide");
            }
        }
    }
})