using Toybox.System;
using Toybox.Lang;
using Toybox.Application;

class TimeHelper {
    function getTimeString() {
        var timeFormat = "$1$:$2$";
        var clockTime = System.getClockTime();
        var hours = clockTime.hour;
        var mins = clockTime.min.format("%02d");
        if (!System.getDeviceSettings().is24Hour) {
        	/* 9:45 - 12hr time format */
        	if (hours == 0) {
        		hours = 12;
        	}
            else if (hours > 12) {
                hours = hours - 12;
            }
        } else if (Application.getApp().getProperty("UseMilitaryFormat")) {
        	/* 0800 - military time format */
            timeFormat = "$1$$2$";
            hours = hours.format("%02d");
        } else {
        	/* 17:30 - 24hr time format */
        }
        return Lang.format(timeFormat, [hours, mins]);
    }
}