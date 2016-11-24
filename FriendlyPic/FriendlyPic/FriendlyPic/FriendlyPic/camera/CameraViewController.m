
#import "CameraViewController.h"

#import <AssertMacros.h>
#import <QuartzCore/QuartzCore.h>
#import <CoreImage/CoreImage.h>
#import <ImageIO/ImageIO.h>
#import <AssetsLibrary/AssetsLibrary.h>

#import "UserDefaults.h"
#import "ACEDrawingView.h"

#import "FacebookService.h"
#import "GreenBrushActivity.h"

#import "TwitterService.h"

static inline NSNumber* boxInt(NSInteger x) { return [NSNumber numberWithInt:x]; }
static inline NSInteger unboxInt(NSNumber* x) { return [x integerValue]; }

static CGContextRef CreateCGBitmapContextForSize(CGSize size);
static OSStatus CreateCGImageFromCVPixelBuffer(CVPixelBufferRef pixelBuffer, CGImageRef *imageOut);
static void ReleaseCVPixelBuffer(void *pixel, const void *data, size_t size);
static UIImage* newHorizFlippedImage(UIImage* image);

static BOOL writeCGImageToCameraRoll(CGImageRef cgImage, NSDictionary *metadata);
void writeJPEGDataToCameraRoll(NSData* data, NSDictionary* metadata);

static AVCaptureVideoOrientation avOrientationForDeviceOrientation(UIDeviceOrientation deviceOrientation);

static char * const AVCaptureStillImageIsCapturingStillImageContext = "AVCaptureStillImageIsCapturingStillImageContext";

NSString * const CameraOptionsNotification = @"CameraOptionsNotification";

const CGFloat FACE_RECT_BORDER_WIDTH = 3;

CGFloat DegreesToRadians(CGFloat degrees) {return degrees * M_PI / 180;}

@interface CameraViewController ()
{
	CGFloat beginGestureScale;
    
}

@property (strong, nonatomic) UIView *flashView;
@property (strong, nonatomic) ACEDrawingView *slateView;

@property (strong, nonatomic) AVCaptureSession* session;
@property (strong, nonatomic) AVCaptureVideoPreviewLayer *previewLayer;
@property (assign, nonatomic) CGFloat effectiveScale;

@property (strong, nonatomic) NSDictionary *metadata;

@property (strong, nonatomic) NSTimer *timer;

- (void) optionsSelection:(id) sender;
- (void) setupDrawingSlate;
- (void) composeMail;

- (NSArray *) createActivities;

@end

@implementation CameraViewController

@synthesize flashView = _flashView;
@synthesize slateView = _slateView;

UIStoryboardPopoverSegue *popoverSegue;

- (void) setupAVCapture
{
	[self.previewLayer setBackgroundColor:[[UIColor blackColor] CGColor]];
	[self.previewLayer setVideoGravity:AVLayerVideoGravityResizeAspectFill];
        
    self.previewLayer.frame = self.previewView.bounds;
	[self.previewView.layer addSublayer:self.previewLayer];

	// For saving still images and loads graphics for AVF-based overlays
	[self setupGraphics];
	
	// this will allow us to sync freezing the preview when the image is being captured
	[self.stillImageOutput addObserver:self forKeyPath:@"capturingStillImage" options:NSKeyValueObservingOptionNew context:AVCaptureStillImageIsCapturingStillImageContext];

	[self.session startRunning];
}
					
- (void) teardownAVCapture
{
	[self.session stopRunning];
	
	[self.stillImageOutput removeObserver:self forKeyPath:@"capturingStillImage"];
	
	[self teardownGraphics];
	
	[self.previewLayer removeFromSuperlayer];
	self.previewLayer = nil;
	
	self.session = nil;
}

