import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  // PaintingBinding.instance.imageCache
  // ..maximumSize = 10
  // ..maximumSizeBytes = 50 << 20;
  runApp(MaterialApp(
    home: Scaffold(
      appBar: AppBar(
        title: Text("Large Images Test"),
      ),
      body: FutureBuilder<List<File>>(
        future: getExternalStorageDirectory().then((dir) =>
            Directory(path.join(dir.path, 'test_images'))
                .list()
                .cast<File>()
                .toList()),
        builder: (context, snapshot) {
          if (!snapshot.hasData ||
              snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(),
            );
          }
          final images = snapshot.data;
          Timer.periodic(const Duration(milliseconds: 250), (t) {
            var scrollController = PrimaryScrollController.of(context);
            if (scrollController == null) {
              t.cancel();
            } else if (scrollController.hasClients) {
              scrollController.animateTo(scrollController.offset + 300,
                  duration: const Duration(milliseconds: 200),
                  curve: Curves.fastOutSlowIn);
            }
          });
          return Scrollbar(
            child: ListView.builder(
              primary: true,
              itemBuilder: (BuildContext context, int index) =>
                  LargeImage(index, images[index % images.length]),
            ),
          );
        },
      ),
    ),
  ));
}

class LargeImage extends StatelessWidget {
  final int index;

  final File image;

  LargeImage(this.index, this.image) : super(key: ValueKey<String>(image.path));

  @override
  Widget build(BuildContext context) {
    var imageName = path.basenameWithoutExtension(image.path);
    var size = imageName
        .substring(imageName.indexOf("_") + 1)
        .split("x")
        .map(double.parse)
        .toList();
    double width = size[0];
    double height = size[1];
    return Stack(children: [
      AspectRatio(
        aspectRatio: width / height,
        child: Image.file(
          image,
          fit: BoxFit.fitWidth,
          // cacheWidth: 1080,
        ),
      ),
      Text("$index: $image"),
    ]);
  }
}

