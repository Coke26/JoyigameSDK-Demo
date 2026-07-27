#import "JOYDemoPaymentViewController.h"
#import <JoyigameSDK/JoyigameSDK.h>

@interface JOYDemoPaymentItem : NSObject

@property (nonatomic, copy) NSString *displayName;
@property (nonatomic, copy) NSString *productId;
@property (nonatomic, copy) NSString *appleProductId;
@property (nonatomic, copy) NSString *money;
@property (nonatomic, copy) NSString *currency;
@property (nonatomic, copy) NSString *storeDisplayPrice;
@property (nonatomic, copy) NSString *storeCodeStylePrice;
@property (nonatomic, copy) NSString *storeName;
@property (nonatomic, copy) NSString *storeDescriptionText;

@end

@implementation JOYDemoPaymentItem
@end

@interface JOYDemoPaymentViewController ()

@property (nonatomic, strong) UIStackView *contentStackView;
@property (nonatomic, strong) UILabel *statusLabel;
@property (nonatomic, strong) NSMutableArray<JOYDemoPaymentItem *> *items;
@property (nonatomic, strong) NSMutableArray<UILabel *> *itemLabels;

@end

@implementation JOYDemoPaymentViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = UIColor.systemBackgroundColor;
    self.items = [[self buildPaymentItems] mutableCopy];
    self.itemLabels = [NSMutableArray array];
    [self buildPaymentUI];
    [self reloadItemLabels];
}

- (NSArray<JOYDemoPaymentItem *> *)buildPaymentItems {
    return @[
        [self itemWithDisplayName:@"6 元" productId:@"joyi_test_6" appleProductId:@"com.joyigame.demo.pay6" money:@"6"],
        [self itemWithDisplayName:@"30 元" productId:@"joyi_test_30" appleProductId:@"com.joyigame.demo.pay30" money:@"30"],
        [self itemWithDisplayName:@"68 元" productId:@"joyi_test_68" appleProductId:@"com.joyigame.demo.pay68" money:@"68"],
        [self itemWithDisplayName:@"128 元" productId:@"joyi_test_128" appleProductId:@"com.joyigame.demo.pay128" money:@"128"],
    ];
}

- (JOYDemoPaymentItem *)itemWithDisplayName:(NSString *)displayName
                                  productId:(NSString *)productId
                             appleProductId:(NSString *)appleProductId
                                      money:(NSString *)money {
    JOYDemoPaymentItem *item = [[JOYDemoPaymentItem alloc] init];
    item.displayName = displayName;
    item.productId = productId;
    item.appleProductId = appleProductId;
    item.money = money;
    item.currency = @"CNY";
    return item;
}

- (void)buildPaymentUI {
    UIScrollView *scrollView = [[UIScrollView alloc] init];
    scrollView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:scrollView];

    self.contentStackView = [[UIStackView alloc] init];
    self.contentStackView.translatesAutoresizingMaskIntoConstraints = NO;
    self.contentStackView.axis = UILayoutConstraintAxisVertical;
    self.contentStackView.spacing = 14.0;
    [scrollView addSubview:self.contentStackView];

    UILabel *titleLabel = [[UILabel alloc] init];
    titleLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleTitle2];
    titleLabel.textColor = UIColor.labelColor;
    titleLabel.text = @"Joyigame SDK 支付";
    [self.contentStackView addArrangedSubview:titleLabel];

    self.statusLabel = [[UILabel alloc] init];
    self.statusLabel.numberOfLines = 0;
    self.statusLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleFootnote];
    self.statusLabel.textColor = UIColor.secondaryLabelColor;
    self.statusLabel.text = @"等待支付查询或支付操作";
    [self.contentStackView addArrangedSubview:self.statusLabel];

    UIButton *displayButton = [self buttonWithTitle:@"查询展示价格" action:@selector(handleDisplayPriceButtonTapped:)];
    UIButton *infoButton = [self buttonWithTitle:@"查询完整商品信息" action:@selector(handleProductInfoButtonTapped:)];
    [self.contentStackView addArrangedSubview:displayButton];
    [self.contentStackView addArrangedSubview:infoButton];

    for (JOYDemoPaymentItem *item in self.items) {
        UIStackView *itemStack = [[UIStackView alloc] init];
        itemStack.axis = UILayoutConstraintAxisVertical;
        itemStack.spacing = 8.0;
        itemStack.layoutMargins = UIEdgeInsetsMake(12.0, 12.0, 12.0, 12.0);
        itemStack.layoutMarginsRelativeArrangement = YES;
        itemStack.backgroundColor = UIColor.secondarySystemBackgroundColor;

        UILabel *label = [[UILabel alloc] init];
        label.numberOfLines = 0;
        label.font = [UIFont preferredFontForTextStyle:UIFontTextStyleFootnote];
        label.textColor = UIColor.labelColor;
        [itemStack addArrangedSubview:label];
        [self.itemLabels addObject:label];

        UIButton *payButton = [self buttonWithTitle:[NSString stringWithFormat:@"支付 %@", item.displayName]
                                             action:@selector(handlePayButtonTapped:)];
        payButton.tag = [self.items indexOfObject:item];
        [itemStack addArrangedSubview:payButton];

        [self.contentStackView addArrangedSubview:itemStack];
    }

    UILayoutGuide *safeArea = self.view.safeAreaLayoutGuide;
    [NSLayoutConstraint activateConstraints:@[
        [scrollView.leadingAnchor constraintEqualToAnchor:safeArea.leadingAnchor],
        [scrollView.trailingAnchor constraintEqualToAnchor:safeArea.trailingAnchor],
        [scrollView.topAnchor constraintEqualToAnchor:safeArea.topAnchor],
        [scrollView.bottomAnchor constraintEqualToAnchor:safeArea.bottomAnchor],
        [self.contentStackView.leadingAnchor constraintEqualToAnchor:scrollView.contentLayoutGuide.leadingAnchor constant:20.0],
        [self.contentStackView.trailingAnchor constraintEqualToAnchor:scrollView.contentLayoutGuide.trailingAnchor constant:-20.0],
        [self.contentStackView.topAnchor constraintEqualToAnchor:scrollView.contentLayoutGuide.topAnchor constant:20.0],
        [self.contentStackView.bottomAnchor constraintEqualToAnchor:scrollView.contentLayoutGuide.bottomAnchor constant:-20.0],
        [self.contentStackView.widthAnchor constraintEqualToAnchor:scrollView.frameLayoutGuide.widthAnchor constant:-40.0],
    ]];
}

