//
//  MSViewController.h
//  MSRefreshControlDemo
//
//  Created by Maksym Skliarov on 2/14/14.
//  Copyright (c) 2014 Maksym Skliarov. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MSRefreshControl.h"

@interface MSViewController : UIViewController <UITableViewDataSource, MSRefreshControlDelegate>

// Outlets
@property (weak, nonatomic) IBOutlet UITableView *tableView;

// Properties
@property (nonatomic, strong) MSRefreshControl *refreshControl;

@end