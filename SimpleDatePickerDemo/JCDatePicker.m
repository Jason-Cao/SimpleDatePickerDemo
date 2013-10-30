//
//  JCDatePicker.m
//  SimpleDatePickerDemo
//
//  Created by Jason Cao on 13-7-31.
//
//
#define RGBA(r, g, b, a) [UIColor colorWithRed:r/255.0f green:g/255.0f blue:b/255.0f alpha:a]
//#define CELL_HEIGHT 35
#define CELL_WIDTH_YEAR 66
#define CELL_WIDTH_MONTH 59
#define CELL_WIDTH_DAY 59
#define YEARS_TAG 0
#define MONTHS_TAG 1
#define DAYS_TAG 2

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

@interface PickerBackgroundView : UIView

@property (nonatomic, strong) UIColor *bgColor;
@property (nonatomic, strong) UIColor *bannerColor;
@property (nonatomic, strong) UIColor *separatorLineColor;
@property (nonatomic) float bannerHeight;

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

- (void)layoutSubviews
{
    //    self.backgroundColor = _bgColor;
}

- (void)drawRect:(CGRect)rect
{
    //    CGContextRef context = UIGraphicsGetCurrentContext();
    //    CGContextSetFillColorWithColor(con, [UIColor whiteColor].CGColor);
    //    self.backgroundColor = _bgColor;
    UIView *line1 = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 1, self.frame.size.height)];
    UIView *line2 = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 1, self.frame.size.height)];
    line1.backgroundColor = _separatorLineColor;
    line2.backgroundColor = _separatorLineColor;
    line1.frame = CGRectMake(CELL_WIDTH_YEAR, 0, CGRectGetWidth(line1.frame), CGRectGetHeight(line1.frame));
    line2.frame = CGRectMake(CGRectGetMaxX(line1.frame)+CELL_WIDTH_MONTH, 0, CGRectGetWidth(line2.frame), CGRectGetHeight(line2.frame));
    [self addSubview:line1];
    [self addSubview:line2];
    
    UIView *banner = [[UIView alloc] initWithFrame:CGRectMake(0, (self.frame.size.height-_bannerHeight)/2, self.frame.size.width, _bannerHeight)];
    banner.backgroundColor = _bannerColor;
    banner.alpha = 0.75f;
    banner.layer.shadowColor = [UIColor blackColor].CGColor;
    banner.layer.shadowOffset = CGSizeMake(0, 0);
    banner.layer.shadowRadius = 1.0f;
    banner.layer.shadowOpacity = 0.2f;
    banner.layer.masksToBounds = NO;
    banner.clipsToBounds = NO;
    banner.layer.shadowPath = [UIBezierPath bezierPathWithRect:CGRectMake(0, CGRectGetHeight(banner.bounds) , CGRectGetWidth(banner.bounds), 2.5f)].CGPath;
    CALayer *shadowTop = [CALayer layer];
    shadowTop.shadowColor = [UIColor blackColor].CGColor;
    shadowTop.shadowOffset = CGSizeMake(0, 0);
    shadowTop.shadowRadius = 1.0f;
    shadowTop.shadowOpacity = 0.2f;
    shadowTop.shadowPath = [UIBezierPath bezierPathWithRect:CGRectMake(0, -2.5f, CGRectGetWidth(banner.bounds), 2.5f)].CGPath;
    [banner.layer addSublayer:shadowTop];
    [self addSubview:banner];
    
}

@end

@interface JCDatePicker () {
    
    PickerBackgroundView *pickerBackgroundView;
    UITableView *yearsTable;
    UITableView *monthsTable;
    UITableView *daysTable;
    
    NSInteger daysOfMonth;
    NSInteger selectedYear;
    NSInteger selectedMonth;
    NSInteger selectedDay;
    
    //    NSDateFormatter *dateFormatter;
    NSCalendar *calendar;
    
}

@property (nonatomic) CGFloat cellHeight;

@end

@implementation JCDatePicker

- (void)setStartYear:(NSInteger)startYear
{
    _startYear = startYear;
    [self refreshTable:yearsTable];
}

