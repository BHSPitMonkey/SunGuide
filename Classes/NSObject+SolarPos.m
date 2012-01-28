//
//  NSObject+SolarPos.m
//  SunGuide
//
//  Created by Stephen Eisenhauer on 6/1/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//
//	Objective-C solar position functions based on solar_pos.py- (
//
//	Solar_Position
//
//	The azimuth and altitude of the Sun are calculated using formulae first proposed by Spencer (Spencer, 1965),
//	then refined by Szokolay (Szokolay, 1996). Values for solar declination and the equation of time
//	are determined using formulae proposed by Carruthers, et al [1990]

//	The math behind this calculation was taken from:
//	http://squ1.org/wiki/Solar_Position_Calculator

//import "NSObject+SolarPos.h"

double radians (double degrees) {
	return degrees * M_PI/180;	
}

double degrees (double radians) {
	return radians * 180/M_PI;
}

@implementation NSObject (SolarPos)

//// Solar_Position
////
//// The azimuth and altitude of the Sun are calculated using formulae first proposed by Spencer (Spencer, 1965),
//// then refined by Szokolay (Szokolay, 1996). Values for solar declination and the equation of time
//// are determined using formulae proposed by Carruthers, et al [1990]

//// The math behind this calculation was taken from:
//// http://squ1.org/wiki/Solar_Position_Calculator


//// Enter data in this way:
//// Solar_Pos (Lat, Long, TimeZone, Month, Day, Hour)
//// It will return (Altitude, Azimuth)
//// Only Altitude and Azimuth are needed to trace the sun position, for that you will
//// need the Sun_Trace.py script


        
////  Calculates Julian Day
- (NSInteger) julianDayFromMonth:(NSInteger)Month Day:(NSInteger)Day {

	NSInteger j_day = 0;

	if (Month==1)
		j_day = 0 + Day;
	else if (Month==2)
		j_day =	31 + Day;
	else if (Month==3)
		j_day =	59 + Day;
	else if (Month==4)
		j_day = 90 + Day;
	else if (Month==5) 
		j_day = 120 + Day;
	else if (Month==6)
		j_day = 151 + Day;
	else if (Month==7)
		j_day = 181 + Day;
	else if (Month==8)
		j_day = 212 + Day;
	else if (Month==9)
		j_day = 243 + Day;
	else if (Month==10)
		j_day = 273 + Day;
	else if (Month==11)
		j_day = 304 + Day;
	else if (Month==12)
		j_day = 334 + Day;

	return j_day;
}

////  Solar declination as per Carruthers et al:  
- (double) declinationForJulianDay:(NSInteger)julianDay {

	double t = 2 * M_PI * ((julianDay - 1) / 365.0);
	double Dec = 0.322003 - 22.971 * cos(t) - 0.357898 * cos(2*t) - 0.14398 * cos(3*t) + 3.94638 * sin(t) + 0.019334 * sin(2*t) + 0.05928 * sin(3*t);

	// Convert degrees to radians.
	if (Dec > 89.9)
		Dec = 89.9;
	if (Dec < -89.9)
		Dec = -89.9;		
	Dec = radians(Dec);
	
	return Dec;
}
		
////  Calculate the equation of time as per Carruthers et al.
- (double) equationOfTimeForJulianDay:(NSInteger)julianDay {
		
	double t = (279.134 + 0.985647 * julianDay) * (M_PI/180.0);
	
	double fEquation = 5.0323 - 100.976 * sin(t) + 595.275 * sin(2*t) + 3.6858 * sin(3*t) - 12.47 * sin(4*t) - 430.847 * cos(t) + 12.5024 * cos(2*t) + 18.25 * cos(3*t);
	
	//Convert seconds to hours.
	fEquation = fEquation / 3600.00;
				
	return fEquation;
}
		
////  Calculate Local Time
- (double) localTimeForHour:(NSInteger)Hour Minute:(NSInteger)Minute {

	double fLocal = Hour + (Minute/60.0);

	return fLocal;
}

