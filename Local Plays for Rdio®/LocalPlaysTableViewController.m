//
//  LocalPlaysTableViewController.m
//  Local Plays for Rdio®
//
//  Created by Fosco Marotto on 3/30/13.
//  Copyright (c) 2013 Parse. All rights reserved.
//

#import "LocalPlaysTableViewController.h"
#import "RdioSearchResultsTableViewController.h"

@interface LocalPlaysTableViewController ()

@end

@implementation LocalPlaysTableViewController

@synthesize tableData, headerView, searchValue, rdio, searchResults, geopoint;

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    headerView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 320.0f, 88.0f)];
    headerView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"headerBackground"]];
    
    UIButton *searchButton = [UIButton buttonWithType:UIButtonTypeCustom];
    searchButton.frame = CGRectMake(263.0f,26.0f,57.0f,57.0f);
    [searchButton setBackgroundImage:[UIImage imageNamed:@"searchButton"] forState:UIControlStateNormal];
    [searchButton addTarget:self action:@selector(didTapSearch:) forControlEvents:UIControlEventTouchUpInside];
    [headerView addSubview:searchButton];
    
    UITextField *searchText = [[UITextField alloc] initWithFrame:CGRectMake(10.0f, 30.0f, 240.0f, 42.0f)];
    searchText.backgroundColor = [UIColor clearColor];
    searchText.placeholder = @"Search for a track to play";
    searchText.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
    searchText.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    searchText.tag = 9001;

    [headerView addSubview:searchText];
    
    self.tableView.tableHeaderView = headerView;

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    NSLog(@"Local Plays View Appearing");
    [self.tableView reloadData];
    [self.tableView updateConstraints];
}

- (void)didTapSearch:(id)sender {
    NSLog(@"Did tap search..");
    UITextField *searchTextField = (UITextField *)[self.headerView viewWithTag:9001];
    [searchTextField resignFirstResponder];
    NSString *searchText = searchTextField.text;
    searchTextField.text = @"";
    if (searchText.length > 3) {
        [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        searchValue = searchText;
        //NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:searchValue, @"query", @"Track", @"types", @"20", @"count", nil];
        NSLog(@"Calling Rdio API search");
        [rdio callAPIMethod:@"search" withParameters:@{@"query":searchValue,@"types":@"Track",@"count":@"20"} delegate:self];
    } else {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Local Plays" message:@"Search string must be at least 4 characters." delegate:self cancelButtonTitle:@"Okay" otherButtonTitles:nil];
        [alert show];
    }
}

- (void)rdioRequest:(RDAPIRequest *)request didLoadData:(id)data {
    NSLog(@"Returned from API Call to Rdio");
    NSLog(@"%@",data);
    searchResults = (NSArray *)[(NSDictionary *)data objectForKey:@"results"];
    [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
    [self performSegueWithIdentifier:@"mainToSearch" sender:self];
}

- (void)rdioRequest:(RDAPIRequest *)request didFailWithError:(NSError *)error {
    NSLog(@"%@",error);
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    RdioSearchResultsTableViewController *resultsController = (RdioSearchResultsTableViewController *)segue.destinationViewController;
    resultsController.searchResults = searchResults;
    resultsController.rdio = rdio;
    resultsController.geopoint = geopoint;
    resultsController.tableData = tableData;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSLog(@"Asked for COUNT");
    return tableData.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    //NSLog(@"%@",indexPath);
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    cell.backgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"cellBg"]];
        
    PFObject *cellData = [tableData objectAtIndex:indexPath.row];
    NSURL *url = [NSURL URLWithString:[cellData objectForKey:@"icon"]];
    UIImageView *thumb = (UIImageView *)[cell viewWithTag:1];
    thumb.image = nil;
    
    [thumb setImageWithURL:url];
    
    UILabel *trackLabel = (UILabel *)[cell viewWithTag:2];
    UILabel *artistLabel = (UILabel *)[cell viewWithTag:3];
    trackLabel.text = @"";
    artistLabel.text = @"";
    trackLabel.text = [cellData objectForKey:@"name"];
    artistLabel.text = [cellData objectForKey:@"artist"];
    
    return cell;
}



#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary *cellData = [tableData objectAtIndex:indexPath.row];
    [rdio.player playSource:[cellData objectForKey:@"sourceKey"]];

}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    return 80.0f;
}

@end
