import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:klinik_aurora_mobile/config/color.dart';
import 'package:klinik_aurora_mobile/config/constants.dart';
import 'package:klinik_aurora_mobile/config/loading.dart';
import 'package:klinik_aurora_mobile/config/storage.dart';
import 'package:klinik_aurora_mobile/controllers/api_response_controller.dart';
import 'package:klinik_aurora_mobile/controllers/auth/auth_controller.dart';
import 'package:klinik_aurora_mobile/models/auth/auth_request.dart';
import 'package:klinik_aurora_mobile/models/auth/auth_response.dart';
import 'package:klinik_aurora_mobile/views/homepage/homepage.dart';
import 'package:klinik_aurora_mobile/views/widgets/button/button.dart';
import 'package:klinik_aurora_mobile/views/widgets/card/card_container.dart';
import 'package:klinik_aurora_mobile/views/widgets/dialog/reusable_dialog.dart';
import 'package:klinik_aurora_mobile/views/widgets/global/error_message.dart';
import 'package:klinik_aurora_mobile/views/widgets/input_field/input_field.dart';
import 'package:klinik_aurora_mobile/views/widgets/input_field/input_field_attribute.dart';
import 'package:klinik_aurora_mobile/views/widgets/layout/layout.dart';
import 'package:klinik_aurora_mobile/views/widgets/padding/app_padding.dart';
import 'package:klinik_aurora_mobile/views/widgets/selectable_text/app_selectable_text.dart';
import 'package:klinik_aurora_mobile/views/widgets/size.dart';
import 'package:klinik_aurora_mobile/views/widgets/typography/typography.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';

bool isSessionExpiredDialogOpen = false;

class LoginPage extends StatefulWidget {
  final bool? resetUser;
  static const routeName = '/login';

  const LoginPage({
    super.key,
    this.resetUser,
  });

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  TextEditingController usernameController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  ValueNotifier<bool> isObscure = ValueNotifier<bool>(false);

