#import "JOYDemoTestViewController.h"
#import <JoyigameSDK/JoyigameSDK.h>

@interface JOYDemoTestViewController ()

@property (nonatomic, strong) UILabel *statusLabel;
@property (nonatomic, assign) BOOL observingAccountSwitch;
@property (nonatomic, strong) UIButton *sdkLoginButton;
@property (nonatomic, strong) UIButton *logoutButton;
@property (nonatomic, strong) UIButton *bindAccountButton;
@property (nonatomic, strong) UIButton *switchAccountButton;
@property (nonatomic, strong) UIButton *cancelAccountButton;

@end

@implementation JOYDemoTestViewController

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        [self registerForAccountSwitchNotifications];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)coder {
    self = [super initWithCoder:coder];
    if (self) {
        [self registerForAccountSwitchNotifications];
    }
    return self;
}

- (void)registerForAccountSwitchNotifications {
    if (self.observingAccountSwitch) return;
    self.observingAccountSwitch = YES;
    // 场景连接时先创建所有 Tab，再启动 SDK；登录页尚未加载时也必须能接收内部切换。
    NSNotificationCenter *notifications = NSNotificationCenter.defaultCenter;
    JOYSDKCenter *center = JOYSDKCenter.sharedCenter;
    [notifications addObserver:self selector:@selector(handleSwitchAccountDidSucceed:)
                         name:JOYSDKSwitchAccountDidSucceedNotification object:center];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = UIColor.systemBackgroundColor;
    [self buildTestingUI];
}

- (void)dealloc {
    [NSNotificationCenter.defaultCenter removeObserver:self];
}

- (UILabel *)labelWithText:(NSString *)text style:(UIFontTextStyle)style color:(UIColor *)color {
    UILabel *label = [[UILabel alloc] init];
    label.translatesAutoresizingMaskIntoConstraints = NO;
    label.numberOfLines = 0;
    label.font = [UIFont preferredFontForTextStyle:style];
    label.adjustsFontForContentSizeCategory = YES;
    label.textColor = color;
    label.text = text;
    return label;
}

- (void)buildTestingUI {
    UILabel *titleLabel = [self labelWithText:@"账号操作"
                                        style:UIFontTextStyleTitle2 color:UIColor.labelColor];
    self.statusLabel = [self labelWithText:@"请选择操作"
                                    style:UIFontTextStyleBody color:UIColor.labelColor];

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
    for (UIButton *button in @[self.sdkLoginButton, self.logoutButton, self.bindAccountButton,
                                self.switchAccountButton, self.cancelAccountButton]) {
        button.titleLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleBody];
        button.titleLabel.adjustsFontForContentSizeCategory = YES;
        button.titleLabel.numberOfLines = 0;
        button.titleLabel.textAlignment = NSTextAlignmentCenter;
        button.titleLabel.lineBreakMode = NSLineBreakByWordWrapping;
        button.contentEdgeInsets = UIEdgeInsetsMake(8.0, 8.0, 8.0, 8.0);
        [button.heightAnchor constraintGreaterThanOrEqualToConstant:44.0].active = YES;
        [button.heightAnchor constraintGreaterThanOrEqualToAnchor:button.titleLabel.heightAnchor constant:16.0].active = YES;
    }

    UIScrollView *scrollView = [[UIScrollView alloc] init];
    scrollView.translatesAutoresizingMaskIntoConstraints = NO;
    scrollView.alwaysBounceVertical = YES;
    [self.view addSubview:scrollView];
    [scrollView addSubview:stackView];

    UILayoutGuide *safeArea = self.view.safeAreaLayoutGuide;
    [NSLayoutConstraint activateConstraints:@[
        [scrollView.leadingAnchor constraintEqualToAnchor:safeArea.leadingAnchor],
        [scrollView.trailingAnchor constraintEqualToAnchor:safeArea.trailingAnchor],
        [scrollView.topAnchor constraintEqualToAnchor:safeArea.topAnchor],
        [scrollView.bottomAnchor constraintEqualToAnchor:safeArea.bottomAnchor],
        [stackView.leadingAnchor constraintEqualToAnchor:scrollView.contentLayoutGuide.leadingAnchor constant:24.0],
        [stackView.trailingAnchor constraintEqualToAnchor:scrollView.contentLayoutGuide.trailingAnchor constant:-24.0],
        [stackView.topAnchor constraintEqualToAnchor:scrollView.contentLayoutGuide.topAnchor constant:24.0],
        [stackView.bottomAnchor constraintEqualToAnchor:scrollView.contentLayoutGuide.bottomAnchor constant:-24.0],
        [stackView.widthAnchor constraintEqualToAnchor:scrollView.frameLayoutGuide.widthAnchor constant:-48.0],
    ]];
}

// notification.userInfo 为 nil，只表示旧账号已退出；新账号信息由下方登录 completion 返回。
// 真实游戏先清理角色和连接，再像 Demo 一样正常调用登录接口。
- (void)handleSwitchAccountDidSucceed:(NSNotification *)notification {
    // 自动登录后可能尚未打开登录 Tab，先准备展示状态，再处理新一次登录。
    [self loadViewIfNeeded];
    [self startSDKLogin];
}

- (void)showLoginResult:(JOYSDKLoginResult *)result prefix:(NSString *)prefix {
    self.statusLabel.text = [NSString stringWithFormat:@"%@\nuid: %@\nusername: %@\ntoken: %@",
                             prefix, result.uid ?: @"", result.username ?: @"",
                             result.token.length > 0 ? @"已返回" : @"未返回"];
}

- (void)startSDKLogin {
    self.sdkLoginButton.enabled = NO;
    self.statusLabel.text = @"正在打开 SDK 登录";
    __weak typeof(self) weakSelf = self;
    [JOYSDKCenter.sharedCenter startLoginWithCompletion:^(JOYSDKLoginResult *result, NSError *error) {
        __strong typeof(weakSelf) self = weakSelf;
        if (!self) return;
        self.sdkLoginButton.enabled = YES;
        if (error) {
            self.statusLabel.text = [NSString stringWithFormat:@"SDK 登录失败\n%@", error.localizedDescription ?: error.description];
            return;
        }
        // 新账号信息通过本次 completion 获取，SDK 不再发送通用登录成功通知。
        [self showLoginResult:result prefix:@"SDK 登录成功"];
    }];
}

- (void)handleSDKLoginButtonTapped:(UIButton *)sender {
    [self startSDKLogin];
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

            self.statusLabel.text = @"登出操作成功";
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

            [self showLoginResult:result prefix:@"切换账号成功"];
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

            self.statusLabel.text = @"注销账号操作成功";
            NSLog(@"[JoyigameSDKDemo] 注销账号成功");
            // 注销成功后，需自行调用 SDK登录接口
        });
    }];
}

@end
