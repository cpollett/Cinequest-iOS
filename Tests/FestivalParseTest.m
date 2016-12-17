//
//  ShowsAndFestivalTest.m
//  Cinequest
//
//  Created by Hai Nguyen on 11/5/13.
//  Copyright (c) 2013 San Jose State University. All rights reserved.
//  Reworked Chris Pollett 2015
//

#import <XCTest/XCTest.h>
#import "ShowsAndFestivalParser.h"
#import "Festival.h"
#import "Film.h"
#import "VenueLocation.h"
#import "Schedule.h"

@interface FestivalParseTest : XCTestCase

@end

@implementation FestivalParseTest {
    Festival *festival;
}

- (void)setUp
{
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
    ShowsAndFestivalParser *showsAndFestivalParser = [[ShowsAndFestivalParser alloc] init];
    festival = [showsAndFestivalParser parseFakeFestival];
}

- (void)tearDown
{
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}


- (void) testShow6906
{
    Film *film = [festival getFilmForId:@"6906"];
    XCTAssertTrue([@"7 Lives Of Chance" isEqualToString:film.name]);
    XCTAssertTrue([@"Jodi Chase, John Pelkey, Richard Regan Paul, Michele Feren, Maria Regan, John-Archer Ludgreen, Victoria Jelstrom Swilley, Samantha O'Hare, Olivia Miller, Banks Helfrich" isEqualToString: film.cast]);
}

- (void) testSchedulesFor6906
{
    int found = 0;
    for (id obj in [festival schedules]) {
        Schedule *schedule = (Schedule *) obj;
        if ([schedule.ID isEqualToString:@"7268"]) {
            XCTAssertTrue([@"6906" isEqualToString:schedule.itemID]);
            XCTAssertTrue([schedule.startTime hasPrefix:@"6:45"]);
            XCTAssertTrue([schedule.endTime hasPrefix:@"8:41"]);
            XCTAssertTrue([@"C12-S10" isEqualToString:[schedule venue]]);
        }
        if ([schedule.itemID isEqualToString:@"6906"]) found++;
    }
    XCTAssertTrue(found == 3);
}


- (Schedule *) getScheduleForId:(NSString *)ID
{
    for (id obj in [festival schedules]) {
        Schedule *schedule = (Schedule *) obj;
        if ([schedule.ID isEqualToString:ID])
            return schedule;
    }
    return nil;
}

- (VenueLocation *) getVenueLocationForAbbrev:(NSString *) abbrev
{
    for (id obj in festival.venueLocations) {
        VenueLocation *venue = (VenueLocation *) obj;
        if ([venue.venueAbbreviation isEqualToString:abbrev])
            return venue;
    }
    return nil;
}

- (void) testScheduleForFilm6909
{
    Film *film = [festival getFilmForId:@"6909"];
    XCTAssertTrue(4 == [[film schedules] count]);
    XCTAssertTrue([[film schedules] containsObject:[self getScheduleForId:@"7346"]]);
    XCTAssertTrue([[film schedules] containsObject:[self getScheduleForId:@"7347"]]);
    XCTAssertTrue([[film schedules] containsObject:[self getScheduleForId:@"7348"]]);
    XCTAssertTrue([[film schedules] containsObject:[self getScheduleForId:@"8609"]]);
}

- (void) testVenues
{
    XCTAssertTrue(10 == [[festival venueLocations] count]);
    VenueLocation *venue = [self getVenueLocationForAbbrev:@"C12-S7"];
    XCTAssertTrue([venue.name isEqualToString:@"Camera 12 - Screen 7"]);
    XCTAssertTrue([venue.location isEqualToString:@"201 S. Second Street"]);
    XCTAssertTrue([@"C12-S7" isEqualToString:[self getScheduleForId:@"7373"].venue]);
}

@end

