//
//  MSViewController.m
//  MSRefreshControlDemo
//
//  Created by Maksym Skliarov on 2/14/14.
//  Copyright (c) 2014 Maksym Skliarov. All rights reserved.
//

#import "MSViewController.h"

@interface MSViewController ()
@property (nonatomic) BOOL isReloadingDataSource;
@end

@implementation MSViewController




#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Add pull-to-refresh
    self.refreshControl = [[MSRefreshControl alloc] initWithFrame:CGRectMake(0.0f, 0.0f - self.tableView.bounds.size.height, self.view.frame.size.width, self.tableView.bounds.size.height)];
    self.refreshControl.delegate = self;
    [self.tableView addSubview:self.refreshControl];
}

- (void)didUpdateDataSource
{
    self.isReloadingDataSource = NO;
    [self.tableView reloadData];
    [self.refreshControl dataSourceDidFinishLoading:self.tableView];
}




#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    
	[self.refreshControl scrollViewDidScroll:scrollView];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    
	[self.refreshControl scrollViewDidEndDragging:scrollView];
}




#pragma mark - MSRefreshControlDelegate

- (void)tableHeaderDidTriggerRefresh:(MSRefreshControl*)view
{
    self.isReloadingDataSource = YES;
    [self performSelector:@selector(didUpdateDataSource) withObject:nil afterDelay:2.0];
}

- (BOOL)tableDataSourceIsLoading:(MSRefreshControl*)view
{
    return self.isReloadingDataSource;
}




#pragma mark - Table View Data Source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 20;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
    cell.textLabel.text = [NSString stringWithFormat:@"%d", (int)arc4random()%1000];
    return cell;
}




@end