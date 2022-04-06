import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:lucas/helpers/Helper.dart';
import 'package:lucas/helpers/LocalPreferences.dart';
import 'package:lucas/helpers/StateProperties.dart';
import 'package:lucas/helpers/property_change_notifier/property_change_provider.dart';
import 'package:lucas/localizations/L.dart';
import 'package:lucas/models/LucasState.dart';
import 'package:lucas/models/MVideo.dart';
import 'package:lucas/models/MObject.dart';
import 'package:lucas/screens/TextToSpeech.dart';
//import 'package:property_change_notifier/property_change_notifier.dart';
import 'package:transparent_image/transparent_image.dart';

class WVideo extends StatefulWidget {
  bool ignoreVisibility;
  MVideo mVideo;
  String currentLevel = "1";
  //bool isEditMode = false;
  ValueChanged<MObject> onItemTap; // callback for tapping a folder
  ValueChanged<MObject> onItemDoubleTap; // callback for double tapping a folder
  ValueChanged<MObject> onItemLongPress; // callback for updating folder

  WVideo(ignoreVisibility, mVideo, currentLevel, onItemTap, onItemDoubleTap,
      onItemLongPress,
      {Key key})
      : super(key: key) {
    this.ignoreVisibility = ignoreVisibility;
    this.mVideo = mVideo;
    this.currentLevel = currentLevel;
    //this.isEditMode = isEditMode;
    this.onItemTap = onItemTap;
    this.onItemDoubleTap = onItemDoubleTap;
    this.onItemLongPress = onItemLongPress;
  }

  @override
  _WVideoState createState() {
    return _WVideoState(
      this.ignoreVisibility,
      this.mVideo,
      this.currentLevel,
      this.onItemTap,
      this.onItemDoubleTap,
      this.onItemLongPress,
    );
  }
}

class _WVideoState extends State<WVideo> {
  bool ignoreVisibility;
  MVideo mVideo;
  String currentLevel = "1";
  Image localImage;

  ValueChanged<MObject> onItemTap; // callback for tapping a folder
  ValueChanged<MObject> onItemDoubleTap; // callback for double tapping a folder
  ValueChanged<MObject> onItemLongPress; // callback for updating folder

  _WVideoState(
    this.ignoreVisibility,
    this.mVideo,
    this.currentLevel,
    this.onItemTap,
    this.onItemDoubleTap,
    this.onItemLongPress,
  );

  @override
  void initState() {
    super.initState();

    if (mVideo.useAsset == 0) {
      File f = File('${Helper.appDirectory}/${mVideo.localFileName}');
      localImage = Image.file(f);
    }

    // if (mVideo.useAsset == 0) {
    //   if (mVideo.strBase64.isNotEmpty) {
    //     localImage = Image.memory(Base64Decoder().convert(mVideo.strBase64));
    //   }
    // }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    // if (mVideo.useAsset == 0) {
    //   if (localImage != null) {
    //     precacheImage(localImage.image, context);
    //   }
    // }
  }

  @override
  Widget build(BuildContext context) {
    // return PropertyChangeConsumer<LucasState>(
    //   properties: [
    //     StateProperties.isEditMode,
    //   ],
    //   builder: (context, model, property) {
    final lucasState =
        PropertyChangeProvider.of<LucasState>(context, listen: false).value;
    bool isEditMode = lucasState.getObject(StateProperties.isEditMode);
    Color overlayColor = getOverlayForegroundColor(isEditMode);
    double opacity = getOpacity(isEditMode);
    Widget cardVideo = getCardVideo(overlayColor, opacity, isEditMode);

    return GestureDetector(
      onTap: () => onVideoTap(context, mVideo, currentLevel),
      onDoubleTap: () => onVideoDoubleTap(context, mVideo, currentLevel),
      onLongPress: () {
        onVideoLongPress(context, mVideo, currentLevel);
      },
      child: Container(
        height: Helper.tileHeight(context),
        width: Helper.tileHeight(context),
        //constraints: BoxConstraints.expand(),
        margin: const EdgeInsets.all(1.0),
        decoration: myOuterBoxDecoration(isEditMode), //
        child: Container(
          decoration: myInnerBoxDecoration(isEditMode), //
          child: Container(
            decoration: BoxDecoration(
              color: getVideoBackgroundColor(isEditMode),
            ),
            child: cardVideo,
          ),
        ),
      ),
    );
    //   },
    // );
  }

