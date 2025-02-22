/* -*- Mode: Vala; indent-tabs-mode: nil; c-basic-offset: 4; tab-width: 4 -*- */
/* vim: set tabstop=4 softtabstop=4 shiftwidth=4 expandtab : */
/*
 * CircularProgressBar.vala
 *
 * Custom Gtk.Widget to provide a circular progress bar.
 * It extends/subclasses Gtk.Bin instead of Gtk.DrawingArea.
 *
 * Colors, font and some parameters could move onto CSS but for simplicity will be kept inline.
 * Minimum size is hardcoded on MIN_D. Minimum line width is 1.
 *
 * José Miguel Fonte
 */

using Gtk;
using Cairo;

public class Widgets.ProjectProgress : Gtk.Bin {
    private const int MIN_D = 18;
    private int _line_width;
    private double _percentage;
    private string _center_fill_color;
    private string _radius_fill_color;
    private string _progress_fill_color;

    [Description (nick = "Center Fill", blurb = "Center Fill toggle")]
    public bool center_filled {set; get; default = false;}

    [Description (nick = "Radius Fill", blurb = "Radius Fill toggle")]
    public bool radius_filled {set; get; default = false;}

    [Description (nick = "Font", blurb = "Font description without size, just the font name")]
    public string font {set; get; default = "URW Gothic";}

    [Description (nick = "Line Cap", blurb = "Line Cap for stroke as in Cairo.LineCap")]
    public Cairo.LineCap line_cap {set; get; default = Cairo.LineCap.BUTT;}

    [Description (nick = "Inside circle fill color", blurb = "Center pad fill color (Check Gdk.RGBA parse method)")]
    public string center_fill_color {
        get {
            return _center_fill_color;
        }
        set {
            var color = Gdk.RGBA ();
            if (color.parse (value)) {
                _center_fill_color = value;
            }
        }
    }

    [Description (nick = "Circular radius fill color", blurb = "The circular pad fill color (Check GdkRGBA parse method)")] // vala-lint=line-length
    public string radius_fill_color {
        get {
            return _radius_fill_color;
        }
        set {
            var color = Gdk.RGBA ();
            if (color.parse (value)) {
                _radius_fill_color = value;
            }
        }
    }

    [Description (nick = "Progress fill color", blurb = "Progress line color (Check GdkRGBA parse method)")]
    public string progress_fill_color {
        get {
            return _progress_fill_color;
        }
        set {
            var color = Gdk.RGBA ();
            if (color.parse (value)) {
                _progress_fill_color = value;
            }
        }
    }

    [Description (nick = "Circle width", blurb = "The circle radius line width")]
    public int line_width {
        get {
            return _line_width;
        }
        set {
            if (value < 1) {
                _line_width = 1;
            } else {
                _line_width = value;
            }
        }
    }

    [Description (nick = "Percentage/Value", blurb = "The percentage value [0.0 ... 1.0]")]
    public double percentage {
        get {
            return _percentage;
        }
        set {
            if (value > 1.0) {
                _percentage = 1.0;
            } else if (value < 0.0) {
                _percentage = 0.0;
            } else {
                _percentage = value;
            }
        }
    }

    construct {
        _line_width = 1;
        _percentage = 0;
        _center_fill_color = "#adadad";
        _radius_fill_color = "#d3d3d3";
        _progress_fill_color = "#4a90d9";
    }

    public ProjectProgress () {
        notify.connect (() => {
            queue_draw ();
        });
    }

    private int calculate_radius () {
        return (int) double.min (get_allocated_width () / 2, get_allocated_height () / 2) - 1;
    }

    private int calculate_diameter () {
        return 2 * calculate_radius ();
    }

    public override Gtk.SizeRequestMode get_request_mode () {
        return Gtk.SizeRequestMode.CONSTANT_SIZE;
    }

    public override void get_preferred_width (out int min_w, out int natural_w) {
        var d = calculate_diameter ();
        min_w = MIN_D;
        if (d > MIN_D) {
            natural_w = d;
        } else {
            natural_w = MIN_D;
        }
    }

    public override void get_preferred_height (out int min_h, out int natural_h) {
        var d = calculate_diameter ();
        min_h = MIN_D;
        if (d > MIN_D) {
            natural_h = d;
        } else {
            natural_h = MIN_D;
        }
    }

    public override void size_allocate (Gtk.Allocation allocation) {
        base.size_allocate (allocation);
    }

    public override bool draw (Cairo.Context cr) {
        int delta;
        Gdk.RGBA color;

        cr.save ();

        color = Gdk.RGBA ();

        var center_x = get_allocated_width () / 2;
        var center_y = get_allocated_height () / 2;
        var radius = calculate_radius ();
        var d = radius - line_width;
        delta = radius - line_width / 2;
        if (d < 0) {
            delta = 0;
            line_width = radius;
        }

        color = Gdk.RGBA ();
        cr.set_line_cap (line_cap);
        cr.set_line_width (line_width);

        // Center Fill
        if (center_filled == true) {
            cr.arc (center_x, center_y, delta, 0, 2 * Math.PI);
            color.parse (center_fill_color);
            Gdk.cairo_set_source_rgba (cr, color);
            cr.fill ();
        }

        // Radius Fill
        if (radius_filled == true) {
            cr.arc (center_x, center_y, delta, 0, 2 * Math.PI);
            color.parse (radius_fill_color);
            Gdk.cairo_set_source_rgba (cr, color);
            cr.stroke ();
        }

        // Progress Fill
        var progress = ((double) percentage);
        if (progress > 0) {
            cr.arc (center_x,
                    center_y,
                    delta,
                    1.5 * Math.PI,
                    (1.5 + progress * 2 ) * Math.PI);
            color.parse (progress_fill_color);
            Gdk.cairo_set_source_rgba (cr, color);
            cr.stroke ();
        }

        cr.restore ();

        return base.draw (cr);
    }
}
