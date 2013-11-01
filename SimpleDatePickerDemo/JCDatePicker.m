//
//  JCDatePicker.m
//  SimpleDatePickerDemo
//
//  Created by Jason Cao on 13-7-31.
//
//
#define RGBA(r, g, b, a) [UIColor colorWithRed:r/255.0f green:g/255.0f blue:b/255.0f alpha:a]
//#define CELL_HEIGHT 35
//#define CELL_WIDTH_
#define CELL_WIDTH_YEAR_PERCENTAGE 0.4
#define CELL_WIDTH_MONTH_PERCENTAGE 0.3
#define CELL_WIDTH_DAY_PERCENTAGE 0.3
#define CELL_WIDTH_YEAR 66
#define CELL_WIDTH_MONTH 59
#define CELL_WIDTH_DAY 59
#define YEAR_TAG 0
#define MONTH_TAG 1
#define DAY_TAG 2
#define HOUR_TAG 3
#define MINUTE_TAG 4
#define SECOND_TAG 5



void draw1PxStroke(CGContextRef context, CGPoint startPoint, CGPoint endPoint, CGColorRef color)
{
    CGContextSaveGState(context);
    CGContextSetLineCap(context, kCGLineCapSquare);
    CGContextSetStrokeColorWithColor(context, color);
    CGContextSetLineWidth(context, 1.0);
    CGContextMoveToPoint(context, startPoint.x + 0.5, startPoint.y + 0.5);
    CGContextAddLineToPoint(context, endPoint.x + 0.5, endPoint.y + 0.5);
    CGContextStrokePath(context);
    CGContextRestoreGState(context);
}
void drawLinearGradient(CGContextRef context, CGRect rect, CGColorRef startColor, CGColorRef endColor)
{
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGFloat locations[] = { 0.0, 1.0 };
    
    NSArray *colors = @[(__bridge id) startColor, (__bridge id) endColor];
    
    CGGradientRef gradient = CGGradientCreateWithColors(colorSpace, (__bridge CFArrayRef) colors, locations);
    
    
    CGPoint startPoint = CGPointMake(CGRectGetMidX(rect), CGRectGetMinY(rect));
    CGPoint endPoint = CGPointMake(CGRectGetMidX(rect), CGRectGetMaxY(rect));
    
    CGContextSaveGState(context);
    CGContextAddRect(context, rect);
    CGContextClip(context);
    CGContextDrawLinearGradient(context, gradient, startPoint, endPoint, 0);
    CGContextRestoreGState(context);
    
    CGGradientRelease(gradient);
    CGColorSpaceRelease(colorSpace);
}

#import "JCDatePicker.h"

@interface DateFilterCell : UITableViewCell

@property (nonatomic, strong) UIFont *textFont;

@end

@implementation DateFilterCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        self.contentView.backgroundColor = [UIColor clearColor];
        self.textLabel.backgroundColor = [UIColor clearColor];
        self.textLabel.textAlignment = NSTextAlignmentCenter;
        self.backgroundColor = [UIColor clearColor];
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
    
    if (selected) {
        self.textLabel.font = [_textFont fontWithSize:_textFont.pointSize + 1];
        self.textLabel.textColor = [UIColor whiteColor];
    } else {
        self.textLabel.font = _textFont;
        self.textLabel.textColor = [UIColor blackColor];
    }
}

@end

@interface DatePickerTableView : UITableView

- (id)initWithFrame:(CGRect)frame;

@end

@implementation DatePickerTableView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame style:UITableViewStylePlain];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        self.showsVerticalScrollIndicator = NO;
        self.separatorStyle  = UITableViewCellSeparatorStyleNone;
    }
    return self;
}

@end

@interface PickerBackgroundView : UIView

@property (nonatomic, strong) UIColor *bgColor;
@property (nonatomic, strong) UIColor *bannerColor;
@property (nonatomic, strong) UIColor *separatorLineColor;
@property (nonatomic) float bannerHeight;
@property (nonatomic) JCDateFormat dateFormat;

- (id)initWithFrame:(CGRect)frame;

@end

@implementation PickerBackgroundView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.frame = frame;
    }
    return self;
}

- (void)setDateFormat:(JCDateFormat)dateFormat
{
    if (_dateFormat != dateFormat) {
        _dateFormat = dateFormat;
        [self setNeedsDisplay];
    }
}

