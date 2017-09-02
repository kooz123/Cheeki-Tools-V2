// elements of the UI based on the tutorial at: http://codewithchris.com/uipickerview-example/

#import "ViewController.h"
#include "log.h"
#include "sploit.h"
#include "drop_payload.h"

#include <CoreFoundation/CoreFoundation.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <dirent.h>
#include <string.h>
#include <unistd.h>
static char* bundle_path() {
  CFBundleRef mainBundle = CFBundleGetMainBundle();
  CFURLRef resourcesURL = CFBundleCopyResourcesDirectoryURL(mainBundle);
  int len = 4096;
  char* path = malloc(len);
  
  CFURLGetFileSystemRepresentation(resourcesURL, TRUE, (UInt8*)path, len);
  
  return path;
}

NSArray* getBundlePocs() {
  DIR *dp;
  struct dirent *ep;
  
  char* in_path = NULL;
  char* bundle_root = bundle_path();
  asprintf(&in_path, "%s/pocs/", bundle_root);
  
  NSMutableArray* arr = [NSMutableArray array];
  
  dp = opendir(in_path);
  if (dp == NULL) {
    printf("unable to open pocs directory: %s\n", in_path);
    return NULL;
  }
  
  while ((ep = readdir(dp))) {
    if (ep->d_type != DT_REG) {
      continue;
    }
    char* entry = ep->d_name;
    [arr addObject:[NSString stringWithCString:entry encoding:NSASCIIStringEncoding]];
    
  }
  closedir(dp);
  free(bundle_root);
  
  return arr;
}

@interface ViewController ()
@property (weak, nonatomic) IBOutlet UIButton *suicideText;
- (IBAction)suicide:(id)sender;
@property (weak, nonatomic) IBOutlet UILabel *status;
- (IBAction)drinkBtn:(id)sender;
@property (weak, nonatomic) IBOutlet UIButton *drinkTxt;

@end

id vc;
NSArray* bundle_pocs;

@implementation ViewController

- (void)viewDidLoad {
  [super viewDidLoad];
  vc = self;
    _suicideText.enabled = NO;
  // get the list of poc binaries:
  bundle_pocs = getBundlePocs();
}

- (void)didReceiveMemoryWarning {
  [super didReceiveMemoryWarning];
  // Dispose of any resources that can be recreated.
}

// number of columns in picker
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
  return 1;
}

// The number of rows of data
- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
  return [bundle_pocs count];
}

- (NSString*)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
  return [bundle_pocs objectAtIndex:row];
}

- (void)logMsg:(NSString*)msg {
    printf("%s\n", [msg UTF8String]);
  dispatch_async(dispatch_get_main_queue(), ^{
      //_status.text = msg;
  });
}

// the button's initial state is disabled; it's only enabled when the exploit is done
//- (IBAction)getPSButtonClicked:(id)sender {
- (IBAction)getPSButtonClicked:(UIBarButtonItem *)sender {
  char* ps_output = ps();
  logMsg(ps_output);
}

- (IBAction)execButtonClicked:(id)sender {
  // is there at least one poc?
  if ([bundle_pocs count] == 0) {
    return;
  }
  
  // get the currently selected poc index
    NSInteger row = 0;

  // what's the name of that poc?
  NSString* poc_string = [bundle_pocs objectAtIndex:row];
  [self logMsg:poc_string];
  // do this on a different queue?
  dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^(void){
    run_poc((char*)[poc_string cStringUsingEncoding:NSASCIIStringEncoding]);
  });
}

- (void) hasCheeki:(int)b{
    if(b != 1) {
        [_status setText:@"Everything is Cheeki Breeki!"];
        [_drinkTxt setTitle:@"DAVAY DAVAY!" forState:UIControlStateDisabled];
    }else {
        [_status setText:@"Exploit failed"];
        [_drinkTxt setEnabled:YES];
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"panic://"] options:[NSDictionary alloc] completionHandler:nil];
    }
}

- (IBAction)drinkBtn:(id)sender {
  [_status setText:@"Getting drunk..."];
  [_drinkTxt setEnabled:NO];
  [_drinkTxt setTitle:@"Zip. Zip. Zip." forState:UIControlStateDisabled];
  [_suicideText setEnabled:YES];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^(){dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(180 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{

        [self hasCheeki:-1];
    });
    });

  dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^(void){
      int success = -1;
      success = do_exploit();
        if(success == -1) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self hasCheeki:-1];
            });
        } else {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self hasCheeki:0];
            });
        }
  });

}
- (IBAction)suicide:(id)sender {
    UILocalNotification* kek;
    NSString *keksel = [[NSString alloc] initWithContentsOfFile:@"/System/Library/Caches/com.apple.kernelcaches/kernelcache" encoding:NSASCIIStringEncoding error:nil];
    [kek setAlertBody:keksel];
    [kek setAlertTitle:@"RESPRING"];
    [kek setFireDate:[NSDate dateWithTimeIntervalSinceNow:0]];

}
@end

// c method to log string
void logMsg(char* msg) {
  NSString* str = [NSString stringWithCString:msg encoding:NSASCIIStringEncoding];
  [vc logMsg:str];
}
