import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: PageFlipView(),
    );
  }
}

class PageFlipView extends StatefulWidget {
  @override
  _PageFlipViewState createState() => _PageFlipViewState();
}

class _PageFlipViewState extends State<PageFlipView> {
  final PageController _pageController = PageController(initialPage: 1000);
  List<String> _items_title = [];
   List<String> _items_desc = [];
   List<String> _items_image = [];
  final int _totalPages = 5; // Default value if API fails



  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    final response = await http.get(Uri.parse('https://pirnav.com/ecart/getnewsinfo.php'));

    if (response.statusCode == 200) {
      
      List<dynamic> data = json.decode(response.body);
      setState(() {
        _items_title = data.map((item) => item['title'] as String).toList();
        _items_desc = data.map((item) => item['desc'] as String).toList();
        _items_image = data.map((item) => item['imagepath'] as String).toList();
      });
    } else {
      // Handle error
      throw Exception('Failed to load data');
    }
  }

  int _getPageIndex(int index) {
    return index % _items_title.length; // Wrap the index to create a loop
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title:Text('Mundadugu')),
      
      body: _items_title.isEmpty
          ? Center(child: CircularProgressIndicator()) // Loading indicator
          : PageView.builder(
              controller: _pageController,
              scrollDirection: Axis.vertical,
              itemBuilder: (context, index) {
                int pageIndex = _getPageIndex(index);
                return Center(
                  child: GestureDetector(
                    onTap: () {
                      if (_pageController.page!.toInt() == index) {
                        _pageController.nextPage(
                          duration: Duration(milliseconds: 1500),
                          curve: Curves.easeInOut,
                        );
                      }
                    },
                    child: Transform(
                      transform: Matrix4.identity()
                        ..rotateX((index % 2 == 0 ? 1 : -1) * 0.1),
                      alignment: Alignment.center,
                      

                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [

                        

                          // The text positioned over the image



                          Padding(padding: const EdgeInsets.only(bottom: 8),
                            child: ImageWithLoadingIndicator(
                              imageUrl: _items_image[pageIndex], // Replace with your image URL

                            ),
                          //  child:Image.network(_items_image[pageIndex], height: 200, fit:BoxFit.cover)
                          ),
                          
                         Padding(
                            padding:  const EdgeInsets.only(bottom:8, left: 15),
                          child: Text(
                            _items_title[pageIndex],
                            style:const TextStyle(
                              fontWeight:FontWeight.bold,
                              fontSize: 20
                            ),
                          ),
                          ),

                           Padding(
                            padding:  const EdgeInsets.only(bottom:8, left: 15),
                          //  child:Image.network(""),
                          child: Text(
                            _items_desc[pageIndex],
                            style:const TextStyle(
                              fontWeight:FontWeight.normal,
                              color: Color.fromARGB(255, 121, 120, 120),
                              fontSize: 18
                            ),
                          ),
                        ),     
                      ],)
                    ),
                  ),
                );
              },
            ),
    );
  }
}


class ImageWithLoadingIndicator extends StatelessWidget {
  final String imageUrl;

  ImageWithLoadingIndicator({required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    return Image.network(
      imageUrl,
      loadingBuilder: (BuildContext context, Widget child, ImageChunkEvent? loadingProgress) {
        if (loadingProgress == null) {
          // If loadingProgress is null, the image is fully loaded
          return child;
        } else {
          // Show CircularProgressIndicator while loading
          return Center(
            child: CircularProgressIndicator(
              value: loadingProgress.expectedTotalBytes != null
                  ? loadingProgress.cumulativeBytesLoaded / (loadingProgress.expectedTotalBytes ?? 1)
                  : null,
            ),
          );
        }
      },
      errorBuilder: (context, error, stackTrace) {
        return Center(child: Icon(Icons.error, color: Colors.red));
      },
    );
  }
}


