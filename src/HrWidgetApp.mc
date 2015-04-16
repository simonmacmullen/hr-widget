// -*- mode: Javascript;-*-

using Toybox.Application as App;

var view;
var model;

enum
{
    LAST_VALUES,
    LAST_VALUE_TIME,
    RANGE_MULT,
    INVERT
}

class HrWidgetApp extends App.AppBase {
    function onStart() {
        view = new HrWidgetView();
    }

    function onStop() {
        // Write here for the app case
        model.write_data();
    }

    function getInitialView() {
        return [view, new HrWidgetDelegate()];
    }
}
