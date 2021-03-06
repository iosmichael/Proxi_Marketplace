//
//  OrderDetailTableViewController.m
//  ProxiFinal
//
//  Created by Michael Liu on 11/25/15.
//  Copyright © 2015 Michael Liu. All rights reserved.
//
#import "OrderConnection.h"
#import "OrderDetailTableViewController.h"
#import "HHAlertView.h"
#import "RefundViewController.h"
#import "ChatViewController.h"
#define Screen_width [[UIScreen mainScreen]bounds].size.width

@interface OrderDetailTableViewController ()<HHAlertViewDelegate>

@property (strong,nonatomic) UIViewController *presentedModalView;
@end

@implementation OrderDetailTableViewController{
    NSInteger numbersOfOrderDaysBeforeRefund;
    UIView *titleView;
    UIView *priceTitleView;
    CGSize descSize;
    UIView *personDetailView;
    UIView *descView;
    NSDate *order_date;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"regularTableViewCell"];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.allowsSelection = NO;
    numbersOfOrderDaysBeforeRefund = 10;
    [self.tableView setBackgroundView:nil];
    [[HHAlertView shared]setDelegate:self];

    self.presentedModalView = [[UIViewController alloc]init];
    self.presentedModalView.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    self.presentedModalView.modalPresentationStyle = UIModalPresentationOverCurrentContext;
    self.presentedModalView.view.backgroundColor = [UIColor colorWithWhite:0.0 alpha:0.7];
    [self setupElements];
    [self refundButtonEligibility];
    
}
-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    self.navigationController.navigationBarHidden = NO;
}
-(void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
    [[NSNotificationCenter defaultCenter]removeObserver:self];
}

-(void)refresh{
    [self.item_image setImage:[UIImage imageWithData:self.order.img_data]];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#pragma mark- Table View Datasource & Table View Delegate

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    [self.tableView dequeueReusableCellWithIdentifier:@"regularTableViewCell"];
    UITableViewCell *cell = [[UITableViewCell alloc]init];
    switch (indexPath.section) {
            
        case 0:
            [cell.contentView addSubview:self.item_image];
            break;
        case 1:
            [cell.contentView addSubview:priceTitleView];
            break;
        case 2:
            [cell.contentView addSubview:descView];
            break;
        case 3:
             [cell.contentView addSubview:personDetailView];
            break;
        default:
            break;
    }
    
    return cell;
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    switch (indexPath.section) {
            
        case 0:
            return Screen_width*0.9+10;
            break;
        case 1:
            return 120;
            break;
        case 2:
            return descSize.height+50;
            break;
        default:
            return 70;
            break;
    }
    
    
    return 0;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 1;
}
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 4;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    switch (section) {
        case 1:
            return 35;
            break;
        case 2:
            return 2;
            break;
        case 3:
            return 2;
            break;
        default:
            return 0;
            break;
    }
}
-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    if(section==1) {
        UIView *dateView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, Screen_width, 33)];
        dateView.backgroundColor = [UIColor whiteColor];
        UIImageView *imageView = [[UIImageView alloc]initWithFrame:CGRectMake(Screen_width-158, 5, 33, 33)];
        [imageView setImage:[UIImage imageNamed:@"Time"]];
        [dateView addSubview:imageView];
        [dateView addSubview:self.item_post_time];
        return dateView;
    }else{
        return nil;
    }
}


#pragma mark- Setup Elements

-(void)setupElements{
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(refresh) name:@"RefreshTableNotification" object:nil];
    UIImage *image = [self resizeImage:[UIImage imageNamed:@"Proxi Logo.png"] toSize:CGSizeMake(90, 35)];
    UIImageView *imageView = [[UIImageView alloc]initWithImage:image];
    self.navigationItem.titleView = imageView;
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    [self.navigationController.navigationBar
     setTitleTextAttributes:@{NSFontAttributeName:[UIFont fontWithName:@"Gotham-Book" size:25],NSForegroundColorAttributeName : [UIColor whiteColor]}];
    [self setupTime];
    [self setupItemInfo];
    [self setupPersonInfo];
}

