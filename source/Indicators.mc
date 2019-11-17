using Toybox.Activity;
using Toybox.ActivityMonitor as Act;
using Toybox.Application as App;
using Toybox.Graphics;
using Toybox.Math;
using Toybox.SensorHistory as SH;
using Toybox.System as Sys;
using Toybox.Time;
using Toybox.Time.Gregorian;
using Toybox.WatchUi;

const INDICATOR_LINE_WIDTH = 2;
const BATTERY_HEAD_HEIGHT = 4;
const BATTERY_MARGIN = 1;

const BATTERY_LEVEL_SHOW = 99;
const BATTERY_LEVEL_HIGH = 75;
const BATTERY_LEVEL_MID = 50;
const BATTERY_LEVEL_LOW = 25;
const BATTERY_LEVEL_CRITICAL = 10;

const DK_BLUE = 85;
const LT_BLUE = 43775;

const HR_100_MAX = 188;
const HR_90_VHARD = 174;
const HR_80_HARD = 161;
const HR_70_MODERATE = 148;
const HR_60_LIGHT = 134;
const HR_50_VLIGHT = 121;

class Indicators extends WatchUi.Drawable {

    function initialize() {
        var dictionary = {
            :identifier => "BatteryIcon"
        };

        Drawable.initialize(dictionary);
    }

    function draw(dc) {
		drawBatteryMeter(dc, 170, 22, 12);
		
		var settings = Sys.getDeviceSettings();
		if (settings.phoneConnected) {
			drawBluetoothIcon(dc, 67, 20, 12);
		}
		if (settings.notificationCount > 0) {
			drawNotificationIcon(dc, 110, 20, 12, settings.notificationCount);
		}
		if (settings.alarmCount > 0) {
			drawAlarmIcon(dc, 81, 20, 12);
		}
		drawTime(dc, 120, 96);
		drawStepsGraph(dc, 36, 190);
		drawHeartrate(dc, 36, 190);
		drawActivity(dc, 120, 230);
		
		dc.clear();
    }
	
	function drawBatteryMeter(dc, x, y, height) {
		dc.setColor(Graphics.COLOR_WHITE , Graphics.COLOR_TRANSPARENT);
		dc.setPenWidth(INDICATOR_LINE_WIDTH);
	
		var width = height*2;
		// Body.
		// drawRoundedRectangle's x and y are top-left corner of middle of stroke.
		// Bottom-right corner of middle of stroke will be (x + width - 1, y + height - 1).
		dc.drawRoundedRectangle(
			x - (width / 2) + (INDICATOR_LINE_WIDTH / 2),
			y - (height / 2) + (INDICATOR_LINE_WIDTH / 2),
			width - INDICATOR_LINE_WIDTH + 1,
			height - INDICATOR_LINE_WIDTH + 1,
			/* BATTERY_CORNER_RADIUS */ 2);
	
		// Head.
		// fillRectangle() works as expected.
		dc.fillRectangle(
			x + (width / 2) + BATTERY_MARGIN,
			y - (BATTERY_HEAD_HEIGHT / 2),
			/* BATTERY_HEAD_WIDTH */ 2,
			BATTERY_HEAD_HEIGHT);
	
		// Fill.
		// #8: battery returned as float. Use floor() to match native. Must match getValueForFieldType().
		var batteryLevel = Math.floor(Sys.getSystemStats().battery);		
	
		// Fill colour based on battery level.
		var fillColour;
		if (batteryLevel <= BATTERY_LEVEL_CRITICAL) {
			fillColour = Graphics.COLOR_RED;
		} else if (batteryLevel <= BATTERY_LEVEL_LOW) {
			fillColour = Graphics.COLOR_ORANGE;
		} else if (batteryLevel <= BATTERY_LEVEL_MID) {
			fillColour = Graphics.COLOR_YELLOW;
		} else if (batteryLevel <= BATTERY_LEVEL_HIGH) {
			fillColour = Graphics.COLOR_GREEN;
		} else {
			fillColour = Graphics.COLOR_DK_GREEN ;
		}
	
		dc.setColor(fillColour, Graphics.COLOR_TRANSPARENT);
	
		var fillWidth = width - (2 * (INDICATOR_LINE_WIDTH + BATTERY_MARGIN));
		dc.fillRectangle(
			x - (width / 2) + INDICATOR_LINE_WIDTH + BATTERY_MARGIN,
			y - (height / 2) + INDICATOR_LINE_WIDTH + BATTERY_MARGIN,
			Math.ceil(fillWidth * (batteryLevel / 100)), 
			height - (2 * (INDICATOR_LINE_WIDTH + BATTERY_MARGIN)));
			
		if (batteryLevel <= BATTERY_LEVEL_SHOW) {
			dc.drawText(x-(width/2)-3, y-height, Graphics.FONT_XTINY, batteryLevel.toNumber().toString()+"%", Graphics.TEXT_JUSTIFY_RIGHT);
		}
    }
	