- (void)drawRect:(CGRect)rect
{
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, [UIColor clearColor].CGColor);
    CGContextFillRect(context, rect);
    NSArray *portions;
    switch (_dateFormat) {
        case JCDateFormatFull: {
            portions = @[@0.2, @0.36, @0.52, @0.68, @0.84, @1];
        }
            break;
        case JCDateFormatDay: {
            portions = @[@0.4, @0.7, @1];
        }
            break;
        case JCDateFormatClock: {
            portions = @[@0.33, @0.66, @1];
        }
            break;
        default:
            break;
    }
    for (NSNumber *number in portions) {
        CGFloat portion = [number floatValue];
        
        CGPoint startPoint = CGPointMake(portion*rect.size.width, 0);
        CGPoint endPoint = CGPointMake(portion*rect.size.width, rect.size.height);
        draw1PxStroke(context, startPoint, endPoint, _separatorLineColor.CGColor);
    }
    CGRect bannerRect = CGRectMake(0, (rect.size.height-_bannerHeight)/2, rect.size.width, _bannerHeight);
    CGContextSaveGState(context);
    CGContextSetFillColorWithColor(context, [_bannerColor colorWithAlphaComponent:0.75f].CGColor);
    CGContextFillRect(context, bannerRect);
    CGContextRestoreGState(context);

    CGRect upperRect = CGRectMake(0, CGRectGetMinY(bannerRect)-2, CGRectGetWidth(bannerRect), 2);
    CGRect lowerRect = CGRectMake(0, CGRectGetMaxY(bannerRect), CGRectGetWidth(bannerRect), 2);
    drawLinearGradient(context, upperRect, [UIColor clearColor].CGColor, [UIColor colorWithWhite:0 alpha:0.2].CGColor);
    drawLinearGradient(context, lowerRect, [UIColor colorWithWhite:0 alpha:0.2].CGColor, [UIColor clearColor].CGColor);
}

@end

@interface JCDatePicker () {
    
    NSMutableArray *tables;
    PickerBackgroundView *pickerBackgroundView;
    DatePickerTableView *yearTable;
    DatePickerTableView *monthTable;
    DatePickerTableView *dayTable;
    DatePickerTableView *hourTable;
    DatePickerTableView *minuteTable;
    DatePickerTableView *secondTable;
    
    NSInteger daysOfMonth;
    NSInteger selectedYear;
    NSInteger selectedMonth;
    NSInteger selectedDay;
    NSInteger selectedHour;
    NSInteger selectedMinute;
    NSInteger selectedSecond;
    //    NSDateFormatter *dateFormatter;
    NSCalendar *calendar;
    
}

@property (nonatomic) CGFloat cellHeight;

@end

@implementation JCDatePicker

- (void)setStartYear:(NSInteger)startYear
{
    _startYear = startYear;
    [self refreshTable:[tables objectAtIndex:YEAR_TAG]];
}

- (void)setYearRange:(NSInteger)yearRange
{
    _yearRange = yearRange;
    [self refreshTable:[tables objectAtIndex:YEAR_TAG]];
}

- (void)setDate:(NSDate *)date
{
    _date = date;
    NSDateComponents* components = [calendar components:NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit fromDate:date];
    selectedYear = components.year;
    selectedMonth = components.month;
    selectedDay = components.day;
    
    [self refreshTable:[tables objectAtIndex:YEAR_TAG]];
    [self refreshTable:[tables objectAtIndex:MONTH_TAG]];
    [self refreshTable:[tables objectAtIndex:DAY_TAG]];
}

- (void)setBgColor:(UIColor *)bgColor
{
    _bgColor = bgColor;
    [self layoutViews];
}

- (void)setPickerColor:(UIColor *)pickerColor
{
    _pickerColor = pickerColor;
    [self layoutViews];
}

- (void)setSeparatorLineColor:(UIColor *)separatorLineColor
{
    _separatorLineColor = separatorLineColor;
    [self layoutViews];
}

- (void)setFont:(UIFont *)font
{
    _font = font;
    [self refreshTable:[tables objectAtIndex:YEAR_TAG]];
    [self refreshTable:[tables objectAtIndex:MONTH_TAG]];
    [self refreshTable:[tables objectAtIndex:DAY_TAG]];
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        self.frame = frame;
        [self viewInit];
        [self setDefaults];
        [self layoutViews];
        [self setupControl];
    }
    return self;
}

