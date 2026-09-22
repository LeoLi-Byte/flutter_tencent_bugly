#import "BuglyLogBridge.h"

@implementation BuglyLogBridge

+ (void)logWithLevel:(BuglyLogLevel)level tag:(nullable NSString *)tag message:(NSString *)message {
    [BuglyLog level:level tag:tag log:@"%@", message];
}

@end