//
//  ViewController.m
//  CarPool
//
//  Created by Nathan Chen on 4/27/17.
//  Copyright © 2017 Nathan Chen. All rights reserved.
//

#import "ViewController.h"
#import "FormViewController.h"
#import "FireBaseManager.h"
#import "CustomNavController.h"
#import "AppDelegate.h"
@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setNeedsStatusBarAppearanceUpdate];
    [GIDSignIn sharedInstance].uiDelegate=self;
    [GIDSignIn sharedInstance].delegate=self;
    // Do any additional setup after loading the view, typically from a nib.
}
-(UIStatusBarStyle)preferredStatusBarStyle{
    return UIStatusBarStyleLightContent;
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)loginWithCredential:(FIRAuthCredential *)credential{
    [[FIRAuth auth]signInWithCredential:credential completion:^(FIRUser * _Nullable user, NSError * _Nullable error) {
        [(AppDelegate *)[UIApplication sharedApplication].delegate setNetworkIndication:NO];
        if(error)
            NSLog(@"Login With Credential Error%@",error.description);
        else{
            FIRDatabaseReference *userRef=[[[[FireBaseManager sharedFireBaseManager].databaseRef root]child:@"users"]child:user.uid];
           
            [userRef observeSingleEventOfType:FIRDataEventTypeValue withBlock:^(FIRDataSnapshot * _Nonnull snapshot) {
                if([snapshot hasChildren]){
                    NSLog(@"already exsites%@",snapshot.key);
                    AppDelegate *ad = (AppDelegate *)[[UIApplication sharedApplication]delegate];
                    if(ad.instanceID){
                        [userRef updateChildValues:@{@"instanceID" : ad.instanceID}];
                    }
                    UserModel *userObject = [UserModel userWithDict:snapshot.value];
                    userObject.uid = snapshot.key;
                    CustomNavController *nav=[self.storyboard instantiateViewControllerWithIdentifier:@"mainNav"];
                    [self presentViewController:nav animated:YES completion:nil];
                }
                else{
                    CustomNavController *nav=[[UIStoryboard storyboardWithName:@"Main" bundle:nil]instantiateViewControllerWithIdentifier:@"formNav"];
                    [self presentViewController:nav animated:YES completion:nil];
                }
            }];
        }
    }];

}
-(void)signIn:(GIDSignIn *)signIn didSignInForUser:(GIDGoogleUser *)user withError:(NSError *)error{
    if(error==nil){
        GIDAuthentication *authentication = user.authentication;
        FIRAuthCredential *credential =
        [FIRGoogleAuthProvider credentialWithIDToken:authentication.idToken
                                         accessToken:authentication.accessToken];
        [self loginWithCredential:credential];
    }
    
}

- (IBAction)fbLogin:(UIButton *)sender {
    [LoginManager ggLogout];
    [(AppDelegate *)[UIApplication sharedApplication].delegate setNetworkIndication:YES];
    FBSDKLoginManager *login = [[FBSDKLoginManager alloc] init];
    [login setLoginBehavior:FBSDKLoginBehaviorNative];
    [login
     logInWithReadPermissions: @[@"public_profile",@"email"]
     fromViewController:self
     handler:^(FBSDKLoginManagerLoginResult *result, NSError *error) {
         if (error) {
             NSLog(@"Process error");
         } else if (result.isCancelled) {
             NSLog(@"Cancelled");
         } else {
             FIRAuthCredential *credential = [FIRFacebookAuthProvider
                                              credentialWithAccessToken:[FBSDKAccessToken currentAccessToken]
                                              .tokenString];
             [self loginWithCredential:credential];
             
           }

     }];
}
- (IBAction)ggSignIn:(UIButton *)sender {
    [LoginManager fbLogout];
     [(AppDelegate *)[UIApplication sharedApplication].delegate setNetworkIndication:YES];
    [[GIDSignIn sharedInstance]signIn];
}

@end

