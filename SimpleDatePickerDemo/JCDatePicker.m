//
//  JCDatePicker.m
//  SimpleDatePickerDemo
//
//  Created by Jason Cao on 13-7-31.
//
//
#define RGBA(r, g, b, a) [UIColor colorWithRed:r/255.0f green:g/255.0f blue:b/255.0f alpha:a]
#define DATE_FORMAT_FULL_PORTIONS @[@0.2, @0.16, @0.16, @0.16, @0.16, @0.16]
#define DATE_FORMAT_DAY_PORTIONS @[@0.4, @0.3, @0.3, @0, @0, @0]
#define DATE_FORMAT_CLOCK_PORTIONS @[@0, @0, @0, @0.33, @0.33, @0.34]
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
@property (nonatomic, readonly) UILabel *label;

@end

@implementation DateFilterCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        self.contentView.backgroundColor = [UIColor clearColor];
        self.backgroundColor = [UIColor clearColor];
        _label = [[UILabel alloc] initWithFrame:self.bounds];
        _label.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
        _label.textAlignment = NSTextAlignmentCenter;
        [self addSubview:_label];
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
    
    if (selected) {
        _label.font = [_textFont fontWithSize:_textFont.pointSize + 1];
        _label.textColor = [UIColor whiteColor];
    } else {
        _label.font = _textFont;
        _label.textColor = [UIColor blackColor];
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
//    CGContextClearRect(context, rect);
    CGContextSetFillColorWithColor(context, [UIColor clearColor].CGColor);
    CGContextFillRect(context, rect);
    NSArray *portions;
    switch (_dateFormat) {
        case JCDateFormatFull: {
            portions = DATE_FORMAT_FULL_PORTIONS;
        }
            break;
        case JCDateFormatDay: {
            portions = DATE_FORMAT_DAY_PORTIONS;
        }
            break;
        case JCDateFormatClock: {
            portions = DATE_FORMAT_CLOCK_PORTIONS;
        }
            break;
        default:
            break;
    }
    CGFloat portionSum = 0;
    for (int i=0; i<portions.count; i++) {
        portionSum += [[portions objectAtIndex:i] floatValue];
        if (portionSum > 0 && portionSum < 1) {
            CGPoint startPoint = CGPointMake(portionSum*rect.size.width, 0);
            CGPoint endPoint = CGPointMake(portionSum*rect.size.width, rect.size.height);
            draw1PxStroke(context, startPoint, endPoint, _separatorLineColor.CGColor);
        }
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
    
    NSMutableDictionary *componentTables;
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

- (void)setDateFormat:(JCDateFormat)dateFormat
{
    if (_dateFormat != dateFormat) {
        _dateFormat = dateFormat;
        [self layoutViews];
    }
}

- (void)setStartYear:(NSInteger)startYear
{
    _startYear = startYear;
    [self refreshTable:[componentTables objectForKey:[NSNumber numberWithInt:YEAR_TAG]]];
}

- (void)setYearRange:(NSInteger)yearRange
{
    _yearRange = yearRange;
    [self refreshTable:[componentTables objectForKey:[NSNumber numberWithInt:YEAR_TAG]]];
}

- (void)setDate:(NSDate *)date
{
    _date = date;
    NSDateComponents* components = [calendar components:NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit|NSHourCalendarUnit|NSMinuteCalendarUnit|NSSecondCalendarUnit fromDate:date];
    selectedYear = components.year;
    selectedMonth = components.month;
    selectedDay = components.day;
    selectedHour = components.hour;
    selectedMinute = components.minute;
    selectedSecond = components.second;
    
    [self refreshTables];
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
    [self refreshTables];
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        self.frame = frame;
        [self viewInit];
        [self setDefaults];
        [self layoutViews];
    }
    return self;
}

- (void)viewInit
{
    pickerBackgroundView = [[PickerBackgroundView alloc] initWithFrame:CGRectZero];
    [self addSubview:pickerBackgroundView];
    
    componentTables = [NSMutableDictionary dictionary];
    calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
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
    _dateFormat = JCDateFormatFull;
}

- (void)layoutViews
{
    CGSize contentSize = self.frame.size;
    pickerBackgroundView.frame = (CGRect){.origin = CGPointMake(0, 0), .size = contentSize};
    pickerBackgroundView.backgroundColor = _bgColor;
    pickerBackgroundView.bannerColor = _pickerColor;
    pickerBackgroundView.bannerHeight = _cellHeight;
    pickerBackgroundView.separatorLineColor = _separatorLineColor;
    pickerBackgroundView.dateFormat = _dateFormat;
    
    //clear tables before layout
    for (UITableView *table in componentTables.allValues) {
        [table removeFromSuperview];
    }
    [componentTables removeAllObjects];
    
    NSArray *portions;
    switch (_dateFormat) {
        case JCDateFormatFull: {
            portions = DATE_FORMAT_FULL_PORTIONS;
        }
            break;
        case JCDateFormatDay: {
            portions = DATE_FORMAT_DAY_PORTIONS;
        }
            break;
        case JCDateFormatClock: {
            portions = DATE_FORMAT_CLOCK_PORTIONS;
        }
            break;
        default:
            break;
    }
    CGFloat previousPortionSum = 0;
    for (int i=0; i<portions.count; i++) {
        float currentPortion = [[portions objectAtIndex:i] floatValue];
        if (currentPortion > 0) {
            CGRect frame = CGRectMake(contentSize.width*previousPortionSum, 0, contentSize.width*currentPortion, contentSize.height);
            DatePickerTableView *table = [[DatePickerTableView alloc] initWithFrame:frame];
            table.contentInset = UIEdgeInsetsMake((CGRectGetHeight(table.frame) - _cellHeight)/2, 0, (CGRectGetHeight(table.frame) - _cellHeight)/2, 0);
            [self addSubview:table];
            table.delegate = self;
            table.dataSource = self;
            table.tag = i;
            [componentTables setObject:table forKey:[NSNumber numberWithInt:i]];
        }
        previousPortionSum += currentPortion;
    }
    [self refreshTables];
}

- (void)refreshTables
{
    for (UITableView *table in componentTables.allValues) {
        [self refreshTable:table];
    }
}

- (void)refreshTable:(UITableView *)table
{
    [table reloadData];
    
    switch (table.tag) {
        case YEAR_TAG: {
            
            if ((selectedYear < _startYear) || (selectedYear > (_startYear + _yearRange))) {
                selectedYear = _startYear;
            }
            [self scrollToAndSelectIndex:(selectedYear - _startYear) forTableView:table];
            break;
        }
        case MONTH_TAG: {
            
            [self scrollToAndSelectIndex:(selectedMonth - 1) forTableView:table];
            break;
        }
        case DAY_TAG: {
            
            selectedDay = MIN(daysOfMonth, selectedDay);
            [self scrollToAndSelectIndex:(selectedDay - 1) forTableView:table];
            break;
        }
        case HOUR_TAG: {
            
            [self scrollToAndSelectIndex:selectedHour forTableView:table];
            break;
        }
        case MINUTE_TAG: {
            
            [self scrollToAndSelectIndex:selectedMinute forTableView:table];
            break;
        }
        case SECOND_TAG: {

            [self scrollToAndSelectIndex:selectedSecond forTableView:table];
            break;
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
    CGFloat offsetY = scrollView.contentOffset.y;
    CGFloat index = roundf((offsetY + offsetContentScrollView) / _cellHeight);
    return index;
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
        [self refreshTable:[componentTables objectForKey:[NSNumber numberWithInt:DAY_TAG]]];
    }
    
}

- (void)callBackToUpdateDate
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(datePicker:dateDidChange:)]) {
        
        NSDateComponents *components = [[NSDateComponents alloc] init];
        [components setYear:selectedYear];
        [components setMonth:selectedMonth];
        [components setDay:selectedDay];
        [components setHour:selectedHour];
        [components setMinute:selectedMinute];
        [components setSecond:selectedSecond];
        NSDate *selectedDate = [calendar dateFromComponents:components];
        [self.delegate datePicker:self dateDidChange:selectedDate];
    }
    
}