	function drawBluetoothIcon(dc, x, y, height) {
		dc.setColor(Graphics.COLOR_BLUE , Graphics.COLOR_TRANSPARENT);
		dc.setPenWidth(1);
		
		var width = height/2;
		var x1 = x - (width / 2);  // Left
		var y1 = y - (height / 2); // Top
		var x2 = x + (width / 2);  // Right
		var y2 = y + (height / 2); // Bottom
		var y3 = y - (height / 4); // Up 1/4
		var y4 = y + (height / 4); // Down 1/4
		dc.drawLine(x, y1, x, y2);
		dc.drawLine(x2, y4, x1, y3);
		dc.drawLine(x2, y3, x1, y4);
		dc.drawLine(x, y1, x2, y3);
		dc.drawLine(x, y2, x2, y4);
	}
	
	function drawNotificationIcon(dc, x, y, height, count) {
		dc.setColor(Graphics.COLOR_WHITE , Graphics.COLOR_TRANSPARENT);
		dc.setPenWidth(INDICATOR_LINE_WIDTH);
		
		var width = height;
		var radius = 3;
		var triangleH = 3;
		var x1 = x - (width / 2)-height;
		var y1 = y - ((height-triangleH) / 2);
		var h1 = height-triangleH;
		var x2 = x + (width / 2)-1-height;
		var y2 = y + ((height-triangleH) / 2);
		dc.fillRoundedRectangle(x1, y1, width, h1, radius);
		var pts = [ [x1,y1+radius], [x2-radius,y1+radius], [x2,y2+triangleH] ];
		dc.fillPolygon(pts);
		
		dc.setPenWidth(1);
		var txt = count <= 9 ? count.toString() : "+";
		dc.drawText(x, y-height+triangleH-2, Graphics.FONT_XTINY, txt, Graphics.TEXT_JUSTIFY_CENTER);
		
		dc.setColor(Graphics.COLOR_BLACK , Graphics.COLOR_TRANSPARENT);
		dc.drawText(x-12, y-height-triangleH-1, Graphics.FONT_XTINY, "..", Graphics.TEXT_JUSTIFY_CENTER);
	}
	
	function drawAlarmIcon(dc, x, y, height) {
		dc.setColor(Graphics.COLOR_RED , Graphics.COLOR_TRANSPARENT);
		dc.setPenWidth(2);
		
		var radius = (height-4)/2;
		var XandYto45 = Math.floor(Math.sqrt(2))*(radius);
		dc.drawCircle(x, y+1, radius);
		
		dc.setPenWidth(1);
		dc.drawArc(x-XandYto45, y+1-XandYto45, 2, Graphics.ARC_COUNTER_CLOCKWISE, 0, 270);
		dc.drawArc(x+XandYto45, y+1-XandYto45, 2, Graphics.ARC_COUNTER_CLOCKWISE, 270, 180);
		
		dc.drawLine(x+XandYto45, y+1+XandYto45, x+(height/2), y+1+(height/2));
		dc.drawLine(x-XandYto45, y+1+XandYto45, x-(height/2), y+1+(height/2));
		
		dc.drawLine(x, y+1, x, y+3);
		dc.drawLine(x, y+1, x-3, y+1);
	}
	
