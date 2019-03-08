//
//  MIDPaymentIndomaretViewController.m
//  MidtransKit
//
//  Created by Tommy.Yohanes on 24/05/18.
//  Copyright © 2018 Midtrans. All rights reserved.
//

#import "MIDPaymentIndomaretViewController.h"
#import "MIdtransUIBorderedView.h"
#import "SNPPostPaymentGeneralViewController.h"
#import "VTClassHelper.h"
#import "MidtransUIThemeManager.h"
#import "MidtransTransactionDetailViewController.h"
#import "VTSubGuideController.h"
#import "MIDUITrackingManager.h"

@interface MIDPaymentIndomaretViewController ()
@property (nonatomic,strong) VTSubGuideController *subGuide;
@property (weak, nonatomic) IBOutlet UILabel *instructionLabel;
@property (weak, nonatomic) IBOutlet UIView *instructionPage;
@property (weak, nonatomic) IBOutlet MIdtransUIBorderedView *totalAmountBorderedView;
@property (weak, nonatomic) IBOutlet UILabel *totalAmountLabel;
@property (weak, nonatomic) IBOutlet UILabel *amountLabel;
@property (weak, nonatomic) IBOutlet UILabel *orderIdLabel;
@property (weak, nonatomic) IBOutlet UIButton *confirmPaymentButton;
@end

@implementation MIDPaymentIndomaretViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = self.paymentMethod.title;
    [[MIDUITrackingManager shared] trackEventName:[NSString stringWithFormat:@"pg %@",self.paymentMethod.shortName]];
    NSString* filenameByLanguage = [[MidtransDeviceHelper deviceCurrentLanguage] stringByAppendingFormat:@"_%@", self.paymentMethod.paymentID];
    NSString *guidePath = [VTBundle pathForResource:filenameByLanguage ofType:@"plist"];
    if (guidePath == nil) {
        guidePath = [VTBundle pathForResource:[NSString stringWithFormat:@"en_%@",self.paymentMethod.paymentID] ofType:@"plist"];
    }
    NSArray *instructions = [VTClassHelper instructionsFromFilePath:guidePath];
    self.subGuide = [[VTSubGuideController alloc] initWithInstructions:instructions];
    [self addSubViewController:self.subGuide toView:self.instructionPage];

    self.amountLabel.text = self.info.transaction.grossAmount.formattedCurrencyNumber;
    self.orderIdLabel.text = self.info.transaction.orderID;
    self.instructionLabel.text = [NSString stringWithFormat:[VTClassHelper getTranslationFromAppBundleForString:@"%@ step by step"], self.paymentMethod.title];
    [self.totalAmountBorderedView addGestureRecognizer:
     [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(totalAmountBorderedViewTapped:)]];
    self.totalAmountLabel.textColor = [[MidtransUIThemeManager shared] themeColor];
    self.totalAmountLabel.text = [VTClassHelper getTranslationFromAppBundleForString:@"total.amount"];
    [self.confirmPaymentButton setTitle:[VTClassHelper getTranslationFromAppBundleForString:@"confirm.payment"] forState:UIControlStateNormal];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}
- (void) totalAmountBorderedViewTapped:(id) sender {
    MidtransTransactionDetailViewController *transactionViewController = [[MidtransTransactionDetailViewController alloc] initWithNibName:@"MidtransTransactionDetailViewController" bundle:VTBundle];
    [transactionViewController presentAtPositionOfView:self.totalAmountBorderedView items:self.info.items];
}
- (IBAction)confirmPaymentDidTapped:(id)sender {
    [self showLoadingWithText:nil];
    [[MIDUITrackingManager shared] trackEventName:@"btn confirm payment"];
    [MIDStoreCharge indomaretWithToken:self.snapToken completion:^(MIDIndomaretResult * _Nullable result, NSError * _Nullable error) {
        [self hideLoading];
        if (error) {
            [self handleTransactionError:error];
        } else {
            SNPPostPaymentGeneralViewController *postPaymentVAController = [[SNPPostPaymentGeneralViewController alloc] initWithPaymentResult:result paymentMethod:self.paymentMethod];
            [self.navigationController pushViewController:postPaymentVAController animated:YES];
        }
        
    }];
}

    @end
    