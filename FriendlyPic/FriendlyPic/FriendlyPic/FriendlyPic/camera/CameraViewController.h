


#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import <MessageUI/MessageUI.h>

extern const CGFloat FACE_RECT_BORDER_WIDTH;
extern NSString * const CameraOptionsNotification;

CGFloat DegreesToRadians(CGFloat degrees);
void displayErrorOnMainQueue(NSError *error, NSString *message);

@interface CameraViewController : UIViewController <UIGestureRecognizerDelegate, UIAlertViewDelegate, MFMailComposeViewControllerDelegate>

@property (strong, nonatomic) id dataObject;

@property (strong,nonatomic) AVCaptureStillImageOutput *stillImageOutput;

@property (strong, nonatomic, readonly) AVCaptureSession* session;
@property (strong, nonatomic, readonly) AVCaptureVideoPreviewLayer *previewLayer;
@property (assign, nonatomic, readonly) CGFloat effectiveScale; // pinch-to-zoom maintained by controller

@property (strong, nonatomic) IBOutlet UIBarButtonItem *optionsButton;
@property (weak, nonatomic) IBOutlet UIView *previewView;
@property (strong, nonatomic) UIImageView *stillImageView;
@property (weak, nonatomic) IBOutlet UIToolbar *toolbar;

@property (weak, nonatomic) IBOutlet UISlider *widthSlider;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *clearToolbarItem;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *widthBarButtonItem;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *switchCamera;

// Graphics code will call this when still image capture processing is complete
- (void) unfreezePreview;

- (UIImage *) savePreview;

- (void) setupPreviewForGraphics;
- (void) setupGraphics; // Loads face graphics
- (void) teardownGraphics; // Releases face graphics

- (IBAction) switchCameras:(id) sender;
- (IBAction) handlePinchGesture:(UIGestureRecognizer *) sender;
- (IBAction) takePicture:(id) sender; // grabs a still image and applies the most recent metadata

- (IBAction) clearAction:(id) sender;
- (IBAction) widthAction:(id) sender;
- (IBAction) sliderValueChangedAction:(id) sender;
- (IBAction) optionsAction:(id) sender;

@end