  Widget getCardVideo(Color overlayColor, double opacity, bool isEditMode) {
    bool isMVideoEmpty = false;
    if (mVideo == null) isMVideoEmpty = true;
    if (mVideo != null && mVideo.fileName == null) isMVideoEmpty = true;

    return Container(
      foregroundDecoration: BoxDecoration(
        color: overlayColor,
        backgroundBlendMode: BlendMode.saturation,
      ),
      child: Opacity(
        opacity: opacity,
        child: isMVideoEmpty
            ? CircularProgressIndicator()
            : Column(
                // mainAxisAlignment: MainAxisAlignment.center,
                // crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  (mVideo.useAsset == 0 && localImage == null)
                      ? new Container(
                          height: 2.0,
                          child: LinearProgressIndicator(
                            value: null,
                            valueColor: new AlwaysStoppedAnimation<Color>(
                                Theme.of(context).primaryColor),
                            backgroundColor: Colors.white,
                          ),
                        )
                      : Container(),
                  Expanded(
                    flex: currentLevel == "10" ? 1 : Helper.imageFlexSize,
                    child: Stack(
                      children: <Widget>[
                        Center(
                          child: mVideo.useAsset == 1
                              ? Image.asset(
                                        mVideo.fileName,
                                      ) !=
                                      null
                                  ? Image.asset(
                                      mVideo.fileName,
                                    )
                                  : Image.asset(Helper.imageNotFound)
                              : localImage == null
                                  ? Container()
                                  : FadeInImage(
                                      fadeInDuration: Duration(
                                          milliseconds: Helper.fadeInDuration),
                                      placeholder:
                                          MemoryImage(kTransparentImage),
                                      //placeholder: kTransparentImage,
                                      image: localImage.image,
                                    ),
                        ),
                        Center(
                          child: Opacity(
                            opacity: 0.6,
                            child: Image.asset('assets/images/new_video.png'),
                          ),
                        ),
                        mVideo.isAvailable == 1
                            ? Container()
                            : Center(
                                child: Icon(
                                  Icons.not_interested,
                                  size: Helper.tileHeight(context)-6,
                                  color: Colors.red,
                                ),
                              ),
                      ],
                    ),
                  ),
                  Expanded(
                    flex: currentLevel == "10" ? Helper.imageFlexSize : 2,
                    child: Text(
                      mVideo.textToShow,
                      overflow:
                          currentLevel == "10" ? null : TextOverflow.ellipsis,
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: Helper.getFontSize(currentLevel),
                      ),
                    ),
                  ),
                  Stack(
                    children: [
                      mVideo.minLevelToShow > 1 && isEditMode
                          ? Text(
                              mVideo.minLevelToShow.toString(),
                              style: TextStyle(
                                color: Colors.red,
                                fontWeight: FontWeight.bold,
                                backgroundColor: Colors.white,
                                fontSize: Helper.getFontSize(currentLevel),
                              ),
                            )
                          : Container()
                    ],
                  )
                ],
              ),
      ),
    );
  }

  double getOpacity(bool isEditMode) {
    if (mVideo.isVisible == 1 || ignoreVisibility) {
      return 1.0;
    }

    if (isEditMode)
      return 0.2;
    else
      return 0.0;
  }

  Color getOverlayForegroundColor(bool isEditMode) {
    if (mVideo.isVisible == 1 || ignoreVisibility) {
      return Colors.transparent;
    } else {
      if (isEditMode)
        return Colors.grey;
      else
        return Colors.transparent;
    }
  }

  Color hexToColor(String hexString, {String alphaChannel = 'FF'}) {
    return Color(int.parse(hexString.replaceFirst('#', '0x$alphaChannel')));
  }

  Color getVideoBackgroundColor(bool isEditMode) {
    Color videoBackgroundColor = Colors.white;

    if (mVideo.backgroundColor.length > 0) {
      if (mVideo.backgroundColor.length > 6) {
        videoBackgroundColor =
            hexToColor('#${mVideo.backgroundColor.substring(2)}');
      } else {
        videoBackgroundColor = hexToColor('#${mVideo.backgroundColor}');
      }
    }

    if (mVideo.isVisible == 0 && !isEditMode && !ignoreVisibility)
      videoBackgroundColor = Colors.transparent;

    return videoBackgroundColor;
  }

  onVideoTap(
      BuildContext context, MVideo videoCard, String currentLevel) async {
    final lucasState =
        PropertyChangeProvider.of<LucasState>(context, listen: false).value;
    bool isEditMode = lucasState.getObject(StateProperties.isEditMode);
    if (!isEditMode) {
      // Immediate voice feedback is provided only for level 1-3
      if (currentLevel == '1' || currentLevel == '2' || currentLevel == '3') {
        FlutterTts flutterTts = new FlutterTts();
        String languageCountry =
            await LocalPreferences.getString("languageCountry", "");

        bool isLanguageAvailable =
            await flutterTts.isLanguageAvailable(languageCountry);
        //String settingsText = await L.item("settings title");

        await flutterTts.isLanguageAvailable(languageCountry);
        if (isLanguageAvailable) {
          await flutterTts.setLanguage(languageCountry);

          double ttsSpeed = await LocalPreferences.getDouble("ttsSpeed", 0.5);
          await flutterTts.setSpeechRate(ttsSpeed);

          await flutterTts.speak(videoCard.textToSay);
        } else {
          showDialog(
            context: context,
            builder: (BuildContext context) {
              // return object of type Dialog
              return AlertDialog(
                title: L.getText('no valid voice found'),
                content: SingleChildScrollView(
                  child: L.getText('no voice selected'),
                ),
                actions: <Widget>[
                  // usually buttons at the bottom of the dialog
                  new TextButton(
                    child: L.getUpperText('settings title'),
                    onPressed: () {
                      Navigator.of(context).pop();

                      // open TextToSpeech settings
                      Route route = MaterialPageRoute(
                          builder: (context) => TextToSpeech());
                      Navigator.push(context, route);
                    },
                  ),
                ],
              );
            },
          );
        }
      }
      // else {
      //   if (videoCard.isVisible == 1 || isEditMode || ignoreVisibility) {
      //     final voiceboxState = Provider.of<LucasState>(context);
      //     voiceboxState.addVideoCard(videoCard);
      //   }
      // }
    }

    if (onItemTap != null) {
      onItemTap(videoCard);
    }
  }

  onVideoDoubleTap(
      BuildContext context, MVideo mVideo, String currentLevel) async {
    //if (isEditMode) {
    if (onItemLongPress != null) {
      onItemDoubleTap(mVideo);
    }
    //}
  }

  onVideoLongPress(
      BuildContext context, MVideo mVideo, String currentLevel) async {
    //if (isEditMode) {
    if (onItemLongPress != null) {
      onItemLongPress(mVideo);
    }
    //}
  }

  BoxDecoration myInnerBoxDecoration(bool isEditMode) {
    return BoxDecoration(
      border: Border.all(
        width: 2,
        color: Colors.transparent,
        // (mSound.isVisible == 0 && !isEditMode && ignoreVisibility)
        //     ? Colors.transparent
        //     : mSound.isUnderstood == 1 ? Colors.greenAccent : Colors.white,
      ),
    );
  }

  BoxDecoration myOuterBoxDecoration(bool isEditMode) {
    return BoxDecoration(
      border: Border.all(
        width: (mVideo.isVisible == 0 && !isEditMode && ignoreVisibility)
            ? 1
            : (mVideo.isVisible == 0 && !isEditMode && ignoreVisibility)
                ? 1
                : mVideo.isUnderstood == 1 ? 2 : 1,
        //1,
        color: (mVideo.isVisible == 0 && !isEditMode && ignoreVisibility)
            ? Colors.transparent
            : (mVideo.isVisible == 0 && !isEditMode && ignoreVisibility)
                ? Colors.transparent
                : mVideo.isUnderstood == 1
                    ? Colors.greenAccent[700]
                    : Colors.white,
        //Colors.grey,
      ),
    );
  }
}
