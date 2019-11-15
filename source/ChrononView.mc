using Toybox.Activity;
using Toybox.ActivityMonitor as Act;
using Toybox.WatchUi;
using Toybox.Graphics;
using Toybox.System;
using Toybox.Lang;
using Toybox.Application;

class ChrononView extends WatchUi.WatchFace {

    function initialize() {
        WatchFace.initialize();
    }

    // Load your resources here
    function onLayout(dc) {
        setLayout(Rez.Layouts.WatchFace(dc));
    }

    // Called when this View is brought to the foreground. Restore
    // the state of this View and prepare it to be shown. This includes
    // loading resources into memory.
    function onShow() {
    }

    // Update the view
    function onUpdate(dc) {

        // Update the Time
        //var timeString = TimeHelper.getTimeString();
        //var lblTime = View.findDrawableById("TimeLabel");
        //lblTime.setColor(Application.getApp().getProperty("ForegroundColor"));
        //lblTime.setText(timeString);
		
        // Call the parent onUpdate function to redraw the layout
        View.onUpdate(dc);
    }
    
	function onPartialUpdate(dc) {
		/*dc.setClip(100, 105, 32, 19);
		
		var hrText = "";
		var currentHeartRate = Activity.getActivityInfo().currentHeartRate;
		if(currentHeartRate){
		    hrText = currentHeartRate;
		}else{
		    var heartRateHistory = Act.getHeartRateHistory(1, true);
		    var hrI = heartRateHistory.next();
		    if (hrI != null) {
			    var hr = hrI.heartRate;
			
			    if(hr != Act.INVALID_HR_SAMPLE && hr != null && hr > 0){
			        hrText = hr;
			    }
		    }
		}
		
		dc.drawText(132, 105, Graphics.FONT_TINY, hrText == "" ? "--" : hrText, Graphics.TEXT_JUSTIFY_RIGHT);*/
	}

    // Called when this View is removed from the screen. Save the
    // state of this View here. This includes freeing resources from
    // memory.
    function onHide() {
    }

    // The user has just looked at their watch. Timers and animations may be started here.
    function onExitSleep() {
    }

    // Terminate any active timers and prepare for slow updates.
    function onEnterSleep() {
    }

}