- (void)setDefaults
{
    _startYear = 2000;
    _yearRange = 30;
    daysOfMonth = 31;
    selectedYear = _startYear;
    selectedMonth = 1;
    selectedDay = 1;
    _pickerColor = RGBA(0, 129, 115, 1);
    _separatorLineColor = RGBA(140, 158, 159, 1);
    _bgColor = RGBA(168, 183, 185, 1);
    _font = [UIFont systemFontOfSize:11];
    _cellHeight = self.frame.size.height/5;
}

- (void)viewInit
{
    pickerBackgroundView = [[PickerBackgroundView alloc] initWithFrame:CGRectZero];
    [self addSubview:pickerBackgroundView];
    
    tables = [NSMutableArray array];
    
//    yearTable  = [[DatePickerTableView alloc] initWithFrame:CGRectZero];
//    monthTable = [[DatePickerTableView alloc] initWithFrame:CGRectZero];
//    dayTable   = [[DatePickerTableView alloc] initWithFrame:CGRectZero];
//    hourTable  = [[DatePickerTableView alloc] initWithFrame:CGRectZero];
//    minuteTable = [[DatePickerTableView alloc] initWithFrame:CGRectZero];
//    secondTable = [[DatePickerTableView alloc] initWithFrame:CGRectZero];
//
//    yearTable.tag = YEAR_TAG;
//    monthTable.tag = MONTH_TAG;
//    dayTable.tag = DAY_TAG;
//    hourTable.tag = HOUR_TAG;
//    minuteTable.tag = MINUTE_TAG;
//    secondTable.tag = SECOND_TAG;
//    
//    yearTable.delegate = self;
//    yearTable.dataSource = self;
//    monthTable.delegate = self;
//    monthTable.dataSource = self;
//    dayTable.delegate = self;
//    dayTable.dataSource = self;
//    hourTable.delegate = self;
//    hourTable.dataSource = self;
//    minuteTable.delegate = self;
//    minuteTable.dataSource = self;
//    secondTable.delegate = self;
//    secondTable.dataSource = self;
//    
//    
//    [self addSubview:yearTable];
//    [self addSubview:monthTable];
//    [self addSubview:dayTable];
    
    
}

- (void)layoutViews
{
    self.dateFormat = JCDateFormatDay;
    
    CGSize contentSize = self.frame.size;
    pickerBackgroundView.frame = (CGRect){.origin = CGPointMake(0, 0), .size = contentSize};
    pickerBackgroundView.backgroundColor = _bgColor;
    pickerBackgroundView.bannerColor = _pickerColor;
    pickerBackgroundView.bannerHeight = _cellHeight;
    pickerBackgroundView.separatorLineColor = _separatorLineColor;
    pickerBackgroundView.dateFormat = _dateFormat;
    
    NSArray *portions;
    switch (_dateFormat) {
        case JCDateFormatFull: {
            portions = @[@0.2, @0.36, @0.52, @0.68, @0.84, @1];
        }
            break;
        case JCDateFormatDay: {
            portions = @[@0.4, @0.7, @1];
        }
            break;
        case JCDateFormatClock: {
            portions = @[@0.33, @0.66, @1];
        }
            break;
            
        default:
            break;
    }
    for (int i=0; i<portions.count; i++) {
        float previousPortion = i-1 < 0 ? 0 : [[portions objectAtIndex:i-1] floatValue];
        float portion = [[portions objectAtIndex:i] floatValue];
        CGRect frame = CGRectMake(contentSize.width*previousPortion, 0, contentSize.width*(portion-previousPortion), contentSize.height);
        DatePickerTableView *table = [[DatePickerTableView alloc] initWithFrame:frame];
        table.contentInset = UIEdgeInsetsMake((CGRectGetHeight(table.frame) - _cellHeight)/2, 0, (CGRectGetHeight(table.frame) - _cellHeight)/2, 0);
        
        [tables addObject:table];
        [self addSubview:table];
        table.delegate = self;
        table.dataSource = self;
        
        table.tag = i;
    }
    
//    yearTable.frame = CGRectMake(0, 0, CELL_WIDTH_YEAR_PERCENTAGE*contentSize.width, contentSize.height);
//    monthTable.frame = CGRectMake(CGRectGetMaxX(yearTable.frame)+1, 0, CELL_WIDTH_MONTH_PERCENTAGE*contentSize.width, contentSize.height);
//    dayTable.frame = CGRectMake(CGRectGetMaxX(monthTable.frame)+1, 0, CELL_WIDTH_DAY_PERCENTAGE*contentSize.width, contentSize.height);
//    yearTable.contentInset  = UIEdgeInsetsMake((CGRectGetHeight(yearTable.frame) - _cellHeight)/2, 0, (CGRectGetHeight(yearTable.frame) - _cellHeight)/2, 0);
//    monthTable.contentInset = UIEdgeInsetsMake((CGRectGetHeight(monthTable.frame) - _cellHeight)/2, 0, (CGRectGetHeight(monthTable.frame) - _cellHeight)/2, 0);
//    dayTable.contentInset   = UIEdgeInsetsMake((CGRectGetHeight(dayTable.frame) - _cellHeight)/2, 0, (CGRectGetHeight(dayTable.frame) - _cellHeight)/2, 0);
}

