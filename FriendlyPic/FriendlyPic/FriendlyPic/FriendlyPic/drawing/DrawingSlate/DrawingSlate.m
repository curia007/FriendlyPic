#import "DrawingSlate.h"

@interface DrawingSlate ()

@property (nonatomic, strong) NSMutableArray *drawingPaths;
@property (nonatomic, strong) NSMutableArray *drawingColors;

@end

@implementation DrawingSlate

@synthesize drawingPaths = _drawingPaths;
@synthesize drawingColors = _drawingColors;

@synthesize currentContextReference = _currentContextReference;

#pragma mark - Initialization

- (id)initWithFrame:(CGRect)frame
{
    
    self = [super initWithFrame:frame];
    
    if (self)
    {        
        //Initialize MGDrawingSlate and set default values
        self.backgroundColor = [UIColor clearColor];
        
        _drawingPaths = [NSMutableArray arrayWithCapacity:1];
        _drawingColors = [NSMutableArray arrayWithCapacity:1];
     
    }
    
    return self;
    
}

#pragma mark - Customization Methods

//Call from view controller to change the line weight of the drawing path. Alternatively, just change [drawingSlate]->drawingPath.lineWidth.
- (void) changeLineWeightTo:(NSInteger) weight
{
    // modify to support array of UIBezierPath
   // self.drawingPath.lineWidth = weight;
    
}

//Call from view controller to change the color of the drawing path. Alternatively, just change [drawingSlate]->drawingColor.
- (void) changeColorTo:(UIColor *) color
{
    [[self drawingColors] addObject:color];
}

#pragma mark - Drawing Methods

- (void) drawRect:(CGRect) rect
{
   
    //[self.drawingColor setStroke];
 
    _currentContextReference = UIGraphicsGetCurrentContext();
    
    if ([[self drawingPaths] count] == 0)
    {
        return;
    }
    
    NSUInteger index = [[self drawingPaths] count];
    NSUInteger colorIndex = [[self drawingColors] count];
    
    for (NSInteger i = 0; i < index; i++)
    {
        if (colorIndex <= index)
        {
            if ([[self drawingColors] count] == 0 )
            {
                // set default color
                [[UIColor blackColor] setStroke];
            }
            else
            {
                UIColor *color = nil;
                if ( i >= colorIndex )
                {
                    color = [[self drawingColors] lastObject];
                }
                else
                {
                    color = [[self drawingColors] objectAtIndex:i];
                }
                
                [color setStroke];
            }
        }
        else
        {
            if ([[self drawingColors] count] == 0 )
            {
                // set default color
                [[UIColor blackColor] setStroke];
            }
            else
            {
                UIColor *color = [[self drawingColors] lastObject];
                [color setStroke];
            }
        }
        
        
        UIBezierPath *drawingPath = [[self drawingPaths] objectAtIndex:i];
        [drawingPath strokeWithBlendMode:kCGBlendModeNormal alpha:1.0];

    }

}

-(void)touchesBegan:(NSSet *) touches withEvent:(UIEvent *) event
{
    
    UITouch *touch = [[touches allObjects] objectAtIndex:0];
    
    // create new drawing path to add to array latter    
    UIBezierPath *drawingPath = [[UIBezierPath alloc] init];
    drawingPath.lineCapStyle = kCGLineCapRound;
    drawingPath.miterLimit = 0;
    drawingPath.lineWidth = 4; //Default line weight - change with changeLineWeightTo: method.

    [drawingPath moveToPoint:[touch locationInView:self]];
    [[self drawingPaths] addObject:[drawingPath copy]];
    
}

-(void) touchesMoved:(NSSet *) touches withEvent:(UIEvent *) event
{
    
    UITouch *touch = [[touches allObjects] objectAtIndex:0];

    if (([self drawingPaths] != nil) && [[self drawingPaths] count] > 0)
    {
        [[[self drawingPaths] lastObject] addLineToPoint:[touch locationInView:self]];
    }
    
    [self setNeedsDisplay];
    
}

@end