UIImage *imageFromSampleBuffer(CMSampleBufferRef sampleBuffer)
{
    CVImageBufferRef imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer);
    // Lock the base address of the pixel buffer.
    CVPixelBufferLockBaseAddress(imageBuffer,0);
    
    // Get the number of bytes per row for the pixel buffer.
    size_t bytesPerRow = CVPixelBufferGetBytesPerRow(imageBuffer);
    // Get the pixel buffer width and height.
    size_t width = CVPixelBufferGetWidth(imageBuffer);
    size_t height = CVPixelBufferGetHeight(imageBuffer);
    
    // Create a device-dependent RGB color space.
    static CGColorSpaceRef colorSpace = NULL;
    if (colorSpace == NULL) {
        colorSpace = CGColorSpaceCreateDeviceRGB();
		if (colorSpace == NULL) {
            // Handle the error appropriately.
            return nil;
        }
    }
    
    // Get the base address of the pixel buffer.
    void *baseAddress = CVPixelBufferGetBaseAddress(imageBuffer);
    // Get the data size for contiguous planes of the pixel buffer.
    size_t bufferSize = CVPixelBufferGetDataSize(imageBuffer);
    
    // Create a Quartz direct-access data provider that uses data we supply.
    CGDataProviderRef dataProvider = CGDataProviderCreateWithData(NULL, baseAddress, bufferSize, NULL);
    // Create a bitmap image from data supplied by the data provider.
    CGImageRef cgImage = CGImageCreate(width, height, 8, 32, bytesPerRow, colorSpace, kCGImageAlphaNoneSkipFirst |
                                       kCGBitmapByteOrder32Little, dataProvider, NULL, true, kCGRenderingIntentDefault);
    CGDataProviderRelease(dataProvider);
    
    // Create and return an image object to represent the Quartz image.
    UIImage *image = [UIImage imageWithCGImage:cgImage];
    CGImageRelease(cgImage);
    
    CVPixelBufferUnlockBaseAddress(imageBuffer, 0);
    
    return image;
}

- (AVCaptureDeviceInput*) pickCamera
{
	AVCaptureDevicePosition desiredPosition = (UserDefaults.usingFrontCamera) ? AVCaptureDevicePositionFront : AVCaptureDevicePositionBack;
	BOOL hadError = NO;
	
    for (AVCaptureDevice *d in [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo])
    {
		if ([d position] == desiredPosition)
        {
			NSError *error = nil;
			AVCaptureDeviceInput *input = [AVCaptureDeviceInput deviceInputWithDevice:d error:&error];
			
            if (error)
            {
				hadError = YES;
				displayErrorOnMainQueue(error, @"Could not initialize for AVMediaTypeVideo");
			}
            else if ( [self.session canAddInput:input] )
            {
				return input;
			}
		}
	}
    
	if ( ! hadError )
    {
		// no errors, simply couldn't find a matching camera
		displayErrorOnMainQueue(nil, @"No camera found for requested orientation");
	}
    
	return nil;
}

- (void) updateCameraSelection
{
	// Changing the camera device will reset connection state, so we call the
	// update*Detection functions to resync them.  When making multiple
	// session changes, wrap in a beginConfiguration / commitConfiguration.
	// This will avoid consecutive session restarts for each configuration
	// change (noticeable delay and camera flickering)
	
	[self.session beginConfiguration];
	
	// have to remove old inputs before we test if we can add a new input
	NSArray* oldInputs = [self.session inputs];
	for (AVCaptureInput *oldInput in oldInputs)
		[self.session removeInput:oldInput];
	
	AVCaptureDeviceInput* input = [self pickCamera];
	
    if ( ! input )
    {
		// failed, restore old inputs
		for (AVCaptureInput *oldInput in oldInputs)
        {
			[self.session addInput:oldInput];
        }
	}
    else
    {
		// succeeded, set input and update connection states
		[self.session addInput:input];
	}
    
	[self.session commitConfiguration];
}

// this will freeze the preview when a still image is captured, we will unfreeze it when the graphics code is finished processing the image
- (void) observeValueForKeyPath:(NSString *) keyPath ofObject:(id) object change:(NSDictionary *) change context:(void *)context
{
	if ( context == AVCaptureStillImageIsCapturingStillImageContext )
    {
		BOOL isCapturingStillImage = [[change objectForKey:NSKeyValueChangeNewKey] boolValue];
		
		if ( isCapturingStillImage )
        {
			[self.previewView.superview addSubview:self.flashView];
			[UIView animateWithDuration:0.40f
				animations:^{ self.flashView.alpha=0.65f; }
			 ];
			self.previewLayer.connection.enabled = NO;
		}
	}
}

- (void) setupPreviewForGraphics
{
	[UIView animateWithDuration:.4f
					 animations:^{ self.flashView.alpha=0; }
					 completion:^(BOOL finished){ [self.flashView removeFromSuperview]; }
	 ];
   
    [self setupDrawingSlate];
}

- (void) setupDrawingSlate
{
    _slateView = [[ACEDrawingView alloc] initWithFrame:[[self previewView] frame]];
    [[self slateView] setClipsToBounds:YES];
    [[self slateView] setLineColor:[UIColor blueColor]];
    [[self previewView] addSubview:[self slateView]];
    [[self widthSlider] setValue:[[self slateView] lineWidth]];
}

