({
    addAction : function(component, event, helper) {
        var num1=component.get("v.num1");
        var num2=component.get("v.num2");
        var num3=(num1)/((num2*num2)/10000);
        component.set("v.num3", num3);
        component.set("v.isAdd", true);
        component.set("v.isRefresh", true);
        
    },
     
    refreshAction : function(component, event, helper) {
        component.set("v.num1", 0);
        component.set("v.num2", 0);
        component.set("v.isAdd", false);
        component.set("v.isRefresh", false);
    }
})