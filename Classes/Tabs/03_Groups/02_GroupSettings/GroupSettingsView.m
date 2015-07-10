//
// Copyright (c) 2015 Related Code - http://relatedcode.com
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

#import <Parse/Parse.h>
#import "ProgressHUD.h"
#import "PFUser+Util.h"

#import "AppConstant.h"
#import "recent.h"

#import "GroupSettingsView.h"
#import "ChatView.h"
#import "ProfileView.h"

//-------------------------------------------------------------------------------------------------------------------------------------------------
@interface GroupSettingsView()
{
	PFObject *group;
	NSMutableArray *users;
}

@property (strong, nonatomic) IBOutlet UITableViewCell *cellName;

@property (strong, nonatomic) IBOutlet UILabel *labelName;

@end
//-------------------------------------------------------------------------------------------------------------------------------------------------

@implementation GroupSettingsView

@synthesize cellName;
@synthesize labelName, bannerView;

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (id)initWith:(PFObject *)group_
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	self = [super init];
	group = group_;
	return self;
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)viewDidLoad
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	[super viewDidLoad];
	self.title = @"Group Settings";
	//---------------------------------------------------------------------------------------------------------------------------------------------
	users = [[NSMutableArray alloc] init];
	//---------------------------------------------------------------------------------------------------------------------------------------------
    self.tableView.tableHeaderView = bannerView;
	[self loadGroup];
	[self loadUsers];
}


-(void) viewWillAppear:(BOOL)animated
{
    [self adBanner];
}

-(void)adBanner
{
    self.bannerView.adUnitID = @"ca-app-pub-4886788404179515/8149650981";
    self.bannerView.rootViewController = self;
    [self.bannerView loadRequest:[GADRequest request]];
}
#pragma mark - Backend actions

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)loadGroup
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	labelName.text = group[PF_GROUP_NAME];
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)loadUsers
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	PFQuery *query = [PFQuery queryWithClassName:PF_USER_CLASS_NAME];
	[query whereKey:PF_USER_OBJECTID containedIn:group[PF_GROUP_MEMBERS]];
	[query orderByAscending:PF_USER_FULLNAME_LOWER];
	[query setLimit:1000];
	[query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error)
	{
		if (error == nil)
		{
			[users removeAllObjects];
			[users addObjectsFromArray:objects];
			[self.tableView reloadData];
		}
		else [ProgressHUD showError:@"Network error."];
	}];
}

#pragma mark - User actions

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)actionChat
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	NSString *groupId = group.objectId;
	//---------------------------------------------------------------------------------------------------------------------------------------------
	StartGroupChat(group, users);
	//---------------------------------------------------------------------------------------------------------------------------------------------
	ChatView *chatView = [[ChatView alloc] initWith:groupId];
	[self.navigationController pushViewController:chatView animated:YES];
}

#pragma mark - Table view data source

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	return 2;
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	if (section == 0) return 1;
	if (section == 1) return [users count];
	return 0;
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	if (section == 1) return @"Members";
	return nil;
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	if ((indexPath.section == 0) && (indexPath.row == 0)) return cellName;
	//---------------------------------------------------------------------------------------------------------------------------------------------
	if (indexPath.section == 1)
	{
		UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
		if (cell == nil) cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"cell"];

		PFUser *user = users[indexPath.row];
		cell.textLabel.text = user[PF_USER_FULLNAME];

		return cell;
	}
	return nil;
}

#pragma mark - Table view delegate

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
	//---------------------------------------------------------------------------------------------------------------------------------------------
	if ((indexPath.section == 0) && (indexPath.row == 0)) [self actionChat];
	//---------------------------------------------------------------------------------------------------------------------------------------------
	if (indexPath.section == 1)
	{
		PFUser *user = users[indexPath.row];
		if ([user isEqualTo:[PFUser currentUser]] == NO)
		{
			ProfileView *profileView = [[ProfileView alloc] initWith:nil User:user];
			[self.navigationController pushViewController:profileView animated:YES];
		}
	}
}

@end