	function drawTime(dc, x, y) {
		dc.setColor(Graphics.COLOR_RED , Graphics.COLOR_TRANSPARENT);
		dc.setPenWidth(2);
		
		var today = Gregorian.info(Time.now(), Time.FORMAT_MEDIUM);
		var date = Lang.format("$1$, $2$ $3$, $4$", [today.day_of_week, today.month, today.day, today.year]);
		dc.drawText(x, y-70, Graphics.FONT_XTINY, date, Graphics.TEXT_JUSTIFY_CENTER);
		
		var colon = 8;
        var hours = today.hour;
        var mins = today.min.format("%02d");
        var time = [null,null,null,null];
        if (!System.getDeviceSettings().is24Hour) {
        	/* 9:45 - 12hr time format */
        	if (hours == 0) {
        		hours = 12;
        	}
            else if (hours > 12) {
                hours = hours - 12;
            }
            else if (hours == 12) {
            	
            }
        } else if (App.getApp().getProperty("UseMilitaryFormat")) {
            hours = hours.format("%02d");
            colon = 1;
        }
        
        var hh = hours.toString();
        time[0] = hh.length() == 1 ? null : hh.substring(0,1).toNumber();
        time[1] = hh.length() == 1 ? hh.toNumber() : hh.substring(1,2).toNumber();
        var mm = mins.toString();
        time[2] = mm.substring(0,1).toNumber();
        time[3] = mm.substring(1,2).toNumber();
        
		dc.setColor(Graphics.COLOR_WHITE , Graphics.COLOR_TRANSPARENT);
        if (colon != 1) {
			dc.setPenWidth(1);
        	dc.fillCircle(x, y+20, 4);
        	dc.fillCircle(x, y-20, 4);
			dc.setPenWidth(2);
        }
        
		var fillHorizontal = [
			[1,0,1],[0,0,0],[1,1,1],[1,1,1],[0,1,0],
			[1,1,1],[1,1,1],[1,0,0],[1,1,1],[1,1,1]];
		
		var horizontalBars = [
			[[-75-colon, -40], [-75-colon, 0], [-75-colon, 40]],
			[[-23-colon, -40], [-23-colon, 0], [-23-colon, 40]],
			[[23+colon, -40], [23+colon, 0], [23+colon, 40]],
			[[75+colon, -40], [75+colon, 0], [75+colon, 40]]];
			
		for( var m=0; m<4; m++ ) {
			for( var n=0; n<3; n++ ) {
				if (time[m] != null && fillHorizontal[time[m]][n]==1) {
					dc.setColor(Graphics.COLOR_WHITE , Graphics.COLOR_TRANSPARENT);
				} else { 
					dc.setColor(DK_BLUE , Graphics.COLOR_TRANSPARENT);
				}
					var j = x+horizontalBars[m][n][0];
					var k = y+horizontalBars[m][n][1];
					var pts = [ 
						[j-18,k], 
						[j-13,k-5], 
						[j+13,k-5], 
						[j+18,k], 
						[j+13,k+5], 
						[j-13,k+5], 
						[j-18,k] ];
					dc.fillPolygon(pts);
			}
		}
		
		
		var fillVertical = [
			[1,1,1,1],[0,0,1,1],[0,1,1,0],[0,0,1,1],[1,0,1,1],
			[1,0,0,1],[1,1,0,1],[0,0,1,1],[1,1,1,1],[1,0,1,1]];
			
		var verticalBars = [
			[[-94-colon, -20], [-94-colon, 20], [-56-colon, -20], [-56-colon, 20]],
			[[-42-colon, -20], [-42-colon, 20], [-4-colon, -20], [-4-colon, 20]],
			[[4+colon, -20], [4+colon, 20], [42+colon, -20], [42+colon, 20]],
			[[56+colon, -20], [56+colon, 20], [94+colon, -20], [94+colon, 20]]];
			
		for( var m=0; m<4; m++ ) {
			for( var n=0; n<4; n++ ) {
				if (time[m] != null && fillVertical[time[m]][n]==1) {
					dc.setColor(Graphics.COLOR_WHITE , Graphics.COLOR_TRANSPARENT);
				} else { 
					dc.setColor(DK_BLUE , Graphics.COLOR_TRANSPARENT);
				}
					var j = x+verticalBars[m][n][0];
					var k = y+verticalBars[m][n][1];
					var pts = [ 
						[j,k-18], 
						[j-5,k-13], 
						[j-5,k+13], 
						[j,k+18], 
						[j+5,k+13], 
						[j+5,k-13], 
						[j,k-18] ];
					dc.fillPolygon(pts);
				
			}
		}
	}
	