- (void)setYearRange:(NSInteger)yearRange
{
    _yearRange = yearRange;
    [self refreshTable:yearsTable];
}

- (void)setDate:(NSDate *)date
{
    _date = date;
    NSDateComponents* components = [calendar components:NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit fromDate:date];
    selectedYear = components.year;
    selectedMonth = components.month;
    selectedDay = components.day;
    
    //    if (selectedYear < _startYear || selectedYear > (_startYear + _yearRange)) {
    //        NSLog(@"Year value is out range of date picker");
    //        return;
    //    }
    [self refreshTable:yearsTable];
    [self refreshTable:monthsTable];
    [self refreshTable:daysTable];
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
    [self refreshTable:yearsTable];
    [self refreshTable:monthsTable];
    [self refreshTable:daysTable];
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
    _font = [UIFont systemFontOfSize:9];
    _cellHeight = self.frame.size.height/5;
}

- (void)viewInit
{
    pickerBackgroundView = [[PickerBackgroundView alloc] initWithFrame:CGRectZero];
    yearsTable  = [[UITableView alloc] initWithFrame:CGRectZero];
    monthsTable = [[UITableView alloc] initWithFrame:CGRectZero];
    daysTable   = [[UITableView alloc] initWithFrame:CGRectZero];
    yearsTable.backgroundColor  = [UIColor clearColor];
    monthsTable.backgroundColor = [UIColor clearColor];
    daysTable.backgroundColor   = [UIColor clearColor];
    yearsTable.showsVerticalScrollIndicator  = NO;
    monthsTable.showsVerticalScrollIndicator = NO;
    daysTable.showsVerticalScrollIndicator   = NO;
    yearsTable.separatorStyle  = UITableViewCellSeparatorStyleNone;
    monthsTable.separatorStyle = UITableViewCellSeparatorStyleNone;
    daysTable.separatorStyle   = UITableViewCellSeparatorStyleNone;
    yearsTable.tag = YEARS_TAG;
    monthsTable.tag = MONTHS_TAG;
    daysTable.tag = DAYS_TAG;
    yearsTable.delegate = self;
    yearsTable.dataSource = self;
    monthsTable.delegate = self;
    monthsTable.dataSource = self;
    daysTable.delegate = self;
    daysTable.dataSource = self;
    [self addSubview:pickerBackgroundView];
    [self addSubview:yearsTable];
    [self addSubview:monthsTable];
    [self addSubview:daysTable];
}

- (void)layoutViews
{
    pickerBackgroundView.frame = (CGRect){.origin = CGPointMake(0, 0), .size = self.frame.size};
    pickerBackgroundView.backgroundColor = _bgColor;
    pickerBackgroundView.bannerColor = _pickerColor;
    pickerBackgroundView.bannerHeight = _cellHeight;
    pickerBackgroundView.separatorLineColor = _separatorLineColor;
    
    yearsTable.frame = CGRectMake(0, 0, CELL_WIDTH_YEAR, self.frame.size.height);
    monthsTable.frame = CGRectMake(CGRectGetMaxX(yearsTable.frame)+1, 0, CELL_WIDTH_MONTH, self.frame.size.height);
    daysTable.frame = CGRectMake(CGRectGetMaxX(monthsTable.frame)+1, 0, CELL_WIDTH_DAY, self.frame.size.height);
    yearsTable.contentInset  = UIEdgeInsetsMake((CGRectGetHeight(yearsTable.frame) - _cellHeight)/2, 0, (CGRectGetHeight(yearsTable.frame) - _cellHeight)/2, 0);
    monthsTable.contentInset = UIEdgeInsetsMake((CGRectGetHeight(monthsTable.frame) - _cellHeight)/2, 0, (CGRectGetHeight(monthsTable.frame) - _cellHeight)/2, 0);
    daysTable.contentInset   = UIEdgeInsetsMake((CGRectGetHeight(daysTable.frame) - _cellHeight)/2, 0, (CGRectGetHeight(daysTable.frame) - _cellHeight)/2, 0);
}

