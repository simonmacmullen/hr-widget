// -*- mode: Javascript;-*-

class Chart {
    var model;

    function initialize(a_model) {
        model = a_model;
    }

    function draw(dc, x1, y1, x2, y2,
                  line_color, block_color, min_max_color,
                  draw_axes) {
        var data = model.get_values();

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

        var x_old = null;
        var y_old = null;
        for (var x = x1; x <= x2; x++) {
            item = data[x_item(x, x1, width, data.size())];
            if (item != null) {
                var y = item_y(item, y2, height, range_min, range_max);
                dc.setColor(block_color, Graphics.COLOR_TRANSPARENT);
                dc.drawLine(x, y, x, y2);
                if (x_old != null) {
                    dc.setColor(line_color, Graphics.COLOR_TRANSPARENT);
                    dc.drawLine(x_old, y_old, x, y);
                    // TODO is the below line needed due to a CIQ bug
                    // or some subtlety I don't understand?
                    dc.drawPoint(x, y);
                }
                x_old = x;
                y_old = y;
            }
            else {
                x_old = null;
                y_old = null;
            }
        }

        if (max != 0 and min != max) {
            dc.setColor(min_max_color, Graphics.COLOR_TRANSPARENT);
            label_text(dc, item_x(min_i, x1, width, data.size()),
                       item_y(min, y2, height, range_min, range_max),
                       x1, y1, x2, y2, "" + min, false);
            label_text(dc, item_x(max_i, x1, width, data.size()),
                       item_y(max, y2, height, range_min, range_max),
                       x1, y1, x2, y2, "" + max, true);
        }

        if (draw_axes) {
            dc.setColor(line_color, Graphics.COLOR_TRANSPARENT);
            tick_line(dc, x1, y1, y2, -5, true);
            tick_line(dc, x2, y1, y2, 5, true);
            tick_line(dc, y2, x1, x2 + 1, 5, false);
        }
    }

    function item_x(i, orig_x, width, size) {
        return orig_x + i * width / (size - 1);
    }

    function x_item(x, orig_x, width, size) {
        return (x - orig_x) * (size - 1) / width;
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
}