	function drawStepsGraph(dc, x, y) {
		dc.setColor(Graphics.COLOR_DK_GREEN, Graphics.COLOR_TRANSPARENT);
		dc.setPenWidth(1);
		
		var actH = Act.getHistory();
		var stepHmax = 0;
		if (actH != null && actH.size() > 0) 
		{
			var stepH = [0,0,0,0,0,0,0];
			for (var i=0; i < actH.size() && i < stepH.size(); i++) {
				if (actH[i].steps != null) {
					stepH[i] = actH[i].steps;
					if (stepH[i] > stepHmax) {
						stepHmax = stepH[i];
					}
				}
			}
			/*
			stepHmax = 7100;
			var stepH = [3000,6500,7100,2500,5500,4800,5700];
			*/
			
			stepHmax = Math.ceil(stepHmax/1000.0).toNumber();
			var mod2 = stepHmax % 2 == 0;
			stepHmax = ((mod2 ? stepHmax : stepHmax + 1) * 1000.0).toNumber();
			var graphScale = (40.0/stepHmax);
			
			var pts = [ 
				[x+0,y],
				[x+0,y-((stepH[6]*graphScale).toNumber())],
				[x+28,y-((stepH[5]*graphScale).toNumber())], 
				[x+56,y-((stepH[4]*graphScale).toNumber())], 
				[x+84,y-((stepH[3]*graphScale).toNumber())], 
				[x+112,y-((stepH[2]*graphScale).toNumber())], 
				[x+140,y-((stepH[1]*graphScale).toNumber())], 
				[x+168,y-((stepH[0]*graphScale).toNumber())], 
				[x+168,y]  ];
			dc.fillPolygon(pts);
			
			dc.setColor(Graphics.COLOR_YELLOW, Graphics.COLOR_TRANSPARENT);
			dc.setPenWidth(2);
			dc.drawCircle(x+0,y-((stepH[6]*graphScale).toNumber()), 3);
			dc.drawCircle(x+28,y-((stepH[5]*graphScale).toNumber()), 3); 
			dc.drawCircle(x+56,y-((stepH[4]*graphScale).toNumber()), 3); 
			dc.drawCircle(x+84,y-((stepH[3]*graphScale).toNumber()), 3); 
			dc.drawCircle(x+112,y-((stepH[2]*graphScale).toNumber()), 3); 
			dc.drawCircle(x+140,y-((stepH[1]*graphScale).toNumber()), 3); 
			dc.drawCircle(x+168,y-((stepH[0]*graphScale).toNumber()), 3); 
	
			dc.setColor(Graphics.COLOR_RED, Graphics.COLOR_TRANSPARENT);
			dc.drawText(x+168, y-50, Graphics.FONT_XTINY, (stepHmax).toString(), Graphics.TEXT_JUSTIFY_RIGHT);
		}
	}
	