- (void)setupControl
{
    calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    
//    [self refreshTable:yearTable];
//    [self refreshTable:monthTable];
//    [self refreshTable:dayTable];
    [self refreshTable:[tables objectAtIndex:YEAR_TAG]];
    [self refreshTable:[tables objectAtIndex:MONTH_TAG]];
    [self refreshTable:[tables objectAtIndex:DAY_TAG]];
}

- (void)refreshTable:(UITableView *)table
{
    switch (table.tag) {
        case YEAR_TAG: {
            [[tables objectAtIndex:YEAR_TAG] reloadData];
            if ((selectedYear < _startYear) || (selectedYear > (_startYear + _yearRange))) {
                selectedYear = _startYear;
            }
            [self scrollToAndSelectIndex:(selectedYear - _startYear) forTableView:[tables objectAtIndex:YEAR_TAG]];
            break;
        }
        case MONTH_TAG: {
            [[tables objectAtIndex:MONTH_TAG] reloadData];
            [self scrollToAndSelectIndex:(selectedMonth - 1) forTableView:[tables objectAtIndex:MONTH_TAG]];
            break;
        }
        case DAY_TAG: {
            [[tables objectAtIndex:DAY_TAG] reloadData];
            selectedDay = MIN(daysOfMonth, selectedDay);
            [self scrollToAndSelectIndex:(selectedDay - 1) forTableView:[tables objectAtIndex:DAY_TAG]];
        }
        default:
            break;
    }
}

- (void)scrollToAndSelectIndex:(NSInteger)index forTableView:(UITableView *)tableView
{
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:index inSection:0];
    [tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionNone animated:YES];
    [tableView selectRowAtIndexPath:indexPath animated:YES scrollPosition:UITableViewScrollPositionNone];
}

- (NSInteger)getIndexForScrollViewPosition:(UIScrollView *)scrollView
{    
    CGFloat offsetContentScrollView = (scrollView.frame.size.height - _cellHeight) / 2.0f;
    CGFloat offetY = scrollView.contentOffset.y;
    CGFloat index = roundf((offetY + offsetContentScrollView) / _cellHeight);
    return index;
}

- (NSInteger)getCorrectedIndexForTableView:(UITableView *)tableView
{
    NSInteger calculatedIndex = [self getIndexForScrollViewPosition:tableView];
    
    NSInteger positiveIndex = MAX(0, calculatedIndex);
    switch (tableView.tag) {
        case YEAR_TAG:
            return MIN(_yearRange-1, positiveIndex);
            break;
            
        case MONTH_TAG:
            return MIN(12-1, positiveIndex);
            break;
            
        case DAY_TAG:
            return MIN(daysOfMonth-1, positiveIndex);
            break;
            
        default:
            return 0;
            break;
    }
}

- (void)renewDaysOfMonth
{
    NSDateComponents *components = [[NSDateComponents alloc] init];
    [components setYear:selectedYear];
    [components setMonth:selectedMonth];
    [components setDay:1];
    NSDate *firstDay = [calendar dateFromComponents:components];
    NSRange daysRange = [calendar rangeOfUnit:NSDayCalendarUnit inUnit:NSMonthCalendarUnit forDate:firstDay];
    
    if (daysRange.length != daysOfMonth) {
        daysOfMonth = daysRange.length;
        [self refreshTable:dayTable];
    }
    
}

- (void)callBackToUpdateDate
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(datePicker:dateDidChange:)]) {
        
        NSDateComponents *components = [[NSDateComponents alloc] init];
        [components setYear:selectedYear];
        [components setMonth:selectedMonth];
        [components setDay:selectedDay];
        NSDate *selectedDate = [calendar dateFromComponents:components];
        [self.delegate datePicker:self dateDidChange:selectedDate];
    }
    
}

