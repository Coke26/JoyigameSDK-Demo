#import "ViewController.h"
#import "JOYDemoActivationConfig.h"
#import <JoyigameSDK/JoyigameSDK.h>

@interface ViewController ()

@property (nonatomic, strong) UILabel *statusLabel;
@property (nonatomic, strong) UIButton *activateButton;
@property (nonatomic, strong) UILabel *gameLanguageLabel;

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

    UILabel *languageTitleLabel = [[UILabel alloc] init];
    languageTitleLabel.text = @"游戏语言";
    languageTitleLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleTitle2];
    languageTitleLabel.adjustsFontForContentSizeCategory = YES;
    languageTitleLabel.textColor = UIColor.labelColor;
    languageTitleLabel.numberOfLines = 0;

    self.gameLanguageLabel = [[UILabel alloc] init];
    self.gameLanguageLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleBody];
    self.gameLanguageLabel.adjustsFontForContentSizeCategory = YES;
    self.gameLanguageLabel.textColor = UIColor.labelColor;
    self.gameLanguageLabel.numberOfLines = 0;
    [self showGameLanguage:[JOYSDKCenter.sharedCenter getGameLanguage] action:@"当前游戏语言"];

    UILabel *languageHintLabel = [[UILabel alloc] init];
    languageHintLabel.text = @"设置后重启仍保留；未设置时按设备语言返回，不支持的语言默认 us。仅保存游戏语言选择，不切换 SDK 界面文案。";
    languageHintLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleFootnote];
    languageHintLabel.adjustsFontForContentSizeCategory = YES;
    languageHintLabel.textColor = UIColor.secondaryLabelColor;
    languageHintLabel.numberOfLines = 0;

    UIButton *getLanguageButton = [self gameLanguageButtonWithTitle:@"获取当前游戏语言" action:@selector(handleGetGameLanguage:)];
    NSMutableArray<UIButton *> *setLanguageButtons = [NSMutableArray array];
    for (NSArray<NSString *> *item in @[@[@"us", @"设置为英文（us）"],
                                        @[@"vn", @"设置为越南语（vn）"],
                                        @[@"th", @"设置为泰语（th）"]]) {
        UIButton *button = [self gameLanguageButtonWithTitle:item[1] action:@selector(handleSetGameLanguage:)];
        button.accessibilityIdentifier = [@"demo.gameLanguage.set." stringByAppendingString:item[0]];
        button.tag = setLanguageButtons.count;
        [setLanguageButtons addObject:button];
    }
    getLanguageButton.accessibilityIdentifier = @"demo.gameLanguage.get";

    UIStackView *stackView = [[UIStackView alloc] initWithArrangedSubviews:@[
        titleLabel,
        paramsLabel,
        self.statusLabel,
        self.activateButton,
        languageTitleLabel,
        self.gameLanguageLabel,
        languageHintLabel,
        getLanguageButton
    ]];
    stackView.translatesAutoresizingMaskIntoConstraints = NO;
    stackView.axis = UILayoutConstraintAxisVertical;
    stackView.spacing = 16.0;
    stackView.alignment = UIStackViewAlignmentFill;
    for (UIButton *button in setLanguageButtons) [stackView addArrangedSubview:button];
    [stackView setCustomSpacing:32.0 afterView:self.activateButton];

    UIScrollView *scrollView = [[UIScrollView alloc] init];
    scrollView.translatesAutoresizingMaskIntoConstraints = NO;
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

- (UIButton *)gameLanguageButtonWithTitle:(NSString *)title action:(SEL)action {
    UIButton *button = [UIButton buttonWithType:UIButtonTypeSystem];
    [button setTitle:title forState:UIControlStateNormal];
    button.titleLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleBody];
    button.titleLabel.adjustsFontForContentSizeCategory = YES;
    button.titleLabel.numberOfLines = 0;
    button.titleLabel.textAlignment = NSTextAlignmentCenter;
    button.contentEdgeInsets = UIEdgeInsetsMake(8, 8, 8, 8);
    [button.heightAnchor constraintGreaterThanOrEqualToConstant:44.0].active = YES;
    [button addTarget:self action:action forControlEvents:UIControlEventTouchUpInside];
    return button;
}

- (void)showGameLanguage:(NSString *)language action:(NSString *)action {
    NSDictionary<NSString *, NSString *> *names = @{@"us": @"英文", @"vn": @"越南语", @"th": @"泰语"};
    self.gameLanguageLabel.text = [NSString stringWithFormat:@"%@：%@（%@）", action, language, names[language] ?: @""];
}

- (void)handleGetGameLanguage:(UIButton *)sender {
    NSString *language = [JOYSDKCenter.sharedCenter getGameLanguage];
    [self showGameLanguage:language action:@"获取返回"];
    NSLog(@"[JoyigameSDKDemo] getGameLanguage -> %@", language);
}

- (void)handleSetGameLanguage:(UIButton *)sender {
    NSString *language = @[@"us", @"vn", @"th"][sender.tag];
    NSString *applied = [JOYSDKCenter.sharedCenter setGameLanguage:language];
    [self showGameLanguage:applied action:@"设置返回"];
    NSLog(@"[JoyigameSDKDemo] setGameLanguage:%@ -> %@", language, applied);
}

- (void)handleActivationButtonTapped:(UIButton *)sender {
    if (!JOYDemoActivationConfigurationIsReady()) {
        self.statusLabel.text = @"请在 Info.plist 填写 JOYGameId 和 JOYAppKey";
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