- (void)updateSelectedDateAtIndex:(NSInteger)index forTablelView:(UITableView *)table
{
//    BOOL hasChanged = NO;//可能存在多线程问题//可能已解决
    
    switch (table.tag) {
        case YEAR_TAG: {
            NSInteger nowYear = _startYear + index;
            if (selectedYear != nowYear) {
                selectedYear = nowYear;
//                hasChanged = YES;
                [self callBackToUpdateDate];
                
                [self renewDaysOfMonth];
            }
            break;
        }
        case MONTH_TAG: {
            NSInteger nowMonth = index + 1;
            if (selectedMonth != nowMonth) {
                selectedMonth = nowMonth;
//                hasChanged = YES;
                [self callBackToUpdateDate];
                [self renewDaysOfMonth];
            }
            break;
        }
        case DAY_TAG: {
            NSInteger nowDay = index + 1;
            if (selectedDay != nowDay) {
                selectedDay = nowDay;
//                hasChanged = YES;
                [self callBackToUpdateDate];
            }
            break;
        }
        case HOUR_TAG: {
            NSInteger nowHour = index;
            if (selectedHour != nowHour) {
                selectedHour = nowHour;
//                hasChanged = YES;
                [self callBackToUpdateDate];
            }
            break;
        }
        case MINUTE_TAG: {
            NSInteger nowMinute = index;
            if (selectedMinute != nowMinute) {
                selectedMinute = nowMinute;
//                hasChanged = YES;
                [self callBackToUpdateDate];
            }
            break;
        }
        case SECOND_TAG: {
            NSInteger nowSecond = index;
            if (selectedSecond != nowSecond) {
                selectedSecond = nowSecond;
//                hasChanged = YES;
                [self callBackToUpdateDate];
            }
            break;
        }

        default:
            break;
    }
    
}