// Graphics code will call this when still image capture processing is complete
- (void) unfreezePreview
{
	self.previewLayer.connection.enabled = YES;
	[UIView animateWithDuration:.4f
					 animations:^{ self.flashView.alpha=0; }
					 completion:^(BOOL finished){ [self.flashView removeFromSuperview]; }
	 ];
}

- (UIImage *) savePreview
{
    
    [[self stillImageView] addSubview:[self slateView]];
    UIGraphicsBeginImageContext(self.stillImageView.bounds.size);
    [self.stillImageView.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *resultingImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();

    // test
    //NSData *testData = UIImageJPEGRepresentation([self stillImage], 1.0);
    
    return resultingImage;
}

- (void) optionsSelection:(NSNotification *) notification
{
    
#ifdef DEBUG
    NSLog(@"Notfications working:: notification = %@", notification);
#endif
    
    if (popoverSegue != nil)
    {
        [[popoverSegue popoverController] dismissPopoverAnimated:YES];
    }
    
    NSDictionary *userInfo = [notification userInfo];
    
    NSString *object = [userInfo objectForKey:OptionKey];
    if ([object compare:BluePenOption options:NSCaseInsensitiveSearch] == NSOrderedSame)
    {
        [[self slateView] setLineColor:[UIColor blueColor]];
        [[self slateView] setHidden:NO];
    }
    else if ([object compare:GreenPenOption options:NSCaseInsensitiveSearch] == NSOrderedSame)
    {
        [[self slateView] setLineColor:[UIColor greenColor]];
        [[self slateView] setHidden:NO];
    }
    else if ([object compare:YellowPenOption options:NSCaseInsensitiveSearch] == NSOrderedSame)
    {
        [[self slateView] setLineColor:[UIColor yellowColor]];
        [[self slateView] setHidden:NO];
    }
    else if ([object compare:RedPenOption options:NSCaseInsensitiveSearch] == NSOrderedSame)
    {
        [[self slateView] setLineColor:[UIColor redColor]];
        [[self slateView] setHidden:NO];
    }
    else if ([object compare:FacebookOption options:NSCaseInsensitiveSearch] == NSOrderedSame)
    {
        UIImage *image = [self savePreview];
        
        FacebookService *service = [[FacebookService alloc] init];
        [service setAlertViewDelegate:self];
        NSString *name = [NSString stringWithFormat:@"FriendlyPic_%@", @"a"];
        [service installInitialFacebookApplication:image name:name];
        
        service = nil;
        
    }
    else if ([object compare:TwitterOption options:NSCaseInsensitiveSearch] == NSOrderedSame)
    {
        UIImage *image = [self savePreview];
        
        TwitterService *service = [[TwitterService alloc] init];
        [service setAlertViewDelegate:self];
        [service performUploadWithImage:image name:@"FriendlyPic"];

        service = nil;
    }
    else if ([object compare:SaveOption options:NSCaseInsensitiveSearch] == NSOrderedSame)
    {
        UIImage *image = [self savePreview];
        
        ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];
        [library writeImageToSavedPhotosAlbum:[image CGImage] metadata:[self metadata] completionBlock:^(NSURL *assetURL, NSError *error) {
            if (error != nil)
            {
                displayErrorOnMainQueue(error, nil);
            }
            else
            {
                
            }
        }];
    }
    else if ([object compare:MailOption options:NSCaseInsensitiveSearch] == NSOrderedSame)
    {
        _timer = [NSTimer scheduledTimerWithTimeInterval:.50f target:self selector:@selector(composeMail) userInfo:nil repeats:NO];
    }

}

- (void) composeMail
{
    UIImage *image = [self savePreview];
    NSData *imageData = [NSData dataWithData:UIImagePNGRepresentation(image)];
    
    if ([MFMailComposeViewController canSendMail] == NO)
    {
        displayErrorOnMainQueue(nil, @"Your device is unable to send mail.  A valid email account should established.");
    }
    
    MFMailComposeViewController* controller = [[MFMailComposeViewController alloc] init];
    
    controller.mailComposeDelegate = self;
    [controller setSubject:@"My FriendlyPic"];
    [controller addAttachmentData:imageData mimeType:@"image/png" fileName:@"MyPic"];
    
    [self presentViewController:controller animated:YES completion:^{
    }];
}