- (UIButton *)buttonWithTitle:(NSString *)title action:(SEL)action {
    UIButton *button = [UIButton buttonWithType:UIButtonTypeSystem];
    [button setTitle:title forState:UIControlStateNormal];
    [button addTarget:self action:action forControlEvents:UIControlEventTouchUpInside];
    return button;
}

- (NSArray<NSString *> *)appleProductIDs {
    NSMutableArray<NSString *> *productIDs = [NSMutableArray array];
    for (JOYDemoPaymentItem *item in self.items) {
        [productIDs addObject:item.appleProductId];
    }
    return productIDs;
}

- (void)handleDisplayPriceButtonTapped:(UIButton *)sender {
    sender.enabled = NO;
    self.statusLabel.text = @"正在查询 StoreKit 展示价格";
    [[JOYSDKCenter sharedCenter] getProductsDisplayValueWithProductIDs:[self appleProductIDs]
                                                               handler:^(NSDictionary *displayPriceDict, NSDictionary *codeStyleDisplayPriceDict) {
        dispatch_async(dispatch_get_main_queue(), ^{
            sender.enabled = YES;
            for (JOYDemoPaymentItem *item in self.items) {
                item.storeDisplayPrice = displayPriceDict[item.appleProductId] ?: @"Apple 商品未配置或无效";
                item.storeCodeStylePrice = codeStyleDisplayPriceDict[item.appleProductId] ?: @"";
            }
            self.statusLabel.text = [NSString stringWithFormat:@"展示价格查询完成\ndisplay=%@\ncodeStyle=%@",
                                     displayPriceDict ?: @{},
                                     codeStyleDisplayPriceDict ?: @{}];
            [self reloadItemLabels];
        });
    }];
}

- (void)handleProductInfoButtonTapped:(UIButton *)sender {
    sender.enabled = NO;
    self.statusLabel.text = @"正在查询 StoreKit 完整商品信息";
    [[JOYSDKCenter sharedCenter] getProductsInformationWithProductIDs:[self appleProductIDs]
                                                              handler:^(NSString *currencyCode, NSString *currencySymbol, NSDictionary *productPriceDict, NSDictionary *productNameDict, NSDictionary *productDescriptionDict) {
        dispatch_async(dispatch_get_main_queue(), ^{
            sender.enabled = YES;
            for (JOYDemoPaymentItem *item in self.items) {
                item.storeName = productNameDict[item.appleProductId] ?: @"Apple 商品未配置或无效";
                item.storeDescriptionText = productDescriptionDict[item.appleProductId] ?: @"";
                item.storeDisplayPrice = productPriceDict[item.appleProductId] ?: item.storeDisplayPrice;
            }
            self.statusLabel.text = [NSString stringWithFormat:@"完整商品信息查询完成\ncurrencyCode=%@\ncurrencySymbol=%@\nprice=%@\nname=%@\ndescription=%@",
                                     currencyCode ?: @"",
                                     currencySymbol ?: @"",
                                     productPriceDict ?: @{},
                                     productNameDict ?: @{},
                                     productDescriptionDict ?: @{}];
            [self reloadItemLabels];
        });
    }];
}

