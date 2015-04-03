// -*- mode: Javascript;-*-

using Toybox.Application as App;
using Toybox.Graphics;
using Toybox.Sensor as Sensor;
using Toybox.System as System;
using Toybox.WatchUi as Ui;

enum
{
    LAST_VALUES,
    LAST_VALUE_TIME
}

class HrWidget extends Ui.View {
    var current = null;
    var values = new [120];

    //! Load your resources here
    function onLayout(dc) {
    }

    //! Restore the state of the app and prepare the view to be shown
    function onShow() {
        Sensor.setEnabledSensors( [Sensor.SENSOR_HEARTRATE] );
        Sensor.enableSensorEvents( method(:onSensor) );

        var app = App.getApp();
        var old_values = app.getProperty(LAST_VALUES);
        var old_time = app.getProperty(LAST_VALUE_TIME);
        if (old_values != null && old_time != null) {
            var delta = (System.getTimer() - old_time) / 1000;
            if (delta > 0) { // Ignore old data from before reboot
                for (var i = 0; i < values.size() - delta; i++) {
                    values[i] = old_values[i + delta];
                }
            }
        }
    }

    //! Update the view
    function onUpdate(dc) {
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_BLACK);
        dc.clear();
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);

        // TODO this is maybe just a tiny bit too ad-hoc
        if (dc.getWidth() == 218 && dc.getHeight() == 218) {
            // Fenix 3
            text(dc, 109, 15, Graphics.FONT_MEDIUM, "HR");
            text(dc, 109, 55, Graphics.FONT_NUMBER_MEDIUM, str(current));
            chart(dc, 23, 85, 195, 172, 200, values);
        } else if (dc.getWidth() == 205 && dc.getHeight() == 148) {
            // Vivoactive, FR920xt, Epix
            text(dc, 70, 25, Graphics.FONT_MEDIUM, "HR");
            text(dc, 120, 25, Graphics.FONT_NUMBER_MEDIUM, str(current));
            chart(dc, 10, 45, 195, 140, 200, values);
        }
    }

    function text(dc, x, y, font, s) {
        dc.drawText(x, y, font, s,
                    Graphics.TEXT_JUSTIFY_CENTER|Graphics.TEXT_JUSTIFY_VCENTER);
    }

    function chart(dc, x1, y1, x2, y2, data_range_max, data) {
        var width = x2 - x1;
        var height = y2 - y1;
        var x = x1;
        var x_next;
        var item;

        var min = 999999;
        var max = 0;
        var min_x = 0;
        var min_y = 0;
        var max_x = 0;
        var max_y = 0;

        for (var i = 0; i < data.size(); i++) {
            item = data[i];
            x_next = x1 + (i + 1) * width / data.size();
            if (item != null) {
                var y = y2 - height * item / data_range_max;
                dc.setColor(Graphics.COLOR_RED, Graphics.COLOR_TRANSPARENT);
                dc.fillRectangle(x, y, x_next - x, y2 - y);
                dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
                dc.drawLine(x, y, x_next, y);
                
                if (item < min) {
                    min = item;
                    min_x = x;
                    min_y = y;
                }
                
                if (item > max) {
                    max = item;
                    max_x = x;
                    max_y = y;
                }
            }
            x = x_next;
        }
        if (max != 0 and min != max) {
            label_text(dc, x1, y1, x2, y2, min_x, min_y, "" + min, false);
            label_text(dc, x1, y1, x2, y2, max_x, max_y, "" + max, true);
        }

        tick_line(dc, x1, y1, y2, -5, true);
        tick_line(dc, x2, y1, y2, 5, true);
        tick_line(dc, y2, x1, x2 + 1, 5, false);
    }

    function label_text(dc, x1, y1, x2, y2, x, y, txt, above) {
        var dims = dc.getTextDimensions(txt, Graphics.FONT_XTINY);
        var w = dims[0];
        x -= w / 2;
        if (x < x1 + 2) {
            x = x1 + 2;
        } else if (x > x2 - w - 2) {
            x = x2 - w - 2;
        }
        if (above) {
            var h = dims[1];
            y -= h;
        }
        dc.drawText(x, y, Graphics.FONT_XTINY, txt, Graphics.TEXT_JUSTIFY_LEFT);
    }

    function tick_line(dc, c, end1, end2, tick_size, vert) {
        tick_line0(dc, c, end1, end2, vert);
        for (var n = 1; n <= 3; n++) {
            tick_line0(dc, ((4 - n) * end1 + n * end2) / 4, c, c + tick_size,
                       !vert);
        }
    }

    function tick_line0(dc, c, end1, end2, vert) {
        if (vert) {
            dc.drawLine(c, end1, c, end2);
        } else {
            dc.drawLine(end1, c, end2, c);
        }
    }

    function str(num) {
        return num == null ? "---" : "" + num;
    }

    //! Called when this View is removed from the screen. Save the
    //! state of your app here.
    function onHide() {
        var app = App.getApp();
        app.setProperty(LAST_VALUES, values);
        app.setProperty(LAST_VALUE_TIME, System.getTimer());
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

class HrWidgetApp extends App.AppBase {
    function onStart() {
    }

    function onStop() {
    }

    function getInitialView() {
        return [new HrWidget()];
    }
}
