#import "ViewController.h"
#import "JOYDemoActivationConfig.h"
#import <JoyigameSDK/JoyigameSDK.h>

@interface ViewController ()

@property (nonatomic, strong) UILabel *statusLabel;
@property (nonatomic, strong) UIButton *activateButton;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = UIColor.systemBackgroundColor;
    [self buildActivationDemoUI];
    [self refreshActivationStatusTextWithPrefix:@"等待启动激活回调"];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handleDemoActivationDidFinish:)
                                                 name:JOYDemoActivationDidFinishNotification
                                               object:nil];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)buildActivationDemoUI {
    UILabel *titleLabel = [[UILabel alloc] init];
    titleLabel.translatesAutoresizingMaskIntoConstraints = NO;
    titleLabel.text = @"Joyigame SDK 激活演示";
    titleLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleTitle2];
    titleLabel.textColor = UIColor.labelColor;

    UILabel *paramsLabel = [[UILabel alloc] init];
    paramsLabel.translatesAutoresizingMaskIntoConstraints = NO;
    paramsLabel.numberOfLines = 0;
    paramsLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleFootnote];
    paramsLabel.textColor = UIColor.secondaryLabelColor;
    paramsLabel.text = [NSString stringWithFormat:@"gameid: %@\npartner_type: 100003\n接口: /active", JOYDemoActivationGameId()];

    self.statusLabel = [[UILabel alloc] init];
    self.statusLabel.translatesAutoresizingMaskIntoConstraints = NO;
    self.statusLabel.numberOfLines = 0;
    self.statusLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleBody];
    self.statusLabel.textColor = UIColor.labelColor;

    self.activateButton = [UIButton buttonWithType:UIButtonTypeSystem];
    self.activateButton.translatesAutoresizingMaskIntoConstraints = NO;
    [self.activateButton setTitle:@"重新请求激活" forState:UIControlStateNormal];
    [self.activateButton addTarget:self action:@selector(handleActivationButtonTapped:) forControlEvents:UIControlEventTouchUpInside];

    UIStackView *stackView = [[UIStackView alloc] initWithArrangedSubviews:@[
        titleLabel,
        paramsLabel,
        self.statusLabel,
        self.activateButton
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

- (void)handleActivationButtonTapped:(UIButton *)sender {
    if (!JOYDemoActivationConfigurationIsReady()) {
        self.statusLabel.text = @"请先在 JoyigameSDKDemo/Info.plist 填写 JOYGameId 和 JOYAppKey";
        return;
    }

    sender.enabled = NO;
    [self refreshActivationStatusTextWithPrefix:@"正在请求 /active"];

    [[JOYSDKCenter sharedCenter] startWithGameId:JOYDemoActivationGameId()
                                         appKey:JOYDemoActivationAppKey()
                                     completion:^(JOYActivationConfig * _Nullable config, NSError * _Nullable error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            sender.enabled = YES;
            if (error) {
                self.statusLabel.text = [NSString stringWithFormat:@"激活失败\n%@", error.localizedDescription ?: error.description];
                NSLog(@"[JoyigameSDKDemo] 手动激活失败: %@", error);
                return;
            }

            [self updateStatusWithActivationConfig:config prefix:@"手动激活成功"];
            NSLog(@"[JoyigameSDKDemo] 手动激活成功: %@", config.rawData);
        });
    }];
}

- (void)refreshActivationStatusTextWithPrefix:(NSString *)prefix {
    self.statusLabel.text = prefix;
}

- (void)handleDemoActivationDidFinish:(NSNotification *)notification {
    dispatch_async(dispatch_get_main_queue(), ^{
        NSError *error = notification.userInfo[@"error"];
        if (error) {
            self.statusLabel.text = [NSString stringWithFormat:@"启动激活失败\n%@", error.localizedDescription ?: error.description];
            return;
        }

        JOYActivationConfig *config = notification.userInfo[@"config"];
        [self updateStatusWithActivationConfig:config prefix:@"启动激活成功"];
    });
}

- (void)updateStatusWithActivationConfig:(JOYActivationConfig *)config prefix:(NSString *)prefix {
    self.statusLabel.text = [NSString stringWithFormat:@"%@\ndebug: %ld\nreview: %@\nfloatBall: %ld\nautoLogin: %ld",
                             prefix,
                             (long)config.isDebugEnabled,
                             config.review,
                             (long)config.isFloatBallEnabled,
                             (long)config.isAutoLoginEnabled];
}

@end
