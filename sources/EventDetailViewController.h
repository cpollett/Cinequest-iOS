//
//  EventDetailViewController.h
//  CineQuest
//
//  Created by Luca Severini on 10/1/13.
//  Copyright (c) 2013 San Jose State University. All rights reserved.
//  Renamed 2015 Chris Pollett
//


@class Special;
@class Schedule;
@class CinequestAppDelegate;

@interface EventDetailViewController : UIViewController <UIWebViewDelegate, MFMailComposeViewControllerDelegate, MFMessageComposeViewControllerDelegate, UIAlertViewDelegate, GPPSignInDelegate, GPPShareDelegate>
{
	CinequestAppDelegate *delegate;
	NSMutableArray *mySchedule;
	UIFont *timeFont;
	UIFont *venueFont;
	UIFont *sectionFont;
	UIFont *actionFont;
	NSInteger googlePlusConnectionDone;
	BOOL viewWillDisappear;
}

@property (nonatomic, strong) IBOutlet UIWebView *webView;
@property (nonatomic, strong) IBOutlet UITableView *detailTableView;
@property (nonatomic, strong) IBOutlet UIActivityIndicatorView *activityIndicator;

@property (nonatomic, strong) Special *event;

- (id) initWithEventID:(NSString*)eventId;
- (id) initWithEvent:(Special*)evnt;

@end
