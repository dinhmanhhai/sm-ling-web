import 'dart:async';

import 'package:SMLingg/app/choose_book/book.provider.dart';
import 'package:SMLingg/app/choose_book/choose_book.view.dart';
import 'package:SMLingg/app/class_screen/class.provider.dart';
import 'package:SMLingg/app/class_screen/class.view.dart';
import 'package:SMLingg/app/components/show_tool_tip.component.dart';
import 'package:SMLingg/app/lesson/lesson.view.dart';
import 'package:SMLingg/app/unit/unit.provider.dart';
import 'package:SMLingg/config/application.dart';
import 'package:SMLingg/config/config_screen.dart';
import 'package:SMLingg/resources/i18n.dart';
import 'package:SMLingg/themes/style.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';

import 'dialog_show_message_and_action.dart';

class MyCustomAppbar extends StatefulWidget implements PreferredSizeWidget {
  final double height;
  final double width;
  final bool showAvatar;
  final String title;
  final bool unitScreen;
  final bool saveLesson;
  final bool chooseBook;
  final int classIndex;

  const MyCustomAppbar(
      {Key key,
      this.height,
      this.width,
      this.showAvatar,
      this.title,
      this.unitScreen = false,
      this.saveLesson,
      this.chooseBook,
      this.classIndex})
      : super(key: key);

  @override
  _MyCustomAppbarState createState() => _MyCustomAppbarState();

  @override
  // TODO: implement preferredSize
  Size get preferredSize => Size.fromHeight(height);
}