//// 	Calculate solar time.
//	def Solar_Time(fLongitude, fLatitude, fTimeZone, fLocalTime, fEquation):
- (NSDictionary *) solarTimeForLocation:(CLLocationCoordinate2D)location timeZone:(NSTimeZone *)nsTimeZone localTime:(double)fLocalTime equationOfTime:(double)fEquation declination:(double)fDeclination {

	double fLatitude	= location.latitude;
	double fLongitude	= location.longitude;
	
	// TODO:
	// Get a useful timeZone value using the given NSTimeZone. (We cannot do arithmetic with a NSTimeZone by itself!)
	double fTimeZone = -6; // bogus
	
	// Calculate difference (in minutes) from reference longitude.
	double fDifference = degrees(fLongitude - fTimeZone) * 4 / 60.0;

	// Convert solar noon to local noon.
	double local_noon = 12.0 - fEquation - fDifference;

	// Calculate angle normal to meridian plane.
	if (fLatitude > (0.99 * (M_PI/2.0)))
		fLatitude = (0.99 * (M_PI/2.0));
	if (fLatitude < -(0.99 * (M_PI/2.0)))
		fLatitude = -(0.99 * (M_PI/2.0));

	double test = -tan(fLatitude) * tan(fDeclination);
	double t;
	
	if (test < -1)
		t = acos(-1.0) / (15 * (M_PI / 180.0));
	else if (test > 1)
		t = acos(1.0) / (15 * (M_PI / 180.0));
	else
		t = acos(-tan(fLatitude) * tan(fDeclination)) / (15 * (M_PI / 180.0));

	// Sunrise and sunset.
	double fSunrise = local_noon - t;
	double fSunset  = local_noon + t;

	// Check validity of local time.
	if (fLocalTime > fSunset)
		fLocalTime = fSunset;
	if (fLocalTime < fSunrise)
		fLocalTime = fSunrise;
	if (fLocalTime > 24.0)
		fLocalTime = 24.0;
	if (fLocalTime < 0.0)
		fLocalTime = 0.0;

	// Calculate solar time.
	double fSolarTime = fLocalTime + fEquation + fDifference;
		
	// return (fSolarTime, fSunrise, fSunset);
	NSNumber * SolarTime	= [NSNumber numberWithDouble:fSolarTime];
	NSNumber * Sunrise		= [NSNumber numberWithDouble:fSunrise];
	NSNumber * Sunset		= [NSNumber numberWithDouble:fSunset];
	NSDictionary * dict = [NSDictionary dictionaryWithObjectsAndKeys:SolarTime, @"Solar Time", Sunrise, @"Sunrise Time", Sunset, @"Sunset Time", nil];
	return dict;
}
    
////  Calculate Sun Hour Angle
- (double) sunHourAngleForSolarTime:(double)fSolarTime {

	double fHourAngle = 15 * (fSolarTime - 12) * (M_PI/180.0);
	return fHourAngle;
}
    
////  Calculate current altitude
//	def Alt(fLatitude, fDeclination, fHourAngle): 
- (double) altitudeForLatitude:(double)fLatitude declination:(double)fDeclination sunHourAngle:(double)fHourAngle {
		
	double t = sin(fDeclination) * sin(fLatitude) + cos(fDeclination) * cos(fLatitude) * cos(fHourAngle);
	double fAltitude = asin(t);

	return fAltitude;
}
    
////  Calculates Sun Azimuth
//	def Az(fLatitude, fAltitude, fDeclination, fHourAngle):
- (double) sunAzimuthForLatitude:(double)fLatitude altitude:(double)fAltitude declination:(double)fDeclination sunHourAngle:(double)fHourAngle localTime:(double)fLocalTime {

	double t = (cos(fLatitude) * sin(fDeclination)) - (cos(fDeclination) * sin(fLatitude) * cos(fHourAngle));
	
	double sin1, cos2;
		
	// Avoid division by zero error.
	if (fAltitude < (M_PI/2.0)) {
		sin1 = (-cos(fDeclination) * sin(fHourAngle)) / cos(fAltitude);
		cos2 = t / cos(fAltitude);
	}
	else {
		sin1 = 0.0;
		cos2 = 0.0;
	}
			
	// Some range checking.
	if (sin1 > 1.0)		sin1 = 1.0;
	if (sin1 < -1.0)	sin1 = -1.0;
	if (cos2 < -1.0)	cos2 = -1.0;
	if (cos2 > 1.0)		cos2 = 1.0;
			
	// Calculate azimuth subject to quadrant.
	double fAzimuth;
	if (sin1 < -0.99999)
		fAzimuth = asin(sin1);
	else if ((sin1 > 0.0) & (cos2 < 0.0)) {
		if (sin1 >= 1.0)
			fAzimuth = -(M_PI/2.0);
		else
			fAzimuth = (M_PI/2.0) + ((M_PI/2.0) - asin(sin1));
	}
	else if ((sin1 < 0.0) & (cos2 < 0.0)) {
		if (sin1 <= -1.0)
			fAzimuth = (M_PI/2.0);
		else
			fAzimuth = -(M_PI/2.0) - ((M_PI/2.0) + asin(sin1));
	}
	else
		fAzimuth = asin(sin1);
		
	// A little last-ditch range check.
	if ((fAzimuth < 0.0) & (fLocalTime < 10.0))
		fAzimuth = -fAzimuth;

	return fAzimuth;
}

