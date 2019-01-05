#import "DrifterPlugin.h"
#import <drifter/drifter-Swift.h>

@implementation DrifterPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [SwiftDrifterPlugin registerWithRegistrar:registrar];
}
@end
