//
//  Festival.m
//  Cinequest
//
//  Created by Hai Nguyen on 11/5/13.
//  Copyright (c) 2013 San Jose State University. All rights reserved.
//

#import "Festival.h"
#import "Schedule.h"
#import "Film.h"
#import "Special.h"
#import "Forum.h"
#import "ProgramItem.h"
#import "CinequestItem.h"

//This class provides administrative methods for the Festival Object
@implementation Festival
//create getters setters for the Festival fields
@synthesize programItems;
@synthesize films;
@synthesize schedules;
@synthesize venueLocations;
@synthesize lastChanged;

@synthesize forums;
@synthesize specials;

@synthesize dateToFilmsDictionary;
@synthesize sortedKeysInDateToFilmsDictionary;
@synthesize sortedIndexesInDateToFilmsDictionary;

@synthesize alphabetToFilmsDictionary;
@synthesize sortedKeysInAlphabetToFilmsDictionary;
//@synthesize sortedIndexesInAlphabetToFilmsDictionary;

@synthesize dateToForumsDictionary;
@synthesize sortedKeysInDateToForumsDictionary;
@synthesize sortedIndexesInDateToForumsDictionary;

@synthesize dateToSpecialsDictionary;
@synthesize sortedKeysInDateToSpecialsDictionary;
@synthesize sortedIndexesInDateToSpecialsDictionary;

//Initialization method for Festival Class
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
        
        forums = [[NSMutableArray alloc]  init];
        specials = [[NSMutableArray alloc] init];
        
        dateToFilmsDictionary = [[NSMutableDictionary alloc] init];
        sortedKeysInDateToFilmsDictionary = [[NSMutableArray alloc] init];
        sortedIndexesInDateToFilmsDictionary = [[NSMutableArray alloc] init];
        
        alphabetToFilmsDictionary = [[NSMutableDictionary alloc] init];
        sortedKeysInAlphabetToFilmsDictionary = [[NSMutableArray alloc] init];
        sortedIndexesInDateToFilmsDictionary = [[NSMutableArray alloc] init];
        
        dateToForumsDictionary = [[NSMutableDictionary alloc] init];
        sortedKeysInDateToForumsDictionary = [[NSMutableArray alloc] init];
        sortedIndexesInDateToForumsDictionary = [[NSMutableArray alloc] init];
        
        dateToSpecialsDictionary = [[NSMutableDictionary alloc] init];
        sortedKeysInDateToSpecialsDictionary = [[NSMutableArray alloc] init];
        sortedIndexesInDateToSpecialsDictionary = [[NSMutableArray alloc] init];
	}
	
    return self;
}
//Given a date, return the schedule from the Festival which starts on that date.
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
//Given an id, find the event from Special and return the particular Special object that matches the id,  otherwise return nil
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
//Given an id, return the Forum object from this particular Festival which matches the id, otherwise return nil
- (Forum*) getForumForId:(NSString *)ID
{
 	for(Forum* forum in forums)
	{
        if ([forum.ID isEqualToString:ID])
		{
            return forum;
		}
	}
	
    return nil;
}
//Given an id, return the film that matches the id in this Festival, otherwise return nil
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
//Given an id, return a ProgramItem that matches the id in this Festival, otherwise return nil
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
//Given an id, first find if a forum exist for the id and return, if a forum is not found, get an event which matches the id and return, if neither forum nor event is found, then return a film matching the id
- (CinequestItem*) getScheduleItem:(NSString *)itemID
{
	CinequestItem* item = [self getForumForId:itemID];
	if(item == nil)
	{
		item = [self getEventForId:itemID];
		if(item == nil)
		{
			item = [self getFilmForId:itemID];
		}
	}
	
	return item;
}

@end