-(void)setupTime{
    self.item_post_time = [[UILabel alloc]initWithFrame:CGRectMake(Screen_width-125,0, 105, 33)];
    /*date Formatter*/
    NSDateFormatter *dateFormatter=[[NSDateFormatter alloc]init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSDate *date=[dateFormatter dateFromString:self.order.order_date];
    order_date = date;
    NSLocale *usLocale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US"];
    [dateFormatter setLocale:usLocale];
    dateFormatter.timeStyle = NSDateFormatterNoStyle;
    dateFormatter.dateStyle = NSDateFormatterMediumStyle;
    NSString *dateStr=[dateFormatter stringFromDate:date];
    self.item_post_time.text = dateStr;
}
-(void)setupItemInfo{
    UIImageView *titleIcon = [[UIImageView alloc]initWithFrame:CGRectMake(15, 15, 40, 40)];
    self.item_title = [[UILabel alloc]initWithFrame:CGRectMake(75, 20, Screen_width-15, 25)];
    self.item_title.numberOfLines = 0;
    self.item_title.adjustsFontSizeToFitWidth = YES;
    NSAttributedString *titleStr =[[NSAttributedString alloc]initWithString:self.order.item_title attributes:@{NSFontAttributeName : [UIFont fontWithName:@"Gotham-Light" size:18]}];
    self.item_title.attributedText = titleStr;
    [titleIcon setImage:[UIImage imageNamed:@"gift"]];
    UIImageView *priceIcon = [[UIImageView alloc]initWithFrame:CGRectMake(15, 65, 40, 40)];
    [priceIcon setImage:[UIImage imageNamed:@"vemo"]];
    self.item_current_price = [[UILabel alloc]initWithFrame:CGRectMake(75, 70, Screen_width-15, 25)];
    NSAttributedString *priceStr =[[NSAttributedString alloc]initWithString:[@"$ " stringByAppendingString:self.order.order_price] attributes:@{NSFontAttributeName : [UIFont fontWithName:@"Gotham-Light" size:19]}];
    self.item_current_price.attributedText = priceStr;
    UIButton *refundButton = [[UIButton alloc]initWithFrame:CGRectMake(Screen_width-15-116, 70, 116, 22)];
    [refundButton setImage:[UIImage imageNamed:@"refundCode"] forState:UIControlStateDisabled];
    [refundButton setImage:[UIImage imageNamed:@"refundCode_active"] forState:UIControlStateNormal];
    [refundButton addTarget:self action:@selector(retrieveRefundCode) forControlEvents:UIControlEventTouchUpInside];
    UILabel *refundButtonDesc = [[UILabel alloc]initWithFrame:CGRectMake(Screen_width-15-116, 95, 116, 15)];
    NSAttributedString *refundLabelDesc =[[NSAttributedString alloc]initWithString:@"You can only access the refund code 10 days after your initial order" attributes:@{NSFontAttributeName : [UIFont fontWithName:@"Gotham-Light" size:6.5]}];
    refundButtonDesc.attributedText = refundLabelDesc;
    refundButtonDesc.numberOfLines = 0;
    refundButtonDesc.lineBreakMode = NSLineBreakByWordWrapping;
    refundButtonDesc.textColor = [UIColor redColor];
    self.refundButton = refundButton;
    self.refundLabel = refundButtonDesc;
    
    priceTitleView = [[UIView alloc]initWithFrame:CGRectMake(0, 0,Screen_width, 120)];
    
    [priceTitleView addSubview:self.item_title];
    [priceTitleView addSubview:titleIcon];
    [priceTitleView addSubview:self.item_current_price];
    [priceTitleView addSubview:priceIcon];
    [priceTitleView addSubview:self.refundButton];
    [priceTitleView addSubview:self.refundLabel];
    
    UIImageView *descIcon = [[UIImageView alloc]initWithFrame:CGRectMake(15, 15, 40, 40)];
    [descIcon setImage:[UIImage imageNamed:@"note"]];
    
    
    NSAttributedString *descStr =[[NSAttributedString alloc]initWithString:self.order.item_description attributes:@{NSFontAttributeName : [UIFont fontWithName:@"Gotham-Light" size:14]}];
    CGSize size = CGSizeMake(230, 999);
    CGRect textRect = [self.order.item_description
                       boundingRectWithSize:size
                       options:NSStringDrawingUsesLineFragmentOrigin
                       attributes:@{NSFontAttributeName:[UIFont fontWithName:@"Gotham-Light" size:14]}
                       context:nil];
    descSize = textRect.size;
    self.item_description = [[UILabel alloc]initWithFrame:CGRectMake(75, 15, Screen_width-90, descSize.height)];
    self.item_description.attributedText = descStr;
    self.item_description.lineBreakMode = NSLineBreakByWordWrapping;
    self.item_description.numberOfLines = 0;
    descView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, Screen_width, descSize.height)];
    [descView addSubview:self.item_description];
    [descView addSubview:descIcon];
    
    
    self.item_image = [[UIImageView alloc]initWithFrame:CGRectMake(Screen_width*0.05, 10, Screen_width*0.9,Screen_width*0.9)];

    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(checkoutPostSuccess:) name:@"FinishCheckoutNotification" object:nil];

    
    if (self.order.img_data) {
        [self.item_image setImage:[UIImage imageWithData:self.order.img_data]];
    }else{
        [self.item_image setImage:[UIImage imageNamed:@"manshoes"]];
    }
}

