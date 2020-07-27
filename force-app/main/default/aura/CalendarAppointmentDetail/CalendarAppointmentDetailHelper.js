({
    onSave: function (component, event) {
        var returnAppointmentDetailEvent = $A.get("e.c:ReturnAppointmentDetailEvent");
        returnAppointmentDetailEvent.fire({
            "titleVal": component.get("v.titleVal"),
            "descriptionVal": component.get("v.descriptionVal"),
            "eventId": component.get("v.eventId")
        });
        component.find("overlayLib").notifyClose();
    }
})