- (void)handlePayButtonTapped:(UIButton *)sender {
    if (sender.tag >= (NSInteger)self.items.count) {
        return;
    }
    JOYDemoPaymentItem *item = self.items[sender.tag];
    sender.enabled = NO;
    self.statusLabel.text = [NSString stringWithFormat:@"正在发起支付：%@", item.displayName];
    NSLog(@"[JoyigameSDKDemo][Payment] 点击支付: productId=%@ appleProductId=%@ money=%@ %@",
          item.productId,
          item.appleProductId,
          item.money,
          item.currency);

    JOYPurchaseRequest *request = [[JOYPurchaseRequest alloc] init];
    request.productId = item.productId;
    request.appleProductId = item.appleProductId;
    request.productName = [NSString stringWithFormat:@"%@档", item.displayName];
    request.money = item.money;
    request.currency = item.currency;
    request.clientOrderId = [NSString stringWithFormat:@"demo_%.0f", NSDate.date.timeIntervalSince1970];
    request.serverId = @"demo_server_1";
    request.serverName = @"Demo 服务器";
    request.roleId = @"demo_role_1";
    request.roleName = @"Demo 角色";
    request.roleLevel = @"1";
    request.extendsInfoData = @"demo_extends";
    request.partner = @"3"; // 苹果支付

    [[JOYSDKCenter sharedCenter] payWithPaymentInfo:request completion:^(JOYPurchaseResult *result, NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            sender.enabled = YES;
            if (error) {
                NSString *message = [self displayMessageForPaymentError:error];
                self.statusLabel.text = [NSString stringWithFormat:@"支付失败\ncode=%ld\n%@", (long)error.code, message];
                NSLog(@"[JoyigameSDKDemo][Payment] 支付失败: domain=%@ code=%ld message=%@",
                      error.domain,
                      (long)error.code,
                      message);
                [self presentPaymentMessageWithTitle:@"支付失败" message:message];
                return;
            }
            self.statusLabel.text = [NSString stringWithFormat:@"支付完成\norderId=%@\ngameOrderId=%@\ntransaction=%@\ndelivered=%@",
                                     result.orderId ?: @"",
                                     result.gameOrderId ?: @"",
                                     result.appleTransactionId ?: @"",
                                     result.delivered ? @"YES" : @"NO"];
            NSLog(@"[JoyigameSDKDemo][Payment] 支付完成: orderId=%@ transaction=%@ delivered=%@",
                  result.orderId,
                  result.appleTransactionId,
                  result.delivered ? @"YES" : @"NO");
        });
    }];
}

- (NSString *)displayMessageForPaymentError:(NSError *)error {
    if ([error.domain isEqualToString:JOYPaymentErrorDomain] && error.code == JOYPaymentErrorNotVerified) {
        return @"请先完成平台登录后再支付";
    }
    return error.localizedDescription ?: error.description ?: @"未知支付错误";
}

- (void)presentPaymentMessageWithTitle:(NSString *)title message:(NSString *)message {
    if (!self.view.window || self.presentedViewController) {
        return;
    }
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:title
                                                                             message:message
                                                                      preferredStyle:UIAlertControllerStyleAlert];
    [alertController addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:nil]];
    [self presentViewController:alertController animated:YES completion:nil];
}

- (void)reloadItemLabels {
    [self.items enumerateObjectsUsingBlock:^(JOYDemoPaymentItem *item, NSUInteger idx, BOOL *stop) {
        (void)stop;
        if (idx >= self.itemLabels.count) {
            return;
        }
        UILabel *label = self.itemLabels[idx];
        label.text = [NSString stringWithFormat:@"%@\nCP 商品 ID: %@\nApple Product ID: %@\n金额: %@ %@\n展示价格: %@\nCode 价格: %@\nApple 名称: %@\nApple 描述: %@",
                      item.displayName,
                      item.productId,
                      item.appleProductId,
                      item.money,
                      item.currency,
                      item.storeDisplayPrice.length > 0 ? item.storeDisplayPrice : @"未查询",
                      item.storeCodeStylePrice.length > 0 ? item.storeCodeStylePrice : @"未查询",
                      item.storeName.length > 0 ? item.storeName : @"未查询",
                      item.storeDescriptionText.length > 0 ? item.storeDescriptionText : @"未查询"];
    }];
}

@end
