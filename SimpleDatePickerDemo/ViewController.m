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

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	JCDatePicker *datePicker = [[JCDatePicker alloc] initWithFrame:CGRectMake(20, 20, 300, 300)];
    [self.view addSubview:datePicker];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