- (NSArray *) createActivities
{
    //NSMutableArray *activities = [NSMutableArray arrayWithCapacity:8];
    
    // Create Facebook Activity
    //GreenBrushActivity *facebookActivity = [[GreenBrushActivity alloc] init];
    //[activities addObject:facebookActivity];
    
    return nil;
    //return activities;
}

- (void) prepareForSegue:(UIStoryboardSegue *) segue sender:(id) sender
{
    if ([segue isKindOfClass:[UIStoryboardPopoverSegue class]] == YES)
    {
        popoverSegue = (UIStoryboardPopoverSegue *)segue;
    }
}

- (void) willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation) toInterfaceOrientation duration:(NSTimeInterval)duration
{
    self.previewLayer.connection.videoOrientation = toInterfaceOrientation;
    self.previewLayer.frame = self.previewView.bounds;
}

#pragma mark - Interface Builder actions

- (IBAction) switchCameras:(id) sender
{
    [UIView transitionWithView:[self previewView] duration:0.5f options:UIViewAnimationOptionTransitionFlipFromRight animations:^{
     } completion:nil];
    
	UserDefaults.usingFrontCamera = !UserDefaults.usingFrontCamera;
	[self updateCameraSelection];
}

- (IBAction) handlePinchGesture:(UIPinchGestureRecognizer *) recognizer
{
	BOOL allTouchesAreOnThePreviewLayer = YES;
	NSUInteger numTouches = [recognizer numberOfTouches], i;
	
    for ( i = 0; i < numTouches; ++i )
    {
		CGPoint location = [recognizer locationOfTouch:i inView:self.previewView];
		CGPoint convertedLocation = [self.previewLayer convertPoint:location fromLayer:self.previewLayer.superlayer];
		if ( ! [self.previewLayer containsPoint:convertedLocation] )
        {
			allTouchesAreOnThePreviewLayer = NO;
			break;
		}
	}
	
	if ( allTouchesAreOnThePreviewLayer )
    {
		self.effectiveScale = beginGestureScale * recognizer.scale;
		if (self.effectiveScale < 1.0)
			self.effectiveScale = 1.0;
		
        if ( self.stillImageOutput )
        {
			CGFloat maxScaleAndCropFactor = [[self.stillImageOutput connectionWithMediaType:AVMediaTypeVideo] videoMaxScaleAndCropFactor];
			if (self.effectiveScale > maxScaleAndCropFactor)
				self.effectiveScale = maxScaleAndCropFactor;
		}
        
		[CATransaction begin];
		[CATransaction setAnimationDuration:.025];
		[self.previewLayer setAffineTransform:CGAffineTransformMakeScale(self.effectiveScale, self.effectiveScale)];
		[CATransaction commit];
	}
}

#pragma mark - View lifecycle

- (void) dealloc
{
	[self teardownAVCapture];
	_flashView = nil;
}

- (void) viewDidLoad
{
    [super viewDidLoad];

    self.session = [AVCaptureSession new];
	[self.session setSessionPreset:AVCaptureSessionPresetiFrame960x540]; // high-res stills, screen-size video
	
	[self updateCameraSelection];
	
	self.previewLayer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:self.session];

	self.effectiveScale = 1.0;
		
	_flashView = [[UIView alloc] initWithFrame:self.previewView.frame];
	self.flashView.backgroundColor = [UIColor whiteColor];
	self.flashView.alpha = 0;
    
//    _slateView = nil;
//    [[self slateView] setClipsToBounds:YES];
//    [[self previewView] addSubview:[self slateView]];
    
    
	   
}

- (void) viewDidUnload
{
	[self teardownAVCapture];
	[self teardownGraphics];
    
	_flashView = nil;
	self.previewView = nil;

    
    [[NSNotificationCenter defaultCenter] removeObserver:CameraOptionsNotification];
    
    [super viewDidUnload];
}

- (void) viewWillAppear:(BOOL) animated
{
    [super viewWillAppear:animated];
    
}

- (void) viewDidAppear:(BOOL) animated
{
    [super viewDidAppear:animated];
    
    NSArray *devices = [AVCaptureDevice devices];
    
#ifdef DEBUG
    for (id device in devices)
    {
        NSLog(@"device : %@", device);
    }
#endif
    
    // If the array is not nil, the device supports image capture
    if (devices != nil)
    {
        [self setupAVCapture];
    }

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(optionsSelection:)
                                                 name:CameraOptionsNotification object:nil];

}

- (void) viewWillDisappear:(BOOL) animated
{
	[super viewWillDisappear:animated];
}

- (void) viewDidDisappear:(BOOL) animated
{
	[super viewDidDisappear:animated];
}

