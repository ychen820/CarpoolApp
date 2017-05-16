//
//  PostViewController.m
//  CarPool
//
//  Created by Nathan Chen on 4/29/17.
//  Copyright © 2017 Nathan Chen. All rights reserved.
//

#import "PostViewController.h"
#import "SearchViewController.h"
#import "CustomNavController.h"
#import <DatePickerDialog-ObjC/LSLDatePickerDialog.h>
#import "GeoFire.h"
#import "FireBaseManager.h"
@interface PostViewController ()<UITextFieldDelegate>

@end

@implementation PostViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.clearButtonTouched=NO;
    self.inputArray=[NSArray arrayWithObjects:self.startLocationField,self.destinationField,self.timeTextfield,self.carModelField, nil];
    // Do any additional setup after loading the view.
}

-(BOOL)textFieldShouldBeginEditing:(UITextField *)textField{
    if(textField==self.timeTextfield){
        [self openDatePicker];
        
    }
    if(textField==self.startLocationField||textField==self.destinationField){
    CustomNavController *nav=[self.storyboard instantiateViewControllerWithIdentifier:@"searchNav"];
    SearchViewController *svc=(SearchViewController *)nav.topViewController;
    svc.textfield=textField;
        svc.pvc=self;
    if(!self.clearButtonTouched)
    [self presentViewController:nav animated:YES completion:nil];
    self.clearButtonTouched=NO;
    }
    return NO;
    
}
-(void)openDatePicker {
    LSLDatePickerDialog *dpDialog = [[LSLDatePickerDialog alloc] init];
    [dpDialog showWithTitle:@"Select Pick Up Time" doneButtonTitle:@"Done" cancelButtonTitle:@"Cancel"
                defaultDate:[NSDate date] minimumDate:nil maximumDate:nil datePickerMode:UIDatePickerModeDateAndTime
                   callback:^(NSDate * _Nullable date){
                       
                       if(date)
                       {
                           NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
                           self.pickUpDate=date;
                           [formatter setDateFormat:@"EEE, MMM d, h:mm a"];
                           NSLog(@"Date selected: %@",[formatter stringFromDate:date]);
                           self.timeTextfield.text=[formatter stringFromDate:date];
                       }
                   }
     ];
}

-(void)textFieldDidBeginEditing:(UITextField *)textField{

}
-(BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string{
    textField.userInteractionEnabled=YES;
    return NO;
}
-(BOOL)textFieldShouldClear:(UITextField *)textField{
    self.clearButtonTouched=YES;
    return YES;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)postAction:(UIBarButtonItem *)sender {
    if(![self checkEmpty]){
        FIRDatabaseReference *postRef=[[[[FireBaseManager sharedFireBaseManager].databaseRef root]child:@"posts"]childByAutoId];
        GeoFire *geoFire=[[GeoFire alloc]initWithFirebaseRef:[[[[FireBaseManager sharedFireBaseManager]databaseRef]root]child:@"startLocations" ]];
        FIRDatabaseReference *userPostRef = [[FireBaseManager sharedFireBaseManager]getUserRef:[FireBaseManager sharedFireBaseManager].currentUser.uid];
        [[[userPostRef child:@"posts"]child:postRef.key]setValue:@YES];
        [geoFire setLocation:self.startLocation forKey:postRef.key];
        FIRDatabaseReference *destRef=[[[FireBaseManager sharedFireBaseManager].databaseRef root]child:@"endLocations"];
        geoFire=[geoFire initWithFirebaseRef:destRef];
        [geoFire setLocation:self.endLocation forKey:postRef.key];
        NSDictionary *dict=@{@"startName": self.startLocationField.text,@"endName":self.destinationField.text,@"date":self.pickUpDate.description,@"owner":[[FIRAuth auth]currentUser].uid,@"carModel":self.carModelField.text};
        [postRef updateChildValues:dict];
        [self.navigationController popViewControllerAnimated:YES];
    }

}

-(BOOL)checkEmpty{
    BOOL isEmpyt=NO;
    for(UITextField* field in self.inputArray){
        if([field.text isEqualToString:@""]||field==nil)
            isEmpyt=YES;
        field.highlighted=YES;
    }
    return isEmpyt;
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