-(void)checkoutPostSuccess:(NSNotification *)noti{
    NSString *protocal = [noti object];
    NSLog(@"protocal: %@",[protocal description]);
    if ([protocal isEqualToString:@"success"]) {
        
        [HHAlertView showAlertWithStyle:HHAlertStyleOk inView:self.presentedModalView.view Title:@"Success" detail:@"Thank you!" cancelButton:nil Okbutton:@"OK"];
        [self presentViewController:self.presentedModalView animated:YES completion:nil];
        
    }else{
        [HHAlertView showAlertWithStyle:HHAlertStyleError inView:self.presentedModalView.view Title:@"Error" detail:@"Please Contact Us" cancelButton:@"Cancel" Okbutton:@"Move Back"];
        [self presentViewController:self.presentedModalView animated:YES completion:nil];
    }
}

-(void)confirmButtonTapped{
    self.confirm_status = @"Confirm Status";
    [HHAlertView showAlertWithStyle:HHAlertStyleWraning inView:self.presentedModalView.view Title:@"Item Received?" detail:@"This Action Cannot Be Undone" cancelButton:@"Cancel" Okbutton:@"Yes"];
    [self presentViewController:self.presentedModalView animated:YES completion:nil];
}


-(void)setupPersonInfo{
    personDetailView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, Screen_width, 70)];
    personDetailView.backgroundColor = [UIColor whiteColor];
    UIButton *personButton = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, Screen_width, 70)];
    [personButton addTarget:self action:@selector(personButtonTapped) forControlEvents:UIControlEventTouchUpInside];
    UIImageView *personIcon = [[UIImageView alloc]initWithFrame:CGRectMake(15, 15, 40, 40)];
    [personIcon setImage:[UIImage imageNamed:@"User"]];
    UILabel *nameLabel = [[UILabel alloc]initWithFrame:CGRectMake(75, 15, Screen_width-75, 17)];
    UILabel *emailLabel = [[UILabel alloc]initWithFrame:CGRectMake(75, 36, Screen_width - 75, 17)];
    
    NSAttributedString *nameStr =[[NSAttributedString alloc]initWithString:[self profileName:self.order.user_info[@"seller_email"]] attributes:@{NSFontAttributeName : [UIFont fontWithName:@"Gotham-Light" size:14]}];
    nameLabel.attributedText = nameStr;
    NSAttributedString *emailStr =[[NSAttributedString alloc]initWithString:self.order.user_info[@"seller_email"] attributes:@{NSFontAttributeName : [UIFont fontWithName:@"Gotham-Light" size:14]}];
    emailLabel.attributedText = emailStr;
    [personDetailView addSubview:personIcon];
    [personDetailView addSubview:nameLabel];
    [personDetailView addSubview:emailLabel];
    [personDetailView addSubview:personButton];
    
}
-(void)personButtonTapped{
    ChatViewController *chatViewController = [[ChatViewController alloc]init];
    chatViewController.title = [self profileName:self.order.user_info[@"seller_email"]];
    chatViewController.seller_email = self.order.user_info[@"seller_email"];
    [self.navigationController pushViewController:chatViewController animated:YES];
}

