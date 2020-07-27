({
    renderCalendar : function(component) {
        var helper = this;
        var eventsMap = component.get("v.events");

        var eventArray =  [];
		debugger;
        $.each(eventsMap, $A.getCallback(function(index, value){
            var newEvent = {
                id : value.Id,
                title : value.title,
                start : moment(value.startDateTime),
                end : moment(value.endDateTime),
                description : value.description,
                owner : value.owner,
                booking : value.sObjectId,
                isRebooking : value.isRebooking,
                priority : value.priority,
                appDate : value.appDate,
                clinic : value.clinic
            };
            eventArray.push(newEvent);
        }));
        var calendarButtons = component.get('v.calendarButtons');

        var calendar = $('#'+component.get("v.recordId")).fullCalendar('getCalendar');

        if(component.get('v.simpleRecord').Pre_Ex_appointment_status__c !== 'Confirmed') {
            if (calendar.renderEvents) {
                calendar.removeEventSources();
                calendar.addEventSource({events:eventArray,origArray:eventArray});
            } else {
                $('#' + component.get("v.recordId")).fullCalendar({
                    header: {
                        left: 'today prev,next',
                        center: 'title',
                        right: calendarButtons
                    },
                    timeFormat: 'h:mm a',
                    eventStartEditable: false,
                    disableDragging: true,
                    defaultDate: moment().format("YYYY-MM-DD"),
                    navLinks: true, // can click day/week names to navigate views
                    editable: true,
                    eventLimit: true, // allow "more" link when too many events
                    weekends: component.get('v.weekends'),
                    eventBackgroundColor: component.get('v.eventBackgroundColor'),
                    eventBorderColor: component.get('v.eventBorderColor'),
                    eventTextColor: component.get('v.eventTextColor'),
                    events: eventArray,
                    eventRender: function (event, element) {
                        if (event.booking === component.get("v.recordId")) {
                            element.css("border-color", event.isRebooking ? "#606060" : "#0965ff");
                            element.css("border-width", "2px");
                        }
                        if (event.priority >= 50) {
                            element.css("background", "#f45942");
                        } else if (event.priority < 25) {
                            element.css("background", "#66CC33");
                        } else {
                            element.css("background", "#FFCC33");
                        }
                    },
                    eventClick: function (calEvent, jsEvent, view) {
                        component.set('v.titleVal', calEvent.title);
                        component.set('v.descriptionVal', calEvent.description);
                        component.set('v.startDateTimeVal', moment(calEvent.start._d).format());
                        component.set('v.endDateTimeVal', moment(calEvent.end._d).format());
                        component.set('v.idVal', calEvent.id);
                        component.set('v.newOrEdit', 'Edit');
                        component.set('v.priority', calEvent.priority);
                        component.set('v.appDate', moment(calEvent.appDate));
                        component.set('v.clinic', calEvent.clinic);
                        helper.openModal(component, event);
                    }
                });
            }
        }
    },
    deleteRecord : function(component, event) {
        this.deleteEvent(component, event, event.getSource().get("v.value"), function(response){
            var state = response.getState();
            if (state === "SUCCESS") {
                $('#calendar').fullCalendar( 'removeEvents', response.getReturnValue());
                //helper.closeModal(component, event);
                component.set('v.titleVal','');
                component.set('v.idVal','');
                component.set('v.startDateTimeVal','');
                component.set('v.endDateTimeVal','');
                component.set('v.descriptionVal','');
            }
            else if (state === "INCOMPLETE") {
                // do something
            }
            else if (state === "ERROR") {
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.log("Error message: " +
                            errors[0].message);
                    }
                } else {
                    console.log("Unknown error");
                }
            }
        });
    },
    deleteEvent : function(component, event, eventId, callback){
        var action = component.get("c.deleteEvent");

        action.setParams({
            "eventId": eventId,
            "sObjectName" : component.get("v.sObjectName"),
            "titleField" : component.get("v.titleField"),
            "startDateTimeField" : component.get("v.startDateTimeField"),
            "endDateTimeField" : component.get("v.endDateTimeField"),
            "descriptionField" : component.get("v.descriptionField"),
            "userField" : component.get("v.userField")
        });

        if (callback) {
            action.setCallback(this, callback);
        }

        $A.enqueueAction(action);
    },
    openModal : function(component, event) {
        $A.createComponents([
                ["c:CalendarAppointmentDetail",
                    {
                        "titleVal" : component.get("v.titleVal"),
                        "descriptionVal" : component.get("v.descriptionVal"),
                        "startDateTimeVal" :  component.get("v.startDateTimeVal"),
                        "endDateTimeVal" : component.get("v.endDateTimeVal"),
                        "eventId" : component.get("v.idVal")
                    }
                ]
            ],
            function(components, status){
                if (status === "SUCCESS") {
                    component.find('overlayLib').showCustomModal({
                        header: component.get("v.newOrEdit") + ' ' + component.get("v.objectLabel"),
                        body: components[0],
                        showCloseButton: true,
                        closeCallback: function() { }
                    })
                }
            }
        );
    },
    setModalWidowData : function(component, event) {
        var titleVal, descriptionVal, eventId, eventsMap;
        titleVal = event.getParam("titleVal");
        descriptionVal = event.getParam("descriptionVal");
        component.set("v.titleVal",titleVal);
        component.set("v.descriptionVal",descriptionVal);
        eventId = event.getParam("eventId");

        eventsMap = component.get("v.events");
        $.each(eventsMap, $A.getCallback(function(index, value){
            if(value.Id === eventId) {
                value.title = titleVal;
                value.description = descriptionVal;
                value.sObjectId = component.get("v.recordId");
                value.isRebooking = false;
            } else {
                if(value.sObjectId === component.get("v.recordId")) {
                    value.isRebooking = true;
                }
            }
        }));
        component.set("v.events", eventsMap);
    },
    createRecord : function(component, event) {
        var evObj = {
            "id" : component.get('v.idVal'),
            "title" : component.get("v.titleVal"),
            "startDateTime" : moment(component.get("v.startDateTimeVal")).format(),
            "endDateTime" : moment(component.get("v.endDateTimeVal")).format(),
            "appDate" : moment(component.get("v.appDate")).format(),
            "description" : component.get("v.descriptionVal"),
            "sObjectId" : component.get("v.recordId"),
            "priority" : component.get("v.priority"),
            "clinic": component.get("v.clinic"),
            "clinicProduct": component.get("v.clinicProduct")
        };
        if (component.get('v.idVal')) {
            evObj.id = component.get('v.idVal');
            //$('#calendar').fullCalendar( 'removeEvents', component.get('v.idVal') );
        }
        this.upsertEvent(component, evObj, function(response, helper){
            var state = response.getState();
            if (state === "SUCCESS") {
                $A.get('e.force:refreshView').fire();
            } else if (state === "ERROR") {
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.log("Error message: " +
                            errors[0].message);
                    }
                } else {
                    console.log("Unknown error");
                }
            }
        });
    },
    upsertEvent : function(component, evObj, callback) {
        var action, fieldApiNamesJSON = [];
        action = component.get("c.upsertAndBookingEvents");
        fieldApiNamesJSON = {
            title : component.get("v.titleField"),
            startDateTime : component.get("v.startDateTimeField"),
            endDateTime : component.get("v.endDateTimeField"),
            description : component.get("v.descriptionField"),
            owner : component.get("v.userField")
        };

        action.setParams({
            "sEventObj": JSON.stringify(evObj),
            "sObjectName" : component.get("v.sObjectName"),
            "fieldApiNamesJSON" : JSON.stringify(fieldApiNamesJSON)
        });

        if (callback) {
            action.setCallback(this, callback);
        } else {
            action.setCallback(this, function (response) {
                var state = response.getState();
                if (state === "SUCCESS") {
                    this.addMsg(component, "Success", "success");
                } else if (state === "ERROR") {
                    if (response.getError()) {
                        console.log("Error: " + response.getError()[0].message);
                    } else {
                        console.log("Unknown error");
                    }
                }
            });
        }

        $A.enqueueAction(action);
    }
    //    closeModal : function(component, event) {
//        var overlay = component.find('overlayLib');
//        $A.util.removeClass(modal, 'slds-fade-in-open');
//        var backdrop = component.find('backdrop');
//        $A.util.removeClass(backdrop, 'slds-backdrop--open');
//    }
})