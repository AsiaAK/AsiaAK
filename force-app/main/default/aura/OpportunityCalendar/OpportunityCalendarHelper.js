({
    initCmp: function(component) {
        console.log("initCmp OpportunityCalendar");
	},
	
	getActivities: function(component) {
        /* get range */
        var range = component.get("v.range");
        console.log("range", JSON.parse(JSON.stringify(range)));

        if (!$A.util.isEmpty(range)) {
            /* add async process to watcher */
            this.addAsyncProcess(component);

            console.log("getActivities CalendarManager");

            /* create filter */
            var activitiesFilter = {
                range: {
                    start: range.start.utc().format(),
                    end: range.end.utc().format()
                },
                groupBy: component.get("v.groupBy"),
                opportunityId: component.get("v.recordId")
            };

            console.log(activitiesFilter);

            var action = component.get("c.getActivities");
            action.setParams({
                activitiesFilterJSON: JSON.stringify(activitiesFilter)
            });
            action.setCallback(this, function(data) {
                if (component.isValid()) {
                    var response = JSON.parse(data.getReturnValue());
                    console.log("response", JSON.parse(JSON.stringify(response)));

                    if (response.status === "success") {
                        var events = response.data.events;

                        events.forEach(function(event) {
                            event.start = moment.tz(event.start, $A.get("$Locale.timezone"));
                            event.end = moment.tz(event.end, $A.get("$Locale.timezone"));
                        });

                        /* set events */
                        component.set("v.events", events);

                        /* set resources */
                        component.set("v.resources", response.data.resources);
                    } else if (response.status === "warning") {
                        this.showToast(component, response.status, "Warning", response.message);
                    } else if (response.status === "error") {
                        this.showToast(component, response.status, "Error", response.message);
                    }

                    /* remove async process from watcher */
                    this.removeAsyncProcess(component);
                }
            });
            $A.enqueueAction(action);
        }
	},
	
	dateRangeChange: function(component, event) {
        console.log("dateRangeChange CalendarManager");
		event.stopPropagation();
        var intervalStart = event.getParam("data").intervalStart;
        var intervalEnd = event.getParam("data").intervalEnd;
        console.log("interval", JSON.parse(JSON.stringify(event.getParam("data"))));
        var range = component.get("v.range");
        console.log("range", JSON.parse(JSON.stringify(range)));
        console.log("$A.util.isEmpty(range)", $A.util.isEmpty(range));
        if (!$A.util.isEmpty(range)) {
            console.log("!intervalStart.isBetween(range.start, range.end)", !intervalStart.isBetween(range.start, range.end, null, '[]'));
            console.log("!intervalEnd.isBetween(range.start, range.end)", !intervalEnd.isBetween(range.start, range.end, null, '[]'));
        }
		if ($A.util.isEmpty(range) || !intervalStart.isBetween(range.start, range.end, null, '[]') || !intervalEnd.isBetween(range.start, range.end, null, '[]')) {
			component.set("v.range", {
				start: moment(intervalStart),
				end: moment(intervalEnd)
			});
        }
	},
	
	activityClick: function(component, event) {
        console.log("activityClick CalendarManager");
        event.stopPropagation();
	},
	
	dayClick: function(component, event) {
        console.log("dayClick CalendarManager");
        event.stopPropagation();
	},
	
	onLoading: function(component, event) {
        event.stopPropagation();

        /* get event data */
        var eventData = event.getParam("data");

        if (!$A.util.isEmpty(eventData)) {
            var isLoading = eventData.isLoading;

            if (isLoading) {
                /* add async process to watcher */
                this.addAsyncProcess(component);
            } else {
                /* remove async process from watcher */
                this.removeAsyncProcess(component);
            }
        }
	},
	
	showToast: function(component, variant, title, message) {
        /* get notification library */
        var notifLib = component.find("notifLib");

        if (!$A.util.isEmpty(notifLib)) {
            var toast = {
                variant: variant,
                title: title,
                message: message
            };

            /* show toast */
            notifLib.showToast(toast);
        }
    },

    addAsyncProcess: function(component) {
        var asyncProcesses = component.get("v.asyncProcesses");
        asyncProcesses += 1;
        component.set("v.asyncProcesses", asyncProcesses);
    },

    removeAsyncProcess: function(component) {
        var asyncProcesses = component.get("v.asyncProcesses");
        asyncProcesses -= 1;
        component.set("v.asyncProcesses", asyncProcesses);
    }

})