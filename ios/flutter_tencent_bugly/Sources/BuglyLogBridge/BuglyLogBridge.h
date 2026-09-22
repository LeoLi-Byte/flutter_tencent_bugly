#import <Foundation/Foundation.h>

#import <Bugly/BuglyLog.h>

NS_ASSUME_NONNULL_BEGIN

/// +[BuglyLog level:tag:log:...] 为 C 可变参数方法，无法桥接进 Swift，由此类代为调用。
@interface BuglyLogBridge : NSObject

/// message 需为已格式化的纯字符串，内部按 "%@" 原样转发，其中的 % 占位符不会被解析。
+ (void)logWithLevel:(BuglyLogLevel)level tag:(nullable NSString *)tag message:(NSString *)message;

@end

NS_ASSUME_NONNULL_END