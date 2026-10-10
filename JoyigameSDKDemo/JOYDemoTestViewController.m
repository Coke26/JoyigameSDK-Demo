#import "JOYDemoTestViewController.h"
#import <JoyigameSDK/JoyigameSDK.h>

@interface JOYDemoTestViewController ()

@property (nonatomic, strong) UILabel *statusLabel;
@property (nonatomic, strong) UIButton *sdkLoginButton;
@property (nonatomic, strong) UIButton *logoutButton;
@property (nonatomic, strong) UIButton *bindAccountButton;
@property (nonatomic, strong) UIButton *switchAccountButton;
@property (nonatomic, strong) UIButton *cancelAccountButton;

@end

@implementation JOYDemoTestViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = UIColor.systemBackgroundColor;
    [self buildTestingUI];
}

- (void)buildTestingUI {
    UILabel *titleLabel = [[UILabel alloc] init];
    titleLabel.translatesAutoresizingMaskIntoConstraints = NO;
    titleLabel.text = @"Joyigame SDK 测试";
    titleLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleTitle2];
    titleLabel.textColor = UIColor.labelColor;

    UILabel *descriptionLabel = [[UILabel alloc] init];
    descriptionLabel.translatesAutoresizingMaskIntoConstraints = NO;
    descriptionLabel.numberOfLines = 0;
    descriptionLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleFootnote];
    descriptionLabel.textColor = UIColor.secondaryLabelColor;
    descriptionLabel.text = @"这里集中放置项目完成前的临时测试入口，后续可整页删除。";

    self.statusLabel = [[UILabel alloc] init];
    self.statusLabel.translatesAutoresizingMaskIntoConstraints = NO;
    self.statusLabel.numberOfLines = 0;
    self.statusLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleBody];
    self.statusLabel.textColor = UIColor.labelColor;
    self.statusLabel.text = @"等待测试操作";

    self.sdkLoginButton = [UIButton buttonWithType:UIButtonTypeSystem];
    self.sdkLoginButton.translatesAutoresizingMaskIntoConstraints = NO;
    [self.sdkLoginButton setTitle:@"打开 SDK 登录" forState:UIControlStateNormal];
    [self.sdkLoginButton addTarget:self action:@selector(handleSDKLoginButtonTapped:) forControlEvents:UIControlEventTouchUpInside];

    self.logoutButton = [UIButton buttonWithType:UIButtonTypeSystem];
    self.logoutButton.translatesAutoresizingMaskIntoConstraints = NO;
    [self.logoutButton setTitle:@"登出" forState:UIControlStateNormal];
    [self.logoutButton addTarget:self action:@selector(handleLogoutButtonTapped:) forControlEvents:UIControlEventTouchUpInside];

    self.bindAccountButton = [UIButton buttonWithType:UIButtonTypeSystem];
    self.bindAccountButton.translatesAutoresizingMaskIntoConstraints = NO;
    self.bindAccountButton.tag = 1001;
    [self.bindAccountButton setTitle:@"绑定账号" forState:UIControlStateNormal];
    [self.bindAccountButton addTarget:self action:@selector(handleBindAccountButtonTapped:) forControlEvents:UIControlEventTouchUpInside];

    self.switchAccountButton = [UIButton buttonWithType:UIButtonTypeSystem];
    self.switchAccountButton.translatesAutoresizingMaskIntoConstraints = NO;
    self.switchAccountButton.tag = 1002;
    [self.switchAccountButton setTitle:@"切换账号" forState:UIControlStateNormal];
    [self.switchAccountButton addTarget:self action:@selector(handleSwitchAccountButtonTapped:) forControlEvents:UIControlEventTouchUpInside];

    self.cancelAccountButton = [UIButton buttonWithType:UIButtonTypeSystem];
    self.cancelAccountButton.translatesAutoresizingMaskIntoConstraints = NO;
    self.cancelAccountButton.tag = 1003;
    [self.cancelAccountButton setTitle:@"注销账号" forState:UIControlStateNormal];
    [self.cancelAccountButton addTarget:self action:@selector(handleCancelAccountButtonTapped:) forControlEvents:UIControlEventTouchUpInside];

    UIStackView *stackView = [[UIStackView alloc] initWithArrangedSubviews:@[
        titleLabel,
        descriptionLabel,
        self.statusLabel,
        self.sdkLoginButton,
        self.logoutButton,
        self.bindAccountButton,
        self.switchAccountButton,
        self.cancelAccountButton
    ]];
    stackView.translatesAutoresizingMaskIntoConstraints = NO;
    stackView.axis = UILayoutConstraintAxisVertical;
    stackView.spacing = 16.0;
    stackView.alignment = UIStackViewAlignmentFill;
    [self.view addSubview:stackView];

    UILayoutGuide *safeArea = self.view.safeAreaLayoutGuide;
    [NSLayoutConstraint activateConstraints:@[
        [stackView.leadingAnchor constraintEqualToAnchor:safeArea.leadingAnchor constant:24.0],
        [stackView.trailingAnchor constraintEqualToAnchor:safeArea.trailingAnchor constant:-24.0],
        [stackView.topAnchor constraintEqualToAnchor:safeArea.topAnchor constant:48.0],
    ]];
}

