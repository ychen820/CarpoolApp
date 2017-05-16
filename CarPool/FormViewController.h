//
//  FormViewController.h
//  CarPool
//
//  Created by Nathan Chen on 4/27/17.
//  Copyright © 2017 Nathan Chen. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FormViewController : UIViewController
@property (weak, nonatomic) IBOutlet UITextField *firstNameView;
@property (weak, nonatomic) IBOutlet UITextField *lastNameView;
@property (weak, nonatomic) IBOutlet UITextField *ageView;
@property (assign) NSUInteger loginMethod;
@property(strong,nonatomic) id thirdparty_login;
@end
