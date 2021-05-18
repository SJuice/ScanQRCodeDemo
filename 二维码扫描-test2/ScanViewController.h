//
//  ScanViewController.h
//  二维码扫描-test2
//
//  Created by game-netease on 2021/5/17.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface ScanViewController : UIViewController
@property (nonatomic, copy) void(^resultBlock)(NSString *value);
@end

NS_ASSUME_NONNULL_END