- (BOOL) shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation) interfaceOrientation
{
    // Return YES for supported orientations
	//return (interfaceOrientation == UIInterfaceOrientationPortrait);
    return YES;
}

- (BOOL) gestureRecognizerShouldBegin:(UIGestureRecognizer *) gestureRecognizer
{
	if ( [gestureRecognizer isKindOfClass:[UIPinchGestureRecognizer class]] )
    {
		beginGestureScale = self.effectiveScale;
	}
	return YES;
}

- (void) didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - 
#pragma mark Camera methods

- (void) setupGraphics
{
    if (self.stillImageOutput != nil)
    {
        [self.session removeOutput:self.stillImageOutput];
        self.stillImageOutput = nil;
    }
    
	self.stillImageOutput = [AVCaptureStillImageOutput new];
	
    if ( [self.session canAddOutput:self.stillImageOutput] )
    {
		[self.session addOutput:self.stillImageOutput];
	}
    else
    {
		self.stillImageOutput = nil;
	}
	
}

- (void) teardownGraphics
{
	self.stillImageOutput = nil;
}

- (IBAction) takePicture:(id) sender
{
    // Check to see if stillImageView exists.  If it exists, unfreeze image
    if ([self stillImageView] != nil)
    {
        [[self stillImageView] removeFromSuperview];
        [[self slateView] removeFromSuperview];
        
        [self setStillImageView:nil];
        [self setSlateView:nil];
        
        [self unfreezePreview];
        
        // disable clear and width buttons
        [[self widthBarButtonItem] setEnabled:NO];
        [[self clearToolbarItem] setEnabled:NO];
        [[self optionsButton] setEnabled:NO];
        
        // enable switch camera button
        [[self switchCamera] setEnabled:YES];
        
        return;
    }
    
    // clear
    [self setMetadata:nil];
    
	// Find out the current orientation and tell the still image output.
	AVCaptureConnection *stillImageConnection = [self.stillImageOutput connectionWithMediaType:AVMediaTypeVideo];
	UIDeviceOrientation currentDeviceOrientation = [[UIDevice currentDevice] orientation];
	AVCaptureVideoOrientation avcaptureOrientation = avOrientationForDeviceOrientation(currentDeviceOrientation);
	[stillImageConnection setVideoOrientation:avcaptureOrientation];
	[stillImageConnection setVideoScaleAndCropFactor:self.effectiveScale];
	[stillImageConnection setAutomaticallyAdjustsVideoMirroring:NO];
	[stillImageConnection setVideoMirrored:[self.previewLayer.connection isVideoMirrored]];
	
    [self.stillImageOutput setOutputSettings:[NSDictionary dictionaryWithObject:AVVideoCodecJPEG
                                                                         forKey:AVVideoCodecKey]];
    
    if (stillImageConnection == nil)
    {
        displayErrorOnMainQueue(nil, @"Encountered an issue creating image");
        [self unfreezePreview];
        
        // disable clear and width buttons
        [[self widthBarButtonItem] setEnabled:NO];
        [[self clearToolbarItem] setEnabled:NO];
        [[self optionsButton] setEnabled:NO];
        
        // enable switch camera button
        [[self switchCamera] setEnabled:YES];

        return;
    }
    
	[self.stillImageOutput captureStillImageAsynchronouslyFromConnection:stillImageConnection completionHandler:
	 ^(CMSampleBufferRef imageDataSampleBuffer, NSError *error) {
         if (error)
         {
             displayErrorOnMainQueue(error, @"Take picture failed");
         }
         else if ( ! imageDataSampleBuffer )
         {
             displayErrorOnMainQueue(nil, @"Take picture failed: received null sample buffer");
         }
         else
         {
             
             // Draw the graphics onto the image we captured
             //CGImageRef cgImageResult = [self imageFromSampleBuffer:imageDataSampleBuffer];
             
             NSData *jpegData = [AVCaptureStillImageOutput jpegStillImageNSDataRepresentation:imageDataSampleBuffer];
             
             CGImageSourceRef source = CGImageSourceCreateWithData((__bridge_retained  CFDataRef)jpegData, NULL);
             
             //get all the metadata in the image
             _metadata = (__bridge NSDictionary *) CGImageSourceCopyPropertiesAtIndex(source,0,NULL);

             // write it to the camera roll
             //NSDictionary* attachments = (__bridge_transfer NSDictionary*)CMCopyDictionaryOfAttachments(kCFAllocatorDefault, imageDataSampleBuffer, kCMAttachmentMode_ShouldPropagate);
             
             //NSLog(@"attachments = %@", attachments);
             NSLog(@"create photo");
             
             UIImage *stillImage = [UIImage imageWithData:jpegData];
             //UIImage *stillImage = [UIImage imageWithCGImage: cgImageResult];
             
             _stillImageView = [[UIImageView alloc] initWithImage:stillImage];
             [[self stillImageView] setFrame:[[self previewView] frame]];
             
             // disable clear and width buttons
             [[self widthBarButtonItem] setEnabled:YES];
             [[self clearToolbarItem] setEnabled:YES];
             [[self optionsButton] setEnabled:YES];
             
             // disable switch camera button
             [[self switchCamera] setEnabled:NO];
             

             //            [[self previewLayer] removeFromSuperlayer];
             //            [[self previewView] addSubview:stillView];
             
             
             //writeCGImageToCameraRoll(cgImageResult,attachments);
             //CGImageRelease(cgImageResult);
         }
         
         // We used KVO in the main CameraViewController to freeze the preview when a still image was captured.
         // Now we are ready to take another image, unfreeze the preview
         dispatch_async(dispatch_get_main_queue(), ^(void) {
             //		[self unfreezePreview];
             [self setupPreviewForGraphics];
         });
     }];
}

