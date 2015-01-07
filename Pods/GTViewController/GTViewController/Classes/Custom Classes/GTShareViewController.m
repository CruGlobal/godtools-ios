//
//  GTShareViewController.m
//  GTViewController
//
//  Created by Michael Harrison on 5/20/14.
//  Copyright (c) 2014 Michael Harrison. All rights reserved.
//

#import "GTShareViewController.h"

#import "SSCWhatsAppActivity.h"

NSString *const GTShareViewControllerCampaignLinkCampaignSource        = @"godtools-ios";
NSString *const GTShareViewControllerCampaignLinkCampaignMedium        = @"email";
NSString *const GTShareViewControllerCampaignLinkCampaignName          = @"app-sharing";

@interface GTShareViewController ()

@end

@implementation GTShareViewController

- (instancetype)init {
	
	NSString *campaignLink				= [self produceLinkForCampaign: GTShareViewControllerCampaignLinkCampaignName source:GTShareViewControllerCampaignLinkCampaignSource medium:GTShareViewControllerCampaignLinkCampaignMedium];
	
	SSCWhatsAppActivity *whatsAppActivity	= [[SSCWhatsAppActivity alloc] init];
	
	self = [super initWithActivityItems:@[[NSURL URLWithString:campaignLink]] applicationActivities:@[whatsAppActivity]];
    self.excludedActivityTypes = [[NSArray alloc]init];
	if (self) {

		self.excludedActivityTypes	= @[//UIActivityTypePostToFacebook,
										//UIActivityTypePostToTwitter,
										//UIActivityTypePostToWeibo,
										//UIActivityTypeMessage,
										//UIActivityTypeMail,
										UIActivityTypePrint,
										//UIActivityTypeCopyToPasteboard,
										//UIActivityTypeAssignToContact,
										//UIActivityTypeSaveToCameraRoll,
										/////////UIActivityTypeAddToReadingList,    //iOS7
										/////////UIActivityTypePostToFlickr,        //iOS7
										////////UIActivityTypePostToVimeo,          //iOS7
										//UIActivityTypePostToTencentWeibo,         //iOS7
										/////////UIActivityTypeAirDrop              //iOS7
										];
        if(([[[UIDevice currentDevice] systemVersion] compare:@"7.0" options:NSNumericSearch] != NSOrderedAscending)){//if version is greater than or equal to 7.0
            
             NSMutableArray* excludedActivityForEqualOrGreaterThaniOS7 = [[NSMutableArray alloc]initWithArray:@[
                                                                                                                UIActivityTypeAddToReadingList,
                                                                                                                UIActivityTypePostToFlickr,UIActivityTypePostToVimeo,
                                                                                                                //UIActivityTypePostToTencentWeibo,
                                                                                                                UIActivityTypeAirDrop]];

            
            [excludedActivityForEqualOrGreaterThaniOS7 addObjectsFromArray:self.excludedActivityTypes];
            self.excludedActivityTypes = [NSArray arrayWithArray:excludedActivityForEqualOrGreaterThaniOS7];
        }
		
	}
	
	return self;
}

- (NSString *)produceShareLink {
	
	return [NSString stringWithFormat:@"http://www.godtoolsapp.com"];
}

- (NSString *)produceLinkForCampaign:(NSString *)campaign source:(NSString *)source medium:(NSString *)medium {
	
	NSString *appVersionNumber	= [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"];
	
	return [self.produceShareLink stringByAppendingFormat:@"?utm_source=%@&utm_medium=%@&utm_content=%@&utm_campaign=%@", source, medium, appVersionNumber, campaign];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
