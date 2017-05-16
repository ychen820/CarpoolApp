//
//  FormViewController.m
//  CarPool
//
//  Created by Nathan Chen on 4/27/17.
//  Copyright © 2017 Nathan Chen. All rights reserved.
//

#import "FormViewController.h"
#import "LoginManager.h"
#import "FireBaseManager.h"
#import "CustomNavController.h"
#import "AppDelegate.h"
@interface FormViewController ()
@property (weak, nonatomic) IBOutlet UITextField *firstNameText;
@property (weak, nonatomic) IBOutlet UITextField *lastNameText;
@property(strong,nonatomic) NSArray *textFields;
@property (weak, nonatomic) IBOutlet UITextField *ageText;
@end

@implementation FormViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.textFields=@[self.firstNameText,self.lastNameText,self.lastNameText,self.ageText];
    NSLog(@"%@",self.thirdparty_login);
    [self navBarSetup];
    // Do any additional setup after loading the view.
}

-(void)navBarSetup{
    [self.navigationController.navigationBar setBarTintColor:[UIColor whiteColor]];
    [self.navigationController.navigationBar setTranslucent:NO];
    self.navigationItem.title=@"Sign Up";
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)signUpAction:(UIButton *)sender {
    Boolean isEmpyt=NO;
    for(UITextField *textfield in self.textFields){
        if([textfield.text isEqualToString:@""]||textfield.text==nil){
            [textfield becomeFirstResponder];
            isEmpyt=YES;
        }
    }
    
    if(!isEmpyt){
        NSString *fn=self.firstNameText.text;
        NSString *ln=self.lastNameText.text;
        NSString *age=self.ageText.text;
        FIRUser *currentUser=[FIRAuth auth].currentUser;
        AppDelegate *ad = (AppDelegate *)[[UIApplication sharedApplication]delegate];
       

        NSDictionary *userDict=@{@"firstName":fn,@"lastName":ln,@"age":age,@"photoURL":[currentUser.photoURL absoluteString]};
                NSString *key=[NSString stringWithFormat:@"users/%@",currentUser.uid];
                [[FireBaseManager sharedFireBaseManager]firebaseSetValue:userDict forKey:key];
        if(ad.instanceID){
            [[FireBaseManager sharedFireBaseManager]firebaseSetValue:@{@"instanceID" : ad.instanceID} forKey:key];
        }
        CustomNavController *nav=[self.storyboard instantiateViewControllerWithIdentifier:@"mainNav"];
        [self presentViewController:nav animated:YES completion:nil];
        }
    
    
}
-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    [self.view endEditing:YES];
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
