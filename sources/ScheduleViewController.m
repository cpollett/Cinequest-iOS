//
//  ScheduleViewController.m
//  CineQuest
//
//  Created by Luca Severini on 10/1/13.
//  Copyright (c) 2013 San Jose State University. All rights reserved.
//
// Edited by Karan Khare and Ramya Shenoy on 11/24/2014
// Edited by Kenan Ozdamar on Jan 2015.
// Rename and reworked Chris Pollett 2015

//


#import "ScheduleViewController.h"
#import "ScheduleDetailViewController.h"
#import "CinequestAppDelegate.h"
#import "Schedule.h"
#import "HotPicksViewController.h"
#import "Special.h"
#import "DataProvider.h"


static NSString *const kEventCellIdentifier = @"EventCell";

@implementation ScheduleViewController

@synthesize refreshControl;
@synthesize switchTitle;
@synthesize eventsTableView;
@synthesize activityIndicator;

//combined dictionaries (so all films/events/forums are displayed in schedule.
@synthesize dateToCombinedDictionary;
@synthesize sortedKeysInDateToCombinedDictionary;
@synthesize sortedIndexesInDateToCombinedDictionary;

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark UIViewController Methods

- (void) viewDidLoad
{
    [super viewDidLoad];

	delegate = appDelegate;
	mySchedule = delegate.mySchedule;
		
	dateDetector = [NSDataDetector dataDetectorWithTypes:NSTextCheckingTypeDate error:nil];

    titleFont = [UIFont boldSystemFontOfSize:[UIFont labelFontSize]];
	timeFont = [UIFont systemFontOfSize:[UIFont systemFontSize]];
	sectionFont = [UIFont boldSystemFontOfSize:18.0];
	venueFont = timeFont;
  
	NSDictionary *attribute = [NSDictionary dictionaryWithObject:[UIFont boldSystemFontOfSize:16.0f] forKey:NSFontAttributeName];
	[switchTitle setTitleTextAttributes:attribute forState:UIControlStateNormal];
	[switchTitle removeSegmentAtIndex:1 animated:NO];
		
	refreshControl = [UIRefreshControl new];
	// refreshControl.attributedTitle = [[NSAttributedString alloc] initWithString:@"Updating Events..."];
	[refreshControl addTarget:self action:@selector(refresh) forControlEvents:UIControlEventValueChanged];
	[((UITableViewController*)self.eventsTableView.delegate) setRefreshControl:refreshControl];
	[self.eventsTableView addSubview:refreshControl];

	eventsTableView.tableHeaderView = nil;
	eventsTableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
}

- (void) viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
    
    [self.eventsTableView setContentOffset:CGPointMake(0.0, 44.0) animated:YES];
    
    self.dateToCombinedDictionary = [delegate.festival.dateToCombinedDictionary mutableCopy];
    self.sortedKeysInDateToCombinedDictionary = [delegate.festival.sortedKeysInDateToCombinedDictionary mutableCopy];
    self.sortedIndexesInDateToCombinedDictionary = [delegate.festival.sortedIndexesInDateToCombinedDictionary mutableCopy];
    

	[self syncTableDataWithScheduler];
	
    [self.eventsTableView reloadData];
	
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receivedNotification:) name:FEED_UPDATED_NOTIFICATION object:nil];
}

