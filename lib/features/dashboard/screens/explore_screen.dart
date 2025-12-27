import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shimmer/shimmer.dart';
import 'package:sizer/sizer.dart';
import 'package:travel_minds/data/repositories/mongo_repository.dart';
import 'package:travel_minds/features/dashboard/models/state_model.dart';
import 'package:travel_minds/features/dashboard/screens/main/package_list_screen.dart';

class ExploreScreen extends StatefulWidget {
  @override
  State<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen> {
  bool showAnimatedSearchBar = true;
  TextEditingController searchController = TextEditingController();
  List<StateModel> allStates = [];
  List<StateModel> filteredStates = [];
  bool isDelayed = true;

  @override
  void initState() {
    super.initState();

    _fetchStates(); // ✅ Start fetching immediately

    Future.delayed(Duration(seconds: 1), () {
      setState(() {
        isDelayed = false; // After delay, update UI
      });
    });

    searchController.addListener(() {
      _filterStates(searchController.text);
    });
  }


  Future<void> _fetchStates() async {
    try {
      var data = await MongoDb.fetchAllPackages();
      List<StateModel> states = data.map<StateModel>((json) => StateModel.fromJson(json)).toList();
      setState(() {
        allStates = states;
        filteredStates = states;
      });
    } catch (e) {
      debugPrint("Error fetching states: $e");
    }
  }

  void _filterStates(String query) {
    setState(() {
      filteredStates = allStates
          .where((state) => state.state.toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromRGBO(8, 9, 11, 1),
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return [
            SliverAppBar(
              pinned: true,
              toolbarHeight: 6.h,
              collapsedHeight: 12.h,
              expandedHeight: 22.h,
              backgroundColor: Color.fromRGBO(8, 9, 11, 1),
              floating: true,
              flexibleSpace: FlexibleSpaceBar(
                titlePadding: EdgeInsets.only(bottom: 8.0),
                centerTitle: true,
                title: Padding(
                  padding: EdgeInsets.only(right: 10, bottom: 6),
                  child: Container(
                    margin: EdgeInsets.only(left: 10),
                    width: 90.w,
                    height: 4.3.h,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10.sp),
                      color: Color.fromARGB(255, 153, 186, 196),
                    ),
                    child: Row(
                      children: [
                        SizedBox(width: 2.w),
                        Icon(Icons.search, color: Color.fromARGB(255, 128, 126, 126), size: 18.sp),
                        SizedBox(width: 3.w),
                        Expanded(
                          child: Container(
                            margin: EdgeInsets.only(bottom: 6),
                            child: TextField(
                              controller: searchController,
                              style: TextStyle(color: Colors.black, fontSize: 14.sp),
                              decoration: InputDecoration(
                                hintText: 'searchStates'.tr,
                                hintStyle: TextStyle(color: Colors.grey[600], fontSize: 14.sp),
                                border: InputBorder.none,
                                enabledBorder: InputBorder.none,
                                focusedBorder: InputBorder.none,
                              ),
                              cursorColor: Colors.black,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                background: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Spacer(),
                    Padding(
                      padding: const EdgeInsets.only(left: 10),
                      child: Text(
                        "explore".tr,
                        style: TextStyle(color: Colors.white, fontSize: 20.sp, fontWeight: FontWeight.w500),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 10),
                      child: Text(
                        "destination".tr,
                        style: TextStyle(color: Colors.white, fontSize: 22.sp, fontWeight: FontWeight.bold),
                      ),
                    ),
                    const Spacer(),
                  ],
                ),
              ),
            ),
          ];
        },
        body: _buildStateList(),
      ),
    );
  }

  Widget _buildStateList() {
    if (isDelayed || allStates.isEmpty) {
      // ✅ Show shimmer effect while loading or waiting for data
      return packageShimmer();
    } else if (filteredStates.isEmpty) {
      // ✅ Show "No states found" only if data is loaded but search found nothing
      return Center(
        child: Text(
          "No states found!",
          style: TextStyle(
            color: Colors.white,
            fontSize: 18.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
      );
    }

    // ✅ Show the actual list of states
    return ListView.builder(
      padding: EdgeInsets.all(16.0),
      itemCount: filteredStates.length,
      itemBuilder: (context, index) {
        return GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => PackageListScreen(state: filteredStates[index]),
              ),
            );
          },
          child: StateTile(state: filteredStates[index]),
        );
      },
    );
  }


}

class StateTile extends StatelessWidget {
  final StateModel state;

  StateTile({required this.state});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 200,
      margin: EdgeInsets.only(bottom: 12.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12.0),
        image: DecorationImage(
          image: NetworkImage(state.stateImage),
          fit: BoxFit.cover,
        ),
      ),
      child: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12.0),
              gradient: LinearGradient(
                colors: [Colors.black54, Colors.transparent],
                begin: Alignment.bottomCenter,
                end: Alignment.topCenter,
              ),
            ),
          ),
          Positioned(
            left: 12.0,
            bottom: 20.0,
            child: Text(
              state.state,
              style: TextStyle(
                color: Colors.white,
                fontSize: 18.0,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

 Widget packageShimmer() {
  return ListView.builder(
    padding: EdgeInsets.all(18.0),
    itemCount: 5, // Display 5 shimmer placeholders
    itemBuilder: (context, index) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 12.0),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: Shimmer.fromColors(
            baseColor: Colors.grey.withOpacity(0.6),
            highlightColor: Colors.white,
            child: Container(
              height: 22.h,
              width: 100.w,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.7),
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
        ),
      );
    },
  );
}


