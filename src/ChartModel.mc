// -*- mode: Javascript;-*-

using Toybox.System as System;
using Toybox.Application as App;

class ChartModel {
    var current = null;
    var values_size = 150;
    var values;
    var range_mult;
    var range_mult_count = 0;

    function initialize() {
        set_mult(1);
    }

    function set_mult(new_mult) {
        if (new_mult != range_mult) {
            range_mult = new_mult;
            values = new [values_size];
        }
    }

    function get_values() {
        return values;
    }

    function get_range_minutes() {
        return (values.size() * range_mult / 60);
    }

    function get_current_str() {
        return current == null ? "---" : "" + current;
    }

    function new_value(new_value) {
        current = new_value;
        range_mult_count++;
        if (range_mult_count >= range_mult) {
            for (var i = 1; i < values.size(); i++) {
                values[i-1] = values[i];
            }
            values[values.size() - 1] = current;
            range_mult_count = 0;
        }
    }

    function read_data() {
        var app = App.getApp();
        var old_range_mult = app.getProperty(RANGE_MULT);
        if (old_range_mult != null) {
            range_mult = old_range_mult;
        }
        else {
            range_mult = 1;
        }

        var old_values = app.getProperty(LAST_VALUES);
        var old_time = app.getProperty(LAST_VALUE_TIME);
        if (old_values != null && old_time != null) {
            values = new[values_size];
            var delta = (System.getTimer() - old_time) / 1000 / range_mult;
            if (delta > 0) { // Ignore old data from before reboot
                for (var i = 0; i < values.size() - delta; i++) {
                    values[i] = old_values[i + delta];
                }
            }
        }
        else {
            values = new[values_size];
        }
    }

    function write_data() {
        var app = App.getApp();
        app.setProperty(LAST_VALUES, values);
        app.setProperty(LAST_VALUE_TIME, System.getTimer());
        app.setProperty(RANGE_MULT, range_mult);
    }
}
