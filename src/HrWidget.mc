// -*- mode: Javascript;-*-

using Toybox.Application as App;
using Toybox.Graphics;
using Toybox.Sensor as Sensor;
using Toybox.WatchUi as Ui;

class HrWidget extends Ui.View {
    var current = null;
    var max = null;
    var min = null;

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
        text(dc, 0.5, 0.05, Graphics.FONT_MEDIUM, "HR");
        text(dc, 0.5, 0.35, Graphics.FONT_NUMBER_THAI_HOT, str(current));
        text(dc, 0.3, 0.7, Graphics.FONT_NUMBER_MEDIUM, str(min));
        text(dc, 0.7, 0.7, Graphics.FONT_NUMBER_MEDIUM, str(max));

        dc.setColor(Graphics.COLOR_LT_GRAY, Graphics.COLOR_TRANSPARENT);
        text(dc, 0.3, 0.85, Graphics.FONT_TINY, "Min");
        text(dc, 0.7, 0.85, Graphics.FONT_TINY, "Max");
    }

    function text(dc, x, y, font, s) {
        dc.drawText(dc.getWidth() * x, dc.getHeight() * y,
                    font, s,
                    Graphics.TEXT_JUSTIFY_CENTER|Graphics.TEXT_JUSTIFY_VCENTER);
    }

    function str(num) {
        return num == null ? "---" : "" + num;
    }

    //! Called when this View is removed from the screen. Save the
    //! state of your app here.
    function onHide() {
    }

    function onSensor(sensorInfo) {
        current = sensorInfo.heartRate;
        if (current != null) {
            if (min == null || min > current) {
                min = current;
            }
            if (max == null || max < current) {
                max = current;
            }
        }
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