	function drawHeartrate(dc, x, y) {
		dc.setColor(Graphics.COLOR_DK_GRAY, Graphics.COLOR_TRANSPARENT);
		dc.setPenWidth(1);
		
		dc.drawLine(x+0, y, x+168, y);
		dc.drawLine(x+0, y-10, x+168, y-10);
		dc.drawLine(x+0, y-20, x+168, y-20);
		dc.drawLine(x+0, y-30, x+168, y-30);
		dc.drawLine(x+0, y-40, x+168, y-40);
		dc.drawLine(x+42, y, x+42, y-40);
		dc.drawLine(x+84, y, x+84, y-40);
		dc.drawLine(x+126, y, x+126, y-40);
		
		var hrText = "";
		var heartRateHistory = null;
		var hrI = null;
		var hr = null;
		var hrPrev = null;
		var hrT = null;
		var hrTPrev = null;
		var currentHeartRate = Activity.getActivityInfo().currentHeartRate;
		if(currentHeartRate != null){
		    hrText = currentHeartRate;
		}else{
		    heartRateHistory = SH.getHeartRateHistory({ :period => 1, :order => SensorHistory.ORDER_NEWEST_FIRST });
		    hrI = heartRateHistory.next();
		    if (hrI != null) {
			    hr = hrI.data;
			
			    if(hr != Act.INVALID_HR_SAMPLE && hr != null){
			        hrText = hr;
			    }
		    }
		}
		
		var heartOffsetX = 219;
		var heartOffsetY = -17;
		dc.setColor(Graphics.COLOR_YELLOW, Graphics.COLOR_TRANSPARENT);
		dc.drawText(heartOffsetX+13, y+heartOffsetY-30, Graphics.FONT_XTINY, hrText == "" ? "--" : hrText, Graphics.TEXT_JUSTIFY_RIGHT);
		var ptsHeart = [ 
			[heartOffsetX+5,y+heartOffsetY-6], 
			[heartOffsetX+7,y+heartOffsetY-8], 
			[heartOffsetX+9,y+heartOffsetY-8], 
			[heartOffsetX+10,y+heartOffsetY-7], 
			[heartOffsetX+10,y+heartOffsetY-5], 
			[heartOffsetX+5,y+heartOffsetY-0], 
			[heartOffsetX+0,y+heartOffsetY-5], 
			[heartOffsetX+0,y+heartOffsetY-7], 
			[heartOffsetX+1,y+heartOffsetY-8], 
			[heartOffsetX+3,y+heartOffsetY-8],
			[heartOffsetX+5,y+heartOffsetY-6] ];
		dc.fillPolygon(ptsHeart);
		
		var nowT = new Time.Moment(Time.now().value());
		var hrDuration = new Time.Duration(3600);
		heartRateHistory = SH.getHeartRateHistory({ :order => SensorHistory.ORDER_NEWEST_FIRST });
		hrI = heartRateHistory.next();
		if (hrI != null) {
		   	hr = hrI.data;
		   	hrT = nowT.compare(hrI.when);
		}
		
		var minHR = heartRateHistory.getMin();
		minHR = minHR == 255 ? "--" : minHR;
		var maxHR = heartRateHistory.getMax();
		maxHR = maxHR == 255 ? "--" : maxHR;
		dc.drawText(x-4, y+heartOffsetY-30, Graphics.FONT_XTINY, maxHR, Graphics.TEXT_JUSTIFY_RIGHT);
		dc.drawText(x-4, y+heartOffsetY-15, Graphics.FONT_XTINY, minHR, Graphics.TEXT_JUSTIFY_RIGHT);
		
		dc.setPenWidth(2);
		while (hrI != null) {
			if(hr != Act.INVALID_HR_SAMPLE){
				hrPrev = hr;
				hrTPrev = hrT;
			}
			
			hrI = heartRateHistory.next();
		    if (hrI != null && hrI.data != null) {
		    	hr = hrI.data;
		   		hrT = nowT.compare(hrI.when);
		   		
				if(hr != Act.INVALID_HR_SAMPLE && hrTPrev != null && hrPrev != null && hrT != null && hr != null) {
					var hrColor = Graphics.COLOR_WHITE;
					if (hr > HR_100_MAX) {
						hrColor = Graphics.COLOR_RED;
					} else if (hr > HR_90_VHARD) {
						hrColor = Graphics.COLOR_PINK;
					} else if (hr > HR_80_HARD) {
						hrColor = Graphics.COLOR_ORANGE;
					} else if (hr > HR_70_MODERATE) {
						hrColor = Graphics.COLOR_GREEN;
					} else if (hr > HR_60_LIGHT) {
						hrColor = Graphics.COLOR_BLUE;
					} else if (hr > HR_50_VLIGHT) {
						hrColor = Graphics.COLOR_LT_GRAY;
					}
					dc.setColor(hrColor, Graphics.COLOR_TRANSPARENT);
					if (hrT.toDouble()<3650.0 && hrTPrev.toDouble()<3600.0) {
						dc.drawLine(
							x+168-((hrTPrev.toDouble()/3600.0)*170).toNumber(), y-((hrPrev-40)/4), 
							x+168-((hrT.toDouble()/3600.0)*170).toNumber(), y-((hr-40)/4));
					} else {
						hrI = null;
					}
				}
		    }
		    //else if (hrI == null && hrTPrev != null && hrPrev != null) {
			//	dc.drawLine(
			//		x+147-((hrTPrev/14400)*147), y-((hrPrev-40)/4), 
			//		x+0, y-((hrPrev-40)/4));
			//}
		}
		
		dc.setColor(Graphics.COLOR_RED, Graphics.COLOR_TRANSPARENT);
		//dc.drawText(x+0, y-10, Graphics.FONT_XTINY, "40", Graphics.TEXT_JUSTIFY_LEFT);
		//dc.drawText(x+0, y-20, Graphics.FONT_XTINY, "80", Graphics.TEXT_JUSTIFY_LEFT);
		//dc.drawText(x+0, y-30, Graphics.FONT_XTINY, "120", Graphics.TEXT_JUSTIFY_LEFT);
		//dc.drawText(x+0, y-40, Graphics.FONT_XTINY, "160", Graphics.TEXT_JUSTIFY_LEFT);
		//dc.drawText(x+0, y-50, Graphics.FONT_XTINY, "200", Graphics.TEXT_JUSTIFY_LEFT);
	}
	
