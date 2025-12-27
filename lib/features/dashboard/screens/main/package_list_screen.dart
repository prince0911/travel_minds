import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:sizer/sizer.dart';
import 'package:travel_minds/features/dashboard/models/package_model.dart';
import 'package:travel_minds/features/dashboard/models/state_model.dart';
import 'package:travel_minds/features/dashboard/screens/main/detail_package_screen.dart';

class PackageListScreen extends StatefulWidget {
  final StateModel state;

  PackageListScreen({required this.state});

  @override
  _PackageListScreenState createState() => _PackageListScreenState();
}

class _PackageListScreenState extends State<PackageListScreen> {
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration(seconds: 2), () {
      setState(() {
        isLoading = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromRGBO(8, 9, 11, 1),
      appBar: AppBar(
          iconTheme: IconThemeData(color: Colors.white),
          backgroundColor: Color.fromRGBO(28, 32, 37, 1.0),
          title: Text('${widget.state.state} Packages',style: TextStyle(color: Colors.white),)),
      body: ListView.separated(
        padding: EdgeInsets.all(16.0),
        itemCount: widget.state.packages.length,
        separatorBuilder: (context, index) => SizedBox(height: 12.0),
        itemBuilder: (context, index) {
          return isLoading
              ? ShimmerEffect()
              : PackageTile(package: widget.state.packages[index],stateName: widget.state.state,);
        },
      ),
    );
  }
}

class PackageTile extends StatelessWidget {
  final PackageModel package;
  final String stateName;

  PackageTile({required this.package, required this.stateName});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // Navigate to the DetailedPackageScreen and pass the package & stateName
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => DetailedPackageScreen(package: package, state: stateName),
          ),
        );
      },
      child: Container(
        height: 200,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12.0),
          image: DecorationImage(
            image: NetworkImage(package.images.isNotEmpty ? package.images[0] : ''),
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
              left: 3.w,
              bottom: 4.2.h,
              child: Text(
                package.name,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 1.8.h,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Positioned(
              left: 3.w,
              bottom: 2.h,
              child: Text(
                package.duration,
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 14.0,
                ),
              ),
            ),
            Positioned(
              right: 3.w,
              bottom: 1.5.h,
              child: Text(
                package.pricing.budget,
                style: TextStyle(
                  color: Colors.greenAccent,
                  fontSize: 16.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
class ShimmerEffect extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.grey.withOpacity(0.6),
      highlightColor: Colors.white,
      child: Container(
        height: 200,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12.0),
          color: Colors.white,
        ),
      ),
    );
  }
}
