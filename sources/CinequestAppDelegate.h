//
//  CinequestAppDelegate.h
//  Cinequest
//
//  Created by Luca Severini on 10/1/13.
//  Copyright (c) 2013 San Jose State University. All rights reserved.
//


#define FILMSBYTIME		@"https://mobile.cinequest.org/mobileCQ.php?type=schedules&filmtitles&iphone"
#define FILMSBYTITLE	@"https://mobile.cinequest.org/mobileCQ.php?type=films&iphone"
#define OLD_NEWS		@"https://mobile.cinequest.org/mobileCQ.php?type=xml&name=ihome"
#define EVENTS			@"https://mobile.cinequest.org/mobileCQ.php?type=xml&name=ievents"
#define DVDs			@"https://mobile.cinequest.org/mobileCQ.php?type=dvds&distribution=none&iphone"
#define DETAILFORFILMID @"https://mobile.cinequest.org/mobileCQ.php?type=film&iphone&id="
#define DETAILFORDVDID	@"https://mobile.cinequest.org/mobileCQ.php?type=dvd&iphone&id="
#define DETAILFORPrgId	@"https://mobile.cinequest.org/mobileCQ.php?type=program_item&iphone&id="
#define DETAILFORITEM	@"https://mobile.cinequest.org/mobileCQ.php?type=xml&name=items&iphone&id="
#define MODE			@"https://mobile.cinequest.org/mobileCQ.php?type=mode"
#define TRENDING_FEED	@"https://www.cinequest.org/misc/trending/XML/MobileTrending_Top10Events.xml"
#define NEWS_FOR_DATE_FEED	@"https://payments.cinequest.org/websales/feed.ashx?guid=d52499c1-3164-429f-b057-384dd7ec4b23&showslist=true&"
#define VIDEO_FEED      @"https://payments.cinequest.org/websales/feed.ashx?guid=d52499c1-3164-429f-b057-384dd7ec4b23&showslist=true&"
#define MAIN_FEED		@"https://payments.cinequest.org/websales/feed.ashx?guid=d52499c1-3164-429f-b057-384dd7ec4b23&showslist=true&"
#define VENUES			@"https://www.cinequest.org/misc/venuelist.php"
#define CALENDAR_FILE   @"calendar.plist"

#define CELL_TITLE_LABEL_TAG	1
#define	CELL_TIME_LABEL_TAG		2
#define CELL_VENUE_LABEL_TAG	3
#define CELL_FACEBOOKBUTTON_TAG	4
#define CELL_RIGHTBUTTON_TAG	5
#define CELL_IMAGE_TAG			6
#define CELL_LEFTBUTTON_TAG		100

#define SHORT_PROGRAM_SECTION   0
#define SCHEDULE_SECTION        1
#define SOCIAL_MEDIA_SECTION	2
#define ACTION_SECTION			3

#define TICKET_LINE @"telprompt://1-408-295-3378"

#define CALENDAR_NAME @"Cinequest"
#define CINEQUEST_DATACACHE_FOLDER @"CinequestDataCache"

#define EMPTY 0
#define ONE_YEAR (60.0 * 60.0 * 24.0 * 365.0)


//For the hot picks segmented control
#define VIEW_TRENDING	0
#define VIEW_VIDEOS     1

// Switched from VIEW_BY_DATE and VIEW_BY_TITLE
// use these to switch into appropriate code blocks
#define VIEW_BY_FILMS	0
#define VIEW_BY_EVENTS	1

#define NETWORK_CONNECTION_NONE  0
#define NETWORK_CONNECTION_WIFI  1
#define NETWORK_CONNECTION_PHONE 2

#define FEED_UPDATED_NOTIFICATION @"FeedUpdateNotification"

#define GOOGLEPLUS_CLIENTID	@"470208679525-9nYBufiT7puYS3jIkOe49Rv6.apps.googleusercontent.com";	// org.cinequest.mobileapp
// #define GOOGLEPLUS_CLIENTID	@"452265719636-qbqmhro0t3j9jip1npl69a3er7biidd2.apps.googleusercontent.com"; // com.google.GooglePlusPlatformSample

#define CRASHLYTICS_ID @"dfa118a0f8f784b89d3b2619021de8f24bf7524b"

#define appDelegate ((CinequestAppDelegate*)[[UIApplication sharedApplication] delegate])
#define app [UIApplication sharedApplication]

@class HotPicksViewController;
@class Reachability;
@class DataProvider;


#import <EventKit/EventKit.h>
#import "Schedule.h"
#import "Festival.h"

@interface CinequestAppDelegate : NSObject <UIApplicationDelegate, UITabBarControllerDelegate, NSXMLParserDelegate> 
{
	NSInteger curTabIndex;
}

@property (nonatomic, strong) HotPicksViewController *hotPicksView;
@property (nonatomic, strong) NSMutableArray *mySchedule;
@property (readwrite) BOOL isPresentingModalView;
@property (readwrite) BOOL isLoggedInFacebook;
@property (readwrite) BOOL isOffSeason;
@property (nonatomic, strong) Festival *festival;
@property (nonatomic, strong) NSDictionary *venuesDictionary;
@property (nonatomic, strong) Reachability *reachability;
@property (atomic, assign) NSInteger networkConnection;	// 0: No connection, 1: WiFi, 2: Phone data
@property (nonatomic, strong) DataProvider *dataProvider;
@property (nonatomic, strong) NSString *OSVersion;
@property (nonatomic, assign) BOOL retinaDisplay;
@property (nonatomic, assign) BOOL iPhone4Display;
@property (nonatomic, assign) NSInteger deviceIdiom;
@property (atomic, assign) BOOL isFetchingFestival;
@property (atomic, assign) BOOL festivalParsed;
@property (atomic, assign) BOOL venuesParsed;
@property (nonatomic, assign) BOOL firstLaunch;
@property (nonatomic, assign) BOOL locationServicesON;
@property (nonatomic, assign) BOOL userLocationON;

@property (nonatomic, strong) IBOutlet UIWindow *window;
@property (nonatomic, strong) IBOutlet UITabBarController *tabBar;

// For Calendar Events
@property (nonatomic, strong) EKEventStore *eventStore;
@property (nonatomic, strong) EKCalendar *cinequestCalendar;
@property (nonatomic, strong) NSString *calendarIdentifier;
@property (nonatomic, strong) NSMutableArray *arrayCalendarItems;
@property (nonatomic, strong) NSMutableDictionary *dictSavedEventsInCalendar;

- (BOOL) connectedToNetwork;
- (void) startReachability:(NSString*)hostName;

- (void) addOrRemoveSchedule:(Schedule*)schedule;
- (BOOL) addOrRemoveScheduleToCalendar:(Schedule*)schedule;
- (void) populateCalendarEntries;
- (void) checkEventStoreAccessForCalendar;
- (void) checkAndSyncWithCalendar:(BOOL)calendarAccessGranted;
- (void) fetchVenues;
- (void) fetchFestival;
- (void) showMessage:(NSString*)message onView:view hideAfter:(NSTimeInterval)time;

- (NSURL*) cachesDirectory;
- (NSURL*) documentsDirectory;

@end



