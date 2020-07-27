({
    close: function(component) {
        component.find("overlayLib").notifyClose();
    },

    cancel: function(component) {
        component.find("overlayLib").notifyClose();
    },

    ok: function(component) {
        component.getEvent("onaction").fire({
            data: {
                action: "ok",
                data: component.get("v.data")
            }
        });
    }
})