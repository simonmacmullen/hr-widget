// -*- mode: Javascript;-*-

using Toybox.Application as App;

var widget;

class HrWidgetApp extends App.AppBase {
    function onStart() {
    }

    function onStop() {
    }

    function getInitialView() {
        widget = new HrWidgetView();
        return [widget, new HrWidgetDelegate()];
    }
}
