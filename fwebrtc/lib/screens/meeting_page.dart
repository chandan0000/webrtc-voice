import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:flutter_webrtc_wrapper/webrtc_meeting_helper.dart';
import 'package:fwebrtc/constans.dart';
import 'package:fwebrtc/model/meeting_details.dart';
import 'package:fwebrtc/screens/home_screen.dart';
import 'package:fwebrtc/utils/user.utils.dart';
import 'package:fwebrtc/widgets/control_pannel.dart';
import 'package:fwebrtc/widgets/remote_controller.dart';

class MeetingPage extends StatefulWidget {
  final String? meetingId;
  final String? name;
  final MeetingDetails meetingDetails;
  const MeetingPage({
    this.meetingId,
    this.name,
    required this.meetingDetails,
    super.key,
  });

  @override
  State<MeetingPage> createState() => _MeetingPageState();
}

class _MeetingPageState extends State<MeetingPage> {
  final _loaclRenderer = RTCVideoRenderer();
  final Map<String, dynamic> mediaContraints = {
    "audio": true,
    "video": true,
  };
  bool isConnectionFailed = false;
  WebRTCMeetingHelper? meetingHelper;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: _buildMeetingRoom(),
      bottomNavigationBar: ControlPanel(
        onAudioToggle: onAudioToggle,
        onVideoToggle: onVideoToggle,
        videoEnabled: isVideoEnabled(),
        audioEnabled: isAudioEnabled(),
        isConnectionFailed: isConnectionFailed,
        onReconnect: handleReconnect,
        onMeetingEnd: onMeetingEnd,
      ),
    );
  }

  void startMeeting() async {
    final String userId = await loadUserId();
    meetingHelper = WebRTCMeetingHelper(
      url: "http:$hosturl",
      meetingId: widget.meetingDetails.id,
      userId: userId,
      name: widget.name,
    );
    MediaStream localStream = await navigator.mediaDevices.getUserMedia(
      mediaContraints,
    );
    _loaclRenderer.srcObject = localStream;
    meetingHelper!.stream = localStream;
    meetingHelper!.on("open", context, (ev, context) {
      setState(() {
        isConnectionFailed = false;
      });
    });
    meetingHelper!.on("connection", context, (ev, context) {
      setState(() {
        isConnectionFailed = false;
      });
    });
    meetingHelper!.on("open", context, (ev, context) {
      setState(() {
        isConnectionFailed = false;
      });
    });
    meetingHelper!.on("user-left", context, (ev, context) {
      setState(() {
        isConnectionFailed = false;
      });
    });
    meetingHelper!.on("video-toggle", context, (ev, context) {
      setState(() {});
    });
    meetingHelper!.on("audio-toggle", context, (ev, context) {
      setState(() {});
    });
    meetingHelper!.on("meeting-ended", context, (ev, context) {
      setState(() {
        onMeetingEnd();
      });
    });
    meetingHelper!.on("connection-setting-changed", context, (ev, context) {
      setState(() {
        isConnectionFailed = false;
      });
    });
    meetingHelper!.on("stream-changed", context, (ev, context) {
      setState(() {});
    });
  }

  intiRenders() async {
    await _loaclRenderer.initialize();
  }

  @override
  void initState() {
    super.initState();
    intiRenders();
    startMeeting();
  }

  @override
  void deactivate() {
    super.deactivate();
    _loaclRenderer.dispose();
    if (meetingHelper != null) {
      meetingHelper!.destroy();
      meetingHelper = null;
    }
  }

  void onMeetingEnd() {
    if (meetingHelper != null) {
      meetingHelper!.endMeeting();
      meetingHelper = null;
      gotoHomePage();
    }
  }

  _buildMeetingRoom() {
    return Stack(
      children: [
        meetingHelper != null && meetingHelper!.connections.isNotEmpty
            ? GridView.count(
                crossAxisCount: meetingHelper!.connections.length < 3 ? 1 : 2,
                children: List.generate(
                    meetingHelper!.connections.length,
                    (index) => Padding(
                          padding: const EdgeInsets.all(1),
                          child: RemoteConnection(
                            renderer:
                                meetingHelper!.connections[index].renderer,
                            connection: meetingHelper!.connections[index],
                          ),
                        )),
              )
            : const Center(
                child: Padding(
                  padding: EdgeInsets.all(10.0),
                  child: Text(
                    "waitng for particiption to join meeting",
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 24,
                    ),
                  ),
                ),
              ),
        Positioned(
          bottom: 10,
          right: 0,
          child: SizedBox(
            child: RTCVideoView(_loaclRenderer),
          ),
        )
      ],
    );
  }

  void onAudioToggle() {
    if (meetingHelper != null) {
      setState(() {
        meetingHelper!.toggleAudio();
      });
    }
  }

  void onVideoToggle() {
    if (meetingHelper != null) {
      setState(() {
        meetingHelper!.toggleVideo();
      });
    }
  }

  void handleReconnect() {
    if (meetingHelper != null) {
      meetingHelper!.reconnect();
    }
  }

  bool isVideoEnabled() {
    return meetingHelper != null ? meetingHelper!.audioEnabled! : false;
  }

  bool isAudioEnabled() {
    return meetingHelper != null ? meetingHelper!.videoEnabled! : false;
  }

  void gotoHomePage() {
    Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (conetx) => const HomeScreen()));
  }
}
