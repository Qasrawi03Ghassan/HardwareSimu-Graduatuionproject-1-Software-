import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hardwaresimu_software_graduation_project/mobilePages/welcome.dart';
import 'package:videosdk/videosdk.dart';
import 'close_tab.dart';

class MeetingScreen extends StatefulWidget {
  String? meetingId;
  String? token;
  String? participantName;
  String? isHost;

  String? meetingIdM;
  String? tokenM;
  String? participantNameM;
  String? isHostM;

  final VoidCallback? onLeave;

  MeetingScreen({
    this.meetingIdM,
    this.tokenM,
    this.participantNameM,
    this.isHostM,
    this.onLeave,
    Key? key,
  }) : super(key: key);

  @override
  _MeetingScreenState createState() => _MeetingScreenState();
}

class _MeetingScreenState extends State<MeetingScreen> {
  late Room room;
  String? presenterId;

  @override
  void initState() {
    super.initState();

    if (kIsWeb) {
      final uri = Uri.base;

      widget.meetingId = uri.queryParameters['meetingId'] ?? '';
      widget.token = uri.queryParameters['token'] ?? '';
      widget.participantName = uri.queryParameters['participantName'] ?? '';
      widget.isHost = uri.queryParameters['isHost'] ?? 'true';

      /*print('Received meetingId: ${widget.meetingId}');
      print('Received token: ${widget.token}');
      print('Received participantName: ${widget.participantName}');*/

      // Create a Room instance
      room = VideoSDK.createRoom(
        roomId: widget.meetingId ?? '',
        token: widget.token ?? '',
        displayName: widget.participantName ?? '',
        micEnabled: false,
        camEnabled: false,
        metaData: {'isHost': widget.isHost},
      );
    } else {
      // Create a Room instance
      room = VideoSDK.createRoom(
        roomId: widget.meetingIdM ?? '',
        token: widget.tokenM ?? '',
        displayName: widget.participantNameM ?? '',
        micEnabled: false,
        camEnabled: false,
        defaultCameraIndex: 1,
        metaData: {'isHost': widget.isHostM ?? 'true'},
      );
    }

    // Join the room
    room.join();
  }

  @override
  void dispose() {
    room.end();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (kIsWeb &&
            (widget.meetingId!.isEmpty ||
                widget.token!.isEmpty ||
                widget.participantName!.isEmpty) ||
        !kIsWeb &&
            (widget.meetingIdM!.isEmpty ||
                widget.tokenM!.isEmpty ||
                widget.participantNameM!.isEmpty)) {
      return Scaffold(
        body: Center(child: Text('Missing essential parameters')),
      );
    }
    // The MeetingView widget is provided by the package
    return Scaffold(
      backgroundColor: darkBg,
      appBar: AppBar(
        backgroundColor: Colors.grey[900],
        automaticallyImplyLeading: false,
        title: SelectableText(
          'Meeting ID: ${kIsWeb ? widget.meetingId : widget.meetingIdM}',
          style: GoogleFonts.comfortaa(
            color: Colors.white,
            fontSize: kIsWeb ? 30 : 20,
          ),
        ),
        centerTitle: true,
      ),
      body: MeetingView(
        room: room,
        presenterId: presenterId,
        isHost: widget.isHost,
        onLeave: widget.onLeave,
      ),
    );
  }
}

class MeetingView extends StatefulWidget {
  final Room room;
  String? presenterId;
  String? isHost;

  final VoidCallback? onLeave;

  MeetingView({
    required this.room,
    required this.presenterId,
    required this.isHost,
    required this.onLeave,
    Key? key,
  }) : super(key: key);

  @override
  _MeetingViewState createState() => _MeetingViewState();
}

class _MeetingViewState extends State<MeetingView> {
  bool micEnabled = false;
  bool camEnabled = false;
  Stream? screenShareStream;
  Stream? videoStream;
  Stream? audioStream;

