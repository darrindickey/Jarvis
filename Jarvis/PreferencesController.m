//
//  PreferencesController.m
//  Jarvis
//
//  Created by Gabriel Ulici on 6/17/13.
//  Copyright (c) 2013 Night Ideas Lab Inc. All rights reserved.
//

#import "PreferencesController.h"

@implementation PreferencesController

// Preferences Toolbar
@synthesize generalPreferenceView = _generalPreferenceView;
@synthesize speechPreferenceView = _speechPreferenceView;
@synthesize timeAndDatePreferenceView = _timeAndDatePreferenceView;
@synthesize icalAndRemaindersPreferenceView = _icalAndRemaindersPreferenceView;
@synthesize weatherPreferenceView = _weatherPreferenceView;
@synthesize emailPreferenceView = _emailPreferenceView;
@synthesize newsPreferenceView = _newsPreferenceView;
@synthesize quotationPreferenceView = _quotationPreferenceView;
@synthesize updatePreferenceView = _updatePreferenceView;

// Update
@synthesize updateDateField;
@synthesize profileDateField;

// Weather
@synthesize locationField;
@synthesize mapWebView;
@synthesize locationManager;
@synthesize locationLabel;

#pragma mark -
#pragma mark Class Methods

- (void)dealloc
{
    [updateDateField release];
    [profileDateField release];
    [locationField release];
    [locationLabel release];
    [locationManager stopUpdatingLocation];
	[locationManager release];
    [super dealloc];
}

- (void) awakeFromNib
{
    // reading from the plist file
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    // retriving  the last update date and
    // last profile sent date from plist file
    NSDate *updateDate = [defaults objectForKey:@"SULastCheckTime"];
    NSDate *profileDate = [defaults objectForKey:@"SULastProfileSubmissionDate"];
    
    // checking and setting the last update date
    // and last profile sent date into the interface
    if ([profileDate.description length] > 0) {
        [updateDateField setObjectValue:updateDate];
    }
    else {
        [updateDateField setStringValue:NSLocalizedString(@"Never", @"Text that appears if there where no check for update")];
    }
    
    
    if ([profileDate.description length] > 0) {
        [profileDateField setObjectValue:profileDate];
    }
    else {
        [profileDateField setStringValue:NSLocalizedString(@"Never", @"Text that appears if there where not sent any profile data")];
    }
    
    // TODO: load the weather stuff only when the wether view is active
    //       and releasing them when switching from it
    /* 	Weather Stuff retriving the location */
	locationManager = [[CLLocationManager alloc] init];
	locationManager.delegate = self;
	[locationManager startUpdatingLocation];
    
    [defaults release];
}

#pragma mark -
#pragma mark Toolbar Configuration

- (void)setupToolbar{
    [self addView:self.generalPreferenceView label: NSLocalizedString(@"General", @"General Window title") image: [NSImage imageNamed: @"PrefGeneral"]];
    [self addView:self.weatherPreferenceView label: NSLocalizedString(@"Weather", @"Weather Window title") image: [NSImage imageNamed: @"PrefWeather"]];
    [self addView:self.updatePreferenceView label: NSLocalizedString(@"Update", @"Update Window title") image: [NSImage imageNamed: @"PrefUpdate"]];
    
    //[self addView:self.generalPreferenceView label:@"General" imageName:@"NSGeneral"];
    
    //[self addFlexibleSpacer]; //added a space between the icons
    
    // Optional configuration settings.
    [self setCrossFade:[[NSUserDefaults standardUserDefaults] boolForKey:@"fade"]];
    [self setShiftSlowsAnimation:[[NSUserDefaults standardUserDefaults] boolForKey:@"shiftSlowsAnimation"]];
}

#pragma mark -
#pragma mark Weather Methods

- (IBAction)findLocation:(id)sender {
    // retrives the City and Country
    NSString *locationText = [locationField stringValue];
    NSString *messageForLabel = [[NSString alloc] initWithFormat:NSLocalizedString(@"Your location is: %@", @"Message after the user inseted his location"), locationText];
    
    // separa NSString in mai single pointers
    //    NSString *list = @"Norman, Stanley, Fletcher";
    //    NSArray *listItems = [list componentsSeparatedByString:@", "];
    
    if ([locationText length] >0) {
        // Displays the user his location
        [locationLabel setStringValue:messageForLabel];
    }
    else {
        // If the user will not write a city and country then we will display this message
        [locationLabel setStringValue:NSLocalizedString(@"Please enter a City and Country.", @"Message that appeareas if the user did not inserted his location")];
    }
    
    [messageForLabel release];
    
    //    if (!firstLaunch) {
    //
    //        [fDefaults setInteger:721943 forKey: @"LocationCode"];
    //    }
    
    
}