// Get the Azimuth using the month/day, timezone, local sunrise hour/minute, latitude
- (double) sunAzimuthForLocation:(CLLocationCoordinate2D)fLocation date:(NSDate *)fDate timeZone:(NSTimeZone *)fTimeZone {
	
	// Get the julian day (from month, day)
	int fJulian = [self julianDayFromMonth:[[[fDate description] substringWithRange:NSMakeRange(5,2)] intValue] 
									   Day:[[[fDate description] substringWithRange:NSMakeRange(8,2)] intValue]];
	
	// Get the declination (from julian day)
	double fDeclination = [self declinationForJulianDay:fJulian];
	
	// Get the equation of time (from julian day)
	double fEquation = [self equationOfTimeForJulianDay:fJulian];
	
	// Get the local (sunrise) time (from hour, minute)
	// TODO
	double fLocalTime = [self localTimeForHour:6 Minute:30];	// bogus
	
	// Get the solar time (from timezone, local time, equation of time, declination)
	NSDictionary * solarTimes = [self solarTimeForLocation:fLocation timeZone:fTimeZone localTime:fLocalTime equationOfTime:fEquation declination:fDeclination];
	double fSolarTime = [[solarTimes objectForKey:@"Solar Time"] doubleValue];
	
	// Get the sun hour angle (from solar time)
	double fHourAngle = [self sunHourAngleForSolarTime:fSolarTime];
	
	// Get the altitude (from latitude[given], decl, sunhourangle)
	double fAltitude = [self altitudeForLatitude:fLocation.latitude declination:fDeclination sunHourAngle:fHourAngle];
	
	// Get the azimuth (from the above collected info!)
	double theAzimuth = [self sunAzimuthForLatitude:fLocation.latitude altitude:fAltitude declination:fDeclination sunHourAngle:fHourAngle localTime:fLocalTime];

	return theAzimuth;
}

	
////	Tell the script what to do
/*
////This calculates the sun position        
def Solar_Pos (Long, Lat, TimeZone, Month, Day, Hour, Minute):
- (NSDictionary *) solarPositionWithLocation:(CLLocationCoordinate2D)location TimeZone:(NSNumber)timeZone

	// convert latitude, longitude and timezone to radians
	Lat = radians(Lat)
	Long = radians(Long)
	TimeZone = radians(TimeZone * 15)
   
	// get Julian Day
	Julian = J_Day(Month, Day)
	
	// get Declination
	fDeclination = Dec(Julian)
	
	// get Equation of Time
	fEquation = EquationOfTime(Julian)
	
	// get Local Time
	fLocalTime = Local_Time(Hour, Minute)
	
	// get Solar Time
	fSolarTime = Solar_Time(Long, Lat, TimeZone, fLocalTime, fEquation)
	fSunrise = fSolarTime[1]
	fSunset = fSolarTime[2]

	// get Hour Angle
	Hour_Angle = H_Ang(fSolarTime[0])

	// get Altitude
	fAltitude = Alt(Lat, fDeclination, Hour_Angle)

	// get Azimuth    
	fAzimuth = Az(Lat, fAltitude, fDeclination, Hour_Angle)
	
////	Prepare output values

	// Output Declination.
	fDeclination = degrees(fDeclination)
	
	// Output equation of time.
	fEquation = fEquation * 60
	
	// Output altitude value.
	fAltitude = degrees(fAltitude)
	
	// Output azimuth value.
	fAzimuth = degrees(fAzimuth)
	
	// Output solar time.
	t = int(floor(fSolarTime[0]))
	m = int(floor((fSolarTime[0] - t) * 60.0))
	if (m < 10):
		minute = "0" + str(m)
	else: minute = m
	if (t < 10):
		hour = "0" + str(t)
	else:
		hour = t
	sSolarTime = str(hour) + ":" + str(minute)
	
	// Output sunrise time.
	t = int(floor(fSunrise))
	m = int(floor((fSunrise - t) * 60.0))
	if (m < 10):
		minute = "0" + str(m)
	else:
		minute = m
	if (t < 10):
		hour = "0" + str(t)
	else:
		hour = t
	sSunrise = str(hour) + ":" + str(minute)
	
	// Output sunset time.
	t = int(floor(fSunset))
	m = int(floor((fSunset - t) * 60.0))
	if (m < 10):
		minute = "0" + str(m)
	else:
		minute = m
	if (t < 10):
		hour = "0" + str(t)
	else:
		hour = t
	fSunset = str(hour) + ":" + str(minute)
	
	// This last line is what Python returns to you, in this case:
	// Declination, Equation, Azimuth, Altitude, SolarTime, Sunrise, Sunset 
	return (fDeclination, fEquation, fAzimuth, fAltitude, sSolarTime, sSunrise, fSunset)

}	 
	 
*/

@end
