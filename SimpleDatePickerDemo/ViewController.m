//
//  ViewController.m
//  SimpleDatePickerDemo
//
//  Created by Jason Cao on 13-7-31.
//
//

#import "ViewController.h"
#import "JCDatePicker.h"

@interface ViewController () <JCDatePickerDelegate, UIPickerViewDelegate, UIPickerViewDataSource>


@end

@implementation ViewController {
    NSDateFormatter *dateFormatter;
    JCDatePicker *datePicker;
    UIButton *fromButton;
    UIButton *toButton;
    UIButton *activedButton;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)viewWillAppear:(BOOL)animated
{
    dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setLocale:[NSLocale systemLocale]];//[[NSLocale alloc] initWithLocaleIdentifier:@"zh_CN"]];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];

    datePicker = [[JCDatePicker alloc] initWithFrame:CGRectMake(0, 0, 300, 100)];
    datePicker.center = CGPointMake(CGRectGetMidX(self.view.frame), CGRectGetMidY(self.view.frame));
    [self.view addSubview:datePicker];
    datePicker.delegate = self;
    datePicker.font = [UIFont systemFontOfSize:8];
    datePicker.date = [NSDate date];
    datePicker.dateFormat = JCDateFormatFull;
    
    fromButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    toButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    fromButton.frame = CGRectMake(0, 0, 150, 15);
    toButton.frame = CGRectMake(0, 0, 150, 15);
    fromButton.center = CGPointMake(CGRectGetMidX(self.view.frame), CGRectGetMaxY(datePicker.frame) + 50);
    toButton.center = CGPointMake(CGRectGetMidX(self.view.frame), CGRectGetMaxY(fromButton.frame) + 20);
    fromButton.titleLabel.font = [UIFont systemFontOfSize:9];
    toButton.titleLabel.font = [UIFont systemFontOfSize:9];
    [fromButton setTintColor:[UIColor colorWithWhite:0.3 alpha:1]];
    [toButton setTintColor:[UIColor colorWithWhite:0.3 alpha:1]];
    [fromButton addTarget:self action:@selector(buttonPressed:) forControlEvents:UIControlEventTouchUpInside];
    [toButton addTarget:self action:@selector(buttonPressed:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:fromButton];
    [self.view addSubview:toButton];
    [fromButton setTitle:[dateFormatter stringFromDate:[NSDate date]] forState:UIControlStateNormal];
    [toButton setTitle:[dateFormatter stringFromDate:[NSDate dateWithTimeIntervalSinceNow:24*60*60]] forState:UIControlStateNormal];
    UILabel *fromHint = [[UILabel alloc] init];
    UILabel *toHint = [[UILabel alloc] init];
    CGRect fromFrame = fromButton.frame;
    CGRect toFrame = toButton.frame;
    fromFrame.origin.x  -= fromFrame.size.width;
    toFrame.origin.x  -= toFrame.size.width;
    fromHint.frame = fromFrame;
    toHint.frame = toFrame;
    fromHint.text = @"From Date:";
    toHint.text = @"To Date:";
    fromHint.textAlignment = NSTextAlignmentRight;
    toHint.textAlignment = NSTextAlignmentRight;
    fromHint.font = [UIFont systemFontOfSize:10];
    toHint.font = [UIFont systemFontOfSize:10];
    [self.view addSubview:fromHint];
    [self.view addSubview:toHint];
    
    UILabel *formatLabel = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMinX(toHint.frame), CGRectGetMaxY(toHint.frame)+50, CGRectGetWidth(toHint.frame), CGRectGetHeight(toHint.frame))];
    formatLabel.text = @"Date Format:";
    formatLabel.textAlignment = NSTextAlignmentRight;
    formatLabel.font = [UIFont systemFontOfSize:10];
    [self.view addSubview:formatLabel];
    UIPickerView *formatPicker = [[UIPickerView alloc] init];
    formatPicker.frame = CGRectMake(CGRectGetMaxX(formatLabel.frame)+10, CGRectGetMaxY(fromButton.frame), 50, 162);

    [self.view addSubview:formatPicker];
    formatPicker.delegate = self;
    formatPicker.dataSource = self;
    formatPicker.backgroundColor = [UIColor clearColor];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)buttonPressed:(UIButton *)button
{
    NSString *dateString = button.titleLabel.text;
    NSDate *date = [dateFormatter dateFromString:dateString];
    [datePicker setDate:date];
    
    if(activedButton) {
        [activedButton setTintColor:[UIColor colorWithWhite:0.3 alpha:1]];
    }
    [button setTintColor:[UIColor colorWithRed:0 green:0.4 blue:1 alpha:1]];
    activedButton = button;
}

#pragma mark - JCDatePicker Delegate

- (void)datePicker:(JCDatePicker *)datePicker dateDidChange:(NSDate *)date
{
    NSString *dateString = [dateFormatter stringFromDate:date];
    [activedButton setTitle:dateString forState:UIControlStateNormal];
}

#pragma mark - UIPickerView Delegate

- (CGFloat)pickerView:(UIPickerView *)pickerView rowHeightForComponent:(NSInteger)component
{
    return 20;
}

- (CGFloat)pickerView:(UIPickerView *)pickerView widthForComponent:(NSInteger)component
{
    return 50;
}

- (UIView *)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)view
{
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 50, 20)];
    label.textAlignment = NSTextAlignmentCenter;
    label.font = [UIFont systemFontOfSize:9];
    switch (row) {
        case 0:
            label.text = @"Full";
            break;
        case 1:
            label.text = @"Day";
            break;
        case 2:
            label.text = @"Clock";
            break;
        default:
            break;
    }
    return label;
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    switch (row) {
        case 0:
            [datePicker setDateFormat:JCDateFormatFull];
            [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
            break;
        case 1:
            [datePicker setDateFormat:JCDateFormatDay];
            [dateFormatter setDateFormat:@"yyyy-MM-dd"];
            break;
        case 2:
            [datePicker setDateFormat:JCDateFormatClock];
            [dateFormatter setDateFormat:@"HH:mm:ss"];
            break;
            
        default:
            break;
    }
}

#pragma mark - UIPickerView DataSource

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    return 3;
}

@end
