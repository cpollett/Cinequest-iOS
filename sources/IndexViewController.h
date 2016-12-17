//
//  IndexViewController.h
//  CineQuest
//
//  Created by Luca Severini on 10/1/13.
//  Copyright (c) 2013 San Jose State University. All rights reserved.
//  Renamed Chris Pollett 2015
//

@class CinequestAppDelegate;
@class Schedule;
@class Festival;

@interface IndexViewController : UIViewController < UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate, UISearchDisplayDelegate>
{
	NSMutableArray *mySchedule;
	NSInteger switcher;
	CinequestAppDelegate *delegate;
	CGFloat listByDateOffset;
	CGFloat listByTitleOffset;
	UIFont *titleFont;
	UIFont *timeFont;
	UIFont *venueFont;
	UIFont *sectionFont;
    EKCalendar *cinequestCalendar;
    EKEventStore *eventStore;
	BOOL statusBarHidden;
	NSDataDetector *dateDetector;
	BOOL searchActive;
}

@property (nonatomic, strong) IBOutlet UIActivityIndicatorView *activityIndicator;
@property (nonatomic, strong) IBOutlet UISegmentedControl *switchTitle;
@property (nonatomic, strong) IBOutlet UITableView *filmsTableView;
@property (nonatomic, strong) IBOutlet UISearchBar *filmSearchBar;

@property (nonatomic, strong) UIRefreshControl *refreshControl;
@property (nonatomic, strong) NSMutableDictionary *dateToFilmsDictionary;
@property (nonatomic, strong) NSMutableArray *sortedKeysInDateToFilmsDictionary;			// Sections
@property (nonatomic, strong) NSMutableArray *sortedIndexesInDateToFilmsDictionary;			// Films
@property (nonatomic, strong) NSMutableDictionary *alphabetToFilmsDictionary;				// Films
@property (nonatomic, strong) NSMutableArray *sortedKeysInAlphabetToFilmsDictionary;		// Sections
// Events

@property (nonatomic, strong) NSMutableDictionary *dateToEventsDictionary;
@property (nonatomic, strong) NSMutableArray *sortedKeysInDateToEventsDictionary;
@property (nonatomic, strong) NSMutableArray *sortedIndexesInDateToEventsDictionary;
@property (nonatomic, strong) IBOutlet UITableView *eventsTableView;


- (IBAction) switchTitle:(id)sender;
- (IBAction) calendarButtonTapped:(id)sender event:(id)touchEvent;

@end
