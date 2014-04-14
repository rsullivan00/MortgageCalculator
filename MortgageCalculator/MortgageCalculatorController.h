//
//  MortgageCalculatorController.h
//  MortgageCalculator
//
//  Created by rick michael sullivan on 4/11/14.
//  Copyright (c) 2014 Rick Sullivan. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MortgageCalculatorController : UIViewController <UITextFieldDelegate>
{
}


@property (nonatomic, copy) NSDecimalNumber *amountBorrowed;
@property (nonatomic, copy) NSDecimalNumber *interestRate;
@property (nonatomic, assign) int loanTerm;
@property (nonatomic, assign) BOOL taxes;
@property (nonatomic, copy) NSDecimalNumber *monthlyPayment;

@property (strong, nonatomic) IBOutlet UILabel *interestRateLabel;
@property (strong, nonatomic) IBOutlet UILabel *monthlyPaymentLabel;
@property (strong, nonatomic) IBOutlet UITextField *amountBorrowedTextField;
@property (strong, nonatomic) IBOutlet UISlider *interestRateSlider;
@property (strong, nonatomic) IBOutlet UISegmentedControl *loanTermSegControl;
@property (strong, nonatomic) IBOutlet UISwitch *taxSwitch;


@end
