//
//  HotPicksViewController.h
//  CineQuest
//
//  Converted from by Chris Pollett NewsViewController
//  Copyright (c) 2015 San Jose State University. All rights reserved.
//

@interface HotPicksViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, UIWebViewDelegate>
{
	UIFont *titleFont;
    NSInteger switcher;
	BOOL tabBarAnimation;
}
@property (nonatomic, strong) IBOutlet UITableView *hotPicksTableView;
@property (nonatomic, strong) IBOutlet UIActivityIndicatorView *activityIndicator;
@property (nonatomic, strong) IBOutlet UISegmentedControl *switchTitle;

@property (nonatomic, strong) UIRefreshControl *refreshControl;
@property (nonatomic, strong) NSMutableArray *feed;

- (IBAction) switchTitle:(id)sender;
@end
