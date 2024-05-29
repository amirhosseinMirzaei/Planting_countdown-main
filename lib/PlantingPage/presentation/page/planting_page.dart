import 'dart:async';
import 'dart:convert';
import 'dart:math';

// import 'package:app_tutorial/app_tutorial.dart';
// import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:lottie/lottie.dart';
// import 'package:notruphil/features/ForestReportPage/presentation/page/forest_report_page.dart';
// import 'package:notruphil/features/ForestReportPage/presentation/page/my_phone_report_page.dart';
import 'package:plant/background_service.dart';
import 'package:plant/notification/local_notifictions.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sleek_circular_slider/sleek_circular_slider.dart';
import 'package:wakelock/wakelock.dart';

// import '../../../../core/services/planting_service.dart';
// import '../../../../core/utils/MyTools.dart';
// import '../../../../core/utils/app_theme.dart';
// import '../../../../core/utils/my_material_page_route.dart';
// import '../../../../core/widgets/TutorialItemContent.dart';
// import '../../../../core/widgets/my_bottom_navigation_bar.dart';
import '../widgets/CustomSwitch.dart';

class PlantingPage extends StatefulWidget {
  const PlantingPage({Key? key}) : super(key: key);

  @override
  State<PlantingPage> createState() => _PlantingPageState();
}

enum Types { STUDY, SPORT, OTHER, ENTERTAINMENT, REST, SOCIAL, WORK, UNSET }