- (UIImage *)resizeImage:(UIImage *)image toSize:(CGSize)resize

{
    UIGraphicsBeginImageContextWithOptions(CGSizeMake(resize.width, resize.height), NO, [UIScreen mainScreen].scale);
    [image drawInRect:CGRectMake(0, 0, resize.width, resize.height)];
    UIImage *reSizeImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return reSizeImage;
}

-(NSString *)profileName:(NSString *)email{
    NSString *usernameString = email;
    NSArray *components = [usernameString componentsSeparatedByString:@"@"];
    NSString *nameString = [components objectAtIndex:0];
    NSArray *nameComponents = [nameString componentsSeparatedByString:@"."];
    NSString *firstName = [nameComponents objectAtIndex:0];
    
    NSString *capitalizedFirstName = [firstName stringByReplacingCharactersInRange:NSMakeRange(0,1)
                                                                        withString:[[firstName substringToIndex:1] capitalizedString]];
    NSString *lastName = [nameComponents objectAtIndex:1];
    NSString *capitalizedLastName = [lastName stringByReplacingCharactersInRange:NSMakeRange(0,1)
                                                                      withString:[[lastName substringToIndex:1] capitalizedString]];
    
    NSString *fullName = [capitalizedFirstName stringByAppendingString:[@" " stringByAppendingString:capitalizedLastName]];
    return fullName;

}

-(void)retrieveRefundCode{
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(refundCode:) name:@"RefundCodeNotification" object:nil];
    OrderConnection *connection = [[OrderConnection alloc]init];
    [connection retrieveRefundCode:self.order.item_id];
}

-(void)refundCode:(NSNotification *)noti{
    self.confirm_status = @"Refund Code";
    NSString *code = [noti object];
    [HHAlertView showAlertWithStyle:HHAlertStyleDefault inView:self.presentedModalView.view Title:@"Refund Code" detail:code cancelButton:nil Okbutton:@"Cancel"];
    if (self.presentedViewController == NULL) {
        [self presentViewController:self.presentedModalView animated:YES completion:nil];
    }else{
        NSLog(@"%@",[self.presentedViewController description]);
    }
    
}

-(void)refundButtonEligibility{
    NSDate *now = [NSDate date];
    NSDate *tenDaysBefore = [now dateByAddingTimeInterval:-60*60*24*numbersOfOrderDaysBeforeRefund];
    if ([order_date compare:tenDaysBefore]==NSOrderedAscending) {
        self.refundButton.enabled = YES;
        self.refundLabel.hidden = YES;
    }else{
        self.refundButton.enabled = NO;
        self.refundLabel.hidden = NO;
    }
}

-(void)didClickButtonAnIndex:(HHAlertButton)button{
    if ([self.confirm_status isEqualToString:@"Confirm Status"]) {
        if (button==HHAlertButtonOk) {
            self.confirm_status = @"Process";
            OrderConnection *orderConnection = [[OrderConnection alloc]init];
            [orderConnection finishCheckOut:self.order.item_id];
            NSLog(@"%@",[self.order description]);
        }
        
    }else if ([self.confirm_status isEqualToString:@"Process"]){
        if (button==HHAlertButtonCancel) {
            self.confirm_status=@"Confirm Status";
        }else if (button==HHAlertButtonOk){
            [self.navigationController popToRootViewControllerAnimated:YES];
        }
    }else if ([self.confirm_status isEqualToString:@"Refund Code"]){
    
    }
    
    [self.presentedModalView dismissViewControllerAnimated:YES completion:nil];
    
}

@end
