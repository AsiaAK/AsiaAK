({
	initCmp: function(component) {
        var step = component.get("v.step");

        if (!$A.util.isEmpty(step)) {
            var steps = component.get("v.steps");
            var stepNumber = steps.indexOf(step);

            component.set("v.stepNumber", stepNumber);
        }
    },

    stepChange: function(component, event) {
        var step = event.getParam("value");

        if (!$A.util.isEmpty(step)) {
            var steps = component.get("v.steps");
            var stepNumber = steps.indexOf(step);

            component.set("v.stepNumber", stepNumber);
        }
    },

    actionButtonClick: function(component, event) {
        var actionClicked = event.getSource().getLocalId();

        var steps = component.get("v.steps");
        var step = component.get("v.step");
        var stepNumber = component.get("v.stepNumber");

        if (actionClicked === "BACK") {
            stepNumber--;
        } else if (actionClicked === "NEXT") {
            stepNumber++;
        }

		component.getEvent("onaction").fire({
			data: {
                action: "changeStep",
                initialStep: step,
                actionClicked: actionClicked,
                step: steps[stepNumber]
			}
		});
    }
})