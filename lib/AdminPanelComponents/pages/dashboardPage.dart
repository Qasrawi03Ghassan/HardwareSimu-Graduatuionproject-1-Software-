import 'dart:convert';
import 'dart:math';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hardwaresimu_software_graduation_project/comments.dart';
import 'package:hardwaresimu_software_graduation_project/courseVideo.dart';
import 'package:hardwaresimu_software_graduation_project/courses.dart';
import 'package:hardwaresimu_software_graduation_project/mobilePages/welcome.dart';
import 'package:hardwaresimu_software_graduation_project/posts.dart';
import 'package:hardwaresimu_software_graduation_project/users.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

class DashboardPage extends StatefulWidget {
  final bool theme;
  final User user;
  const DashboardPage({super.key, required this.theme, required this.user});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  List<Course> dbCoursesList = [];
  List<User> dbUsersList = [];
  List<CourseVideo> dbCoursesVideos = [];
  List<Post> dbPostsList = [];
  List<Comment> dbCommentsList = [];

  String selectedChart = 'Comments';
  List<FlSpot> chartData = [];
  int selectedYear = DateTime.now().year;
  int selectedMonth = DateTime.now().month;
  List<String> chartLabels = [];

  void updateChartDataFromDB(List<dynamic> items) {
    Map<String, int> countPerDay = {};

    for (var item in items) {
      var rawDate;
      if (item is Map) {
        rawDate = item['createdAt'];
      } else {
        rawDate = item.createdAt;
      }

      if (rawDate == null) continue;

      DateTime date =
          rawDate is DateTime
              ? rawDate
              : DateTime.tryParse(rawDate.toString()) ?? DateTime.now();

      String day = DateFormat('yyyy-MM-dd').format(date);
      countPerDay[day] = (countPerDay[day] ?? 0) + 1;
    }

    List<String> sortedDays = countPerDay.keys.toList()..sort();
    List<FlSpot> data = [];

    for (int i = 0; i < sortedDays.length; i++) {
      data.add(FlSpot(i.toDouble(), countPerDay[sortedDays[i]]!.toDouble()));
    }

    setState(() {
      chartData = data;
      chartLabels = sortedDays;
    });
  }

  Future<void> _fetchUsers() async {
    final response = await http.get(
      Uri.parse(
        kIsWeb
            ? 'http://localhost:3000/api/users'
            : 'http://10.0.2.2:3000/api/users',
      ),
    );
    if (response.statusCode == 200) {
      final List<dynamic> json = jsonDecode(response.body);
      setState(() {
        dbUsersList = json.map((item) => User.fromJson(item)).toList();
      });
    } else {
      throw Exception('Failed to load users');
    }
  }

  Future<void> _fetchCourses() async {
    final response = await http.get(
      Uri.parse(
        kIsWeb
            ? 'http://localhost:3000/api/courses'
            : 'http://10.0.2.2:3000/api/courses',
      ),
    );
    if (response.statusCode == 200) {
      final List<dynamic> json = jsonDecode(response.body);
      if (mounted) {
        setState(() {
          dbCoursesList = json.map((item) => Course.fromJson(item)).toList();
        });
      }
    } else {
      throw Exception('Failed to load courses');
    }
  }

  Future<void> _fetchCoursesVideos() async {
    final response = await http.get(
      Uri.parse(
        kIsWeb
            ? 'http://localhost:3000/api/cVideos'
            : 'http://10.0.2.2:3000/api/cVideos',
      ),
    );
    if (response.statusCode == 200) {
      final List<dynamic> json = jsonDecode(response.body);
      setState(() {
        dbCoursesVideos =
            json.map((item) => CourseVideo.fromJson(item)).toList();
      });
    } else {
      throw Exception('Failed to load courses\' videos');
    }
  }

  Future<void> _fetchPosts() async {
    final response = await http.get(
      Uri.parse(
        kIsWeb
            ? 'http://localhost:3000/api/posts'
            : 'http://10.0.2.2:3000/api/posts',
      ),
    );
    if (response.statusCode == 200) {
      final List<dynamic> json = jsonDecode(response.body);
      setState(() {
        dbPostsList = json.map((item) => Post.fromJson(item)).toList();
      });
    } else {
      throw Exception('Failed to load posts');
    }
  }

  Future<void> _fetchComments() async {
    final response = await http.get(
      Uri.parse(
        kIsWeb
            ? 'http://localhost:3000/api/comments'
            : 'http://10.0.2.2:3000/api/comments',
      ),
    );
    if (response.statusCode == 200) {
      final List<dynamic> json = jsonDecode(response.body);
      setState(() {
        dbCommentsList = json.map((item) => Comment.fromJson(item)).toList();
      });
    } else {
      throw Exception('Failed to load comments');
    }
  }