	function drawActivity(dc, x, y) {
		dc.setColor(Graphics.COLOR_YELLOW, Graphics.COLOR_TRANSPARENT);
		dc.setPenWidth(1);

		var info = Act.getInfo();
		var cals = info.calories;
		cals = cals == null ? 0 : cals;
		var stairs = info.floorsClimbed;
		stairs = stairs == null ? 0 : stairs;
		var stairG = info.floorsClimbedGoal;
		stairG = stairG == null ? 10 : stairG;
		var miles = info.distance;
		miles = miles == null ? 0.1 : miles/160934.4;
		var stepC = info.steps;
		stepC = stepC == null ? 3000 : (stepC < 1 ? 1 : stepC);
		var stepG = info.stepGoal;
		stepG = stepG == null ? 6000 : stepG;
		
		dc.drawText(x+43, y-15, Graphics.FONT_XTINY, cals.toString() + "C", Graphics.TEXT_JUSTIFY_RIGHT);
		
		dc.setPenWidth(2);
		dc.drawLine(x-39, y+1, x-39, y-2);
		dc.drawLine(x-39, y-2, x-42, y-2);
		dc.drawLine(x-42, y-2, x-42, y-5);
		dc.drawLine(x-42, y-5, x-45, y-5);
		dc.drawLine(x-45, y-5, x-45, y-8);
		dc.drawLine(x-45, y-8, x-48, y-8);
		dc.drawText(x-36, y-15, Graphics.FONT_XTINY, stairs.toString() /*+ "/" + stairG.toString()*/, Graphics.TEXT_JUSTIFY_LEFT);
		
		dc.drawText(x+74, y-33, Graphics.FONT_XTINY, miles.format("%.2f") + "mi", Graphics.TEXT_JUSTIFY_RIGHT);
		
		dc.setColor(Graphics.COLOR_DK_GREEN, Graphics.COLOR_TRANSPARENT);
		dc.setPenWidth(1);
		dc.fillEllipse(x-73, y-24, 2, 3);
		dc.fillEllipse(x-73, y-17, 1, 2);
		dc.drawText(x-68, y-33, Graphics.FONT_XTINY, stepC.toString() + "/" + stepG.toString(), Graphics.TEXT_JUSTIFY_LEFT);
		
		dc.setPenWidth(5);
		var stepGraphWidth = 160;
		var stepGraphValue = ((stepC.toDouble()/stepG.toDouble())*stepGraphWidth).toNumber();
		if (stepGraphValue > stepGraphWidth) {
			stepGraphValue = x+(stepGraphWidth/2);
		} else {
			stepGraphValue = x-(stepGraphWidth/2)+stepGraphValue;
		}
		dc.drawLine(x-(stepGraphWidth/2), y-35, stepGraphValue, y-35);
		dc.setColor(Graphics.COLOR_RED, Graphics.COLOR_TRANSPARENT);
		dc.drawLine(stepGraphValue, y-35, x+(stepGraphWidth/2), y-35);
	}
}
