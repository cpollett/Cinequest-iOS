//
//  Festival.m
//  Cinequest
//
//  A festival is used to contain collections of cinequest items in different
//  sort orders.
//
//  Created by Hai Nguyen on 11/5/13.
//  Copyright (c) 2013 San Jose State University. All rights reserved.
//

#import "Festival.h"
#import "Schedule.h"
#import "Film.h"
#import "Special.h"
#import "ProgramItem.h"
#import "CinequestItem.h"


@implementation Festival

@synthesize programItems;
@synthesize films;
@synthesize schedules;
@synthesize venueLocations;
@synthesize lastChanged;

@synthesize specials;

@synthesize dateToFilmsDictionary;
@synthesize sortedKeysInDateToFilmsDictionary;
@synthesize sortedIndexesInDateToFilmsDictionary;

@synthesize alphabetToFilmsDictionary;
@synthesize sortedKeysInAlphabetToFilmsDictionary;
//@synthesize sortedIndexesInAlphabetToFilmsDictionary;

@synthesize dateToSpecialsDictionary;
@synthesize sortedKeysInDateToSpecialsDictionary;
@synthesize sortedIndexesInDateToSpecialsDictionary;

@synthesize dateToCombinedDictionary;
@synthesize sortedKeysInDateToCombinedDictionary;
@synthesize sortedIndexesInDateToCombinedDictionary;

- (id) init
{
	self = [super init];
	if(self != nil)
	{
		programItems = [[NSMutableArray alloc] init];
		films = [[NSMutableArray alloc] init];
		schedules = [[NSMutableArray alloc] init];
		venueLocations = [[NSMutableArray alloc] init];
		lastChanged = @"";
        
        specials = [[NSMutableArray alloc] init];
        
        dateToFilmsDictionary = [[NSMutableDictionary alloc] init];
        sortedKeysInDateToFilmsDictionary = [[NSMutableArray alloc] init];
        sortedIndexesInDateToFilmsDictionary = [[NSMutableArray alloc] init];
        
        alphabetToFilmsDictionary = [[NSMutableDictionary alloc] init];
        sortedKeysInAlphabetToFilmsDictionary = [[NSMutableArray alloc] init];
        sortedIndexesInDateToFilmsDictionary = [[NSMutableArray alloc] init];
        
        dateToSpecialsDictionary = [[NSMutableDictionary alloc] init];
        sortedKeysInDateToSpecialsDictionary = [[NSMutableArray alloc] init];
        sortedIndexesInDateToSpecialsDictionary = [[NSMutableArray alloc] init];
        
        dateToCombinedDictionary = [[NSMutableDictionary alloc] init];
        sortedKeysInDateToCombinedDictionary = [[NSMutableArray alloc] init];
        sortedIndexesInDateToCombinedDictionary = [[NSMutableArray alloc] init];
	}
	
    return self;
}

- (NSMutableArray*) getSchedulesForDay:(NSString *)date
{
    NSMutableArray *result = [NSMutableArray new];
	
    for(Schedule *schedule in schedules)
	{
        if ([schedule.startTime hasPrefix:date])
		{
            [result addObject:schedule];
        }
    }
	
    return result;
}

- (Special*) getEventForId:(NSString *)ID
{
	for(Special* event in specials)
	{
        if ([event.ID isEqualToString:ID])
		{
            return event;
		}
	}
	
    return nil;
}

- (Film*) getFilmForId:(NSString *)ID
{
 	for(Film* film in films)
	{
        if ([film.ID isEqualToString:ID])
		{
            return film;
		}
	}
	
    return nil;
}

- (ProgramItem*) getProgramItemForId:(NSString *)ID
{
 	for(ProgramItem* item in programItems)
	{
        if ([item.ID isEqualToString:ID])
		{
            return item;
		}
	}
	
    return nil;
}

- (CinequestItem*) getScheduleItem:(NSString *)itemID
{
	CinequestItem* item = [self getEventForId:itemID];
		if(item == nil)
		{
			item = [self getFilmForId:itemID];
		}
	
	
	return item;
}

@end