- (void)handleSDKLoginButtonTapped:(UIButton *)sender {
    sender.enabled = NO;
    self.statusLabel.text = @"正在打开 SDK 登录";

    [[JOYSDKCenter sharedCenter] startLoginWithCompletion:^(JOYSDKLoginResult * _Nullable result, NSError * _Nullable error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            sender.enabled = YES;
            if (error) {
                NSLog(@"[JoyigameSDKDemo] SDK 登录失败: %@", error);
                self.statusLabel.text = [NSString stringWithFormat:@"SDK 登录失败\n%@", error.localizedDescription ?: error.description];
                return;
            }
            NSLog(@"[JoyigameSDKDemo] SDK 登录成功: uid=%@", result.uid);
            self.statusLabel.text = [NSString stringWithFormat:@"SDK 登录成功\nuid: %@\nusername: %@\ntoken: %@",
                                     result.uid ?: @"",
                                     result.username ?: @"",
                                     result.token.length > 0 ? @"已返回" : @"未返回"];
        });
    }];
}

- (void)handleLogoutButtonTapped:(UIButton *)sender {
    sender.enabled = NO;
    self.statusLabel.text = @"正在登出";

    [[JOYSDKCenter sharedCenter] logoutWithCompletion:^(BOOL success, NSError * _Nullable error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            sender.enabled = YES;
            if (!success || error) {
                self.statusLabel.text = [NSString stringWithFormat:@"登出失败\n%@", error.localizedDescription ?: error.description ?: @"未知错误"];
                NSLog(@"[JoyigameSDKDemo] 登出失败: %@", error);
                return;
            }

            self.statusLabel.text = @"登出成功\n已清理当前 session，并隐藏悬浮球";
            NSLog(@"[JoyigameSDKDemo] 登出成功");
        });
    }];
}

- (void)handleBindAccountButtonTapped:(UIButton *)sender {
    sender.enabled = NO;
    self.statusLabel.text = @"正在打开账号绑定";

    [[JOYSDKCenter sharedCenter] bindAccountWithCompletion:^(BOOL success, NSError * _Nullable error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            sender.enabled = YES;
            if (!success || error) {
                self.statusLabel.text = [NSString stringWithFormat:@"账号绑定失败\n%@", error.localizedDescription ?: error.description ?: @"未知错误"];
                NSLog(@"[JoyigameSDKDemo] 账号绑定失败: %@", error);
                return;
            }

            self.statusLabel.text = @"账号绑定流程已打开\n账号已绑定时 SDK 会直接提示";
            NSLog(@"[JoyigameSDKDemo] 账号绑定流程已打开或账号已绑定");
        });
    }];
}

- (void)handleSwitchAccountButtonTapped:(UIButton *)sender {
    sender.enabled = NO;
    self.statusLabel.text = @"正在切换账号";

    [[JOYSDKCenter sharedCenter] switchAccountWithCompletion:^(JOYSDKLoginResult * _Nullable result, NSError * _Nullable error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            sender.enabled = YES;
            if (error) {
                self.statusLabel.text = [NSString stringWithFormat:@"切换账号失败\n%@", error.localizedDescription ?: error.description];
                NSLog(@"[JoyigameSDKDemo] 切换账号失败: %@", error);
                return;
            }

            self.statusLabel.text = [NSString stringWithFormat:@"切换账号成功\nuid: %@\nusername: %@",
                                     result.uid ?: @"",
                                     result.username ?: @""];
            NSLog(@"[JoyigameSDKDemo] 切换账号成功: uid=%@", result.uid);
        });
    }];
}

- (void)handleCancelAccountButtonTapped:(UIButton *)sender {
    sender.enabled = NO;
    self.statusLabel.text = @"正在注销账号";

    [[JOYSDKCenter sharedCenter] cancelAccountWithCompletion:^(BOOL success, NSError * _Nullable error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            sender.enabled = YES;
            if (!success || error) {
                self.statusLabel.text = [NSString stringWithFormat:@"注销账号失败\n%@", error.localizedDescription ?: error.description ?: @"未知错误"];
                NSLog(@"[JoyigameSDKDemo] 注销账号失败: %@", error);
                return;
            }

            self.statusLabel.text = @"注销账号成功\n已清理当前 session，并隐藏悬浮球";
            NSLog(@"[JoyigameSDKDemo] 注销账号成功");
            // 注销成功后，需自行调用 SDK登录接口
        });
    }];
}

@end
