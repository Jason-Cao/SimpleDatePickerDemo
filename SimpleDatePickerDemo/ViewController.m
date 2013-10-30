//
//  ViewController.m
//  SimpleDatePickerDemo
//
//  Created by Jason Cao on 13-7-31.
//
//

#import "ViewController.h"
#import "JCDatePicker.h"

@interface ViewController () <JCDatePickerDelegate>


@end

@implementation ViewController {
    UILabel *dateLabel;
    NSDateFormatter *dateFormatter;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)viewWillAppear:(BOOL)animated
{
    JCDatePicker *datePicker = [[JCDatePicker alloc] initWithFrame:CGRectMake(0, 0, 200, 200)];
    datePicker.center = CGPointMake(CGRectGetMidX(self.view.frame), CGRectGetMidY(self.view.frame));
    [self.view addSubview:datePicker];
    datePicker.delegate = self;
    
    dateLabel = [[UILabel alloc] init];
    dateLabel.frame = CGRectMake(0, 0, 150, 50);
    dateLabel.center = CGPointMake(CGRectGetMidX(self.view.frame), CGRectGetMaxY(datePicker.frame) + 50);
    dateLabel.backgroundColor = [UIColor colorWithWhite:0 alpha:0.1];
    dateLabel.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:dateLabel];
    UILabel *hint = [[UILabel alloc] init];
    CGRect hintFrame = dateLabel.frame;
    hintFrame.origin.x  -= hintFrame.size.width;
    hint.frame = hintFrame;
    hint.text = @"Selected Date:";
    hint.textAlignment = NSTextAlignmentRight;
    hint.font = [UIFont systemFontOfSize:12];
    [self.view addSubview:hint];
    
    dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"zh_CN"]];
    [dateFormatter setDateFormat:@"yyyy-MM-dd"];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - JCDatePicker Delegate

- (void)datePicker:(JCDatePicker *)datePicker dateDidChange:(NSDate *)date
{
    NSString *dateString = [dateFormatter stringFromDate:date];
    dateLabel.text = dateString;
}

@end
