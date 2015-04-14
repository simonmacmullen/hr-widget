// -*- mode: Javascript;-*-

using Toybox.Graphics;
using Toybox.Sensor as Sensor;
using Toybox.System as System;
using Toybox.WatchUi as Ui;
using Toybox.Application as App;

enum
{
    LAST_VALUES,
    LAST_VALUE_TIME,
    RANGE_MULT,
    INVERT
}

class HrWidgetView extends Ui.View {
    var current = null;
    var values_size = 150;
    var values;
    var range_mult;
    var range_mult_count = 0;
    var invert = false;
    var chart;

    function set_mult(new_mult) {
        if (new_mult != range_mult) {
            range_mult = new_mult;
            values = new [values_size];
        }
    }

    function get_values() {
        return values;
    }

    function toggle_colors() {
        invert = !invert;
    }

    //! Load your resources here
    function onLayout(dc) {
        chart = new Chart();
    }

    //! Restore the state of the app and prepare the view to be shown
    function onShow() {
        if (values == null) {
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

            var old_invert = app.getProperty(INVERT);
            if (old_invert != null) {
                invert = old_invert;
            }
        }

        Sensor.setEnabledSensors( [Sensor.SENSOR_HEARTRATE] );
        Sensor.enableSensorEvents( method(:onSensor) );
    }

    //! Called when this View is removed from the screen. Save the
    //! state of your app here.
    function onHide() {
        // Write here for the widget case
        write_data();
    }

    function write_data() {
        var app = App.getApp();
        app.setProperty(LAST_VALUES, values);
        app.setProperty(LAST_VALUE_TIME, System.getTimer());
        app.setProperty(RANGE_MULT, range_mult);
        app.setProperty(INVERT, invert);
    }

    //! Update the view
    function onUpdate(dc) {
        var fg = invert ? Graphics.COLOR_BLACK : Graphics.COLOR_WHITE;
        var bg = invert ? Graphics.COLOR_WHITE : Graphics.COLOR_BLACK;

        dc.setColor(fg, bg);
        dc.clear();
        dc.setColor(fg, Graphics.COLOR_TRANSPARENT);

        var minutes_label = (values.size() * range_mult / 60) + " MINUTES";

        // TODO this is maybe just a tiny bit too ad-hoc
        if (dc.getWidth() == 218 && dc.getHeight() == 218) {
            // Fenix 3
            text(dc, 109, 15, Graphics.FONT_TINY, "HEART");
            text(dc, 109, 45, Graphics.FONT_NUMBER_MEDIUM, str(current));
            text(dc, 109, 192, Graphics.FONT_XTINY, minutes_label);
            chart.draw(dc, 23, 75, 195, 172, fg, Graphics.COLOR_RED, values);
        } else if (dc.getWidth() == 205 && dc.getHeight() == 148) {
            // Vivoactive, FR920xt, Epix
            text(dc, 70, 25, Graphics.FONT_MEDIUM, "HR");
            text(dc, 120, 25, Graphics.FONT_NUMBER_MEDIUM, str(current));
            text(dc, 102, 135, Graphics.FONT_XTINY, minutes_label);
            chart.draw(dc, 10, 45, 195, 120, fg, Graphics.COLOR_RED, values);
        }
    }

    function text(dc, x, y, font, s) {
        dc.drawText(x, y, font, s,
                    Graphics.TEXT_JUSTIFY_CENTER|Graphics.TEXT_JUSTIFY_VCENTER);
    }

    function str(num) {
        return num == null ? "---" : "" + num;
    }

    function onSensor(sensorInfo) {
        current = sensorInfo.heartRate;
        range_mult_count++;
        if (range_mult_count >= range_mult) {
            for (var i = 1; i < values.size(); i++) {
                values[i-1] = values[i];
            }
            values[values.size() - 1] = current;
            range_mult_count = 0;
        }
        Ui.requestUpdate();
    }
}

class HrWidgetDelegate extends Ui.InputDelegate {
    function onKey(evt) {
        if (evt.getKey() == Ui.KEY_ENTER) {
            Ui.pushView(new Rez.Menus.MainMenu(), new MenuDelegate(),
                        Ui.SLIDE_LEFT);
            return true;
        }
        return false;
    } 
}

class MenuDelegate extends Ui.MenuInputDelegate {
    function onMenuItem(item) {
        if (item == :set_period) {
            Ui.pushView(new Rez.Menus.PeriodMenu(), new PeriodMenuDelegate(),
                        Ui.SLIDE_LEFT);
            return true;
        }
        else if (item == :swap_colors) {
            widget.toggle_colors();
            return true;
        } 
        Ui.popView(Ui.SLIDE_RIGHT);
        return true;
    }
}

class PeriodMenuDelegate extends Ui.MenuInputDelegate {
    function onMenuItem(item) {
        if (item == :min_2) {
            widget.set_mult(1);
        }
        else if (item == :min_5) {
            widget.set_mult(2);
        }
        else if (item == :min_10) {
            widget.set_mult(4);
        }
        else if (item == :min_15) {
            widget.set_mult(6);
        }
        else if (item == :min_30) {
            widget.set_mult(12);
        }
        else if (item == :min_45) {
            widget.set_mult(18);
        }
        else if (item == :min_60) {
            widget.set_mult(24);
        }
        Ui.popView(Ui.SLIDE_RIGHT);
        return true;
    } 
}