class _PlantingPageState extends State<PlantingPage>
    with TickerProviderStateMixin, WidgetsBindingObserver {
  AnimationController? _lottieController;
  //amirhossein
  late OverlayEntry _overlayEntry;
  Types _selectedType = Types.STUDY;
  int _selectedTreeNum = 2;

  final messagesKey = GlobalKey();
  final screenOnKey = GlobalKey();
  final durationKey = GlobalKey();
  final operationKey = GlobalKey();

  final myReadKey = GlobalKey();
  final myPhoneKey = GlobalKey();

  // List<TutorialItem> tutorialItems = [];


  void initItems() {
    // tutorialItems.addAll({
    //   TutorialItem(
    //     globalKey: messagesKey,
    //     color: Colors.black.withOpacity(0.6),
    //     borderRadius: const Radius.circular(15.0),
    //     shapeFocus: ShapeFocus.roundedSquare,
    //     child: TutorialItemContent(
    //       myChildKey: messagesKey,
    //       title: 'پیام ها',
    //       content: 'اینجا پیام های انگیزشین ، برای شارژ شدن روحیه ات',
    //     ),
    //   ),
    //   TutorialItem(
    //     globalKey: screenOnKey,
    //     color: Colors.black.withOpacity(0.6),
    //     borderRadius: const Radius.circular(15.0),
    //     shapeFocus: ShapeFocus.roundedSquare,
    //     child: TutorialItemContent(
    //       myChildKey: screenOnKey,
    //       title: 'صفحه روشن',
    //       content: 'با روشن کردن این دکمه ، صفحه گوشی شما خاموش نمیشود',
    //     ),
    //   ),
    //   TutorialItem(
    //     globalKey: durationKey,
    //     color: Colors.black.withOpacity(0.6),
    //     borderRadius: const Radius.circular(15.0),
    //     shapeFocus: ShapeFocus.roundedSquare,
    //     child: TutorialItemContent(
    //       myChildKey: durationKey,
    //       title: 'مدت فعالیت',
    //       content: 'با منوی گردان میتونی مدت فعالیت رو به دقیقه تعیین کنی',
    //     ),
    //   ),
    //   TutorialItem(
    //     globalKey: operationKey,
    //     color: Colors.black.withOpacity(0.6),
    //     borderRadius: const Radius.circular(15.0),
    //     shapeFocus: ShapeFocus.roundedSquare,
    //     child: TutorialItemContent(
    //       myChildKey: operationKey,
    //       title: 'نوع فعالیت',
    //       content: 'اینجا میتونی نوع فعالیت خودت رو تعیین کنی',
    //     ),
    //   ),
    //   TutorialItem(
    //     globalKey: myReadKey,
    //     color: Colors.black.withOpacity(0.6),
    //     borderRadius: const Radius.circular(15.0),
    //     shapeFocus: ShapeFocus.roundedSquare,
    //     child: TutorialItemContent(
    //       myChildKey: myReadKey,
    //       title: 'مطالعات من',
    //       content: 'از این طریق میزان مطالعات و کارهایی که در طول روز انجام دادی رو ببینی',
    //     ),
    //   ),
    //   TutorialItem(
    //     globalKey: myPhoneKey,
    //     color: Colors.black.withOpacity(0.6),
    //     borderRadius: const Radius.circular(15.0),
    //     shapeFocus: ShapeFocus.roundedSquare,
    //     child: TutorialItemContent(
    //       myChildKey: myPhoneKey,
    //       title: 'گوشی من',
    //       content: 'این پنل میزان استفاده شما از هر اپلیکیشن رو نمایش میدهد',
    //     ),
    //   ),
    // });
  } //21:39

  PlantingService? pService;

  @override
  void initState() {
    // readPreviousDatas();
    WidgetsBinding.instance.addObserver(this);
    pService = PlantingService();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await readPreviousDatas();
      await runAfterBuild();
      setState(() {});
    });
    WidgetsFlutterBinding.ensureInitialized();

    initItems();
    _lottieController =
        AnimationController(vsync: this, duration: leftDuration);

    super.initState();
  }

  Future<void> runAfterBuild() async {
    // MyTools.showTutorial(pageName: "PlantingPage", context: context, tutorialItems: tutorialItems);

    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text('Run after build')));
    var prefs = await SharedPreferences.getInstance();
    final remain = prefs.getInt('countdownSeconds');
    bool hasToContinue = (remain != null);

    if (leftDuration.inSeconds > 0 && hasToContinue) {
      _startWorking();
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('start_working')));
      isWorking = true;
    }
  }

  Future<void> setEndTime() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final DateTime dateTimeNow = DateTime.now();
    final endTime = dateTimeNow.add(leftDuration);
    prefs.setString('end_time', endTime.toString());
  }

  Future<void> readPreviousDatas() async {
    //amirhossein

    var prefs = await SharedPreferences.getInstance();
    var endTime = DateTime.parse(prefs.getString('end_time')!);
    final DateTime dateTimeNow = DateTime.now();

    int leftseconds = endTime.difference(dateTimeNow).inSeconds;

    if (dateTimeNow.isAfter(endTime)) {
      await clearTime();
    } else {
      leftDuration = Duration(seconds: leftseconds);
    }

    _selectedType = Types.values[prefs.getInt("_selectedType") ?? 0];
    _selectedTreeNum = prefs.getInt("_selectedTreeNum") ?? 1;
    isWakeScreen = prefs.getBool("isWakeScreen") ?? false;
    _setScreenWakeSetting();

    //if (_lottieController != null) _lottieController!.dispose();

    setState(() {});
  }

  void writeCurrentData() async {
    var prefs = await SharedPreferences.getInstance();
    await prefs.setInt("_selectedType", _selectedType.index);
    await prefs.setInt("_selectedTreeNum", _selectedTreeNum);
    await prefs.setBool("isWakeScreen", isWakeScreen);

    if (mounted) {
      setState(() {});
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    try {
      if (_lottieController != null) {
        _lottieController!.dispose();
      }
    } catch (e) {
      debugPrint(e.toString());
    }

    try {
      if (pService != null && pService!.timer != null)
        pService!.timer!.cancel();
    } catch (e) {
      debugPrint(e.toString());
    }

    writeCurrentData();
    super.dispose();
  }

  Duration selectedDuration = const Duration(minutes: 2);
  Duration leftDuration = const Duration(minutes: 2);

  bool isWorking = false;

//  late Timer timer;

//amirhossein
//clear sharedpreferences time
  Future<void> clearTime() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('countdownSeconds');
    await prefs.remove('end_time');
  }

  _startWorking() {
    //amirhossein
    _overlayEntry = OverlayEntry(
      builder: (context) => Positioned.fill(
        child: GestureDetector(
          onTap: () {},
          child: Container(
            color: Colors.white.withOpacity(0),
          ),
        ),
      ),
    );
    Overlay.of(context).insert(_overlayEntry);
    if (leftDuration.inMinutes == 2 && _lottieController != null) {
      _lottieController!.reset(); // Reset the animation
      _lottieController!.forward(); // Start the animation again
    }
    //if (_lottieController != null) _lottieController!.duration = leftDuration;

    try {
      pService!.startForegroundService(type: _selectedType);

      pService!.timer =
          Timer.periodic(const Duration(seconds: 1), (Timer timer) {
        //fixme set duration on 1 seconds
        isWorking = true;
        print(leftDuration.inSeconds);
        if (leftDuration.inSeconds > 0) {
          leftDuration = leftDuration - const Duration(seconds: 1);
        } else {
          LocalNotification.showSimpleNotification(
              title: 'Notruphil',
              body: 'this is a notification',
              payload: 'timer is down');
          _overlayEntry.remove();
          writeReportData();
          _stopWorking();
          clearTime(); //cleartimer in sharedpreferenc//amirhossein
          _showNotification(
              title: "خسته نباشی",
              body:
                  "فعالیت ${getTypeName(type: _selectedType)} شما به پایان رسید");

          // MyTools.showAlert(
          //   type: DialogType.success,
          //   context: context,
          //   title: "خسته نباشی",
          //   desc: "همینطور ادامه بده ، موفق باشی",
          //   btnOk: "تایید",
          //   btnCancel: "ادامه",
          //   btnOkOnPress: () {},
          //   btnCancelOnPress: () {},
          // ).show();
        }

        if (_lottieController != null) {
          var left = selectedDuration.inSeconds.toDouble() -
              leftDuration.inSeconds.toDouble();

          //_lottieController!.animateTo(left);
          _lottieController!.forward(from: left / (selectedDuration.inSeconds));
        }

        setState(() {});
      });
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  _resetAnimationController() {
    if (_lottieController != null) {
      _lottieController!.stop(canceled: true);
      _lottieController!.reset();
    }
  }

  _stopWorking() {
    setState(() {
      isWorking = false;

      _resetAnimationController();

      if (pService != null && pService!.timer != null) {
        pService!.timer!.cancel();
        pService!.stopService();
      }
    });
  }

  late ScaffoldMessengerState scaffoldMessenger;

  bool isWakeScreen = false;

  @override
  Widget build(BuildContext context) {
    scaffoldMessenger = ScaffoldMessenger.of(context);
    var screenSize = MediaQuery.of(context).size;

    return WillPopScope(
        onWillPop: _onBackPressed,
        child: Scaffold(
          // backgroundColor: AppColor.forestBackground,
          // bottomNavigationBar: Visibility(visible: !isWorking, child: MyBottomNavigationBar(context: context, index: 3)),
          body: Container(
            margin: const EdgeInsets.only(top: 24),
            width: screenSize.width,
            height: screenSize.height,
            // color: AppColor.forestBackground,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Expanded(child: SizedBox()),
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 8),
                  child: Text(_getForestMessage(),
                      key: messagesKey,
                      textDirection: TextDirection.rtl,
                      style: const TextStyle(
                        fontSize: 20,
                        // color: AppColor.forestForeground,
                      )),
                ),

                if (!kIsWeb) ...[
                  const Expanded(child: SizedBox()),
                  CustomSwitch(
                    key: screenOnKey,
                    value: isWakeScreen,
                    onChanged: (bool val) {
                      setState(() {
                        isWakeScreen = val;
                        _setScreenWakeSetting();
                        if (isWakeScreen) _showScreenHintMessage();
                      });
                    },
                  )
                ],

                const Expanded(child: SizedBox()),
                SizedBox(
                  width: screenSize.width - 180,
                  height: screenSize.width - 180,
                  child: SleekCircularSlider(
                      key: durationKey,
                      min: -1,
                      max: 121,
                      innerWidget: (value) {
                        return Container(
                            margin: const EdgeInsets.all(12),
                            decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                                color: Color(0xffF4E869)),
                            child: LottieBuilder.asset(
                                "assets/lottie/plant" +
                                    _selectedTreeNum.toString() +
                                    ".json",
                                controller: _lottieController));
                      },
                      initialValue: leftDuration.inMinutes.toDouble(),
                      appearance: CircularSliderAppearance(
                          angleRange: 360,
                          startAngle: 270,
                          size: screenSize.width - 150,
                          animationEnabled: true,
                          customColors: CustomSliderColors(
                              // progressBarColor: AppColor.forestForeground,
                              // shadowColor: AppColor.forestForeground,
                              // trackColor: AppColor.white
                              ),
                          customWidths: CustomSliderWidths(
                              trackWidth: 5, progressBarWidth: 12),
                          infoProperties: InfoProperties(
                              mainLabelStyle: const TextStyle(
                            color: Colors.transparent,
                            // backgroundColor: AppColor.forestForeground
                          ))),
                      onChangeEnd: (isWorking)
                          ? null
                          : (double value) {
                              if (!isWorking) {
                                _resetAnimationController();
                                setState(() {
                                  selectedDuration =
                                      Duration(minutes: value.toInt());
                                  leftDuration =
                                      Duration(minutes: value.toInt());
                                });
                              }
                            },
                      onChange: (isWorking)
                          ? null
                          : (double value) {
                              if (!isWorking) {
                                setState(() {
                                  leftDuration =
                                      Duration(minutes: value.toInt());
                                });
                              }
                            }),
                ),
                const Expanded(child: SizedBox()),
                GestureDetector(
                  onTap: () {
                    if (!isWorking) {
                      _showOptionsBottomSheet();
                    }
                  },
                  child: Chip(
                      key: operationKey,
                      // backgroundColor: AppColor.forestForeground,
                      labelStyle: const TextStyle(fontSize: 14),
                      label: Text(getSelectedMode()),
                      avatar: Icon(Icons.circle,
                          color: getColorByType(type: _selectedType),
                          size: 12)),
                ),
                Text(_getDurationText(),
                    style: const TextStyle(
                        // color: AppColor.forestForeground,
                        fontSize: 46)),
                const Expanded(child: SizedBox()),
                Visibility(
                  visible: (leftDuration.inSeconds > 0),
                  child: ElevatedButton(
                      onPressed: () {
                        if (isWorking) {
                          _stopWorking();
                        } else {
                          setEndTime();
                          LocalNotification.scheduleNotification(
                              title: 'Notruphil',
                              body: 'this is a notification',
                              payload: 'timer is down',
                              time: leftDuration.inSeconds);

                          _startWorking();
                          isWorking = true;
                        }
                      },
                      child: Text(
                        (isWorking) ? "صبر کن" : "شروع کن",
                        style: const TextStyle(
                            fontFamily: 'vazir_medium',
                            // color: AppColor.black,
                            fontSize: 18),
                      ),
                      style: ElevatedButton.styleFrom(
                          // backgroundColor:
                          // AppColor.white,
                          fixedSize: const Size(200, 30),
                          shape: const RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(24.0))))),
                ),

                const SizedBox(height: 10),

                ElevatedButton(
                    key: myReadKey,
                    onPressed: () {
                      // Navigator.push(context, MyMaterialPageRoute(page: ForestReportPage()));
                    },
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Text(
                          "مطالعات من",
                          style: TextStyle(
                              fontFamily: 'vazir_medium',
                              // color: AppColor.black,
                              fontSize: 18),
                        ),
                        SizedBox(width: 2),
                        Icon(
                          Icons.library_books_sharp,
                          // color: AppColor.forestBackground
                        ),
                      ],
                    ),
                    style: ElevatedButton.styleFrom(
                        // backgroundColor: AppColor.white,
                        fixedSize: Size(screenSize.width - 80, 50),
                        shape: const RoundedRectangleBorder(
                            borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(24.0),
                                topRight: Radius.circular(24.0))))),
                Container(
                  width: 200, height: 0.5,
                  // color: AppColor.grey
                ),
                ElevatedButton(
                    key: myPhoneKey,
                    onPressed: () {
                      // Navigator.push(context, MyMaterialPageRoute(page: const MyPhoneReport()));
                    },
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Text(
                          "گوشی من",
                          style: TextStyle(
                              fontFamily: 'vazir_medium',
                              // color: AppColor.black
                              fontSize: 18),
                        ),
                        SizedBox(width: 8),
                        Icon(
                          Icons.phone_android,
                          // color: AppColor.forestBackground
                        ),
                      ],
                    ),
                    style: ElevatedButton.styleFrom(
                        // backgroundColor: AppColor.white,
                        fixedSize: Size(screenSize.width - 80, 50),
                        shape: const RoundedRectangleBorder(
                            borderRadius: BorderRadius.only(
                                bottomLeft: Radius.circular(24.0),
                                bottomRight: Radius.circular(24.0))))),

                const SizedBox(height: 12),

                //const Expanded(child: SizedBox()),
                //_buildReportAndMyPhoneButtons(),
              ],
            ),
          ),
        ));
  }

  //amirhossein

  //lifecycles
  void didChangeAppLifecycleState(AppLifecycleState state) async {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.resumed) {
      if (leftDuration > Duration.zero) {
        // _stopBackgroundService();
        // removeOverlay();
        await readPreviousDatas();
      }
    } else if (state == AppLifecycleState.paused) {
      // _startBackgroundService();

      final prefs = await SharedPreferences.getInstance();
      final remainingSeconds = leftDuration;
      prefs.setInt('countdownSeconds', remainingSeconds.inSeconds);
    }
  }

  String getSelectedMode() {
    switch (_selectedType) {
      case Types.STUDY:
        return "خواندن";
      case Types.SPORT:
        return "ورزش";
      case Types.OTHER:
        return "متفرقه";
      case Types.ENTERTAINMENT:
        return "سرگرمی";
      case Types.REST:
        return "استراحت";
      case Types.SOCIAL:
        return "شبکه اجتماعی";
      case Types.WORK:
        return "کار";
      case Types.UNSET:
        return "تعیین نشده";
    }
  }

  final items = List<String>.from({
    "اگر می‌خوای یه کار ساده رو سختش کنی، بازم به فردا موکولش کن!",
    "دیروز را رها کردم، از اهالی امروزم🎭",
    "برای طلوعِ پس از شب‌های تلاش ادامه بده...",
    "هر چی هستی، خوب‌ترین نوع خودت باش✨️",
    "جوری عمل کن که بدهکار خودت و توانمندی‌هات نشی...",
    "روح تو لیاقت اینو داره که با شادی زندگی کنه...",
    "سبز شو و جوانه بزن که فصل اُمید است🕊",
    "قولی که به خودت دادی رو نشکنی!",
    "ادامه بده، می‌گذری از تاریکی...",
    "بلند پرواز باش، اما پله پله پرواز کن...",
    "انگیزه نداری شروع کنی؟ شروع کنی، انگیزه میاد!",
    "جا نزن ، همینطور ادامه بده",
    "امروز بهترین نسخه‌ی خودت رو با این دنیا سهیم شو✌️",
    "ایمانت رو مچاله نکن! خدا درهایی رو برات باز می‌کنه که حتی در نزدی...",
    "تلاش الانت کاوریه روی تمام نتیجه‌های گذشتت و حتی گندکاریات!",
    "دست به کار شو، و به همه نشون بده چه کارایی ازت بر میاد👊",
    "بذار موفقیتت صدای تو باشه وقتی که تو سکوتت سخت تلاش می‌کنی!",
    "هفته هفت روز داره و يه روزى يكى از اونا نيست، الان وقتشه...",
    "کافی هستی برای اینکه بتونی دنیاتو واسه خودت قشنگ‌ کنی🤍",
    "رابرت کیوساکی؛ ناکامی، الهام‌ بخش برنده‌ها و شکست‌ دهنده بازنده‌هاست.",
    "نتیجه رضایت بخش آخر روز باعث اعتماد به نفس می‌شه، پاشو و بهترینت باش",
    "",
  });

  int messageCounter = 0;
  int lastNumber = 0;

  String _getForestMessage() {
    if (!isWorking) return "همین الان شروع کن!";
    messageCounter++;

    if (messageCounter % 900 == 0) {
      lastNumber = Random().nextInt(items.length - 1);
    }

    return items[lastNumber];
  }

  String _getDurationText() {
    int minutes = leftDuration.inSeconds ~/ 60;
    int secs = (leftDuration - Duration(minutes: minutes)).inSeconds;

    if (minutes < 10) {
      if (secs < 10) {
        return "0" + minutes.toString() + ":0" + secs.toString();
      } else {
        return "0" + minutes.toString() + ":" + secs.toString();
      }
    } else {
      if (secs < 10) {
        return minutes.toString() + ":0" + secs.toString();
      } else {
        return minutes.toString() + ":" + secs.toString();
      }
    }
  }

  void _showOptionsBottomSheet() {
    showModalBottomSheet(
        context: context,
        backgroundColor: Colors.transparent,
        builder: (context) {
          return StatefulBuilder(
              builder: (BuildContext context, StateSetter setState) {
            return Container(
                decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(20.0),
                        topRight: Radius.circular(20.0))),
                child: ClipRRect(
                    borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(20.0),
                        topRight: Radius.circular(20.0)),
                    child: Column(children: [
                      Container(
                        width: 50,
                        height: 2,
                        color: Colors.grey,
                        margin: const EdgeInsets.only(top: 12, bottom: 12),
                      ),
                      Container(
                          margin: const EdgeInsets.only(right: 8),
                          alignment: Alignment.centerRight,
                          child: const Text("نوع گیاه",
                              style: TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.bold))),
                      SizedBox(
                          width: MediaQuery.of(context).size.width,
                          height: 250,
                          child: Column(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                Row(
                                    children: [
                                      _buildPlantType(
                                          index: 1, setState: setState),
                                      _buildPlantType(
                                          index: 2, setState: setState),
                                      _buildPlantType(
                                          index: 3, setState: setState),
                                    ],
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceAround),
                                Row(
                                    children: [
                                      _buildPlantType(
                                          index: 4, setState: setState),
                                      _buildPlantType(
                                          index: 5, setState: setState),
                                      _buildPlantType(
                                          index: 6, setState: setState),
                                    ],
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceAround)
                              ])),
                      const Expanded(child: SizedBox()),
                      Container(
                          margin: const EdgeInsets.only(right: 12),
                          alignment: Alignment.centerRight,
                          child: const Text("نوع فعالیت",
                              style: TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.bold))),
                      Container(
                        width: MediaQuery.of(context).size.width,
                        height: 50,
                        margin: const EdgeInsets.symmetric(vertical: 4),
                        child: ListView.builder(
                            itemBuilder: (context, index) {
                              return GestureDetector(
                                onTap: () {
                                  _selectedType =
                                      getSelectedModeForType(index: index);
                                  setState(() {});
                                },
                                child: Container(
                                  margin:
                                      const EdgeInsets.symmetric(horizontal: 2),
                                  child: Chip(
                                      backgroundColor: (_selectedType ==
                                              getSelectedModeForType(
                                                  index: index))
                                          ? const Color(0xffF4E869)
                                          : const Color(0x67b0d9b1),
                                      labelStyle: const TextStyle(fontSize: 14),
                                      label: Text(getSelectedModeForSelect(
                                          index: index)),
                                      avatar: Icon(Icons.circle,
                                          color: getColor(index: index),
                                          size: 12)),
                                ),
                              );
                            },
                            itemCount: 8,
                            scrollDirection: Axis.horizontal),
                      )
                    ])));
          });
        }).then((value) {
      setState(() {});
    });
  }

  String? getTypeName({required Types type}) {
    switch (type) {
      case Types.STUDY:
        return "مطالعه";
      case Types.ENTERTAINMENT:
        return "سرگرمی";
      case Types.OTHER:
        return "متفرقه";
      case Types.REST:
        return "استراحت";
      case Types.SOCIAL:
        return "شبکه اجتماعی";
      case Types.SPORT:
        return "ورزش";
      case Types.UNSET:
        return "تعیین نشده";
      case Types.WORK:
        return "کار";
    }
  }

  String getSelectedModeForSelect({required int index}) {
    switch (index) {
      case 0:
        return "خواندن";
      case 1:
        return "ورزش";
      case 2:
        return "متفرقه";
      case 3:
        return "سرگرمی";
      case 4:
        return "استراحت";
      case 5:
        return "شبکه اجتماعی";
      case 6:
        return "کار";
      case 7:
        return "تعیین نشده";
    }
    return "null";
  }

  Types getSelectedModeForType({required int index}) {
    switch (index) {
      case 0:
        return Types.STUDY;
      case 1:
        return Types.SPORT;
      case 2:
        return Types.OTHER;
      case 3:
        return Types.ENTERTAINMENT;
      case 4:
        return Types.REST;
      case 5:
        return Types.SOCIAL;
      case 6:
        return Types.WORK;
      case 7:
        return Types.UNSET;
    }
    return Types.STUDY;
  }

  _buildPlantType({required int index, required StateSetter setState}) {
    final AnimationController _lottieController =
        AnimationController(vsync: this, duration: const Duration(seconds: 2));
    _lottieController.forward();

    var screenSize = MediaQuery.of(context).size;
    var cardSize = screenSize.width / 3 - 50;
    return GestureDetector(
        onTap: () {
          _selectedTreeNum = index;
          setState(() {});
        },
        child: Card(
            color: (_selectedTreeNum == index)
                ? const Color(0xffF4E869)
                : Colors.white,
            child: Container(
                alignment: Alignment.center,
                width: cardSize,
                height: cardSize,
                child: LottieBuilder.asset(
                    "assets/lottie/plant" + index.toString() + ".json",
                    controller: _lottieController))));
  }

  Future<bool> _onBackPressed() {
    writeCurrentData();
    if (isWorking) {
      scaffoldMessenger.showSnackBar(SnackBar(
          content: const Text('صبر نمیکنی کارت تموم بشه؟'),
          action: SnackBarAction(
              onPressed: () async {
                Navigator.pop(context);
              },
              label: 'بازگشت')));

      return Future.value(false);
    } else {
      return Future.value(true);
    }
  }

  void _setScreenWakeSetting() {
    if (isWakeScreen) {
      Wakelock.enable();
    } else {
      Wakelock.disable();
    }
  }

  void _showScreenHintMessage() {
    scaffoldMessenger
        .showSnackBar(const SnackBar(content: Text('صفحه گوشی روشن می ماند')));
  }

  void writeReportData() async {
    DateTime dateNow = DateTime.now();

    Map<String, dynamic> report = {
      "id": DateTime.now().millisecondsSinceEpoch,
      "isUsedForCompetitive": false,
      "date": dateNow.toIso8601String(),
      "type": _selectedType.index,
      "duration": selectedDuration.inSeconds
    };

    var prefs = await SharedPreferences.getInstance();
    List<dynamic> data =
        await jsonDecode(prefs.getString("totalReports") ?? "[]");
    data.add(report);
    prefs.setString("totalReports", jsonEncode(data));
  }

  Color getColor({required int index}) {
    switch (index) {
      case 1:
        {
          return const Color(0xff3D30A2);
        }
      case 2:
        {
          return const Color(0xffB15EFF);
        }
      case 3:
        {
          return const Color(0xffFFA33C);
        }
      case 4:
        {
          return const Color(0xffFFFB73);
        }
      case 5:
        {
          return const Color(0xff1F1717);
        }
      case 6:
        {
          return const Color(0xff5272F2);
        }
    }
    return const Color(0xffB0D9B1);
  }

  Color getColorByType({required Types type}) {
    int index = 0;

    if (type == Types.STUDY) {
      index = 0;
    } else if (type == Types.SPORT) {
      index = 1;
    } else if (type == Types.OTHER) {
      index = 2;
    } else if (type == Types.ENTERTAINMENT) {
      index = 3;
    } else if (type == Types.REST) {
      index = 4;
    } else if (type == Types.SOCIAL) {
      index = 5;
    } else if (type == Types.WORK) {
      index = 6;
    } else if (type == Types.UNSET) {
      index = 7;
    }

    return getColor(index: index);
  }

  void _showNotification(
      {required String? title, required String? body}) async {
    if (!kIsWeb) return;
    AndroidNotificationDetails androidPlatformChannelSpecifics =
        const AndroidNotificationDetails(
      "848480",
      'notruphil_channel', // Replace with your desired channel name
      channelDescription: 'Your Channel Description',
      // Replace with your desired channel description
      icon: '@mipmap/ic_launcher_adaptive_fore',
      subText: "پایان جنگل من",
      onlyAlertOnce: true,
      importance: Importance.max,
      priority: Priority.high,
    );
    NotificationDetails platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);

    await FlutterLocalNotificationsPlugin().show(
      848480,
      title ?? "",
      body ?? "",
      platformChannelSpecifics,
      payload: 'notification_payload',
    );
  }
}