  @override
  void initState() {
    super.initState();
    _fetchUsers();
    _fetchCourses();
    _fetchPosts();
    _fetchComments();
    _fetchPosts().then((_) => updateChartDataFromDB(dbPostsList));
    _fetchCourses().then((_) => updateChartDataFromDB(dbCoursesList));
    _fetchComments().then((_) => updateChartDataFromDB(dbCommentsList));
  }

  String displayTitle(String title) {
    return title.length <= 30 ? title : '${title.substring(0, 30)}...';
  }

  int getNonAdminUsers() {
    return dbUsersList.where((user) => !user.isAdmin).toList().length;
  }

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> stats = [
      {
        'label': 'Courses',
        'count': dbCoursesList.length,
        'icon': Icons.school,
        'color': Colors.green,
      },
      {
        'label': 'Users',
        'count': getNonAdminUsers(),
        'icon': Icons.people,
        'color': Colors.blue,
      },
      {
        'label': 'Posts',
        'count': dbPostsList.length,
        'icon': Icons.article,
        'color': Colors.orange,
      },
      {
        'label': 'Comments',
        'count': dbCommentsList.length,
        'icon': Icons.comment,
        'color': Colors.purple,
      },
    ];

    final cardColor =
        widget.theme
            ? Colors.blue.shade600
            : const Color.fromARGB(255, 67, 70, 92);
    final textColor = widget.theme ? Colors.white : Colors.green.shade600;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Overview Cards
          Center(
            child: Wrap(
              alignment: WrapAlignment.center,
              spacing: 20,
              runSpacing: 20,
              children:
                  stats.map((stat) {
                    return Container(
                      width: 400,
                      height: 150,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: cardColor,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: const [
                          BoxShadow(
                            color: Colors.black26,
                            blurRadius: 6,
                            offset: Offset(2, 4),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 50,
                            backgroundColor:
                                widget.theme ? Colors.white : Colors.grey[100],
                            child: Icon(
                              stat['icon'],
                              color: stat['color'],
                              size: 60,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                stat['count'].toString(),
                                style: GoogleFonts.comfortaa(
                                  fontSize: 50,
                                  fontWeight: FontWeight.bold,
                                  color: textColor,
                                ),
                              ),
                              Text(
                                stat['label'],
                                style: GoogleFonts.comfortaa(
                                  fontSize: 30,
                                  color: textColor,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  }).toList(),
            ),
          ),

          const SizedBox(height: 40),

          // Recent Posts Table
          Center(
            child: Wrap(
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      'Recent Posts',
                      style: GoogleFonts.comfortaa(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color:
                            widget.theme ? Colors.blue.shade600 : Colors.white,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Card(
                      elevation: 3,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: DataTable(
                        columns: [
                          DataColumn(
                            label: Expanded(
                              child: Center(
                                child: Text(
                                  style: GoogleFonts.comfortaa(),
                                  'Post ID',
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ),
                          ),
                          DataColumn(
                            label: Expanded(
                              child: Center(
                                child: Text(
                                  'Title',
                                  textAlign: TextAlign.center,
                                  style: GoogleFonts.comfortaa(),
                                ),
                              ),
                            ),
                          ),
                          DataColumn(
                            label: Expanded(
                              child: Center(
                                child: Text(
                                  style: GoogleFonts.comfortaa(),
                                  'Author',
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ),
                          ),
                        ],
                        rows:
                            (dbPostsList.toList()..sort(
                                  (a, b) => b.postID.compareTo(a.postID),
                                ))
                                .take(3)
                                .map(
                                  (post) => DataRow(
                                    cells: [
                                      DataCell(
                                        Text(
                                          post.postID.toString(),
                                          style: GoogleFonts.comfortaa(),
                                        ),
                                      ),
                                      DataCell(
                                        Tooltip(
                                          message: post.description,
                                          child: Text(
                                            displayTitle(post.description),
                                            style: GoogleFonts.comfortaa(),
                                          ),
                                        ),
                                      ),
                                      DataCell(
                                        Text(
                                          post.userEmail,
                                          style: GoogleFonts.comfortaa(),
                                        ),
                                      ),
                                    ],
                                  ),
                                )
                                .toList(),
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 10),
                Column(
                  children: [
                    Text(
                      'Recent Comments',
                      style: GoogleFonts.comfortaa(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color:
                            widget.theme ? Colors.blue.shade600 : Colors.white,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Card(
                      elevation: 3,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: DataTable(
                        columns: [
                          DataColumn(
                            label: Expanded(
                              child: Center(
                                child: Text(
                                  'Comment ID',
                                  textAlign: TextAlign.center,
                                  style: GoogleFonts.comfortaa(),
                                ),
                              ),
                            ),
                          ),
                          DataColumn(
                            label: Expanded(
                              child: Center(
                                child: Text(
                                  'Title',
                                  textAlign: TextAlign.center,
                                  style: GoogleFonts.comfortaa(),
                                ),
                              ),
                            ),
                          ),
                          DataColumn(
                            label: Expanded(
                              child: Center(
                                child: Text(
                                  'Author',
                                  textAlign: TextAlign.center,
                                  style: GoogleFonts.comfortaa(),
                                ),
                              ),
                            ),
                          ),
                        ],
                        rows:
                            (dbCommentsList.toList()..sort(
                                  (a, b) => b.commentID.compareTo(a.commentID),
                                ))
                                .take(3)
                                .map(
                                  (comment) => DataRow(
                                    cells: [
                                      DataCell(
                                        Text(
                                          comment.commentID.toString(),
                                          style: GoogleFonts.comfortaa(),
                                        ),
                                      ),
                                      DataCell(
                                        Tooltip(
                                          message: comment.description,
                                          child: Text(
                                            displayTitle(comment.description),
                                            style: GoogleFonts.comfortaa(),
                                          ),
                                        ),
                                      ),
                                      DataCell(
                                        Text(
                                          comment.userEmail,
                                          style: GoogleFonts.comfortaa(),
                                        ),
                                      ),
                                    ],
                                  ),
                                )
                                .toList(),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Dashboard Insights Section
          Text(
            'Insights',
            style: GoogleFonts.comfortaa(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: widget.theme ? Colors.blue.shade600 : Colors.white,
            ),
          ),
          const SizedBox(height: 16),
          Card(
            elevation: 3,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  buildChart(),
                  const SizedBox(height: 24),
                  //recentActivityFeed(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget recentActivityFeed() {
    final activities = [
      'Ahmed enrolled in Flutter Course',
      'Fatima posted "How to debug?"',
      'New comment on Java Course',
      'Khalid liked a post',
    ];

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Recent Activity',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            ...activities.map(
              (activity) => ListTile(
                leading: Icon(Icons.notifications, color: Colors.blue),
                title: Text(activity),
                dense: true,
                contentPadding: EdgeInsets.zero,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildChart() {
    void updateChartDataFromDB(List<dynamic> dataList) {
      final int daysInMonth = DateTime(selectedYear, selectedMonth + 1, 0).day;
      final Map<int, int> dayCounts = {
        for (int i = 1; i <= daysInMonth; i++) i: 0,
      };

      for (var item in dataList) {
        late DateTime date;

        if (item is Course) {
          date = item.createdAt;
        } else if (item is Post) {
          date = item.createdAt;
        } else if (item is Comment) {
          date = item.createdAt;
        } else {
          continue;
        }

        if (date.year == selectedYear && date.month == selectedMonth) {
          dayCounts[date.day] = dayCounts[date.day]! + 1;
        }
      }

      chartData =
          dayCounts.entries
              .map(
                (entry) =>
                    FlSpot((entry.key - 1).toDouble(), entry.value.toDouble()),
              )
              .toList();

      chartLabels = List.generate(daysInMonth, (index) {
        final day = index + 1;
        return '${selectedYear.toString()}-${selectedMonth.toString().padLeft(2, '0')}-$day';
      });
    }

    List<dynamic> selectedList;
    if (selectedChart == 'Courses') {
      selectedList = dbCoursesList;
    } else if (selectedChart == 'Posts') {
      selectedList = dbPostsList;
    } else {
      selectedList = dbCommentsList;
    }

    updateChartDataFromDB(selectedList);

    double rawMax =
        chartData.isNotEmpty
            ? chartData.map((e) => e.y).reduce((a, b) => a > b ? a : b)
            : 1;

    double maxY = (rawMax * 1.1).ceilToDouble();
    if (maxY == 0) maxY = 1; //

    double interval = (maxY / 5).ceilToDouble();
    if (interval < 1) interval = 1;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '$selectedChart Chart',
              style: GoogleFonts.comfortaa(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color:
                    widget.theme ? Colors.blue.shade600 : Colors.green.shade600,
              ),
            ),
            Expanded(child: SizedBox(width: 10)),
            Text(
              'Select chart type',
              style: GoogleFonts.comfortaa(
                color:
                    widget.theme ? Colors.blue.shade600 : Colors.green.shade600,
              ),
            ),
            const SizedBox(width: 10),
            DropdownButton<String>(
              value: selectedChart,
              items:
                  ['Courses', 'Posts', 'Comments']
                      .map(
                        (label) =>
                            DropdownMenuItem(value: label, child: Text(label)),
                      )
                      .toList(),
              onChanged: (value) {
                setState(() {
                  selectedChart = value!;
                });
              },
            ),
          ],
        ),
        Row(
          children: [
            Text(
              'Select year',
              style: GoogleFonts.comfortaa(
                color:
                    widget.theme ? Colors.blue.shade600 : Colors.green.shade600,
              ),
            ),
            const SizedBox(width: 3),
            DropdownButton<int>(
              value: selectedYear,
              items:
                  List.generate(5, (index) => DateTime.now().year - index)
                      .map(
                        (year) =>
                            DropdownMenuItem(value: year, child: Text('$year')),
                      )
                      .toList(),
              onChanged: (value) {
                setState(() {
                  selectedYear = value!;
                });
              },
            ),
            const SizedBox(width: 30),
            Text(
              'Select month',
              style: GoogleFonts.comfortaa(
                color:
                    widget.theme ? Colors.blue.shade600 : Colors.green.shade600,
              ),
            ),
            const SizedBox(width: 3),
            DropdownButton<int>(
              value: selectedMonth,
              items:
                  List.generate(12, (index) => index + 1)
                      .map(
                        (month) => DropdownMenuItem(
                          value: month,
                          child: Text('$month'),
                        ),
                      )
                      .toList(),
              onChanged: (value) {
                setState(() {
                  selectedMonth = value!;
                });
              },
            ),
          ],
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 320,
          child: LineChart(
            LineChartData(
              clipData: FlClipData.all(),
              minY: 0,
              maxY: maxY,
              // chartData.map((e) => e.y).fold(0.0, (a, b) => a > b ? a : b) +
              // 1,
              minX: 0,
              maxX:
                  chartLabels.length > 1
                      ? (chartLabels.length - 1).toDouble()
                      : 1,
              titlesData: FlTitlesData(
                topTitles: AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                bottomTitles: AxisTitles(
                  axisNameWidget: Padding(
                    padding: const EdgeInsets.only(top: 5.0),
                    child: Text(
                      'Day',
                      style: GoogleFonts.comfortaa(
                        fontSize: 20,
                        fontWeight: FontWeight.w900,
                        color:
                            widget.theme
                                ? Colors.blue.shade600
                                : Colors.green.shade600,
                      ),
                    ),
                  ),
                  axisNameSize: 32,
                  sideTitles: SideTitles(
                    showTitles: true,
                    interval: 5,
                    reservedSize: 32,
                    getTitlesWidget: (value, _) {
                      int index = value.toInt();
                      if (index >= 0 && index < chartLabels.length) {
                        return Text(
                          chartLabels[index].split('-').last,
                          style: GoogleFonts.comfortaa(
                            fontWeight: FontWeight.w900,
                            fontSize: 12,
                            color:
                                widget.theme
                                    ? Colors.blue.shade600
                                    : Colors.green.shade600,
                          ),
                        );
                      }
                      return const SizedBox.shrink();
                    },
                  ),
                ),
                leftTitles: AxisTitles(
                  axisNameWidget: Padding(
                    padding: const EdgeInsets.only(right: 20, bottom: 5),
                    child: Text(
                      'Count',
                      style: GoogleFonts.comfortaa(
                        fontSize: 20,
                        fontWeight: FontWeight.w900,
                        color:
                            widget.theme
                                ? Colors.blue.shade600
                                : Colors.green.shade600,
                      ),
                    ),
                  ),
                  axisNameSize: 28,
                  sideTitles: SideTitles(
                    showTitles: true,
                    interval: interval,
                    reservedSize: 32,
                    getTitlesWidget:
                        (value, _) => Text(
                          value.toInt().toString(),
                          style: GoogleFonts.comfortaa(
                            fontSize: 14,
                            fontWeight: FontWeight.w900,
                            color:
                                widget.theme
                                    ? Colors.blue.shade600
                                    : Colors.green.shade600,
                          ),
                        ),
                  ),
                ),
                rightTitles: AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
              ),
              gridData: FlGridData(show: true),
              borderData: FlBorderData(show: true),
              lineBarsData: [
                LineChartBarData(
                  spots: chartData,
                  isCurved: true,
                  color:
                      widget.theme
                          ? Colors.blue.shade600
                          : Colors.green.shade600,
                  dotData: FlDotData(
                    show: true,
                    getDotPainter: (spot, percent, barData, index) {
                      // Only show dot if y is not zero
                      if (spot.y == 0) {
                        return FlDotCirclePainter(
                          radius: 0,
                          color: Colors.transparent,
                        );
                      }
                      return FlDotCirclePainter(
                        radius: 4,
                        color:
                            widget.theme
                                ? Colors.blue.shade600
                                : Colors.green.shade600,
                        strokeWidth: 1,
                        strokeColor: Colors.white,
                      );
                    },
                  ),

                  belowBarData: BarAreaData(
                    show: true,
                    color:
                        widget.theme
                            ? Colors.blue.shade600.withOpacity(0.3)
                            : Colors.green.shade600.withOpacity(0.3),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
