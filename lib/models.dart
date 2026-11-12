/// 星语 App 的数据模型。
library;

class MeProfile {
  MeProfile({
    required this.name,
    required this.emoji,
    required this.ava,
    required this.sig,
    required this.tags,
  });

  String name;
  String emoji;
  String ava;
  String sig;
  List<String> tags;
}

class Friend {
  const Friend({
    required this.id,
    required this.name,
    required this.emoji,
    required this.ava,
    this.age = 0,
    this.city = '',
    this.mbti = '',
    this.score = 0,
    this.heart = 0,
    this.target = 200,
    this.days = 0,
    this.rel = '好友',
    this.group = 'all',
    this.online = false,
    this.isGroup = false,
    this.sig = '',
    this.sub,
    this.tags = const [],
    this.mom = const [],
    this.trait = const [0, 0, 0, 0],
  });

  final String id;
  final String name;
  final String emoji;
  final String ava;
  final int age;
  final String city;
  final String mbti;
  final int score;
  final int heart;
  final int target;
  final int days;
  final String rel;
  final String group; // soul / close / all / group
  final bool online;
  final bool isGroup;
  final String sig;
  final String? sub;
  final List<String> tags;
  final List<String> mom;
  final List<int> trait;
}

enum MsgKind { system, incoming, outgoing, quiz }

class ChatMessage {
  ChatMessage({
    required this.kind,
    this.text,
    this.voice = false,
    this.duration,
    this.bars = const [],
    this.image = false,
    this.label,
    this.time,
  });

  factory ChatMessage.system(String text) =>
      ChatMessage(kind: MsgKind.system, text: text);

  factory ChatMessage.incoming(String text) =>
      ChatMessage(kind: MsgKind.incoming, text: text);

  factory ChatMessage.outgoing(String text, {String? time}) =>
      ChatMessage(kind: MsgKind.outgoing, text: text, time: time);

  factory ChatMessage.voice({
    required String duration,
    required List<double> bars,
  }) =>
      ChatMessage(
        kind: MsgKind.incoming,
        voice: true,
        duration: duration,
        bars: bars,
      );

  factory ChatMessage.image(String label) => ChatMessage(
        kind: MsgKind.incoming,
        image: true,
        label: label,
      );

  factory ChatMessage.quiz() => ChatMessage(kind: MsgKind.quiz);

  final MsgKind kind;
  final String? text;
  final bool voice;
  final String? duration;
  final List<double> bars;
  final bool image;
  final String? label;
  final String? time;
}

class ChatThread {
  ChatThread({
    required this.id,
    required this.name,
    required this.emoji,
    required this.ava,
    required this.meta,
    required this.heart,
    required this.target,
    required this.messages,
    this.isGroup = false,
  });

  final String id;
  final String name;
  final String emoji;
  final String ava;
  final String meta;
  int heart;
  final int target;
  final List<ChatMessage> messages;
  final bool isGroup;

  double get ratio => (heart / target).clamp(0.0, 1.0);

  int get heartLeft => target - heart < 0 ? 0 : target - heart;
}

class FriendRequest {
  FriendRequest({
    required this.id,
    required this.name,
    required this.emoji,
    required this.ava,
    required this.age,
    required this.city,
    required this.mbti,
    required this.score,
    required this.time,
    required this.note,
    this.status = 'pending',
  });

  final String id;
  final String name;
  final String emoji;
  final String ava;
  final int age;
  final String city;
  final String mbti;
  final int score;
  final String time;
  final String note;
  String status; // pending / accepted / ignored
}

class Post {
  Post({
    required this.id,
    required this.name,
    required this.emoji,
    required this.ava,
    required this.meta,
    required this.text,
    required this.highlight,
    required this.mediaLabel,
    required this.mediaIndex,
    required this.tags,
    required this.likes,
    required this.comments,
    required this.following,
    this.liked = false,
  });

  final String id;
  final String name;
  final String emoji;
  final String ava;
  final String meta;
  final String text;
  final String? highlight;
  final String mediaLabel;
  final int mediaIndex;
  final List<String> tags;
  int likes;
  final int comments;
  bool liked;
  bool following;
}

class MomentComment {
  MomentComment({
    required this.name,
    required this.emoji,
    required this.ava,
    required this.text,
  });

  final String name;
  final String emoji;
  final String ava;
  final String text;
}

class Moment {
  Moment({
    required this.isMe,
    required this.name,
    required this.emoji,
    required this.ava,
    required this.meta,
    required this.text,
    required this.grid,
    required this.likes,
    required this.comments,
  });

  final bool isMe;
  final String name;
  final String emoji;
  final String ava;
  final String meta;
  final String text;
  final List<String> grid;
  final int likes;
  final List<MomentComment> comments;
  bool liked = false;
}

class RecentChat {
  const RecentChat({
    required this.chatId,
    required this.name,
    required this.emoji,
    required this.ava,
    required this.preview,
    required this.time,
    this.chip,
    this.online = false,
    this.badge = 0,
    this.dot = false,
  });

  final String chatId;
  final String name;
  final String emoji;
  final String ava;
  final String preview;
  final String time;
  final String? chip;
  final bool online;
  final int badge;
  final bool dot;
}