  @override
  void initState() {
    super.initState();

    // Handle when the room is left
    widget.room.on(Events.roomLeft, () {
      //widget.room.leave();
      //Navigator.of(context).pop();
      if (widget.onLeave != null) {
        widget.onLeave!();
      } else {
        Navigator.of(context).pop(); // fallback
      }
    });

    // Handle participant joins/leaves
    widget.room.on(Events.participantJoined, (_) => setState(() {}));
    widget.room.on(Events.participantLeft, (_) => setState(() {}));

    //Listening if remote participant starts presenting
    widget.room.on(Events.presenterChanged, (String? presenterId) {
      setState(() {
        widget.presenterId = presenterId;
      });
    });

    // LOCAL screen share
    widget.room.localParticipant.on(Events.streamEnabled, (stream) async {
      if (stream.kind == 'share') {
        setState(() {
          screenShareStream = stream;
          widget.presenterId = widget.room.localParticipant.id;
        });
      } else if (stream.kind == 'audio') {
        setState(() {
          audioStream = stream;
          micEnabled = true;
        });
      } else if (stream.kind == 'video') {
        setState(() {
          videoStream = stream;
          camEnabled = true;
        });
      }
    });

    widget.room.localParticipant.on(Events.streamDisabled, (stream) {
      if (stream.kind == 'share') {
        setState(() {
          screenShareStream = null;
          widget.presenterId = null;
        });
      } else if (stream.kind == 'video') {
        setState(() {
          videoStream = null;
          micEnabled = false;
        });
      } else if (stream.kind == 'audio') {
        setState(() {
          audioStream = null;
          camEnabled = false;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // Get participants map
    final participants = widget.room.participants;

    // Add local participant to the list
    final localParticipant = widget.room.localParticipant;

    // Combine local and remote participants for display
    final allParticipants = [localParticipant, ...participants.values];

    /*bool isScreenSharing = widget.room.localParticipant.streams.containsKey(
      "share",
    );*/

    return Scaffold(
      backgroundColor: Colors.black,
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 10),

            // Shared screen
            if (widget.presenterId != null)
              SizedBox(
                height:
                    kIsWeb ? MediaQuery.of(context).size.height * 0.85 : null,
                child: ShareScreenTile(
                  participant:
                      widget.presenterId == widget.room.localParticipant.id
                          ? widget.room.localParticipant
                          : widget.room.participants[widget.presenterId],
                ),
              ),

            if (widget.presenterId != null)
              Divider(color: Colors.white, thickness: 2),

            // Video grid
            SizedBox(
              height:
                  !kIsWeb
                      ? MediaQuery.of(context).size.height * 0.799
                      : MediaQuery.of(context).size.height,
              child: GridView.builder(
                physics: const BouncingScrollPhysics(),
                shrinkWrap: true,
                padding: const EdgeInsets.all(8),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 8,
                  crossAxisSpacing: 8,
                  childAspectRatio: 1,
                ),
                itemCount: allParticipants.length,
                itemBuilder: (context, index) {
                  final participant = allParticipants[index];
                  return ParticipantVideoTile(participant: participant);
                },
              ),
            ),
          ],
        ),
      ),

      // Fixed Controls
      bottomNavigationBar: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 👥 Participant count label
          Container(
            width: double.infinity,
            color: Colors.black87,
            padding: const EdgeInsets.symmetric(vertical: 6),
            child: Text(
              'Participants: ${allParticipants.length}',
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),

          // 🎮 Bottom control bar
          Container(
            color: Colors.grey[900],
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                // Mic toggle
                Tooltip(
                  message: !micEnabled ? 'Turn mic on' : 'Turn mic off',
                  child: IconButton(
                    icon: Icon(
                      !micEnabled ? Icons.mic : Icons.mic_off,
                      color: !micEnabled ? Colors.green : Colors.red,
                    ),
                    onPressed: () {
                      setState(() {
                        micEnabled = !micEnabled;
                        micEnabled
                            ? widget.room.unmuteMic()
                            : widget.room.muteMic();
                      });
                    },
                  ),
                ),

                // Camera toggle
                Tooltip(
                  message: !camEnabled ? 'Turn camera on' : 'Turn camera off',
                  child: IconButton(
                    icon: Icon(
                      !camEnabled ? Icons.videocam : Icons.videocam_off,
                      color: !camEnabled ? Colors.green : Colors.red,
                    ),
                    onPressed: () {
                      setState(() {
                        camEnabled = !camEnabled;
                        camEnabled
                            ? widget.room.enableCam()
                            : widget.room.disableCam();
                      });
                    },
                  ),
                ),

                // Screen share toggle
                Tooltip(
                  message: 'Share screen',
                  child: IconButton(
                    icon: Icon(
                      widget.presenterId != null
                          ? Icons.stop_screen_share
                          : Icons.screen_share,
                      color:
                          widget.presenterId != null
                              ? Colors.red
                              : Colors.green,
                    ),
                    onPressed: () async {
                      try {
                        if (widget.presenterId != null) {
                          await widget.room.disableScreenShare();
                        } else {
                          await widget.room.enableScreenShare();
                        }
                      } catch (e) {
                        ScaffoldMessenger.of(
                          context,
                        ).showSnackBar(SnackBar(content: Text("Error: $e")));
                      }
                      setState(() {});
                    },
                  ),
                ),

                // Leave button
                Tooltip(
                  message: 'Leave meeting',
                  child: IconButton(
                    icon: const Icon(Icons.call_end, color: Colors.redAccent),
                    onPressed: () {
                      widget.room.leave();
                      widget.onLeave?.call();
                      closeCurrentTab();
                    },
                  ),
                ),

                // End meeting (host only)
                if (widget.isHost == 'true')
                  Tooltip(
                    message: 'End meeting',
                    child: IconButton(
                      icon: const Icon(Icons.close, color: Colors.redAccent),
                      onPressed: () async {
                        bool? confirmed = await showDialog(
                          barrierDismissible: false,
                          context: super.context,
                          builder:
                              (context) => AlertDialog(
                                backgroundColor: darkBg,
                                title: Text(
                                  'End meeting?',
                                  style: GoogleFonts.comfortaa(
                                    color: Colors.white,
                                  ),
                                ),
                                content: Text(
                                  'Are you sure you want to end this meeting?',
                                  style: GoogleFonts.comfortaa(
                                    color: Colors.white,
                                  ),
                                ),
                                actions: [
                                  TextButton(
                                    onPressed:
                                        () => Navigator.pop(context, false),
                                    child: Text(
                                      'No',
                                      style: GoogleFonts.comfortaa(
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                  TextButton(
                                    onPressed:
                                        () => Navigator.pop(context, true),
                                    child: Text(
                                      'Yes, end meeting',
                                      style: GoogleFonts.comfortaa(
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                        );
                        if (confirmed!) {
                          allParticipants.clear();
                          widget.room.end();
                          widget.onLeave?.call();
                          Navigator.of(context).pop();
                          closeCurrentTab();
                        }
                      },
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class ParticipantVideoTile extends StatefulWidget {
  final Participant participant;
  const ParticipantVideoTile({super.key, required this.participant});

  @override
  State<ParticipantVideoTile> createState() => _ParticipantTileState();
}

class _ParticipantTileState extends State<ParticipantVideoTile> {
  Stream? videoStream;
  Stream? audioStream;
  Stream? shareStream;

  @override
  void initState() {
    // initial video stream for the participant
    widget.participant.streams.forEach((key, Stream stream) {
      setState(() {
        if (stream.kind == 'video') {
          videoStream = stream;
        } else if (stream.kind == 'audio') {
          audioStream = stream;
        } else if (stream.kind == 'share') {
          shareStream = stream;
        }
      });
    });

    _initStreamListeners();
    super.initState();
  }

  _initStreamListeners() {
    widget.participant.on(Events.streamEnabled, (Stream stream) {
      if (stream.kind == 'video') {
        setState(() => videoStream = stream);
      } else if (stream.kind == 'audio') {
        setState(() => audioStream = stream);
      } else if (stream.kind == 'share') {
        setState(() => shareStream = stream);
      }
    });

    widget.participant.on(Events.streamDisabled, (Stream stream) {
      if (stream.kind == 'video') {
        setState(() => videoStream = null);
      } else if (stream.kind == 'audio') {
        setState(() => audioStream = null);
      } else if (stream.kind == 'share') {
        setState(() => shareStream = null);
      }
    });
  }

  @override
  void setState(fn) {
    if (mounted) {
      super.setState(fn);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Stack(
        children: [
          Positioned.fill(
            child:
                videoStream != null
                    ? RTCVideoView(
                      videoStream?.renderer as RTCVideoRenderer,
                      objectFit:
                          RTCVideoViewObjectFit.RTCVideoViewObjectFitCover,
                    )
                    : Container(
                      color: Colors.grey.shade800,
                      child: const Center(
                        child: Icon(
                          Icons.person,
                          size: 100,
                          color: Colors.white,
                        ),
                      ),
                    ),
          ),

          // Bottom-left overlay for participant name
          Positioned(
            left: 8,
            bottom: 8,
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: kIsWeb ? 8 : 4,
                vertical: kIsWeb ? 4 : 2,
              ),
              decoration: BoxDecoration(
                color: Colors.black54,
                borderRadius: BorderRadius.circular(4),
              ),
              child: Row(
                children: [
                  Icon(
                    audioStream != null ? Icons.mic : Icons.mic_off,
                    color: audioStream != null ? Colors.green : Colors.red,
                    size: 20,
                  ),
                  const SizedBox(width: kIsWeb ? 10 : 5),
                  Icon(
                    videoStream != null ? Icons.videocam : Icons.videocam_off,
                    color: videoStream != null ? Colors.green : Colors.red,
                    size: 20,
                  ),
                  const SizedBox(width: kIsWeb ? 10 : 5),
                  Text(
                    widget.participant.displayName,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: kIsWeb ? 14 : 12,
                    ),
                    //overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class ShareScreenTile extends StatefulWidget {
  final Participant? participant;
  const ShareScreenTile({super.key, required this.participant});

  @override
  State<ShareScreenTile> createState() => _ShareScreenTileState();
}

class _ShareScreenTileState extends State<ShareScreenTile> {
  Stream? videoStream;

  @override
  void initState() {
    // initial video stream for the participant
    widget.participant?.streams.forEach((key, value) {
      setState(() {
        if (value.kind == 'share') {
          videoStream = value;
        }
      });
    });

    _initStreamListeners();
    super.initState();
  }

  _initStreamListeners() {
    /* widget.participant?.on(Events.streamEnabled, (Stream stream) {
      if (stream.kind == 'share') {
        setState(() => videoStream = stream);
      }
    });

    widget.participant?.on(Events.streamDisabled, (Stream stream) {
      if (stream.kind == 'share') {
        setState(() => videoStream = null);
      }
    });*/
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child:
          videoStream != null
              ? Padding(
                padding: const EdgeInsets.all(8),
                child: AspectRatio(
                  aspectRatio: 16 / 9,
                  child: Stack(
                    children: [
                      RTCVideoView(
                        videoStream?.renderer as RTCVideoRenderer,
                        objectFit:
                            RTCVideoViewObjectFit.RTCVideoViewObjectFitCover,
                      ),
                      // Presenter's name overlay
                      Positioned(
                        left: 12,
                        bottom: 12,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.black54,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            '${widget.participant!.displayName}\'s screen',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              shadows: [
                                Shadow(
                                  blurRadius: 4,
                                  color: Colors.black,
                                  offset: Offset(1, 1),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              )
              : null,
    );
  }
}