- (CGImageRef) imageFromSampleBuffer:(CMSampleBufferRef) sampleBuffer // Create a CGImageRef from sample buffer data
{
    CVImageBufferRef imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer);
    CVPixelBufferLockBaseAddress(imageBuffer,0);        // Lock the image buffer
    
    uint8_t *baseAddress = (uint8_t *)CVPixelBufferGetBaseAddressOfPlane(imageBuffer, 0);   // Get information of the image
    //void *baseAddress = CVPixelBufferGetBaseAddress(imageBuffer);  // Another approach
    
    size_t bytesPerRow = CVPixelBufferGetBytesPerRow(imageBuffer);
    
    size_t width = CVPixelBufferGetWidth(imageBuffer);
    size_t height = CVPixelBufferGetHeight(imageBuffer);
    
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    
    CGContextRef newContext = CGBitmapContextCreate(baseAddress, width, height, 8, bytesPerRow, colorSpace, kCGBitmapByteOrder32Little | kCGImageAlphaPremultipliedFirst);
    
    CGImageRef newImage = CGBitmapContextCreateImage(newContext);
    CGContextRelease(newContext);
    
    CGColorSpaceRelease(colorSpace);
    CVPixelBufferUnlockBaseAddress(imageBuffer,0);
    /* CVBufferRelease(imageBuffer); */  // do not call this!
    
    return newImage;
}

- (CGImageRef) newGraphics:(CMSampleBufferRef) imageDataSampleBuffer
{
	CVImageBufferRef srcCVImageBuffer = CMSampleBufferGetImageBuffer(imageDataSampleBuffer);
	if ( ! srcCVImageBuffer )
    {
		displayErrorOnMainQueue(nil, @"Take picture failed: still image sample buffer did not contain image buffer");
		return NULL;
	}
	
	CGImageRef srcImage = NULL;
	OSStatus err = CreateCGImageFromCVPixelBuffer(srcCVImageBuffer, &srcImage);
	if( err!=noErr || ! srcImage )
    {
		displayErrorOnMainQueue(nil, [NSString stringWithFormat:@"Take picture failed: could not create CGImage (OSStatus %ld, img %p)",err,srcImage]);
		return NULL;
	}
	
	CGRect backgroundImageRect = CGRectMake(0., 0., CGImageGetWidth(srcImage), CGImageGetHeight(srcImage));
	CGContextRef bitmapContext = CreateCGBitmapContextForSize(backgroundImageRect.size);
	if ( ! bitmapContext )
    {
		displayErrorOnMainQueue(nil, @"Take picture failed: could not create CGBitmapContext");
		CFRelease(srcImage);
		return NULL;
	}
	
	CGContextClearRect(bitmapContext, backgroundImageRect);
	CGContextDrawImage(bitmapContext, backgroundImageRect, srcImage);
	CFRelease(srcImage);
    
	// convert the drawing context to a final image
	CGImageRef cgImageResult = CGBitmapContextCreateImage(bitmapContext);
	CGContextRelease (bitmapContext);
	if ( ! cgImageResult )
    {
		displayErrorOnMainQueue(nil, @"Failed to convert context to CGImage");
		return NULL;
	}
    
	return cgImageResult;
}