- (void) viewWillDisappear:(BOOL)animated
{
	[super viewWillDisappear: animated];
	
    //combined dictionaries
    self.dateToCombinedDictionary = nil;
    self.sortedKeysInDateToCombinedDictionary = nil;
    self.sortedIndexesInDateToCombinedDictionary = nil;
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void) viewDidAppear:(BOOL)animated
{
	[super viewDidAppear: animated];
	
	if([[NSUserDefaults standardUserDefaults] boolForKey:@"ScheduleUpdated"])
	{
		[appDelegate showMessage:@"Schedule updated" onView:self.view hideAfter:3.0];
		
		[[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"ScheduleUpdated"];
        [[NSUserDefaults standardUserDefaults] synchronize];
	}
}

#pragma mark Private Methods

- (void) refresh
{
	[appDelegate fetchFestival];
	[appDelegate fetchVenues];
	
	[self updateDataAndTable];
	
	[refreshControl endRefreshing];
	
	[NSThread sleepForTimeInterval:0.5];
}

- (void) receivedNotification:(NSNotification*) notification
{
    if ([[notification name] isEqualToString:FEED_UPDATED_NOTIFICATION]) // Not really necessary until there is only one notification
	{
		[self performSelectorOnMainThread:@selector(updateDataAndTable) withObject:nil waitUntilDone:NO];

		[appDelegate showMessage:@"Scheduleupdated" onView:self.view hideAfter:3.0];

		[[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"ScheduleUpdated"];
        [[NSUserDefaults standardUserDefaults] synchronize];
	}
}

- (void) updateDataAndTable
{
    //combined dictionaries
    self.dateToCombinedDictionary = [delegate.festival.dateToCombinedDictionary mutableCopy];
    self.sortedKeysInDateToCombinedDictionary = [delegate.festival.sortedKeysInDateToCombinedDictionary mutableCopy];
    self.sortedIndexesInDateToCombinedDictionary = [delegate.festival.sortedIndexesInDateToCombinedDictionary mutableCopy];
    
    
	[self.eventsTableView reloadData];
}

- (NSDate*) dateFromString:(NSString*)string
{
	__block NSDate *detectedDate;
	
	[dateDetector enumerateMatchesInString:string options:kNilOptions range:NSMakeRange(0, string.length) usingBlock:
	 ^(NSTextCheckingResult *result, NSMatchingFlags flags, BOOL *stop)
	 {
		 detectedDate = result.date;
	 }];
	
	return detectedDate;
}

- (void) syncTableDataWithScheduler
{
    [delegate populateCalendarEntries];
    
    //combined dict.
    NSInteger sectionCount = [self.sortedKeysInDateToCombinedDictionary count];
    
	NSInteger myScheduleCount = [mySchedule count];
	if(myScheduleCount == 0)
	{
		return;
	}
	
	// Sync current data
	for (NSUInteger section = 0; section < sectionCount; section++)
	{
        //combined dictionaries
        NSString *day = [self.sortedKeysInDateToCombinedDictionary objectAtIndex:section];
        NSMutableArray *events =  [self.dateToCombinedDictionary objectForKey:day];
        
        
		NSInteger eventCount = [events count];
		
		for (NSUInteger row = 0; row < eventCount; row++)
		{
			NSArray *schedules = [[events objectAtIndex:row] schedules];
			NSInteger scheduleCount = [schedules count];

			for (NSUInteger schedIdx = 0; schedIdx < scheduleCount; schedIdx++)
			{
				Schedule *schedule = [schedules objectAtIndex:schedIdx];

				NSUInteger idx;
				for (idx = 0; idx < myScheduleCount; idx++)
				{
					Schedule *selSchedule = [mySchedule objectAtIndex:idx];
					if ([selSchedule.ID isEqualToString:schedule.ID])
					{
						schedule.isSelected = YES;
						break;
					}
				}
				if(idx == myScheduleCount)
				{
					schedule.isSelected = NO;
				}
			}
		}
	}
}

- (void) calendarButtonTapped:(id)sender event:(id)touchEvent
{
    Schedule *schedule = [self getItemForSender:sender event:touchEvent];
    schedule.isSelected ^= YES;
    
    // Call to Appdelegate to Add/Remove from Calendar
    [delegate addOrRemoveScheduleToCalendar:schedule];
    [delegate addOrRemoveSchedule:schedule];
	
    [self syncTableDataWithScheduler];
    
    NSLog(@"Schedule:ItemID-ID:%@-%@", schedule.itemID, schedule.ID);
	
    UIButton *calendarButton = (UIButton*)sender;
    UIImage *buttonImage = (schedule.isSelected) ? [UIImage imageNamed:@"cal_selected.png"] : [UIImage imageNamed:@"cal_unselected.png"];
    [calendarButton setImage:buttonImage forState:UIControlStateNormal];
}

- (Schedule*) getItemForSender:(id)sender event:(id)touchEvent
{
    NSSet *touches = [touchEvent allTouches];
	UITouch *touch = [touches anyObject];
	CGPoint currentTouchPosition = [touch locationInView:self.eventsTableView];
	NSIndexPath *indexPath = [self.eventsTableView indexPathForRowAtPoint:currentTouchPosition];
	NSInteger row = [indexPath row];
	NSInteger section = [indexPath section];
    Schedule *schedule = nil;
    
    if (indexPath != nil)
	{
        //combined dictionary
        NSString *day = [self.sortedKeysInDateToCombinedDictionary objectAtIndex:section];
        
		NSDate *date = [self dateFromString:day];
        
        //combined dictionary
        Special *event = [[self.dateToCombinedDictionary objectForKey:day] objectAtIndex:row];
        
		for (schedule in event.schedules)
		{
            if ([self compareStartDate:schedule.startDate withSectionDate:date])
			{
				break;
			}
		}
    }
	
    return schedule;
}

//Returns result of comparision between the StartDate of Schedule
//with the SectionDate of tableview using Calendar Components Day-Month-Year
- (BOOL) compareStartDate:(NSDate *)startDate withSectionDate:(NSDate *)sectionDate
{
    //Compare Date using Day-Month-year components excluding the time
    NSCalendar *calendar = [NSCalendar currentCalendar];
    //removed year as a part of component here
    NSInteger components = (NSDayCalendarUnit | NSMonthCalendarUnit );
    
    NSDateComponents *date1Components = [calendar components:components fromDate: startDate];
    NSDateComponents *date2Components = [calendar components:components fromDate: sectionDate];
    
    startDate = [calendar dateFromComponents:date1Components];
    sectionDate = [calendar dateFromComponents:date2Components];
    
    return ([startDate compare:sectionDate] >= NSOrderedSame);
}

#pragma mark UITableView DataSource

- (NSInteger) numberOfSectionsInTableView:(UITableView *)tableView
{
    //combined dictionaries
    return [self.sortedKeysInDateToCombinedDictionary count];
}

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    //combined dictionaries
    NSString *day = [self.sortedKeysInDateToCombinedDictionary objectAtIndex:section];
    return [[self.dateToCombinedDictionary objectForKey:day] count];
}

- (UITableViewCell*) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	NSUInteger section = [indexPath section];
	NSUInteger row = [indexPath row];

    //combined dict.
    NSString *day = [self.sortedKeysInDateToCombinedDictionary objectAtIndex:section];
    
	NSDate *date = [self dateFromString:day];
    
    //combined dict.
    Special *event = [[self.dateToCombinedDictionary objectForKey:day] objectAtIndex:row];
    
	Schedule *schedule = nil;
	for (schedule in event.schedules) {
        
        if ([self compareStartDate:schedule.startDate withSectionDate:date]) {
			break;
		}
	}

	BOOL selected = NO;
	NSUInteger count = [mySchedule count];
	for(int idx = 0; idx < count; idx++)
	{
		Schedule *selSchedule = [mySchedule objectAtIndex:idx];
		if([schedule.ID isEqualToString:selSchedule.ID])
		{
			selected = YES;
			break;
		}
	}

	UIImage *buttonImage = selected ? [UIImage imageNamed:@"cal_selected.png"] : [UIImage imageNamed:@"cal_unselected.png"];
	UILabel *titleLabel = nil;
	UILabel *timeLabel = nil;
	UILabel *venueLabel = nil;
	UIButton *calendarButton = nil;
	
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kEventCellIdentifier];
    if (cell == nil)
	{
		cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:kEventCellIdentifier];
		cell.selectionStyle = UITableViewCellSelectionStyleNone;
		
		titleLabel = [UILabel new];
		titleLabel.tag = CELL_TITLE_LABEL_TAG;
        titleLabel.font = titleFont;
		[cell.contentView addSubview:titleLabel];
		
		timeLabel = [UILabel new];
		timeLabel.tag = CELL_TIME_LABEL_TAG;
        timeLabel.font = timeFont;
		[cell.contentView addSubview:timeLabel];
		
		venueLabel = [UILabel new];
		venueLabel.tag = CELL_VENUE_LABEL_TAG;
        venueLabel.font = venueFont;
		[cell.contentView addSubview:venueLabel];
		
		calendarButton = [UIButton buttonWithType:UIButtonTypeCustom];
		calendarButton.tag = CELL_LEFTBUTTON_TAG;
		[calendarButton addTarget:self action:@selector(calendarButtonTapped:event:) forControlEvents:UIControlEventTouchUpInside];
		[cell.contentView addSubview:calendarButton];
	}
	
	NSInteger titleNumLines = 1;
	titleLabel = (UILabel*)[cell viewWithTag:CELL_TITLE_LABEL_TAG];
	CGSize size = [event.name sizeWithAttributes:@{ NSFontAttributeName : titleFont }];
    if(size.width < 256.0)
    {
        [titleLabel setFrame:CGRectMake(52.0, 6.0, 256.0, 20.0)];
    }
    else
    {
        [titleLabel setFrame:CGRectMake(52.0, 6.0, 256.0, 42.0)];
        titleNumLines = 2;
    }
    
    [titleLabel setNumberOfLines:titleNumLines];
    titleLabel.text = event.name;
    
	timeLabel = (UILabel*)[cell viewWithTag:CELL_TIME_LABEL_TAG];
	[timeLabel setFrame:CGRectMake(52.0, titleNumLines == 1 ? 28.0 : 50.0, 250.0, 20.0)];
	timeLabel.text = [NSString stringWithFormat:@"%@ %@ - %@", schedule.dateString, schedule.startTime, schedule.endTime];
	
	venueLabel = (UILabel*)[cell viewWithTag:CELL_VENUE_LABEL_TAG];
	[venueLabel setFrame:CGRectMake(52.0, titleNumLines == 1 ? 46.0 : 68.0, 250.0, 20.0)];
	venueLabel.text = [NSString stringWithFormat:@"Venue: %@", schedule.venue];
	
	calendarButton = (UIButton*)[cell viewWithTag:CELL_LEFTBUTTON_TAG];
	[calendarButton setFrame:CGRectMake(8.0, titleNumLines == 1 ? 12.0 : 24.0, 40.0, 40.0)];
	[calendarButton setImage:buttonImage forState:UIControlStateNormal];
	
    return cell;
}