class _MyCustomAppbarState extends State<MyCustomAppbar> {
  StreamController emit;
  ShowMoreModel aPopup;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    if ((widget.showAvatar && Application.sharePreference.getInt("count") == 1)) {
      Future.delayed(Duration(milliseconds: 100), () {
        Application.sharePreference.remove("count");
        createDialogShowMessageAndAction(
            context: context,
            top: SizeConfig.blockSizeVertical * 50,
            title: "Do you want to continue the last lesson?".i18n,
            titleLeftButton: "No".i18n,
            titleRightButton: "Yes".i18n,
            leftAction: () {
              Provider.of<UnitModel>(context, listen: false).clearSave();
              Navigator.pop(context);
            },
            rightAction: () {
              Navigator.pop(context);
              Get.off(LessonScreen(
                  userLevel: Application.sharePreference.getInt("saveUserLevel"),
                  userLesson: Application.sharePreference.getInt("saveUserLesson"),
                  id: Application.sharePreference.getString("saveId")));
            });
      });
    }
  }

  var listKeys = List.generate(2, (index) => GlobalKey());

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    if (aPopup != null) aPopup.dismiss();
    if (emit != null) emit.close();
  }

  @override
  Widget build(BuildContext context) {
    final save = Provider.of<UnitModel>(context, listen: false);
    return Consumer<ClassModel>(builder: (context, icon, child) {
      return Container(
          height: widget.height,
          width: widget.width,
          color: AppColor.mainThemes,
          child: Row(children: [
            SizedBox(width: SizeConfig.safeBlockHorizontal * 5),
            (widget.showAvatar)
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(180),
                    child: Application.user.avatar != null
                        ? Image.network(Application.user.avatar, height: widget.height / 3 * 2, fit: BoxFit.fill)
                        : Image.asset('assets/class/picture.png', height: widget.height / 3 * 2))
                : IconButton(
                    onPressed: () {
                      if (widget.unitScreen == true) {
                        print("widget.classIndex: ${widget.classIndex}");
                        Provider.of<BookModel>(context, listen: false).setGrade(widget.classIndex - 1);
                        Get.off(ChooseBook(), transition: Transition.rightToLeftWithFade, preventDuplicates: true);
                      }
                      if (widget.chooseBook == true) {
                        Get.off(ClassScreen(), transition: Transition.rightToLeftWithFade, preventDuplicates: true);
                      }
                    },
                    icon: Icon(Icons.arrow_back_ios),
                    color: AppColor.backButton,
                  ),
            SizedBox(width: SizeConfig.safeBlockHorizontal * 2),
            (widget.showAvatar)
                ? Container(width: SizeConfig.blockSizeHorizontal * 8)
                : Container(
                    child: Text(widget.title,
                        style: TextStyle(
                            fontSize: SizeConfig.safeBlockVertical * 3,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF5877AA))),
                  ),
            Expanded(child: SizedBox()),
            Stack(
              children: [
                Row(children: [
                  SizedBox(width: SizeConfig.blockSizeVertical * 2),
                  Container(
                    height: SizeConfig.blockSizeVertical * 4,
                    width: SizeConfig.blockSizeVertical * 7,
                    decoration: BoxDecoration(
                        color: Color(0xFFC9E5F8),
                        borderRadius:
                            BorderRadius.only(topRight: Radius.circular(10), bottomRight: Radius.circular(10))),
                  )
                ]),
                Row(children: [
                  GestureDetector(
                    key: listKeys[0],
                    child: InkWell(
                      onTap: () {
                        icon.setShowValue();
                        emit = StreamController();
                        aPopup = ShowMoreExplainItem().createToolTips(
                            'assets/honey_point.svg',
                            "Level",
                            "Số level bạn đã hoàn thành là ${(!widget.unitScreen) ? "${icon.hive}" : Application.unitList.level.toString()}.",
                            context);
                        emit.stream.listen((a) => {
                              aPopup.dismiss(),
                              emit.close(),
                            });
                        ShowMoreExplainItem().showToolTips(aPopup, listKeys[0]);
                      },
                      child: SvgPicture.asset(
                        'assets/honey_point.svg',
                        height: SizeConfig.blockSizeVertical * 4,
                      ),
                    ),
                  ),
                  SizedBox(width: SizeConfig.safeBlockHorizontal * 2),
                  Container(
                      child: Text((!widget.unitScreen) ? "${icon.hive}" : Application.unitList.level.toString(),
                          style: TextStyle(
                              fontSize: SizeConfig.safeBlockVertical * 3,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF5877AA)))),
                ])
              ],
            ),
            SizedBox(width: SizeConfig.safeBlockHorizontal * 5),
            Stack(children: [
              Row(children: [
                SizedBox(width: SizeConfig.blockSizeVertical * 2),
                Container(
                  height: SizeConfig.blockSizeVertical * 4,
                  width: SizeConfig.blockSizeVertical * 7,
                  decoration: BoxDecoration(
                      color: Color(0xFFC9E5F8),
                      borderRadius: BorderRadius.only(topRight: Radius.circular(10), bottomRight: Radius.circular(10))),
                )
              ]),
              Row(children: [
                GestureDetector(
                  key: listKeys[1],
                  child: InkWell(
                    onTap: () {
                      icon.setShowValue();
                      emit = StreamController();
                      aPopup = ShowMoreExplainItem().createToolTips(
                          'assets/droplets_yellow.svg',
                          "Số điểm",
                          "Số điểm bạn đã đạt được là ${(!widget.unitScreen) ? "${icon.diamond}" : Application.unitList.score.toString()}.",
                          context);
                      emit.stream.listen((a) => {
                            aPopup.dismiss(),
                            emit.close(),
                          });
                      ShowMoreExplainItem().showToolTips(aPopup, listKeys[1]);
                    },
                    child: SvgPicture.asset(
                      'assets/droplets_yellow.svg',
                      height: SizeConfig.blockSizeVertical * 4,
                    ),
                  ),
                ),
                SizedBox(width: SizeConfig.safeBlockHorizontal * 2),
                Container(
                    child: Text((!widget.unitScreen) ? "${icon.diamond}" : Application.unitList.score.toString(),
                        style: TextStyle(
                            fontSize: SizeConfig.safeBlockVertical * 3,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF5877AA))))
              ])
            ]),
            SizedBox(width: SizeConfig.safeBlockHorizontal * 5)
          ]));
    });
  }
}