- (IBAction) clearAction:(id) sender
{
    [[self slateView] undoLatestStep];
}

- (IBAction) widthAction:(id) sender
{
    if ([[self widthSlider] isHidden] == NO)
    {
        [[self widthSlider] setHidden:YES];
    }
    else
    {
        [[self previewView] bringSubviewToFront:[self widthSlider]];
        [[self widthSlider] setHidden:NO];
    }
}

- (IBAction)optionsAction:(id)sender
{
    NSArray *activities = [self createActivities];
        
    UIActivityViewController *activityViewController = [[UIActivityViewController alloc] initWithActivityItems:nil applicationActivities:activities];
    
    [self presentViewController:activityViewController animated:YES completion:^{
    
    }];
}

- (IBAction) sliderValueChangedAction:(id) sender
{
    UISlider *slider = (UISlider *) sender;

#ifdef DEBUG
    NSLog(@"slider value changed : %f", [slider value]);
#endif
    
    [[self slateView] setLineWidth:[slider value]];
}

#pragma mark -
#pragma mark - UIAlertViewDelegate

- (void) alertView:(UIAlertView *) alertView clickedButtonAtIndex:(NSInteger) buttonIndex
{
    NSLog(@"UIAlertView delegate");
    
    // Settings (Cancel)
    if (buttonIndex == 0)
    {
        // [self ]
    }
}

#pragma mark -
#pragma mark MFMailComposeViewControllerDelegate methods

- (void) mailComposeController:(MFMailComposeViewController*) controller didFinishWithResult:(MFMailComposeResult) result error:(NSError*) error
{
    if (error != nil)
    {
        displayErrorOnMainQueue(error, nil);
        return;
    }
    if (result == MFMailComposeResultSent)
    {
        NSLog(@"Friendly Pic sent sucessfully...");
    }

    [controller dismissViewControllerAnimated:YES completion:^{
    }];
}

@end

#pragma mark -
#pragma mark Camera functions

// creates a CGContext of the specified size for doing off-screen graphics
static CGContextRef CreateCGBitmapContextForSize(CGSize size)
{
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGContextRef context = CGBitmapContextCreate (NULL,
                                                  size.width,
                                                  size.height,
                                                  8, // bits per component
                                                  (size.width * 4), // row size - four bytes per pixel
                                                  colorSpace,
                                                  kCGImageAlphaPremultipliedLast);
	CGContextSetAllowsAntialiasing (context, NO);
    CGColorSpaceRelease( colorSpace );
    return context;
}

// locks the base address of the pixel buffer and creates a CGImage referencing the image data
static OSStatus CreateCGImageFromCVPixelBuffer(CVPixelBufferRef pixelBuffer, CGImageRef *imageOut)
{
	CVPixelBufferRetain( pixelBuffer );
	CVPixelBufferLockBaseAddress( pixelBuffer, 0 );
	void *sourceBaseAddr = CVPixelBufferGetBaseAddress( pixelBuffer );
	
	CGBitmapInfo bitmapInfo;
	OSType sourcePixelFormat = CVPixelBufferGetPixelFormatType( pixelBuffer );
	if ( kCVPixelFormatType_32ARGB == sourcePixelFormat )
		bitmapInfo = kCGBitmapByteOrder32Big | kCGImageAlphaNoneSkipFirst;
	else if ( kCVPixelFormatType_32BGRA == sourcePixelFormat )
		bitmapInfo = kCGBitmapByteOrder32Little | kCGImageAlphaNoneSkipFirst;
	else {
		displayErrorOnMainQueue(nil, [NSString stringWithFormat:@"Unknown pixel format %lu",sourcePixelFormat]);
		CVPixelBufferUnlockBaseAddress( pixelBuffer, 0 );
		CVPixelBufferRelease( pixelBuffer );
		return -95014;
	}
	
	size_t sourceRowBytes = CVPixelBufferGetBytesPerRow( pixelBuffer );
	size_t width = CVPixelBufferGetWidth( pixelBuffer );
	size_t height = CVPixelBufferGetHeight( pixelBuffer );
	
	CGColorSpaceRef colorspace = CGColorSpaceCreateDeviceRGB();
    
	CGDataProviderRef provider = CGDataProviderCreateWithData( pixelBuffer, sourceBaseAddr, sourceRowBytes * height, ReleaseCVPixelBuffer );
	if ( provider ) {
		*imageOut = CGImageCreate( width, height, 8, 32, sourceRowBytes, colorspace, bitmapInfo, provider, NULL, true, kCGRenderingIntentDefault );
		CGDataProviderRelease( provider );
	}
	
	if ( colorspace ) CGColorSpaceRelease( colorspace );
	return noErr;
}

