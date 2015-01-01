//
//  ViewController.m
//  assignment7
//
//  Created by Student on 3/7/14.
//  Copyright (c) 2014 Oscar. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    isJoin = false;

    
    [_name setDelegate:self];
    [_message setDelegate:self];
    [_name.inputView setNeedsDisplay];
    
	// Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (IBAction)send:(id)sender
{
    if(isJoin)
    {
        NSString *response  = [NSString stringWithFormat:@"msg:%@", _message.text];
        [self sendMessage:response];
        _message.text = @"";
    }
    else
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Please, join first!" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
    }
}


- (IBAction)join:(id)sender
{
    
        [_name resignFirstResponder];
    
    
        [_message resignFirstResponder];
        [UIView beginAnimations:nil context:NULL];
        [UIView setAnimationDuration:0.25];
        _message.frame = CGRectMake(20,439,240,30);
        [UIView commitAnimations];
    
    
    if(!isJoin)
    {
        [self initNetworkCommunications:HOSTIP port:PORT];
        NSString *response;
        if([_name.text  isEqual: @""])
        {
            response  = [NSString stringWithFormat:@"iam:Mystery Man"];
        }
        else
        {
            response  = [NSString stringWithFormat:@"iam:%@", _name.text];
        }
        
        NSData *data = [[NSData alloc] initWithData:[response dataUsingEncoding:NSASCIIStringEncoding]];
        [outputStream write:[data bytes] maxLength:[data length]];
        isJoin = true;
        [_join setTitle:@"Logout" forState:UIControlStateNormal];
    }
    else
    {
        [self closeNetworkCommunications];
        isJoin = false;
        [_join setTitle:@"Join" forState:UIControlStateNormal];
        [_textArea setText:[_textArea.text stringByAppendingString:[NSString stringWithFormat:@"You left the chat room.\n"]]];
    }
}

-(void)messageArrived:(NSString *)message
{
	[_textArea setText:[_textArea.text stringByAppendingString:[NSString stringWithFormat:@"%@",message]]];
}

-(void) initNetworkCommunications:(NSString *)ipAddr port:(int)port
{
    CFReadStreamRef readStream;
    CFWriteStreamRef writeStream;
    CFStreamCreatePairWithSocketToHost(NULL,
                                       (__bridge CFStringRef)ipAddr, port, &readStream, &writeStream);
    inputStream = (__bridge NSInputStream *) readStream;
    outputStream = (__bridge NSOutputStream *) writeStream;
    [inputStream setDelegate:self];
    [outputStream setDelegate:self];
    [inputStream scheduleInRunLoop:[NSRunLoop currentRunLoop]
                           forMode:NSDefaultRunLoopMode];
    [outputStream scheduleInRunLoop:[NSRunLoop currentRunLoop]
                            forMode:NSDefaultRunLoopMode];
    [inputStream open];
    [outputStream open];
}

// finish and close communications
-(void) closeNetworkCommunications
{
    [inputStream close];
    [outputStream close];
    [inputStream removeFromRunLoop:[NSRunLoop currentRunLoop]
                           forMode:NSDefaultRunLoopMode];
    [outputStream removeFromRunLoop:[NSRunLoop currentRunLoop]
                            forMode:NSDefaultRunLoopMode];
}

// send an NSString text message
-(void) sendMessage: (NSString *)textMessage
{
    [textMessage getCString:(char *)outBuf maxLength:MSGSIZE
                   encoding:NSUTF8StringEncoding];
    [outputStream write:outBuf maxLength:strlen((const char *)outBuf)+1];
}

// handle a stream event (NSStream delegate protocol)
-(void) stream: (NSStream *) theStream handleEvent: (NSStreamEvent) streamEvent
{
    switch (streamEvent)
    {
        case NSStreamEventOpenCompleted:
            NSLog (@"stream opened");
            break;
            
        case NSStreamEventHasBytesAvailable:
            NSLog (@"bytes avail");
            if (theStream == inputStream)
            {
                uint8_t *bufptr;
                bufptr = inBuf;
                int len, total=0;
                while ([inputStream hasBytesAvailable])
                {   len = [inputStream read:bufptr maxLength:MSGSIZE];
                    if (len > 0)
                    {   bufptr += len;
                        total += len;
                    }
                }
                NSString *note = [[NSString alloc] initWithBytes:inBuf length:total
                                                        encoding:NSUTF8StringEncoding];
                [self messageArrived:note];
            }
            break;
            
        case NSStreamEventErrorOccurred:
            NSLog(@"cannot connect to host");
            break;
            
        case NSStreamEventEndEncountered:
            NSLog (@"stream closed");
            [self closeNetworkCommunications];
            break;
            
        case NSStreamEventHasSpaceAvailable:
            NSLog(@"space available");
            break;
            
        default:
            NSLog(@"unknown comm error");
            break;
    }
}

-(BOOL) textFieldShouldReturn:(UITextField *)_textField
{
    if([_name isFirstResponder])
        [_name resignFirstResponder];
    if([_message isFirstResponder])
    {
        [_message resignFirstResponder];
        [UIView beginAnimations:nil context:NULL];
        [UIView setAnimationDuration:0.25];
        _message.frame = CGRectMake(20,439,240,30);
        [UIView commitAnimations];
    }
    
    return YES;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    if([_message isFirstResponder])
    {
        [UIView beginAnimations:nil context:NULL];
        [UIView setAnimationDuration:0.25];
        _message.frame = CGRectMake(0,230,320,30);
        [UIView commitAnimations];
    }
    
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.25];
    _message.frame = CGRectMake(20,439,240,30);
    [UIView commitAnimations];
    
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch * touch = [[event allTouches] anyObject];
    
    if ([_name isFirstResponder] && [touch view] != _name)
        [_name resignFirstResponder];
    
    if ([_message isFirstResponder] && [touch view] != _message)
    {
        [_message resignFirstResponder];
        [UIView beginAnimations:nil context:NULL];
        [UIView setAnimationDuration:0.25];
        _message.frame = CGRectMake(20,439,240,30);
        [UIView commitAnimations];
    }
}



@end
