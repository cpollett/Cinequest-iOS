//
//  FilmsViewController.m
//  CineQuest
//
//  Created by Luca Severini on 10/1/13.
//  Copyright (c) 2013 San Jose State University. All rights reserved.
//
//  Edited by Karan Khare and Ramya Shenoy on 11/24/2014


#import "EventsViewController.h"
#import "EventDetailViewController.h"
#import "NewsViewController.h"
#import "FilmsViewController.h"
#import "FilmDetailViewController.h"
#import "CinequestAppDelegate.h"
#import "Schedule.h"
#import "DataProvider.h"
#import "Film.h"
#import "Festival.h"
#import "Special.h"


static NSString *const kDateCellIdentifier = @"DateCell";
static NSString *const kTitleCellIdentifier = @"TitleCell";
static NSString *const kEventCellIdentifier = @"EventCell";





@implementation UIView (private)

- (void) removeAnimationDidStop:(NSString *)animationID finished:(NSNumber *)finished context:(void *)context
{
    if ([animationID isEqualToString:@"fadeout"])
    {
        // Restore the opacity
        CGFloat originalOpacity = [(__bridge_transfer NSNumber *)context floatValue];
        self.layer.opacity = originalOpacity;
        
        [self removeFromSuperview];
    }
}

- (void) removeFromSuperviewAnimated
{
    [UIView beginAnimations:@"fadeout" context:(__bridge_retained void *)[NSNumber numberWithFloat:self.layer.opacity]];
    
    [UIView setAnimationDuration:1.0];
    [UIView setAnimationDidStopSelector:@selector(removeAnimationDidStop:finished:context:)];
    [UIView setAnimationDelegate:self];
    
    self.layer.opacity = 0;
    
    [UIView commitAnimations];
}

@end


@implementation FilmsViewController

@synthesize refreshControl;
@synthesize switchTitle;
@synthesize filmsTableView;
@synthesize activityIndicator;
@synthesize filmSearchBar;
@synthesize dateToFilmsDictionary;
@synthesize sortedKeysInDateToFilmsDictionary;
@synthesize sortedIndexesInDateToFilmsDictionary;
@synthesize alphabetToFilmsDictionary;
@synthesize sortedKeysInAlphabetToFilmsDictionary;
// Adding for Events segment
@synthesize eventsTableView;
@synthesize dateToEventsDictionary;
@synthesize sortedIndexesInDateToEventsDictionary;
@synthesize sortedKeysInDateToEventsDictionary;


#pragma mark - UIViewController Delegate methods

- (void) viewDidLoad
{
    [super viewDidLoad];
    
    delegate = appDelegate;
    mySchedule = delegate.mySchedule;
    cinequestCalendar = delegate.cinequestCalendar;
    eventStore = delegate.eventStore;
    
    dateDetector = [NSDataDetector dataDetectorWithTypes:NSTextCheckingTypeDate error:nil];
	  	
    titleFont = [UIFont boldSystemFontOfSize:[UIFont labelFontSize]];
    timeFont = [UIFont systemFontOfSize:[UIFont systemFontSize]];
    sectionFont = [UIFont boldSystemFontOfSize:18.0];
    venueFont = timeFont;
    
    self.searchDisplayController.searchResultsTableView.tableHeaderView = nil;
    self.searchDisplayController.searchResultsTableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    self.searchDisplayController.searchResultsTableView.sectionIndexColor = [UIColor redColor];
    
    [self setSearchKeyAsDone];
    
    NSDictionary *attribute = [NSDictionary dictionaryWithObject:[UIFont boldSystemFontOfSize:16.0f] forKey:NSFontAttributeName];
    [switchTitle setTitleTextAttributes:attribute forState:UIControlStateNormal];
    
    statusBarHidden = NO;
    
    refreshControl = [UIRefreshControl new];
    // refreshControl.attributedTitle = [[NSAttributedString alloc] initWithString:@"Updating Films..."];
    [refreshControl addTarget:self action:@selector(refresh) forControlEvents:UIControlEventValueChanged];
    [((UITableViewController*)self.filmsTableView.delegate) setRefreshControl:refreshControl];
    [self.filmsTableView addSubview:refreshControl];
    [self.eventsTableView addSubview:refreshControl];
    
    filmsTableView.tableHeaderView = nil;
    filmsTableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    
    eventsTableView.tableHeaderView = nil;
    eventsTableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
}