- (void)updateSelectedDateAtIndex:(NSInteger)index forTablelView:(UITableView *)table
{
    BOOL hasChanged = NO;//可能存在多线程问题//可能已解决
    
    switch (table.tag) {
        case YEAR_TAG: {
            NSInteger nowYear = _startYear + index;
            if (selectedYear != nowYear) {
                selectedYear = nowYear;
                hasChanged = YES;
                [self callBackToUpdateDate];
                
                [self renewDaysOfMonth];
            }
            break;
        }
        case MONTH_TAG: {
            NSInteger nowMonth = index + 1;
            if (selectedMonth != nowMonth) {
                selectedMonth = nowMonth;
                hasChanged = YES;
                [self callBackToUpdateDate];
                [self renewDaysOfMonth];
            }
            break;
        }
        case DAY_TAG: {
            NSInteger nowDay = index + 1;
            if (selectedDay != nowDay) {
                selectedDay = nowDay;
                hasChanged = YES;
                [self callBackToUpdateDate];
            }
            break;
        }
        default:
            break;
    }
    
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    
}

- (void)scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset
{
    /*
     Note: scrollView.contentOffset == targetContentOffset
     
     float currentOffsetY = scrollView.contentOffset.y;
     NSLog(@"current offset y: %f",currentOffsetY);
     float targetOffsetY = targetContentOffset->y;
     NSLog(@"target offset y: %f",targetOffsetY);
     float adjustedOffsetY;
     if (currentOffsetY > targetOffsetY) {
     NSLog(@"down");
     adjustedOffsetY = ceil(targetOffsetY/CELL_HEIGHT)*CELL_HEIGHT;
     } else {
     NSLog(@"up");
     adjustedOffsetY = floor(targetOffsetY/CELL_HEIGHT)*CELL_HEIGHT;
     }
     NSLog(@"adjusted offset y: %f",adjustedOffsetY);
     *targetContentOffset = CGPointMake(targetContentOffset->x, adjustedOffsetY);
     NSLog(@"test ceil  = %f",ceil(targetOffsetY/CELL_HEIGHT));
     **/
    
    float targetOffsetY = targetContentOffset->y;
    //    NSLog(@"target offset y: %f",targetOffsetY);
    float adjustedOffsetY = round(targetOffsetY/_cellHeight)*_cellHeight;
    //    NSLog(@"adjusted offset y: %f",adjustedOffsetY);
    
    *targetContentOffset = CGPointMake(targetContentOffset->x, adjustedOffsetY);
}

- (void)selectMiddleRowOnScreenForTableView:(UITableView *)tableView
{
    NSInteger index = [self getIndexForScrollViewPosition:tableView];
    [tableView selectRowAtIndexPath:[NSIndexPath indexPathForRow:index inSection:0] animated:YES scrollPosition:UITableViewScrollPositionNone];
    [self updateSelectedDateAtIndex:index forTablelView:tableView];
}

- (void)scrollViewDidEndScroll:(UIScrollView *)scrollView
{
    [self selectMiddleRowOnScreenForTableView:(UITableView *)scrollView];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    if (!decelerate) {
        NSLog(@"/////////////////scroll end but not decelerate");
        [self scrollViewDidEndScroll:scrollView];
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    [self scrollViewDidEndScroll:scrollView];
}

- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    return nil;
}

- (BOOL)tableView:(UITableView *)tableView shouldHighlightRowAtIndexPath:(NSIndexPath *)indexPath
{
    return NO;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return _cellHeight;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    switch (tableView.tag) {
        case YEAR_TAG:
            return _yearRange;
            break;
            
        case MONTH_TAG:
            return 12;
            break;
            
        case DAY_TAG:
            return daysOfMonth;
            break;
            
        default:
            return 0;
            break;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    DateFilterCell *cell;
    static NSString *cellIdentifier = @"DateCell";
    cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    if (cell == nil) {
        cell = [[DateFilterCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    cell.textFont = _font;
    switch (tableView.tag) {
        case YEAR_TAG: {
            
            cell.textLabel.text = [NSString stringWithFormat:@"%d年",_startYear + indexPath.row];
            break;
        }
        case MONTH_TAG: {
            
            cell.textLabel.text = [NSString stringWithFormat:@"%d月",indexPath.row + 1];
            break;
        }
        case DAY_TAG: {
            
            cell.textLabel.text = [NSString stringWithFormat:@"%d日",indexPath.row + 1];
            break;
        }
        default:
            break;
    }
    return cell;
}

@end