#pragma -
#pragma WOIED

- (NSInteger *)getWOIEDfromlatitude: (double) latitude andLongitude: (double) longitude {
    NSLog(@"Latitude: %f and longitude: %f", latitude, longitude);
    
    NSString *weatherContent = [[NSString alloc] initWithString:@""];
	weatherContent = [NSString stringWithContentsOfURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://api.flickr.com/services/rest/?method=flickr.places.findByLatLon&api_key=ca5edb0f6f046f0e9e1ee43dd49277e4&lat=41.868163&lon=12.587606"]] encoding: NSUTF8StringEncoding error:nil];

    NSLog(@"Flickr respornce: %@",weatherContent);
    
    
    
    
    
    
    
    
    return 0;
}

#pragma -
#pragma Find Location

+ (double)latitudeRangeForLocation:(CLLocation *)aLocation
{
	const double M = 6367000.0; // approximate average meridional radius of curvature of earth
	const double metersToLatitude = 1.0 / ((M_PI / 180.0) * M);
	const double accuracyToWindowScale = 2.0;
	
	return aLocation.horizontalAccuracy * metersToLatitude * accuracyToWindowScale;
}

+ (double)longitudeRangeForLocation:(CLLocation *)aLocation
{
	double latitudeRange =
    [PreferencesController latitudeRangeForLocation:aLocation];
	
	return latitudeRange * cos(aLocation.coordinate.latitude * M_PI / 180.0);
}

- (void)locationManager:(CLLocationManager *)manager
	didUpdateToLocation:(CLLocation *)newLocation
           fromLocation:(CLLocation *)oldLocation
{
	// Ignore updates where nothing we care about changed
	if (newLocation.coordinate.longitude == oldLocation.coordinate.longitude &&
		newLocation.coordinate.latitude == oldLocation.coordinate.latitude &&
		newLocation.horizontalAccuracy == oldLocation.horizontalAccuracy)
	{
		return;
	}
    
	// Load the HTML for displaying the Google map from a file and replace the
	// format placeholders with our location data
	NSString *htmlString = [NSString stringWithFormat:
                            [NSString
                             stringWithContentsOfFile:
                             [[NSBundle mainBundle]
                              pathForResource:@"googleMaps" ofType:@"html"]
                             encoding:NSUTF8StringEncoding
                             error:NULL],
                            newLocation.coordinate.latitude,
                            newLocation.coordinate.longitude,
                            [PreferencesController latitudeRangeForLocation:newLocation],
                            [PreferencesController longitudeRangeForLocation:newLocation]];
	
	// Load the HTML in the WebView and set the labels
	[[mapWebView mainFrame] loadHTMLString:htmlString baseURL:nil];
	[locationLabel setStringValue:[NSString stringWithFormat:@"%f, %f",
                                   newLocation.coordinate.latitude, newLocation.coordinate.longitude]];
    [self getWOIEDfromlatitude:newLocation.coordinate.latitude andLongitude:newLocation.coordinate.longitude];
}

- (void)locationManager:(CLLocationManager *)manager
       didFailWithError:(NSError *)error
{
	[[mapWebView mainFrame]
     loadHTMLString:
     [NSString stringWithFormat:
      NSLocalizedString(@"Location manager failed with error: %@", nil),
      [error localizedDescription]]
     baseURL:nil];
	[locationLabel setStringValue:@""];
}


#pragma -
#pragma Other Functions
- (void)windowWillTerminate:(NSNotification *)aNotification
{
	[locationManager stopUpdatingLocation];
	[locationManager release];
}

- (IBAction)openInDefaultBrowser:(id)sender
{
	CLLocation *currentLocation = locationManager.location;
	
	NSURL *externalBrowserURL = [NSURL URLWithString:[NSString stringWithFormat:
                                                      @"http://maps.google.com/maps?ll=%f,%f&amp;spn=%f,%f",
                                                      currentLocation.coordinate.latitude,
                                                      currentLocation.coordinate.longitude,
                                                      [PreferencesController latitudeRangeForLocation:currentLocation],
                                                      [PreferencesController longitudeRangeForLocation:currentLocation]]];
    
	[[NSWorkspace sharedWorkspace] openURL:externalBrowserURL];
}

@end