- (BOOL) prefersStatusBarHidden
{
    return statusBarHidden;
}

- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    self.dateToFilmsDictionary = [delegate.festival.dateToFilmsDictionary mutableCopy];
    self.sortedKeysInDateToFilmsDictionary = [delegate.festival.sortedKeysInDateToFilmsDictionary mutableCopy];
    self.sortedIndexesInDateToFilmsDictionary = [delegate.festival.sortedIndexesInDateToFilmsDictionary mutableCopy];
    self.alphabetToFilmsDictionary = [delegate.festival.alphabetToFilmsDictionary mutableCopy];
    self.sortedKeysInAlphabetToFilmsDictionary = [delegate.festival.sortedKeysInAlphabetToFilmsDictionary mutableCopy];
    
    
    // Properties declared for Events view of the Segmented Control
    self.dateToEventsDictionary = [delegate.festival.dateToSpecialsDictionary mutableCopy];
    self.sortedKeysInDateToEventsDictionary = [delegate.festival.sortedKeysInDateToSpecialsDictionary mutableCopy];
    self.sortedIndexesInDateToEventsDictionary = [delegate.festival.sortedIndexesInDateToSpecialsDictionary mutableCopy];
    
    
    
    
    [self syncTableDataWithScheduler];
    
    if(searchActive)
    {
        [self.searchDisplayController.searchResultsTableView reloadData];
    }
    else
    {
        [self.filmsTableView reloadData];
        [self.eventsTableView reloadData];
    }
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receivedNotification:) name:FEED_UPDATED_NOTIFICATION object:nil];
}