#pragma mark - UIScrollViewDelegate Additional Methods

- (void)scrollViewDidEndScroll:(UIScrollView *)scrollView
{
    [self selectMiddleRowOnScreenForTableView:(UITableView *)scrollView];
}

- (void)selectMiddleRowOnScreenForTableView:(UITableView *)tableView
{
    NSInteger index = [self getIndexForScrollViewPosition:tableView];
    [tableView selectRowAtIndexPath:[NSIndexPath indexPathForRow:index inSection:0] animated:YES scrollPosition:UITableViewScrollPositionNone];
    [self updateSelectedDateAtIndex:index forTablelView:tableView];
}

#pragma mark - UIScrollView Delegate

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
    float adjustedOffsetY = round(targetOffsetY/_cellHeight)*_cellHeight;
    *targetContentOffset = CGPointMake(targetContentOffset->x, adjustedOffsetY);
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

#pragma mark - UITableView Delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self scrollToAndSelectIndex:indexPath.row forTableView:tableView];
    [self updateSelectedDateAtIndex:indexPath.row forTablelView:tableView];
}

- (BOOL)tableView:(UITableView *)tableView shouldHighlightRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return _cellHeight;
}

#pragma mark - UITableView DataSource

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
            
        case HOUR_TAG:
            return 24;
            break;
            
        case MINUTE_TAG:
            return 60;
            break;
            
        case SECOND_TAG:
            return 60;
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
            
            cell.label.text = [NSString stringWithFormat:@"%d年",_startYear + indexPath.row];
            break;
        }
        case MONTH_TAG: {
            
            cell.label.text = [NSString stringWithFormat:@"%d月",indexPath.row + 1];
            break;
        }
        case DAY_TAG: {
            
            cell.label.text = [NSString stringWithFormat:@"%d日",indexPath.row + 1];
            break;
        }
        case HOUR_TAG: {
            
            cell.label.text = [NSString stringWithFormat:@"%d时",indexPath.row];
            break;
        }
        case MINUTE_TAG: {
            
            cell.label.text = [NSString stringWithFormat:@"%d分",indexPath.row];
            break;
        }
        case SECOND_TAG: {

            cell.label.text = [NSString stringWithFormat:@"%d秒",indexPath.row];
            break;
        }
        default:
            break;
    }
    return cell;
}

@end
