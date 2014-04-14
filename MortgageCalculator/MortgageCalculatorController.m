//
//  MortgageCalculatorController.m
//  MortgageCalculator
//
//  Created by rick michael sullivan on 4/11/14.
//  Copyright (c) 2014 Rick Sullivan. All rights reserved.
//

#import "MortgageCalculatorController.h"

@interface MortgageCalculatorController ()
+ (NSDecimalNumberHandler *) getCurrencyBehavior;

@end

@implementation MortgageCalculatorController

@synthesize amountBorrowed,
            interestRate,
            loanTerm,
            taxes,
            monthlyPayment,
            interestRateLabel,
            monthlyPaymentLabel,
            amountBorrowedTextField,
            interestRateSlider,
            loanTermSegControl,
            taxSwitch;

/* Returns a NSDecimalNumberHandler that allows us to use the NSDecimalNumber class as currency. */
+(NSDecimalNumberHandler *) getCurrencyBehavior
{
    return [NSDecimalNumberHandler decimalNumberHandlerWithRoundingMode:NSRoundPlain
                                                           scale:2
                                                raiseOnExactness:NO
                                                 raiseOnOverflow:NO
                                                raiseOnUnderflow:NO
                                             raiseOnDivideByZero:NO];
}

-(IBAction) amountChanged:(id)sender
{
    UITextField *amountField = sender;
    
    NSDecimalNumber *input = [NSDecimalNumber decimalNumberWithString:amountField.text];
    
    if (input == [NSDecimalNumber notANumber] || input < 0) {
        /* Should alert the user when their input is invalid. */
        NSLog(@"Amount invalid.");
        
        /* Alert info taken from http://stackoverflow.com/questions/6319417/whats-a-simple-way-to-get-a-text-input-popup-dialog-box-on-an-iphone */
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Invalid amount" message:@"Amount must be positive and contain only numbers and one decimal." delegate:self cancelButtonTitle:@"Hide" otherButtonTitles:nil];
        [alert show];
    } else {
        amountBorrowed = input;
    }
}

-(IBAction) sliderChanged :(id)sender
{
    UISlider *slider = sender;
    NSDecimalNumber *input = [[NSDecimalNumber alloc] initWithFloat:slider.value];
    
    /* Input should be rounded to the tenths place */
    interestRate = [input decimalNumberByRoundingAccordingToBehavior:[NSDecimalNumberHandler decimalNumberHandlerWithRoundingMode:NSRoundPlain
                                        scale:1
                                        raiseOnExactness:NO
                                        raiseOnOverflow:NO
                                        raiseOnUnderflow:NO
                                        raiseOnDivideByZero:NO]];
    interestRateLabel.text = [NSString stringWithFormat:@"%@%%", interestRate];
}

-(IBAction) loanTermChanged:(id)sender
{
    UISegmentedControl *control = sender;
    
    loanTerm = [[control titleForSegmentAtIndex:[control selectedSegmentIndex]] intValue];
}

-(IBAction) taxesSwitched:(id)sender
{
    UISwitch *tSwitch = sender;
    
    taxes = tSwitch.on;
}

-(IBAction) calculate
{
    /* Inputs should have already been cleansed. */
    if ([amountBorrowed compare:[NSDecimalNumber zero]] == NSOrderedSame){

        monthlyPaymentLabel.text = @"$0";
        return;
    }
    
    NSDecimalNumber *monthlyTaxes = [NSDecimalNumber zero];
    
    if (taxes)
        monthlyTaxes = [amountBorrowed decimalNumberByMultiplyingBy:[NSDecimalNumber decimalNumberWithString:@"0.001"]];
    
    if ([interestRate compare:[NSDecimalNumber zero]] == NSOrderedSame) {
        /* Avoid edge cases involving 0% interest. */
        monthlyPayment = [[amountBorrowed decimalNumberByDividingBy:[[NSDecimalNumber alloc] initWithInt:(loanTerm * 12)]] decimalNumberByAdding:monthlyTaxes withBehavior:[MortgageCalculatorController getCurrencyBehavior]];
    } else {
    
        /* These calculations are ugly using the NSDecimalNumber class.
        Calculation was divided up for debugging's sake.    */
        NSDecimalNumber *j = [interestRate decimalNumberByDividingBy:
                          [NSDecimalNumber decimalNumberWithString:@"1200"]];
        NSDecimalNumber *denom = [[NSDecimalNumber one] decimalNumberByAdding:j];
    
        /* Raising to the negative power by doing a^(b) -> 1/(a^b).
        This avoids overflow exceptions. */
        denom = [denom decimalNumberByRaisingToPower:(loanTerm * 12)];
        denom = [[NSDecimalNumber one] decimalNumberByDividingBy:denom];
    
        denom = [[NSDecimalNumber one] decimalNumberBySubtracting:denom];
    
        /* Apply currency behavior on last step to round appropriately. */
        monthlyPayment = [[amountBorrowed decimalNumberByMultiplyingBy:[j decimalNumberByDividingBy:denom]] decimalNumberByAdding:monthlyTaxes withBehavior:[MortgageCalculatorController getCurrencyBehavior]];
    }
    
    monthlyPaymentLabel.text = [NSString stringWithFormat:@"$%@", monthlyPayment];
}

/* Whenever the background is touched, we want to check if the keyboard is open and close it if so. */
-(IBAction) screenTouch
{
    if (amountBorrowedTextField.isFirstResponder) {
        [amountBorrowedTextField resignFirstResponder];
    }
}

/* Allows the return button to close the keyboard.
    Help from http://stackoverflow.com/questions/6190276/how-to-make-return-key-on-iphone-make-keyboard-disappear*/
-(BOOL) textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    
    /* Allow text field to close its own keyboard. */
    amountBorrowedTextField.delegate = self;

    
    /* Set up initial values. */
    amountBorrowed = 0;
    
    interestRateLabel.text = @"5.0%";
    interestRateSlider.value = 5;
    interestRate = [NSDecimalNumber decimalNumberWithString:@"5"];
    
    loanTermSegControl.selectedSegmentIndex = 0;
    loanTerm = 10;
    
    taxSwitch.on = true;
    taxes = true;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
