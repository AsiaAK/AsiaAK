({
	initCmp: function(component) {
        this.getFullCalendar(component);
    },

    eventsChange: function(component) {
        var fullCalendar = component.get("v.fullCalendar");
        if (!$A.util.isEmpty(fullCalendar)) {
            fullCalendar.fullCalendar("refetchEvents");            
        }
    },

    resourcesChange: function(component) {
        var fullCalendar = component.get("v.fullCalendar");
        if (!$A.util.isEmpty(fullCalendar)) {
            fullCalendar.fullCalendar("refetchResources");
            var container = component.find("body-container");
            
            if (container) {
                var containerHeight = container.getElement().offsetHeight;
                if (containerHeight) {
                    fullCalendar.fullCalendar('option', 'contentHeight', containerHeight - 50);
                }
            }
        }
    },

	getFullCalendar: function(component) {
        var calendarElement = component.find("calendar").getElement();
        if (!$A.util.isEmpty(calendarElement)) {
            var fullCalendar = jQuery(calendarElement).fullCalendar({
                schedulerLicenseKey: 'CC-Attribution-NonCommercial-NoDerivatives',
                header: {
                    left: "prev,next today",
                    center: "title",
                    right: "month,agendaWeek,agendaDay"
                    
                },
               
                contentHeight: "auto",
                editable: true, 
                navLinks: true, 
                eventLimit: true, 
                eventLimitClick: "day", 
				fixedWeekCount: false, 
                defaultView: "month",
                allDaySlot: false, 
				eventTextColor: "white", 
                locale: $A.get("$Locale.userLocaleLang"), 
                timezone: $A.get("$Locale.timezone"),
                nowIndicator: true, 
                lazyFetching: false,  
                refetchResourcesOnNavigate: true, 
                eventOrder: "order",
                handleWindowResize: true,
                resources : function(callback, start, end, timezone) {
                    if (component.isValid()) {
                        callback(component.get("v.resources") || []);
                    }
                },
				events: function(start, end, timezone, callback) {
					if (component.isValid()) {
						callback(component.get("v.events") || []);
					}
				},
				viewRender: function(view) {
					component.getEvent("onDateRangeChange").setParams({
						data: {
                            intervalStart: view.start,
                            intervalEnd: view.end
						}
					}).fire();
                },
                eventRender : function(event, element) {
                
                    var showTooltip = component.get("v.showTooltip");
                    if (showTooltip) {
                        element.prop("title", 'Name: '+ event.titleHoverName + '\n'
                            + 'Appointment Status: ' + event.titleHoverAppointmentStatus + '\n'
                            + 'Reminder Call Status: ' + event.titleHoverReminderCallStatus + '\n' 
                            + 'Opportunity Name:' + event.titleHoverOpportunityName + '\n'
                            + 'Opportunity Stage: ' + event.titleHoverOpportunityStage + '\n'
                            + 'Clinic Product: ' + event.titleHoverClinicProduct + '\n' 
                            + 'Paid: ' + event.titleHoverPaid + '\n'
                            + 'Appointment Type: ' + event.titleHoverAppointmentType
                        );
                    }

                    if (event.afterCarePreMedSlot) {
                        element.css("cursor", "default");
                    }
                },
				eventClick: function(calEvent, jsEvent, view) {
                    if (calEvent.url) {
                        window.open(calEvent.url, "_blank");
                        return false;
                    } else if (calEvent.afterCarePreMedSlot) {
                        return false;
                    } else {
                        var calendarEvent = {
                            allDay: calEvent.allDay,
                            className: calEvent.className,
                            color: calEvent.color,
                            end: calEvent.end,
                            id: calEvent.id,
                            mdDayId: calEvent.mdDayId,
                            resourceId: calEvent.resourceId,
                            resourceIds: calEvent.resourceIds,
                            resourceTitle: calEvent.resourceTitle,
                            start: calEvent.start,
                            title: calEvent.title,
                            type: calEvent.type
                        };

                        component.getEvent("onEventClick").setParams({
                            data: {
                                calEvent: calendarEvent
                            }
                        }).fire();
                    }
				},
				dayClick: function(date, jsEvent, view, resourceObj) {
                    if (jsEvent.target.classList.contains("fc-bgevent")) {
                    
                    } else {
                        component.getEvent("onDayClick").setParams({
                            data: {
                                date: moment.tz(date.format("YYYY-MM-DD HH:mm"), $A.get("$Locale.timezone")).toJSON()
                            }
                        }).fire();
                    }
                },
                loading: function(isLoading, view) {
                    component.getEvent("onLoading").setParams({
                        data: {
                            isLoading: isLoading
                        }
                    }).fire();
                },
                views: {
                    month: {
                        resources: false
                    },
                    agendaWeek: {
                        type: 'agenda',
                        duration: { days: 7 },
                        groupByResource: true
                    },
                    agendaDay: {
                        type: 'agenda',
                        duration: { days: 7 },
                        groupByResource: true
                    }
                }
            });

            component.set("v.fullCalendar", fullCalendar);
        }
    }
})