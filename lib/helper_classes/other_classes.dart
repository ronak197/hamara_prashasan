import 'package:hamaraprashasan/home_page/feed_tab/filter_bottom_sheet.dart';


class TableData {
  List<String> headers;
  List<List<String>> contents;
  TableData({this.headers, this.contents});
}



class MyCsvParser {
  static List<List<String>> parser(String data) {
    String colDelemiter = ";", rowDelemiter = "\n";
    List<List<String>> res = [];
    var rows = data.split(rowDelemiter);
    for (var r in rows) {
      res.add(r.split(colDelemiter));
    }
    return res;
  }
}

class SortingFeeds {
  SortingType type;
  bool increasing;
  SortingFeeds([SortingFeeds sortingFeeds]) {
    type = sortingFeeds != null ? sortingFeeds.type : SortingType.none;
    increasing = sortingFeeds != null ? sortingFeeds.increasing : true;
  }
}


