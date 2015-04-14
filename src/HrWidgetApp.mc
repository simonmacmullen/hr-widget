// -*- mode: Javascript;-*-

using Toybox.Application as App;

var widget;

class HrWidgetApp extends App.AppBase {
    function onStart() {
        widget = new HrWidgetView();
    }

    function onStop() {
        // Write here for the app case
        widget.write_data();
    }

    function getInitialView() {
        return [widget, new HrWidgetDelegate()];
    }
}
