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

#import "AppConstant.h"

#import "report.h"

//-------------------------------------------------------------------------------------------------------------------------------------------------
void ReportUser(PFUser *user2)
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	PFUser *user1 = [PFUser currentUser];

	PFQuery *query = [PFQuery queryWithClassName:PF_REPORT_CLASS_NAME];
	[query whereKey:PF_REPORT_USER1 equalTo:user1];
	[query whereKey:PF_REPORT_USER2 equalTo:user2];
	[query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error)
	{
		if (error == nil)
		{
			if ([objects count] == 0)
			{
				PFObject *object = [PFObject objectWithClassName:PF_REPORT_CLASS_NAME];
				object[PF_REPORT_USER1] = user1;
				object[PF_REPORT_USER2] = user2;
				[object saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error)
				{
					if (error == nil)
					{
						[ProgressHUD showSuccess:@"User reported."];
					}
					else NSLog(@"ReportUser save error.");
				}];
			}
			else [ProgressHUD showError:@"User already reported."];
		}
		else NSLog(@"ReportUser query error.");
	}];
}
