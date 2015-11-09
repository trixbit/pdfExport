//
//  ViewController.m
//  scaleTextPDF
//
//  Created by Matthew McClure on 11/7/15.
//  Copyright © 2015 Matthew McClure. All rights reserved.
//

#import "ViewController.h"
#import <MessageUI/MessageUI.h>
#import <MessageUI/MFMailComposeViewController.h>

#import "UITextView+PDFExporter.h"

@interface ViewController () <MFMailComposeViewControllerDelegate>
@property (weak, nonatomic) IBOutlet UITextView *textView;

- (IBAction)fontStepperChanged:(UIStepper *)sender;

@property CGFloat currentFontSize;

@property (strong, nonatomic) NSString *currentFont;

- (IBAction)makeHelveticaBold:(UIButton *)sender;
- (IBAction)makeTimes:(UIButton *)sender;
- (IBAction)makePapyrus:(UIButton *)sender;


@end

@implementation ViewController

- (void)viewDidLoad {
  [super viewDidLoad];
  // Do any additional setup after loading the view, typically from a nib.
  _currentFontSize = 12;
  _currentFont = @"Helvetica-Bold";
  [self.textView setFont:[UIFont fontWithName:_currentFont size:self.currentFontSize]];
}

- (void)didReceiveMemoryWarning {
  [super didReceiveMemoryWarning];
  // Dispose of any resources that can be recreated.
}

- (void)viewDidAppear:(BOOL)animated {
  [self.textView setFont:[UIFont fontWithName:self.currentFont size:self.currentFontSize]];
  [_textView sizeToFit]; //added
  [_textView layoutIfNeeded]; //added

}

- (IBAction)fontStepperChanged:(UIStepper *)sender {
  double stepperValue = [sender value];
  _currentFontSize = stepperValue;
  
  [self viewDidAppear:true];
}

- (IBAction)exportAndMailPDF:(UIButton *)sender {
  
  //somehow save textView content as a scalable PDF, with exact preservation of font and exact placement of word wrapping. that is, if the user's view has three words on the top line and two words on the second line, that needs to be preserved exactly. it can't be that the pdf pushes word #3 down to the second line...
  //once scaled up, the width of the final pdf will be exactly 1008 pixels
  
  //generate pdf code here
  NSData *pdfData = [self.textView PDFData];
  
  //then generate email and send here:
  if([MFMailComposeViewController canSendMail]) {
    MFMailComposeViewController *mailCont = [[MFMailComposeViewController alloc] init];
    mailCont.mailComposeDelegate = self;
    
   //
    
    NSString *fileName = @"test";
    fileName = [fileName stringByAppendingPathExtension:@"pdf"];
      
      
    //replace with pdf something
   [mailCont addAttachmentData:pdfData mimeType:@"application/pdf" fileName:fileName];
    
    [mailCont setSubject:@"test pdf"];
    [mailCont setToRecipients:[NSArray arrayWithObject:@"matthewmcclure@gmail.com"]];
    [mailCont setMessageBody:@"sent from simple tees app" isHTML:NO];
    
    [self presentViewController:mailCont animated:YES completion:nil];
  }

}

- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error
{
    [self dismissViewControllerAnimated:YES completion:nil];
    
    if (result == MFMailComposeResultCancelled)
        NSLog(@"Message cancelled");
    else if (result == MFMailComposeResultSent)
        NSLog(@"Message sent");
    else
        NSLog(@"Message failed");
}

- (IBAction)makeHelveticaBold:(UIButton *)sender {
  _currentFont = @"Helvetica-Bold";
  [self.textView setFont:[UIFont fontWithName:_currentFont size:self.currentFontSize]];
  [self viewDidAppear:true];
}

- (IBAction)makeTimes:(UIButton *)sender {
  _currentFont = @"Times";
  [self.textView setFont:[UIFont fontWithName:_currentFont size:self.currentFontSize]];
  [self viewDidAppear:true];
}

- (IBAction)makePapyrus:(UIButton *)sender {
  _currentFont = @"Papyrus";
  [self.textView setFont:[UIFont fontWithName:_currentFont size:self.currentFontSize]];
  [self viewDidAppear:true];
}
@end
