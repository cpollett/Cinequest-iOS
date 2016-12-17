//
//  ScheduleViewController.h
//  CineQuest
//
//  Created by Luca Severini on 10/1/13.
//  Copyright (c) 2013 San Jose State University. All rights reserved.
//  Renamed 2015 Chris Polletts
//

@class CinequestAppDelegate;

@interface ScheduleViewController : UIViewController <UITableViewDelegate, UITableViewDataSource>
{
	CinequestAppDelegate *delegate;
	NSMutableArray *mySchedule;
    UIFont *titleFont;
	UIFont *timeFont;
	UIFont *venueFont;
	UIFont *sectionFont;
	NSDataDetector *dateDetector;
}

@property (nonatomic, strong) IBOutlet UITableView *eventsTableView;
@property (nonatomic, strong) IBOutlet UIActivityIndicatorView *activityIndicator;
@property (nonatomic, strong) IBOutlet UISegmentedControl *switchTitle;

@property (nonatomic, strong) UIRefreshControl *refreshControl;

//combined dictionaries (so all films/events/forums are displayed in schedule.
@property (nonatomic, strong) NSMutableDictionary *dateToCombinedDictionary;
@property (nonatomic, strong) NSMutableArray *sortedKeysInDateToCombinedDictionary;
@property (nonatomic, strong) NSMutableArray *sortedIndexesInDateToCombinedDictionary;

@end
