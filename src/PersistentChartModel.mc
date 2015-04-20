// -*- mode: Javascript;-*-

using Toybox.System as System;
using Toybox.Application as App;

class PersistentChartModel extends ChartModel {
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

        update_min_max();
    }

    function write_data() {
        var app = App.getApp();
        app.setProperty(LAST_VALUES, values);
        app.setProperty(LAST_VALUE_TIME, System.getTimer());
        app.setProperty(RANGE_MULT, range_mult);
    }
}
