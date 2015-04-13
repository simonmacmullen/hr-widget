// -*- mode: Javascript;-*-

using Toybox.Graphics;
using Toybox.Sensor as Sensor;
using Toybox.System as System;
using Toybox.WatchUi as Ui;
using Toybox.Application as App;

enum
{
    LAST_VALUES,
    LAST_VALUE_TIME
}

class HrWidgetView extends Ui.View {
    var current = null;
    var values = new [120];
    var chart;

    function set_range(range) {
        var size;
        var new_values = new [range];
        var delta = range - values.size();
        for (var i = 0; i < values.size(); i++) {
            var new_i = i + delta;
            if (new_i >= 0 && new_i < new_values.size()) {
                new_values[new_i] = values[i];
            }
        }
        values = new_values;
    }

    function get_values() {
        return values;
    }

    //! Load your resources here
    function onLayout(dc) {
        chart = new Chart();
    }

    //! Restore the state of the app and prepare the view to be shown
    function onShow() {
        var app = App.getApp();
        var old_values = app.getProperty(LAST_VALUES);
        var old_time = app.getProperty(LAST_VALUE_TIME);
        if (old_values != null && old_time != null) {
            values = new[old_values.size()];
            var delta = (System.getTimer() - old_time) / 1000;
            if (delta > 0) { // Ignore old data from before reboot
                for (var i = 0; i < values.size() - delta; i++) {
                    values[i] = old_values[i + delta];
                }
            }
        }

        Sensor.setEnabledSensors( [Sensor.SENSOR_HEARTRATE] );
        Sensor.enableSensorEvents( method(:onSensor) );
    }

    //! Called when this View is removed from the screen. Save the
    //! state of your app here.
    function onHide() {
        var app = App.getApp();
        app.setProperty(LAST_VALUES, values);
        app.setProperty(LAST_VALUE_TIME, System.getTimer());
    }

    //! Update the view
    function onUpdate(dc) {
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_BLACK);
        dc.clear();
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);

        var minutes_label = (values.size() / 60) + " MINUTES";

        // TODO this is maybe just a tiny bit too ad-hoc
        if (dc.getWidth() == 218 && dc.getHeight() == 218) {
            // Fenix 3
            text(dc, 109, 15, Graphics.FONT_TINY, "HEART");
            text(dc, 109, 45, Graphics.FONT_NUMBER_MEDIUM, str(current));
            text(dc, 109, 192, Graphics.FONT_XTINY, minutes_label);
            chart.draw(dc, 23, 75, 195, 172,
                       Graphics.COLOR_WHITE, Graphics.COLOR_RED, values);
        } else if (dc.getWidth() == 205 && dc.getHeight() == 148) {
            // Vivoactive, FR920xt, Epix
            text(dc, 70, 25, Graphics.FONT_MEDIUM, "HR");
            text(dc, 120, 25, Graphics.FONT_NUMBER_MEDIUM, str(current));
            text(dc, 102, 135, Graphics.FONT_XTINY, minutes_label);
            chart.draw(dc, 10, 45, 195, 120,
                       Graphics.COLOR_WHITE, Graphics.COLOR_RED, values);
        }
    }

    function is_round_watch(dc) {
        // TODO this is maybe just a tiny bit too ad-hoc
        // square = 205x148
        return dc.getWidth() == 218 && dc.getHeight() == 218;
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
        for (var i = 1; i < values.size(); i++) {
            values[i-1] = values[i];
        }
        values[values.size() - 1] = current;
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
        Ui.popView(Ui.SLIDE_RIGHT);
        return true;
    }
}

class PeriodMenuDelegate extends Ui.MenuInputDelegate {
    function onMenuItem(item) {
        if (item == :min_2) {
            widget.set_range(120);
        }
        else if (item == :min_5) {
            widget.set_range(300);
        }
        else if (item == :min_10) {
            widget.set_range(600);
        }
        else if (item == :min_15) {
            widget.set_range(900);
        }
        Ui.popView(Ui.SLIDE_RIGHT);
        return true;
    } 
}