- (void)setupControl
{
    
    
    //    dateFormatter = [[NSDateFormatter alloc] init];
    ////    [dateFormatter setTimeZone:]
    ////    [dateFormatter setLocale:];
    //    [dateFormatter setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"zh_CN"]];
    //    [dateFormatter setDateFormat:@"yyyy年 M月 d日"];
    calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    
    [self refreshTable:yearsTable];
    [self refreshTable:monthsTable];
    [self refreshTable:daysTable];
    
}

- (void)refreshTable:(UITableView *)table
{
    switch (table.tag) {
        case YEARS_TAG: {
            [yearsTable reloadData];
            if ((selectedYear < _startYear) || (selectedYear > (_startYear + _yearRange))) {
                selectedYear = _startYear;
            }
            [self scrollToAndSelectIndex:(selectedYear - _startYear) forTableView:yearsTable];
            break;
        }
        case MONTHS_TAG: {
            [monthsTable reloadData];
            [self scrollToAndSelectIndex:(selectedMonth - 1) forTableView:monthsTable];
            break;
        }
        case DAYS_TAG: {
            [daysTable reloadData];
            selectedDay = MIN(daysOfMonth, selectedDay);
            [self scrollToAndSelectIndex:(selectedDay - 1) forTableView:daysTable];
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

- (NSInteger)getIndexForScrollViewPosition:(UIScrollView *)scrollView {
    
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
        case YEARS_TAG:
            return MIN(_yearRange-1, positiveIndex);
            break;
            
        case MONTHS_TAG:
            return MIN(12-1, positiveIndex);
            break;
            
        case DAYS_TAG:
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
        [self refreshTable:daysTable];
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
        case YEARS_TAG: {
            NSInteger nowYear = _startYear + index;
            if (selectedYear != nowYear) {
                selectedYear = nowYear;
                hasChanged = YES;
                [self callBackToUpdateDate];
                
                [self renewDaysOfMonth];
            }
            break;
        }
        case MONTHS_TAG: {
            NSInteger nowMonth = index + 1;
            if (selectedMonth != nowMonth) {
                selectedMonth = nowMonth;
                hasChanged = YES;
                [self callBackToUpdateDate];
                [self renewDaysOfMonth];
            }
            break;
        }
        case DAYS_TAG: {
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
    
    //    if (hasChanged && self.delegate && [self.delegate respondsToSelector:@selector(sharedDatePicker:dateDidChange:)]) {
    //
    //        NSDateComponents *components = [[NSDateComponents alloc] init];
    //        [components setYear:selectedYear];
    //        [components setMonth:selectedMonth];
    //        [components setDay:selectedDay];
    //        NSDate *selectedDate = [calendar dateFromComponents:components];
    //        [self.delegate sharedDatePicker:self dateDidChange:selectedDate];
    //    }
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
        case YEARS_TAG:
            return _yearRange;
            break;
            
        case MONTHS_TAG:
            return 12;
            break;
            
        case DAYS_TAG:
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
        //        [cell addObserver:self forKeyPath:@"selected" options:NSKeyValueObservingOptionNew context:nil];
    }
    cell.textFont = _font;
    switch (tableView.tag) {
        case YEARS_TAG: {
            
            cell.textLabel.text = [NSString stringWithFormat:@"%d年",_startYear + indexPath.row];
            break;
        }
        case MONTHS_TAG: {
            
            cell.textLabel.text = [NSString stringWithFormat:@"%d月",indexPath.row + 1];
            break;
        }
        case DAYS_TAG: {
            
            cell.textLabel.text = [NSString stringWithFormat:@"%d日",indexPath.row + 1];
            break;
        }
        default:
            break;
    }
    return cell;
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    NSLog(@"change: %@",[change valueForKey:@"new"]);
    //    if ((int)[change valueForKey:@"new"] == 1) {
    //        NSLog(@"cell is selected");
    //    }
    if (((UITableViewCell *)object).selected) {
        NSLog(@"////////cell is selected");
        ((UITableViewCell *)object).textLabel.font = [UIFont systemFontOfSize:23];
    }
    //    NSLog(@"key path: %@",keyPath);
    //    if ([object isKindOfClass:[UITableViewCell class]]) {
    //        NSLog(@"kind of uitableviewcell");
    //        
    //    }
    //    NSLog(@"change is %@",change);
}

@end
