//
//  JCDatePicker.h
//  SimpleDatePickerDemo
//
//  Created by Jason Cao on 13-7-31.
//
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>

@class JCDatePicker;

@protocol JCDatePickerDelegate <NSObject>

@optional

- (void)datePicker:(JCDatePicker *)datePicker dateDidChange:(NSDate *)date;

@end

typedef NS_ENUM(NSInteger, JCDateFormat) {
    JCDateFormatFull = 0,
    JCDateFormatDay,
    JCDateFormatClock
};

@interface JCDatePicker : UIControl <UIScrollViewDelegate, UITableViewDelegate, UITableViewDataSource>

@property (nonatomic) JCDateFormat dateFormat;
@property (nonatomic) NSInteger startYear;
@property (nonatomic) NSInteger yearRange;
@property (nonatomic) NSRange rangeOfYear;
@property (nonatomic, weak) id delegate;
@property (nonatomic, strong) NSDate *date;
@property (nonatomic, strong) UIColor *pickerColor;
@property (nonatomic, strong) UIColor *separatorLineColor;
@property (nonatomic, strong) UIFont *font;
@property (nonatomic, strong) UIColor *bgColor;

@end