// passed as a callback to CGDataProviderCreateWithData for automatic cleanup
static void ReleaseCVPixelBuffer(void *pixel, const void *data, size_t size)
{
	CVPixelBufferRef pixelBuffer = (CVPixelBufferRef)pixel;
	CVPixelBufferUnlockBaseAddress( pixelBuffer, 0 );
	CVPixelBufferRelease( pixelBuffer );
}

// returns a new image flipped over the y axis
static UIImage* newHorizFlippedImage(UIImage* image)
{
	CGRect bounds = CGRectMake(0, 0, image.size.width, image.size.height);
	CGContextRef bitmapContext = CreateCGBitmapContextForSize(bounds.size);
	if ( ! bitmapContext ) {
		displayErrorOnMainQueue(nil, @"Could not flip funny face");
		return image;
	}
	CGContextTranslateCTM(bitmapContext, bounds.size.width, 0);
	CGContextScaleCTM(bitmapContext, -1, 1);
	CGContextDrawImage(bitmapContext, bounds, image.CGImage);
	CGImageRef cgImageResult = CGBitmapContextCreateImage(bitmapContext);
	CGContextRelease (bitmapContext);
	if ( ! cgImageResult ) {
		displayErrorOnMainQueue(nil, @"Failed to convert flipped context to CGImage");
		return image;
	}
	UIImage * ans = [UIImage imageWithCGImage:cgImageResult];
	CGImageRelease(cgImageResult);
	return ans;
}

// takes an image, compresses to JPEG and forwards to writeJPEGDataToCameraRoll()
static BOOL writeCGImageToCameraRoll(CGImageRef cgImage, NSDictionary *metadata)
{
	NSMutableData* destinationData = [NSMutableData dataWithLength:0];
	CGImageDestinationRef destination = CGImageDestinationCreateWithData((__bridge CFMutableDataRef)destinationData, CFSTR("public.jpeg"), 1, NULL);
	if ( destination==NULL ) {
		displayErrorOnMainQueue(nil, @"Save to camera roll failed: could not create destination");
		return NO;
	}
	
	const float JPEGCompQuality = 0.85f; // JPEGHigherQuality
	NSDictionary* optionsDict = @{ (__bridge NSString*)kCGImageDestinationLossyCompressionQuality : [NSNumber numberWithFloat:JPEGCompQuality] };
	
	CGImageDestinationAddImage( destination, cgImage, (__bridge CFDictionaryRef)optionsDict );
	BOOL success = CGImageDestinationFinalize( destination );
	CFRelease(destination);
	if ( success )
    {
		writeJPEGDataToCameraRoll(destinationData, metadata);
	}
    else
    {
		displayErrorOnMainQueue(nil, @"Save to camera roll failed: could not finalize destination");
	}
	
	return success;
}

// converts UIDeviceOrientation to AVCaptureVideoOrientation
static AVCaptureVideoOrientation avOrientationForDeviceOrientation(UIDeviceOrientation deviceOrientation)
{
	AVCaptureVideoOrientation result = deviceOrientation;
	if ( deviceOrientation == UIDeviceOrientationLandscapeLeft )
		result = AVCaptureVideoOrientationLandscapeRight;
	else if ( deviceOrientation == UIDeviceOrientationLandscapeRight )
		result = AVCaptureVideoOrientationLandscapeLeft;
	return result;
}

void displayErrorOnMainQueue(NSError *error, NSString *message)
{
	dispatch_async(dispatch_get_main_queue(), ^(void) {
		UIAlertView* alert = [UIAlertView new];
		
        if(error)
        {
			alert.title = [NSString stringWithFormat:@"%@ (%zd)", message, error.code];
			alert.message = [error localizedDescription];
		}
        else
        {
			alert.title = message;
		}
        
		[alert addButtonWithTitle:@"Dismiss"];
		[alert show];
	});
}

// writes the image to the asset library
void writeJPEGDataToCameraRoll(NSData* data, NSDictionary* metadata)
{
	ALAssetsLibrary *library = [ALAssetsLibrary new];
	[library writeImageDataToSavedPhotosAlbum:data metadata:metadata completionBlock:^(NSURL *assetURL, NSError *error)
     {
         if (error)
         {
             displayErrorOnMainQueue(error, @"Save to camera roll failed");
         }
     }];
}

