import 'package:hamaraprashasan/helper_classes/feed_classes/feed_info_details_class.dart';
import 'package:hamaraprashasan/helper_classes/feed_classes/feed_info_class.dart';
import 'package:hamaraprashasan/helper_classes/user_classes/department_user_class.dart';
import 'package:hamaraprashasan/constants/constants.dart';

class Feed {
  FeedInfo feedInfo;
  Department department;
  FeedInfoDetails feedInfoDetails;
  String profileAvatar;
  int bgColor;
  String feedId;

  Feed(
      {FeedInfo feedInfo,
        Department department,
        FeedInfoDetails feedInfoDetails,
        String feedId}) {
    this.feedInfo = feedInfo;
    this.department = department;
    this.feedInfoDetails = feedInfoDetails;
    this.profileAvatar = "assets/avatars/${department.category}.svg";
    this.bgColor = avatarColorMap['${department.category}'];
    this.feedId = feedId;
  }
}

class Feeds {
  List<Feed> feeds = List<Feed>();
}