- (NSArray*) sectionIndexTitlesForTableView:(UITableView*)tableView
{
#pragma message "** OS bug **"
	// Temporary fix for crash in [self.filmsTableView reloadData] usually caused by Google+-related code
	// http://stackoverflow.com/questions/18918986/uitableview-section-index-related-crashes-under-ios-7
	// return nil;
	
    //combined dictionary
    return self.sortedIndexesInDateToCombinedDictionary;
}

- (UIView*) tableView:(UITableView*)tableView viewForHeaderInSection:(NSInteger)section
{
	CGFloat width = tableView.bounds.size.width - 17.0;
	CGFloat height = 24.0;
	
	UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, width, height)];
	view.userInteractionEnabled = NO;
	
	UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0.0, 0.0, width, height)];
	label.backgroundColor = [UIColor redColor];
	label.textColor = [UIColor whiteColor];
	label.font = sectionFont;
	[view addSubview:label];
   
    //combined dictionary
    label.text = [NSString stringWithFormat:@"  %@", [self.sortedKeysInDateToCombinedDictionary objectAtIndex:section]];
    
	return view;
}

#pragma mark UITableView delegate

- (CGFloat) tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
	return 0.01;		// This creates a "invisible" footer
}

- (CGFloat) tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
	return 28.0;
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	NSUInteger section = [indexPath section];
	NSUInteger row = [indexPath row];
    
    //combined dictionary
    NSString *day = [self.sortedKeysInDateToCombinedDictionary  objectAtIndex:section];
    
	NSDate *date = [self dateFromString:day];
  
    //combined dictionary
    Special *event = [[self.dateToCombinedDictionary objectForKey:day] objectAtIndex:row];
    
	for(Schedule *schedule in event.schedules)
	{
        if ([self compareStartDate:schedule.startDate withSectionDate:date])
		{
            
            //Send currently selected event to ScheduleDetailViewController.
            //old behavior used to send an eventid instead of sending
            //object directly.
            ScheduleDetailViewController *scheduleDetail = [[ScheduleDetailViewController alloc] initWithEvent:event];
            
			[self.navigationController pushViewController:scheduleDetail animated:YES];

			break;
		}
	}
}

- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
	NSUInteger section = [indexPath section];
	NSUInteger row = [indexPath row];
    
    //for combined dict.
    NSString *day = [self.sortedKeysInDateToCombinedDictionary objectAtIndex:section];
    Special *event = [[self.dateToCombinedDictionary objectForKey:day] objectAtIndex:row];
    
    CGSize size = [event.name sizeWithAttributes:@{ NSFontAttributeName : titleFont }];
    if(size.width >= 256.0)
    {
        return 90.0;
    }
    else
    {
        return 68.0;
    }
}

@end

