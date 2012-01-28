//
//  NSObject+SolarPos.h
//  SunGuide
//
//  Created by Stephen Eisenhauer on 6/1/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//
//	Objective-C solar position functions based on solar_pos.py
//
//	Solar_Position
//
//	The azimuth and altitude of the Sun are calculated using formulae first proposed by Spencer (Spencer, 1965),
//	then refined by Szokolay (Szokolay, 1996). Values for solar declination and the equation of time
//	are determined using formulae proposed by Carruthers, et al [1990]

//	The math behind this calculation was taken from:
//	http://squ1.org/wiki/Solar_Position_Calculator

#import <Foundation/Foundation.h>


@interface NSObject (SolarPos)

- (NSInteger) julianDayFromMonth:(NSInteger)Month Day:(NSInteger)Day;
- (double) declinationForJulianDay:(NSInteger)julianDay;
- (double) equationOfTimeForJulianDay:(NSInteger)julianDay;
- (double) localTimeForHour:(NSInteger)Hour Minute:(NSInteger)Minute;
- (NSDictionary *) solarTimeForLocation:(CLLocationCoordinate2D)location timeZone:(NSTimeZone *)fTimeZone localTime:(double)fLocalTime equationOfTime:(double)fEquation declination:(double)fDeclination;
- (double) sunHourAngleForSolarTime:(double)fSolarTime;
- (double) altitudeForLatitude:(double)fLatitude declination:(double)fDeclination sunHourAngle:(double)fHourAngle;
- (double) sunAzimuthForLocation:(CLLocationCoordinate2D)fLocation date:(NSDate *)fDate timeZone:(NSTimeZone *)fTimeZone;

@end
