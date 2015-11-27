//
//  RegisterViewController.m
//  ProxiFinal
//
//  Created by Michael Liu on 10/10/15.
//  Copyright © 2015 Michael Liu. All rights reserved.
//

#import "RegisterViewController.h"
#import "UserConnection.h"
#import "User.h"

#define Screen_width [[UIScreen mainScreen]bounds].size.width
#define Screen_height [[UIScreen mainScreen]bounds].size.height

#define RegisterPassProtocol @"successfully create user"

@interface RegisterViewController ()

@end

@implementation RegisterViewController


- (IBAction)backgroundTapped:(id)sender {
    [self.email resignFirstResponder];
    [self.password resignFirstResponder];
    [self.phone resignFirstResponder];
    [self.dateOfBirth resignFirstResponder];
    [self.venmoPhone resignFirstResponder];

}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(registerPass:) name:@"RegisterPassNotification" object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(registerFail) name:@"RegisterFailNotification" object:nil];
    self.firstPage.frame = CGRectMake(0, 0, Screen_width, Screen_height);
    self.secondPage.frame = CGRectMake(Screen_width, 0, Screen_width, Screen_height);
    [self.scrollView setContentSize:CGSizeMake(Screen_width*2, 0)];
    [self.scrollView addSubview:self.firstPage];
    [self.scrollView addSubview:self.secondPage];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)cancelRegister:(id)sender {
    [[NSNotificationCenter defaultCenter]removeObserver:self];
    [self dismissViewControllerAnimated:YES completion:nil];
}
- (IBAction)registerButtonTapped:(id)sender {
    User *user = [[User alloc]initWithID:nil email:self.email.text password:self.password.text phone:self.phone.text];
    UserConnection *connection = [[UserConnection alloc]init];
    self.refresher.hidden = NO;
    [connection registeredUserInfo:user];
    
    
}
-(void)registerPass:(NSNotification *)noti{
    BOOL success = [[noti object]isEqualToString:RegisterPassProtocol];
    if (success) {
        self.refresher.hidden = YES;
        //successAlertView
        [[NSNotificationCenter defaultCenter]removeObserver:self];
        [self dismissViewControllerAnimated:YES completion:nil];
    }else{
        self.refresher.hidden = YES;
        //errorAlertView
        self.password.text = @"";
        [self.scrollView scrollRectToVisible:CGRectMake(0, 0, Screen_width, Screen_height) animated:YES];
    }
}


-(void)registerFail{
    self.refresher.hidden = YES;
    
}
- (IBAction)braintreeliabilityLink:(id)sender {
}
- (IBAction)proxiliabilityLink:(id)sender {
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
