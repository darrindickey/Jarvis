//
//  PreferencesController.m
//  Jarvis
//
//  Created by Gabriel Ulici on 6/17/13.
//  Copyright (c) 2013 Night Ideas Lab Inc. All rights reserved.
//

#import "PreferencesController.h"

@implementation PreferencesController

@synthesize generalPreferenceView = _generalPreferenceView;
@synthesize speechPreferenceView = _speechPreferenceView;
@synthesize timeAndDatePreferenceView = _timeAndDatePreferenceView;
@synthesize icalAndRemaindersPreferenceView = _icalAndRemaindersPreferenceView;
@synthesize weatherPreferenceView = _weatherPreferenceView;
@synthesize emailPreferenceView = _emailPreferenceView;
@synthesize newsPreferenceView = _newsPreferenceView;
@synthesize quotationPreferenceView = _quotationPreferenceView;
@synthesize updatePreferenceView = _updatePreferenceView;

- (void)dealloc
{
    [updateDateField release];
    [profileDateField release];
    [super dealloc];
}

- (void)setupToolbar{
    [self addView:self.generalPreferenceView label: NSLocalizedString(@"General", @"General Window title") image: [NSImage imageNamed: @"PrefGeneral"]];
    [self addView:self.updatePreferenceView label: NSLocalizedString(@"Update", @"Update Window title") image: [NSImage imageNamed: @"PrefUpdate"]];
    
    //[self addView:self.generalPreferenceView label:@"General" imageName:@"NSGeneral"];

    //[self addFlexibleSpacer]; //added a space between the icons
    
    // Optional configuration settings.
    [self setCrossFade:[[NSUserDefaults standardUserDefaults] boolForKey:@"fade"]];
    [self setShiftSlowsAnimation:[[NSUserDefaults standardUserDefaults] boolForKey:@"shiftSlowsAnimation"]];
}

- (void) awakeFromNib
{
    // reading from the plist file
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    // retriving the dates from plist file
    [updateDateField setStringValue: [NSString stringWithFormat: @"%@", [defaults objectForKey:@"SULastCheckTime"]]];
    [profileDateField setStringValue: [NSString stringWithFormat: @"%@", [defaults objectForKey:@"SULastProfileSubmissionDate"]]];

    
}

@end
