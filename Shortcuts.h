/* Shortcuts to make life easier */

// #import "SunGuideAppDelegate.h"

#define UD [NSUserDefaults standardUserDefaults]
#define AD (SunGuideAppDelegate *)[[UIApplication sharedApplication] delegate]

// NSUserDefaults keys
#define PREF_LATITUDE	@"preferred_lat"
#define PREF_LONGITUDE	@"preferred_lon"
#define USE_LOCATION		@"use_cur_location"
#define SETUP_DONE		@"is_setup_done"
#define MAP_LATITUDE_SPAN	@"map_span_lat"
#define MAP_LONGITUDE_SPAN	@"map_span_lon"

#define SGDEBUG	NO