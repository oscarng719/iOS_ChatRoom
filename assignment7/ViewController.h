//
//  ViewController.h
//  assignment7
//
//  Created by Student on 3/7/14.
//  Copyright (c) 2014 Oscar. All rights reserved.
//

#import <UIKit/UIKit.h>

#define MSGSIZE  512

#define PORT     3000

#define HOSTIP   @"129.123.7.14"
//#define HOSTIP   @"localhost"

#define NAME     @"iam:"

#define  MSG     @"msg:"

@interface ViewController : UIViewController <NSStreamDelegate, UITextFieldDelegate>
{
    NSInputStream *inputStream;
    NSOutputStream *outputStream;
    uint8_t inBuf[MSGSIZE], outBuf[MSGSIZE];
    bool isJoin;
}
@property (weak, nonatomic) IBOutlet UIButton *join;

@property (strong, nonatomic) IBOutlet UITextField *message;
@property (strong, nonatomic) IBOutlet UITextView *textArea;
@property (strong, nonatomic) IBOutlet UITextField *name;

-(void)messageArrived:(NSString *)message;
- (IBAction)send:(id)sender;
- (IBAction)join:(id)sender;

@end
