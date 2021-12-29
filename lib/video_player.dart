import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:video_player/video_player.dart';

class VideoPlayerPageExample extends StatefulWidget {
  const VideoPlayerPageExample({Key? key}) : super(key: key);

  @override
  State<VideoPlayerPageExample> createState() => _VideoPlayerPageExampleState();
}

class _VideoPlayerPageExampleState extends State<VideoPlayerPageExample> {
  ImagePicker? imagePicker;
  File? videoFile;
  VideoPlayerController? controller;
  bool isScreen = false;
  bool videoEdit = false;

  @override
  void initState() {
    super.initState();
    imagePicker = ImagePicker();
  }

  @override
  void dispose() {
    controller!.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: isScreen == false ? AppBar(
        title: const Text('Video Player'),
        actions: [buildPickVideo()],
      ) : null,
      body: controller == null ? Container() : buildVideo(),
    );
  }

  Widget buildVideo() {
    return Stack(
      children: [
        GestureDetector(
          onTap: (){
            if(videoEdit == true){
              setState(() {
                videoEdit = false;
              });
            }else{
              setState(() {
                videoEdit = true;
              });
              Future.delayed(const Duration(seconds: 4)).then((value) {
                setState(() {
                  videoEdit = false;
                });
              });
            }

          },
          child: Center(
            child: AspectRatio(
              aspectRatio: controller!.value.aspectRatio,
              child: VideoPlayer(controller!),
            ),
          ),
        ),
        videoEdit == true ? Positioned(
          bottom: 0,
          right: 0,
          left: 0,
          child: Container(
            color: Colors.grey.shade300,
            height: 140,
            width: MediaQuery.of(context).size.width,
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 50),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    slowVideo(),
                    backButton(),
                    playButton(),
                    goButton(),
                    fastVideo(),
                    IconButton(onPressed: (){
                      if(controller!.value.volume == 0){
                        controller!.setVolume(1);
                      }else{
                        controller!.setVolume(0);
                      }
                    }, icon: controller!.value.volume == 1 ? const Icon(Icons.volume_up) : const Icon(Icons.volume_off))
                  ],
                ),
                Row(
                  children: [
                    Text(time() + '     '),
                    Expanded(
                        child: SizedBox(
                            height: 15,
                            child: VideoProgressIndicator(controller!,
                                allowScrubbing: false))),
                    Text('     ' + time1()),
                    IconButton(onPressed: ()async{
                      if(isScreen == true){
                        isScreen = false;
                        WidgetsFlutterBinding.ensureInitialized();
                        await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp,]);
                      }else{
                        isScreen = true;
                        WidgetsFlutterBinding.ensureInitialized();
                        await SystemChrome.setPreferredOrientations([DeviceOrientation.landscapeRight]);
                      }
                    }, icon: const Icon(Icons.fullscreen))
                  ],
                ),
                const SizedBox(
                  height: 6,
                ),
                Text(controller!.value.playbackSpeed.toString()),
              ],
            ),
          ),
        ) : Container()
      ],
    );
  }

  IconButton fastVideo() {
    return IconButton(
        onPressed: () {
          if (controller!.value.playbackSpeed == 1) {
            controller!.setPlaybackSpeed(1.5);
          } else if (controller!.value.playbackSpeed == 0.5) {
            controller!.setPlaybackSpeed(1);
          }
        },
        icon: const Icon(Icons.add));
  }

  IconButton slowVideo() {
    return IconButton(
        onPressed: () {
          if (controller!.value.playbackSpeed == 1) {
            controller!.setPlaybackSpeed(0.5);
          } else if (controller!.value.playbackSpeed == 1.5) {
            controller!.setPlaybackSpeed(1);
          }
        },
        icon: const Icon(Icons.remove));
  }

  IconButton goButton() {
    return IconButton(
        onPressed: () {
          controller!.seekTo(
              Duration(seconds: controller!.value.position.inSeconds + 2));
        },
        icon: const Icon(Icons.rotate_right));
  }

  IconButton backButton() {
    return IconButton(
        onPressed: () {
          controller!.seekTo(
              Duration(seconds: controller!.value.position.inSeconds - 2));
        },
        icon: const Icon(Icons.rotate_left_rounded));
  }

  IconButton playButton() {
    return IconButton(
        onPressed: () {
          if (controller!.value.isPlaying) {
            controller!.pause();
          } else {
            controller!.play();
          }
        },
        icon: controller!.value.isPlaying == false
            ? const Icon(Icons.play_circle_fill)
            : const Icon(Icons.pause_circle_filled));
  }

  String time() {
    var duration =
        Duration(milliseconds: controller!.value.position.inMilliseconds);
    return [duration.inMinutes, duration.inSeconds]
        .map((sag) => sag.remainder(60).toString().padLeft(2, '0'))
        .join(':');
  }

  String time1() {
    var duration =
        Duration(milliseconds: controller!.value.duration.inMilliseconds);
    return [duration.inMinutes, duration.inSeconds]
        .map((sag) => sag.remainder(60).toString().padLeft(2, '0'))
        .join(':');
  }

  Padding buildPickVideo() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: IconButton(
          onPressed: () async {
            var video =
                await imagePicker!.pickVideo(source: ImageSource.gallery);
            videoFile = File(video!.path);
            controller = VideoPlayerController.file(videoFile!)
              ..initialize()
              ..addListener(() {
                setState(() {});
              })
              ..play()
              ..setLooping(true);
          },
          icon: const Icon(Icons.add_circle)),
    );
  }
}
