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

var widget;

class HrWidget extends Ui.View {
    var current = null;
    var values;

    function initialize(a_values) {
        values = a_values;
    }

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

    //! Load your resources here
    function onLayout(dc) {
    }

    //! Restore the state of the app and prepare the view to be shown
    function onShow() {
        Sensor.setEnabledSensors( [Sensor.SENSOR_HEARTRATE] );
        Sensor.enableSensorEvents( method(:onSensor) );
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
            chart(dc, 23, 75, 195, 172, values);
            text(dc, 109, 192, Graphics.FONT_XTINY, minutes_label);
        } else if (dc.getWidth() == 205 && dc.getHeight() == 148) {
            // Vivoactive, FR920xt, Epix
            text(dc, 70, 25, Graphics.FONT_MEDIUM, "HR");
            text(dc, 120, 25, Graphics.FONT_NUMBER_MEDIUM, str(current));
            chart(dc, 10, 45, 195, 120, values);
            text(dc, 102, 135, Graphics.FONT_XTINY, minutes_label);
        }
    }

    function text(dc, x, y, font, s) {
        dc.drawText(x, y, font, s,
                    Graphics.TEXT_JUSTIFY_CENTER|Graphics.TEXT_JUSTIFY_VCENTER);
    }

    function chart(dc, x1, y1, x2, y2, data) {
        var range_border = 5;
        var range_min_size = 30;

        var width = x2 - x1;
        var height = y2 - y1;
        var x = x1;
        var x_next;
        var item;

        var min = 999999;
        var max = 0;
        var min_i = 0;
        var max_i = 0;

        for (var i = 0; i < data.size(); i++) {
            item = data[i];
            if (item != null) {
                if (item < min) {
                    min_i = i;
                    min = item;
                }
                
                if (item > max) {
                    max_i = i;
                    max = item;
                }
            }
        }

        var range_min = min - range_border;
        var range_max = max + range_border;
        if (range_max - range_min < range_min_size) {
            range_max = range_min + range_min_size;
        }

        for (var i = 0; i < data.size(); i++) {
            item = data[i];
            x_next = item_x(i + 1, x1, width, data.size());
            if (item != null) {
                var y = item_y(item, y2, height, range_min, range_max);
                dc.setColor(Graphics.COLOR_RED, Graphics.COLOR_TRANSPARENT);
                dc.fillRectangle(x, y, x_next - x, y2 - y);
                dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
                dc.drawLine(x, y, x_next, y);
            }
            x = x_next;
        }

        if (max != 0 and min != max) {
            label_text(dc, item_x(min_i, x1, width, data.size()),
                       item_y(min, y2, height, range_min, range_max),
                       x1, y1, x2, y2, "" + min, false);
            label_text(dc, item_x(max_i, x1, width, data.size()),
                       item_y(max, y2, height, range_min, range_max),
                       x1, y1, x2, y2, "" + max, true);
        }

        tick_line(dc, x1, y1, y2, -5, true);
        tick_line(dc, x2, y1, y2, 5, true);
        tick_line(dc, y2, x1, x2 + 1, 5, false);
    }

    function item_x(i, orig_x, width, size) {
        return orig_x + i * width / size;
    }

    function item_y(item, orig_y, height, min, max) {
        return orig_y - height * (item - min) / (max - min);
    }

    function label_text(dc, x, y, x1, y1, x2, y2, txt, above) {
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

class HrWidgetApp extends App.AppBase {
    function onStart() {
    }

    function onStop() {
    }

    function getInitialView() {
        var app = App.getApp();
        var old_values = app.getProperty(LAST_VALUES);
        var old_time = app.getProperty(LAST_VALUE_TIME);
        var values;
        if (old_values != null && old_time != null) {
            values = new[old_values.size()];
            var delta = (System.getTimer() - old_time) / 1000;
            if (delta > 0) { // Ignore old data from before reboot
                for (var i = 0; i < values.size() - delta; i++) {
                    values[i] = old_values[i + delta];
                }
            }
        }
        else {
            values = new [120];
        }

        widget = new HrWidget(values);
        return [widget, new HrWidgetDelegate()];
    }
}