  @override
  void initState() {
    SchedulerBinding.instance.scheduleFrameCallback((_) {
      context.read<AuthController>().checkDateTime().then((value) {
        String tokenStatus = value;
        if (tokenStatus == 'expired' || widget.resetUser == true) {
          context.read<AuthController>().logout(context);
        }
        List<String>? rememberMeCredentials = context.read<AuthController>().getRememberMeCredentials();
        bool remember = prefs.getBool(rememberMe) ?? false;
        if (rememberMeCredentials != null && remember) {
          usernameController.text = rememberMeCredentials[0];
          passwordController.text = rememberMeCredentials[1];
        }
      });
    });
    if (kDebugMode) {
      usernameController.text = 'app.user';
      passwordController.text = 'appUser';
      // usernameController.text = 'amin.ariff';
      // passwordController.text = 'Welcome@2028';
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return view();
  }

  Widget view() {
    return FutureBuilder<AuthResponse?>(
      future: context.read<AuthController>().init(context),
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return loadingScreen();
        }
        if (snapshot.connectionState == ConnectionState.done || snapshot.connectionState == ConnectionState.active) {
          return Consumer<AuthController>(
            builder: (context, controller, _) {
              if (controller.authenticationResponse != null &&
                  !DateTime.parse(controller.authenticationResponse!.jwtResponseModel!.expiryDt!)
                      .difference(DateTime.now())
                      .isNegative) {
                Future.delayed(const Duration(milliseconds: 500), () {
                  context.replaceNamed(Homepage.routeName);
                });
                return loadingScreen();
              } else {
                return LayoutWidget(
                  mobile: authPage(),
                  desktop: authPage(),
                );
              }
            },
          );
        }

        return loadingScreen();
      },
    );
  }

  Widget authPage() {
    return Scaffold(
      body: Column(
        children: [
          Container(
            width: screenWidth(100),
            height: screenHeight(100),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: primaryColors,
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Spacer(),
                CardContainer(
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: screenPadding, vertical: screenPadding),
                        child: Column(
                          children: [
                            AppPadding.vertical(denominator: 1 / 2),
                            Container(
                              width: screenWidth(37),
                              height: screenWidth(37),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.grey.withOpacity(0.2),
                                    spreadRadius: 5,
                                    blurRadius: 7,
                                    offset: const Offset(0, 2), // changes position of shadow
                                  ),
                                ],
                              ),
                              child: const ClipOval(
                                child: Image(
                                  image: AssetImage("assets/icons/logo/klinik-aurora.png"),
                                  // color: primary,
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                            // SizedBox(
                            //   child: Image(
                            //     image: const AssetImage("assets/icons/logo/klinik-aurora.png"),
                            //     // color: primary,
                            //     height: screenWidth(40),
                            //   ),
                            // ),
                            // AppSelectableText(
                            //   'GATEWAY',
                            //   style: GoogleFonts.hindMadurai(
                            //     fontSize: 30,
                            //     fontWeight: FontWeight.w800,
                            //     letterSpacing: 15,
                            //     color: primary,
                            //   ),
                            // ),
                            AppPadding.vertical(denominator: 1 / 3),
                            Consumer<AuthController>(builder: (context, snapshot, _) {
                              return Column(
                                children: [
                                  InputField(
                                    field: InputFieldAttribute(
                                      attribute: 'email',
                                      controller: usernameController,
                                      hintText: 'loginPage'.tr(gender: 'username'),
                                      isEmail: true,
                                      isEditableColor: const Color(0xFFEAF2FA),
                                      errorMessage: snapshot.usernameError,
                                      prefixIcon: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        crossAxisAlignment: CrossAxisAlignment.center,
                                        children: [
                                          const SizedBox(
                                            width: 12,
                                          ),
                                          const FaIcon(
                                            Icons.person,
                                            color: primary,
                                          ),
                                          AppPadding.horizontal(denominator: 2),
                                        ],
                                      ),
                                    ),
                                    width: screenHeightByBreakpoint(80, 50, 24),
                                  ),
                                  AppPadding.vertical(),
                                  InputField(
                                    field: InputFieldAttribute(
                                      attribute: 'password',
                                      controller: passwordController,
                                      hintText: 'loginPage'.tr(gender: 'password'),
                                      obscureText: true,
                                      isPassword: true,
                                      isEditableColor: const Color(0xFFEAF2FA),
                                      errorMessage: snapshot.passwordError,
                                      prefixIcon: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        crossAxisAlignment: CrossAxisAlignment.center,
                                        children: [
                                          const SizedBox(
                                            width: 12,
                                          ),
                                          const FaIcon(
                                            Icons.lock,
                                            color: primary,
                                          ),
                                          AppPadding.horizontal(denominator: 2),
                                        ],
                                      ),
                                      obsecureAction: () {
                                        isObscure.value = !isObscure.value;
                                        return null;
                                      },
                                    ),
                                    width: screenHeightByBreakpoint(80, 50, 24),
                                  ),
                                ],
                              );
                            }),
                            AppPadding.vertical(),
                            Consumer<AuthController>(builder: (context, snapshot, _) {
                              return Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Checkbox(
                                    value: snapshot.remember,
                                    onChanged: (value) {
                                      snapshot.remember = value ?? false;
                                    },
                                    activeColor: CupertinoColors.activeBlue,
                                  ),
                                  GestureDetector(
                                    onTap: () {
                                      snapshot.remember = !snapshot.remember;
                                    },
                                    child: const Text(
                                      'Remember Me',
                                    ),
                                  ),
                                ],
                              );
                            }),
                            AppPadding.vertical(denominator: 1),
                            Button(
                              () async {
                                validateField().then((value) {
                                  if (value == true) {
                                    showLoading();
                                    AuthController.logIn(
                                            context,
                                            AuthRequest(
                                                username: usernameController.text, password: passwordController.text))
                                        .then((value) {
                                      dismissLoading();
                                      if (responseCode(value.code)) {
                                        context.read<AuthController>().setAuthenticationResponse(value.data,
                                            usernameValue: usernameController.text,
                                            passwordValue: passwordController.text);
                                      } else if (value.code == 401) {
                                        showDialogError(context, 'error'.tr(gender: 'err-6'));
                                      }
                                    });
                                  }
                                });
                              },
                              color: quaternaryColor,
                              actionText: 'button'.tr(gender: 'login'),
                            ),
                            AppPadding.vertical(),
                          ],
                        ),
                      ),
                    ],
                  ),
                  elevation: 10,
                ),
                SafeArea(
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: screenPadding),
                    child: Column(
                      children: [
                        AppSelectableText(
                          'loginPage'.tr(gender: 'noAccountYet'),
                          style: AppTypography.bodyMedium(context).apply(color: quinaryColor, fontWeightDelta: 1),
                        ),
                        TextButton(
                          onPressed: () {},
                          child: Text(
                            'loginPage'.tr(gender: 'createAnAccount'),
                            style: AppTypography.bodyMedium(context).apply(color: Colors.white, fontWeightDelta: 1),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<bool> validateField() async {
    bool temp = true;
    if (usernameController.text == '') {
      context.read<AuthController>().usernameError = ErrorMessage.required(field: 'loginPage'.tr(gender: 'username'));
      temp = false;
    }
    if (passwordController.text == '') {
      context.read<AuthController>().passwordError = ErrorMessage.required(field: 'loginPage'.tr(gender: 'password'));
      temp = false;
    }
    return temp;
  }

  Widget loadingScreen() {
    return Center(
      child: SizedBox(
        width: 140,
        child: Lottie.asset(
          'assets/lottie/simple-loading.json',
          width: 140,
        ),
      ),
    );
  }
}