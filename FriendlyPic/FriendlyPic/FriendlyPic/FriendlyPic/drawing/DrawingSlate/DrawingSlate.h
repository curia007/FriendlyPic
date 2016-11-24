#import <UIKit/UIKit.h>

@interface DrawingSlate : UIView

@property (assign, nonatomic) CGContextRef currentContextReference;

- (void) changeLineWeightTo:(NSInteger) weight;
- (void) changeColorTo:(UIColor *) color;

@end
