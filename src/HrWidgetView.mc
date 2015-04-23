// -*- mode: Javascript;-*-

using Toybox.Graphics;
using Toybox.Sensor as Sensor;
using Toybox.System as System;
using Toybox.WatchUi as Ui;
using Toybox.Application as App;
using Toybox.Attention as Attention;

class HrWidgetView extends Ui.View {
    var invert = false;
    var chart;
    var have_connected = false;

    function toggle_colors() {
        invert = !invert;
    }

    //! Load your resources here
    function onLayout(dc) {
    }

    //! Restore the state of the app and prepare the view to be shown
    function onShow() {
        if (model == null) {
            model = new PersistentChartModel();
            model.read_data();

            chart = new Chart(model);

            var app = App.getApp();
            if (app.getProperty(INVERT) == true) {
                invert = true;
            }
        }

        Sensor.setEnabledSensors( [Sensor.SENSOR_HEARTRATE] );
        Sensor.enableSensorEvents( method(:onSensor) );
    }

    //! Called when this View is removed from the screen. Save the
    //! state of your app here.
    function onHide() {
        // Write here for the widget case
        model.write_data();
        var app = App.getApp();
        app.setProperty(INVERT, invert);
    }

    //! Update the view
    function onUpdate(dc) {
        var fg = invert ? Graphics.COLOR_BLACK : Graphics.COLOR_WHITE;
        var bg = invert ? Graphics.COLOR_WHITE : Graphics.COLOR_BLACK;

        dc.setColor(fg, bg);
        dc.clear();
        dc.setColor(fg, Graphics.COLOR_TRANSPARENT);

        var duration_label;
        if (model.get_range_minutes() < 60) {
            duration_label = model.get_range_minutes().toNumber() + " MINUTES";
        }
        else {
            duration_label = (model.get_range_minutes() / 60).toNumber() + " HOURS";
        }

        // TODO this is maybe just a tiny bit too ad-hoc
        if (dc.getWidth() == 218 && dc.getHeight() == 218) {
            // Fenix 3
            text(dc, 109, 15, Graphics.FONT_TINY, "HEART");
            text(dc, 109, 45, Graphics.FONT_NUMBER_MEDIUM,
                 fmt_num(model.get_current()));
            text(dc, 109, 192, Graphics.FONT_XTINY, duration_label);
            chart.draw(dc, [23, 75, 195, 172], fg, Graphics.COLOR_RED,
                       30, true, true, false, self);
        } else if (dc.getWidth() == 205 && dc.getHeight() == 148) {
            // Vivoactive, FR920xt, Epix
            text(dc, 70, 25, Graphics.FONT_MEDIUM, "HR");
            text(dc, 120, 25, Graphics.FONT_NUMBER_MEDIUM,
                 fmt_num(model.get_current()));
            text(dc, 102, 135, Graphics.FONT_XTINY, duration_label);
            chart.draw(dc, [10, 45, 195, 120], fg, Graphics.COLOR_RED,
                       30, true, true, false, self);
        }
    }

    function fmt_num(num) {
        if (num == null) {
            return "---";
        }
        else {
            return "" + num;
        }
    }

    function text(dc, x, y, font, s) {
        dc.drawText(x, y, font, s,
                    Graphics.TEXT_JUSTIFY_CENTER|Graphics.TEXT_JUSTIFY_VCENTER);
    }

    var vibrateData = [new Attention.VibeProfile( 25, 100),
                       new Attention.VibeProfile( 50, 100),
                       new Attention.VibeProfile( 75, 100),
                       new Attention.VibeProfile(100, 100),
                       new Attention.VibeProfile( 75, 100),
                       new Attention.VibeProfile( 50, 100),
                       new Attention.VibeProfile( 25, 100)];

    function onSensor(sensorInfo) {
        if (sensorInfo.heartRate != null && !have_connected) {
            Attention.playTone(Attention.TONE_START);
            Attention.vibrate(vibrateData);
            have_connected = true;
        }
        model.new_value(sensorInfo.heartRate);
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
            view.toggle_colors();
            return true;
        } 
        Ui.popView(Ui.SLIDE_RIGHT);
        return true;
    }
}

class PeriodMenuDelegate extends Ui.MenuInputDelegate {
    function onMenuItem(item) {
        if (item == :min_2) {
            model.set_range_minutes(2.5);
        }
        else if (item == :min_5) {
            model.set_range_minutes(5);
        }
        else if (item == :min_10) {
            model.set_range_minutes(10);
        }
        else if (item == :min_15) {
            model.set_range_minutes(15);
        }
        else if (item == :min_30) {
            model.set_range_minutes(30);
        }
        else if (item == :min_45) {
            model.set_range_minutes(45);
        }
        else if (item == :hour_1) {
            model.set_range_minutes(60);
        }
        else if (item == :hour_2) {
            model.set_range_minutes(120);
        }
        else if (item == :hour_8) {
            model.set_range_minutes(480);
        }
        else if (item == :hour_24) {
            model.set_range_minutes(1440);
        }
        Ui.popView(Ui.SLIDE_RIGHT);
        return true;
    } 
}
