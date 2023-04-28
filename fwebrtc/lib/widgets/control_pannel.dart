import 'package:flutter/material.dart';
import 'package:snippet_coder_utils/FormHelper.dart';

class ControlPanel extends StatelessWidget {
  final bool? videoEnabled;
  final bool? audioEnabled;
  final bool? isConnectionFailed;
  final VoidCallback? onVideoToggle;
  final VoidCallback? onAudioToggle;
  final VoidCallback? onReconnect;
  final VoidCallback? onMeetingEnd;
  const ControlPanel({super.key, 
    this.onVideoToggle,
    this.onAudioToggle,
    this.onReconnect,
    this.onMeetingEnd,
    this.videoEnabled,
    this.audioEnabled,
    this.isConnectionFailed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.blueGrey[900],
      height: 60.0,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: buildControls(),
      ),
    );
  }

  List<Widget> buildControls() {
    if (!isConnectionFailed!) {
      return <Widget>[
        IconButton(
          onPressed: onVideoToggle,
          icon: Icon(
            videoEnabled! ? Icons.videocam : Icons.videocam_off,
            color: Colors.white,
            size: 32.0,
          ),
        ),
        IconButton(
          onPressed: onAudioToggle,
          icon: Icon(
            audioEnabled! ? Icons.mic : Icons.mic_off,
            color: Colors.white,
            size: 32.0,
          ),
        ),
        const SizedBox(
          width: 32,
        ),
        Container(
          width: 70,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(
              10,
            ),
          ),
          child: IconButton(
              onPressed: onMeetingEnd!,
              icon: const Icon(
                Icons.call_end,
                color: Colors.white,
              )),
        ),
      ];
    } else {
      return <Widget>[
        FormHelper.submitButton("Reconnect", onReconnect!,
            btnColor: Colors.red, borderRadius: 10, width: 200, height: 40)
      ];
    }
  }
}