- (void) viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear: animated];
    
    self.dateToFilmsDictionary = nil;
    self.sortedKeysInDateToFilmsDictionary = nil;
    self.sortedIndexesInDateToFilmsDictionary = nil;
    self.alphabetToFilmsDictionary = nil;
    self.sortedKeysInAlphabetToFilmsDictionary = nil;
    // properties necessary for EventsViewController to be ported to this ViewController
    self.dateToEventsDictionary = nil;
    self.sortedKeysInDateToEventsDictionary = nil;
    self.sortedIndexesInDateToEventsDictionary = nil;
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear: animated];
    
    if([[NSUserDefaults standardUserDefaults] boolForKey:@"FilmsUpdated"])
    {
        [appDelegate showMessage:@"Films have been updated" onView:self.view hideAfter:3.0];
        
        [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"FilmsUpdated"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    //added for events data to populate
    if([[NSUserDefaults standardUserDefaults] boolForKey:@"EventsUpdated"])
    {
        [appDelegate showMessage:@"Events have been updated" onView:self.view hideAfter:3.0];
        
        [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"EventsUpdated"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
}

#pragma mark - Private methods

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
        
        [appDelegate showMessage:@"Films have been updated" onView:self.view hideAfter:3.0];
        
        [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"FilmsUpdated"];
        [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"EventsUpdated"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
}

- (void) updateDataAndTable
{
    if (switcher == VIEW_BY_FILMS) {
        self.dateToFilmsDictionary = [delegate.festival.dateToFilmsDictionary mutableCopy];
        self.sortedKeysInDateToFilmsDictionary = [delegate.festival.sortedKeysInDateToFilmsDictionary mutableCopy];
        self.sortedIndexesInDateToFilmsDictionary = [delegate.festival.sortedIndexesInDateToFilmsDictionary mutableCopy];
        self.alphabetToFilmsDictionary = [delegate.festival.alphabetToFilmsDictionary mutableCopy];
        self.sortedKeysInAlphabetToFilmsDictionary = [delegate.festival.sortedKeysInAlphabetToFilmsDictionary mutableCopy];
        
        [self.filmsTableView reloadData];
    } else {
        self.dateToEventsDictionary = [delegate.festival.dateToSpecialsDictionary mutableCopy];
        self.sortedKeysInDateToEventsDictionary = [delegate.festival.sortedKeysInDateToSpecialsDictionary mutableCopy];
        self.sortedIndexesInDateToEventsDictionary = [delegate.festival.sortedIndexesInDateToSpecialsDictionary mutableCopy];
        
        [self.eventsTableView reloadData];
    }
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

- (Schedule*) getItemForSender:(id)sender event:(id)touchEvent
{
    NSSet *touches = [touchEvent allTouches];
    UITouch *touch = [touches anyObject];
    CGPoint currentTouchPosition = [touch locationInView:self.filmsTableView];
    NSIndexPath *indexPath = [self.filmsTableView indexPathForRowAtPoint:currentTouchPosition];
    NSInteger row = [indexPath row];
    NSInteger section = [indexPath section];
    Schedule *schedule = nil;
    
    
    
    // Rearrange if blocks on the if(switcher == VIEW_BY_FILMS)
    // VIEW BY TITLE == VIEW BY FILMS
    if (indexPath != nil)
    {
        if(switcher == VIEW_BY_EVENTS) // VIEW_BY_DATE
        {
            NSString *day = [self.sortedKeysInDateToEventsDictionary  objectAtIndex:section];
            NSDate *date = [self dateFromString:day];
            
            Special *event = [[self.dateToEventsDictionary objectForKey:day] objectAtIndex:row];
            
            for (schedule in event.schedules)
            {
                if ([self compareStartDate:schedule.startDate withSectionDate:date])
                {
                    break;
                }
            }
            
        }
        else // VIEW_BY_FILMS
        {
            NSString *sort = [self.sortedKeysInAlphabetToFilmsDictionary objectAtIndex:section];
            NSArray *films = [self.alphabetToFilmsDictionary objectForKey:sort];
            Film *film = [films objectAtIndex:[indexPath row]];
            
            NSInteger index = [(UIButton*)sender tag] - CELL_LEFTBUTTON_TAG;
            if(index < [film.schedules count])
            {
                schedule = (Schedule*)[film.schedules objectAtIndex:index];
            }
        }
    }
    
    return schedule;
}

- (IBAction) switchTitle:(id)sender
{
    switcher = [sender selectedSegmentIndex];
    
    switch (switcher)
    {
            
            
        case VIEW_BY_FILMS:
            listByTitleOffset = [self.filmsTableView contentOffset].y;
            [self.filmsTableView setContentOffset:CGPointMake(0.0, listByDateOffset) animated:NO];
            break;
            
        case VIEW_BY_EVENTS:
            listByDateOffset = [self.filmsTableView contentOffset].y;
            [self.filmsTableView setContentOffset:CGPointMake(0.0, listByTitleOffset) animated:NO];
            break;
            
        default:
            break;
    }
    
    [self.filmsTableView reloadData];
}

- (void) showFilmDetails:(Schedule*)schedule
{
    FilmDetailViewController *filmDetail = [[FilmDetailViewController alloc] initWithFilm:schedule.itemID];
    [[self navigationController] pushViewController:filmDetail animated:YES];
}

- (void) syncTableDataWithScheduler
{
    [delegate populateCalendarEntries];
    
    NSInteger sectionCount = [self.sortedKeysInDateToFilmsDictionary count];
    NSInteger myScheduleCount = [mySchedule count];
    if(myScheduleCount == 0)
    {
        return;
    }
    
    for (NSUInteger section = 0; section < sectionCount; section++)
    {
        NSString *day = [self.sortedKeysInDateToFilmsDictionary objectAtIndex:section];
        NSMutableArray *films =  [self.dateToFilmsDictionary objectForKey:day];
        NSInteger filmCount = [films count];
        
        for (NSUInteger row = 0; row < filmCount; row++)
        {
            NSArray *schedules = [[films objectAtIndex:row] schedules];
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

// Returns result of comparision between the StartDate of Schedule
// with the SectionDate of tableview using Calendar Components Day-Month-Year
- (BOOL) compareStartDate:(NSDate *)startDate withSectionDate:(NSDate *)sectionDate
{
    NSCalendar *calendar = [NSCalendar currentCalendar];
    //removed year as a part of component here
    NSInteger components = (NSDayCalendarUnit | NSMonthCalendarUnit);
    
    NSDateComponents *date1Components = [calendar components:components fromDate: startDate];
    NSDateComponents *date2Components = [calendar components:components fromDate: sectionDate];
    
    startDate = [calendar dateFromComponents:date1Components];
    sectionDate = [calendar dateFromComponents:date2Components];
    
    return ([startDate compare:sectionDate] >= NSOrderedSame);
}

#pragma mark - UITableView Datasource methods

- (NSInteger) numberOfSectionsInTableView:(UITableView*)tableView
{
    switch(switcher)
    {
        case VIEW_BY_EVENTS:
            return [self.sortedKeysInDateToEventsDictionary count];
            break;
            
        case VIEW_BY_FILMS:
            return [self.sortedKeysInAlphabetToFilmsDictionary count];
            break;
            
        default:
            return 0;
            break;
    }
}

- (NSInteger) tableView:(UITableView*)tableView numberOfRowsInSection:(NSInteger)section
{
    switch(switcher)
    {
        case VIEW_BY_EVENTS:
        {
            NSString *day = [self.sortedKeysInDateToEventsDictionary objectAtIndex:section];
            return [[self.dateToEventsDictionary objectForKey:day] count];

        }
            break;
            
        case VIEW_BY_FILMS:
        {
            NSString *sort = [self.sortedKeysInAlphabetToFilmsDictionary objectAtIndex:section];
            return [[self.alphabetToFilmsDictionary objectForKey:sort] count];
        }
            break;
            
        default:
            return 0;
            break;
    }
}

- (UITableViewCell*) tableView:(UITableView*)tableView cellForRowAtIndexPath:(NSIndexPath*)indexPath
{
    NSUInteger section = [indexPath section];
    NSUInteger row = [indexPath row];
    UITableViewCell *cell = nil;
    
    switch(switcher)
    {
            
            /// Switched from VIEW_BY_DATE to VIEW_BY_EVENTS
        case VIEW_BY_EVENTS:
        {
            NSUInteger section = [indexPath section];
            NSUInteger row = [indexPath row];
            
            NSString *day = [self.sortedKeysInDateToEventsDictionary objectAtIndex:section];
            NSDate *date = [self dateFromString:day];
            
            Special *event = [[self.dateToEventsDictionary objectForKey:day] objectAtIndex:row];
            
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
            break;
            
            
            /// Switched from VIEW_BY_TITLE to VIEW_BY_FILMS
        case VIEW_BY_FILMS:
        {
            NSString *letter = [self.sortedKeysInAlphabetToFilmsDictionary objectAtIndex:section];
            NSArray *films = [self.alphabetToFilmsDictionary objectForKey:letter];
            Film *film = [films objectAtIndex:[indexPath row]];
            NSArray *schedules = film.schedules;
            
            NSInteger filmIdx = 0;
            
            cell = [tableView dequeueReusableCellWithIdentifier:kTitleCellIdentifier];
            if(cell == nil)
            {
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:kTitleCellIdentifier];
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
            }
            else
            {
                [[cell.contentView subviews] makeObjectsPerformSelector:@selector(removeFromSuperview)];
            }
            
            NSInteger titleNumLines = 1;
            CGSize size = [film.name sizeWithAttributes:@{ NSFontAttributeName : titleFont }];
            if(size.width >= 256.0)
            {
                titleNumLines = 2;
            }
            
            UILabel *titleLabel = [[UILabel alloc] initWithFrame:titleNumLines == 1 ? CGRectMake(52.0, 6.0, 256.0, 20.0) : CGRectMake(52.0, 6.0, 256.0, 42.0)];
            titleLabel.tag = CELL_TITLE_LABEL_TAG;
            [titleLabel setNumberOfLines:titleNumLines];
            titleLabel.font = titleFont;
            titleLabel.text = film.name;
            [cell.contentView addSubview:titleLabel];
            
            CGFloat hPos = titleNumLines == 1 ? 28.0 : 50.0;
            for(Schedule *schedule in schedules)
            {
                UILabel *timeLabel = [[UILabel alloc] initWithFrame:CGRectMake(52.0, hPos, 250.0, 20.0)];
                timeLabel.text = [NSString stringWithFormat:@"%@ %@ - %@", schedule.dateString, schedule.startTime, schedule.endTime];
                timeLabel.font = timeFont;
                timeLabel.tag = CELL_TIME_LABEL_TAG;
                [cell.contentView addSubview:timeLabel];
                
                UILabel *venueLabel = [[UILabel alloc] initWithFrame:CGRectMake(52.0, hPos + 18.0, 250.0, 20.0)];
                venueLabel.text = [NSString stringWithFormat:@"Venue: %@", schedule.venue];
                venueLabel.font = venueFont;
                venueLabel.tag = CELL_VENUE_LABEL_TAG;
                [cell.contentView addSubview:venueLabel];
                
                UIButton *calButton = [UIButton buttonWithType:UIButtonTypeCustom];
                calButton.frame = CGRectMake(11.0, hPos - 2.0, 40.0, 40.0);
                calButton.tag = CELL_LEFTBUTTON_TAG + filmIdx;
                UIImage *buttonImage = (schedule.isSelected) ? [UIImage imageNamed:@"cal_selected.png"] : [UIImage imageNamed:@"cal_unselected.png"];;
                [calButton setImage:buttonImage forState:UIControlStateNormal];
                [calButton addTarget:self action:@selector(calendarButtonTapped:event:) forControlEvents:UIControlEventTouchUpInside];
                [cell.contentView addSubview:calButton];
                
                hPos += 40.0;
                filmIdx++;
            }
        }
            break;
    }
    
    return cell;
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
    
    switch (switcher)
    {
            /// Switched from VIEW_BY_DATE to VIEW_BY_EVENTS
        case VIEW_BY_EVENTS:
            label.text = [NSString stringWithFormat:@"  %@", [self.sortedKeysInDateToFilmsDictionary objectAtIndex:section]];
            break;
            /// Switched from VIEW_BY_TITLE to VIEW_BY_FILMS
        case VIEW_BY_FILMS:
            label.text = [NSString stringWithFormat:@"  %@", [self.sortedKeysInAlphabetToFilmsDictionary objectAtIndex:section]];
            break;
    }
    
    return view;
}

- (NSArray*) sectionIndexTitlesForTableView:(UITableView*)tableView
{
    
#pragma message "** OS bug **"
    // Temporary fix for crash in [self.filmsTableView reloadData] usually caused by Google+-related code
    // http://stackoverflow.com/questions/18918986/uitableview-section-index-related-crashes-under-ios-7
    // return nil;
    
    switch (switcher)
    {
            /// Switched from VIEW_BY_DATE to VIEW_BY_EVENTS
        case VIEW_BY_EVENTS:
            return self.sortedIndexesInDateToEventsDictionary;
            break;
            /// Switched from VIEW_BY_TITLE to VIEW_BY_FILMS
        case VIEW_BY_FILMS:
            return self.sortedKeysInAlphabetToFilmsDictionary;
            break;
            
        default:
            return nil;
            break;
    }
}

#pragma mark - UITableView Delegate methods

- (CGFloat) tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 28.0;
}
- (CGFloat) tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 0.01;		// This creates a "invisible" footer
}
- (void) tableView:(UITableView*)tableView didSelectRowAtIndexPath:(NSIndexPath*)indexPath
{
    NSInteger section = [indexPath section];
    NSInteger row = [indexPath row];
    
    switch (switcher)
    {
            /// Switched from VIEW_BY_DATE to VIEW_BY_EVENTS
        case VIEW_BY_EVENTS:
        {
            NSString *day = [self.sortedKeysInDateToEventsDictionary  objectAtIndex:section];
            NSDate *date = [self dateFromString:day];
            
            Special *event = [[self.dateToEventsDictionary objectForKey:day] objectAtIndex:row];
            
            for(Schedule *schedule in event.schedules)
            {
                if ([self compareStartDate:schedule.startDate withSectionDate:date])
                {
                    EventDetailViewController *eventDetail = [[EventDetailViewController alloc] initWithEvent:schedule.itemID];
                    [self.navigationController pushViewController:eventDetail animated:YES];
                    
                    break;
                }
            }
        }
            break;
            
            /// Switched from VIEW_BY_TITLE to VIEW_BY_FILMS
        case VIEW_BY_FILMS:
        {
            NSString *sort = [self.sortedKeysInAlphabetToFilmsDictionary objectAtIndex:section];
            NSArray *films = [self.alphabetToFilmsDictionary objectForKey:sort];
            Film *film = [films objectAtIndex:[indexPath row]];
            
            Schedule *schedule = [film.schedules objectAtIndex:0];
            [self showFilmDetails:schedule];
        }
            break;
            
        default:
            break;
    }
}

- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSUInteger section = [indexPath section];
    NSUInteger row = [indexPath row];
    
    /// Switched from VIEW_BY_DATE to VIEW_BY_EVENTS
    if(switcher == VIEW_BY_EVENTS)
    {
        NSString *day = [self.sortedKeysInDateToEventsDictionary  objectAtIndex:section];
        Special *event = [[self.dateToEventsDictionary objectForKey:day] objectAtIndex:row];
        
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
    else // VIEW_BY_FILMS
    {
        NSString *sort = [self.sortedKeysInAlphabetToFilmsDictionary objectAtIndex:section];
        NSArray *films = [self.alphabetToFilmsDictionary objectForKey:sort];
        Film *film = [films objectAtIndex:[indexPath row]];
        
        CGSize size = [film.name sizeWithAttributes:@{ NSFontAttributeName : titleFont }];
        if(size.width >= 256.0)
        {
            return 52.0 + (40.0 * film.schedules.count);
        }
        else
        {
            return 30.0 + (40.0 * film.schedules.count);
        }
    }
}

#pragma mark - Content Filtering methods

- (void) filterContentForSearchText:(NSString*)searchText scope:(NSString*)scope
{
    
    /// Switched from VIEW_BY_DATE to VIEW_BY_EVENTS
    if(switcher == VIEW_BY_EVENTS)
    {
        self.sortedKeysInDateToFilmsDictionary = [delegate.festival.sortedKeysInDateToFilmsDictionary mutableCopy];
        self.sortedIndexesInDateToFilmsDictionary = [self sortedIndexesFromSortedKeys:sortedKeysInDateToFilmsDictionary];
        self.dateToFilmsDictionary = [delegate.festival.dateToFilmsDictionary mutableCopy];
    }
    else // VIEW_BY_TITLE
    {
        self.sortedKeysInAlphabetToFilmsDictionary = [delegate.festival.sortedKeysInAlphabetToFilmsDictionary mutableCopy];
        self.alphabetToFilmsDictionary = [delegate.festival.alphabetToFilmsDictionary mutableCopy];
    }
    
    if(searchText.length != 0)
    {
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF.name contains[c] %@", searchText];
        NSMutableArray *keysToDelete = [NSMutableArray new];
        
        
        /// Switched from VIEW_BY_DATE to VIEW_BY_EVENTS
        if(switcher == VIEW_BY_EVENTS)
        {
            for(NSString *day in self.sortedKeysInDateToFilmsDictionary)
            {
                NSArray *films = [self.dateToFilmsDictionary objectForKey:day];
                NSArray *foundFilms = [NSMutableArray arrayWithArray:[films filteredArrayUsingPredicate:predicate]];
                if(films.count != foundFilms.count)
                {
                    if(foundFilms.count == 0)
                    {
                        [keysToDelete addObject:day];
                        
                        [self.dateToFilmsDictionary removeObjectForKey:day];
                    }
                    else
                    {
                        [self.dateToFilmsDictionary setObject:foundFilms forKey:day];
                    }
                }
            }
            
            [self.sortedKeysInDateToFilmsDictionary removeObjectsInArray:keysToDelete];
            
            self.sortedIndexesInDateToFilmsDictionary = [self sortedIndexesFromSortedKeys:sortedKeysInDateToFilmsDictionary];
        }
        else	// VIEW_BY_FILMS
        {
            for(NSString *letter in self.sortedKeysInAlphabetToFilmsDictionary)
            {
                NSArray *films = [self.alphabetToFilmsDictionary objectForKey:letter];
                NSArray *foundFilms = [NSMutableArray arrayWithArray:[films filteredArrayUsingPredicate:predicate]];
                if(films.count != foundFilms.count)
                {
                    if(foundFilms.count == 0)
                    {
                        [keysToDelete addObject:letter];
                        [self.alphabetToFilmsDictionary removeObjectForKey:letter];
                    }
                    else
                    {
                        [self.alphabetToFilmsDictionary setObject:foundFilms forKey:letter];
                    }
                }
            }
            
            [self.sortedKeysInAlphabetToFilmsDictionary removeObjectsInArray:keysToDelete];
        }
    }
    
    [self.filmsTableView reloadData];
}

#pragma mark - UISearchDisplayController Delegate methods

-(BOOL) searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString
{
    if([searchString caseInsensitiveCompare:@"CS175"] == NSOrderedSame)
    {
        UIImageView *teamView = [[UIImageView alloc] initWithImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"team" ofType:@"png"]]];
        teamView.userInteractionEnabled = YES;
        teamView.contentMode = UIViewContentModeCenter;
        [teamView setFrame:appDelegate.window.frame];
        
        UITapGestureRecognizer *tappedImage = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(imageTouched:)];
        tappedImage.numberOfTapsRequired = 1;
        [teamView addGestureRecognizer:tappedImage];
        
        self.filmSearchBar.text = @"";
        [self.view endEditing:YES];
        [self.filmSearchBar resignFirstResponder];
        
        statusBarHidden = YES;
        [self prefersStatusBarHidden];
        [self setNeedsStatusBarAppearanceUpdate];
        
        teamView.alpha = 0.0;
        [appDelegate.window addSubview:teamView];
        [UIView animateWithDuration:1.0
                         animations:^
         {
             teamView.alpha = 1.0;
         }
                         completion:(void (^)(BOOL finished))^
         {
         }];
        
        return NO;
    }
    
    [self filterContentForSearchText:searchString scope:[[self.searchDisplayController.searchBar scopeButtonTitles] objectAtIndex:[self.searchDisplayController.searchBar selectedScopeButtonIndex]]];
    
    // Return YES to cause the search result table view to be reloaded.
    return YES;
}

- (void) setSearchKeyAsDone
{
    for (UIView *subview in self.filmSearchBar.subviews)
    {
        for (UIView *subSubview in subview.subviews)
        {
            if ([subSubview conformsToProtocol:@protocol(UITextInputTraits)])
            {
                UITextField *textField = (UITextField *)subSubview;
                textField.returnKeyType = UIReturnKeyDone;
                break;
            }
        }
    }
}

- (void) searchBarCancelButtonClicked:(UISearchBar *)searchBar
{
    /// Switched from VIEW_BY_DATE to VIEW_BY_EVENTS
    if(switcher == VIEW_BY_EVENTS)
    {
        self.sortedKeysInDateToFilmsDictionary = [delegate.festival.sortedKeysInDateToFilmsDictionary mutableCopy];
        self.sortedIndexesInDateToFilmsDictionary = [self sortedIndexesFromSortedKeys:self.sortedKeysInDateToFilmsDictionary];
        self.dateToFilmsDictionary = [delegate.festival.dateToFilmsDictionary mutableCopy];
    }
    else // VIEW_BY_TITLE
    {
        self.sortedKeysInAlphabetToFilmsDictionary = [delegate.festival.sortedKeysInAlphabetToFilmsDictionary mutableCopy];
        self.alphabetToFilmsDictionary = [delegate.festival.alphabetToFilmsDictionary mutableCopy];
    }
    
    [self.filmsTableView setSectionIndexMinimumDisplayRowCount:0];
    [self.filmsTableView reloadData];
}

- (void) searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    [searchBar resignFirstResponder];
    
    [self.view endEditing:YES];
}

- (BOOL) searchBarShouldBeginEditing:(UISearchBar *)searchBar
{
    return YES;
}

- (void) searchDisplayControllerDidBeginSearch:(UISearchDisplayController *)controller
{
    [self.searchDisplayController.searchResultsTableView setSectionIndexColor:[UIColor redColor]];
    
    searchActive = YES;
}

- (void) searchDisplayControllerDidEndSearch:(UISearchDisplayController *)controller
{
    searchActive = NO;
}

- (NSMutableArray*) sortedIndexesFromSortedKeys:(NSMutableArray*)sortedKeysArray
{
    NSMutableArray *sortedIndexes = [NSMutableArray new];
    for(NSString *date in sortedKeysArray)
    {
        [sortedIndexes addObject:[[date componentsSeparatedByString:@" "] objectAtIndex: 2]];
    }
    
    return sortedIndexes;
}

#pragma mark - Action methods

- (void) calendarButtonTapped:(id)sender event:(id)touchEvent
{
    Schedule *schedule = [self getItemForSender:sender event:touchEvent];
    schedule.isSelected ^= YES;
    
    // Call to Appdelegate to Add/Remove from Calendar
    [delegate addOrRemoveScheduleToCalendar:schedule];
    [delegate addOrRemoveSchedule:schedule];
    
    [self syncTableDataWithScheduler];
    
    // NSLog(@"Schedule:ItemID-ID:%@-%@", schedule.itemID, schedule.ID);
    
    UIButton *calendarButton = (UIButton*)sender;
    UIImage *buttonImage = (schedule.isSelected) ? [UIImage imageNamed:@"cal_selected.png"] : [UIImage imageNamed:@"cal_unselected.png"];
    [calendarButton setImage:buttonImage forState:UIControlStateNormal];
}

- (void) imageTouched:(id)sender
{
    UITapGestureRecognizer *gesture = (UITapGestureRecognizer*)sender;
    
    [gesture.view removeFromSuperviewAnimated];
    
    statusBarHidden = NO;
    [self prefersStatusBarHidden];
    [self setNeedsStatusBarAppearanceUpdate];
}

@end



