import 'dart:io';

import 'package:image/image.dart';
import 'dart:math' as math;

void main(List<String> args) {
  // delete old test files
  var testDir = Directory("./test_images");
  if (testDir.existsSync()) {
    testDir.listSync().forEach((f) {
      f.deleteSync();
    });
  } else {
    testDir.createSync();
  }
  var count = args.isEmpty ? 100 : int.tryParse(args[0]);

  List<String> imageNames = _generateImages(count);
  print("Generated ${imageNames.length} images in the dir 'test_images'.");
  print("Sync files to android device...");
  var targetDir = "/sdcard/Android/data/com.example.large_image_test/files/test_images";
  Process.runSync("adb", ["shell", "rm", "-r", targetDir]);
  Process.runSync("adb", ["shell", "mkdir", targetDir]);
  Process.runSync("adb", ["push", ...imageNames, targetDir], workingDirectory: testDir.path);
}

List<String> _generateImages(int count) {
  var rand = math.Random();
  var imageNames = <String>[];
  for (var i = 0; i < count; i++) {
    //max: 2000 x 4000
    final image = Image(
      2000,
      1000 + rand.nextInt(3000),
      channels: Channels.rgba,
    );

    var background = getColor(
      rand.nextInt(128) + 128,
      rand.nextInt(128) + 128,
      rand.nextInt(128) + 128,
      rand.nextInt(256),
    );
    var line =
        getColor(rand.nextInt(128), rand.nextInt(128), rand.nextInt(128));
    var circle = getColor(rand.nextInt(64), rand.nextInt(64), rand.nextInt(64));
    var text =
        getColor(rand.nextInt(256), rand.nextInt(256), rand.nextInt(256));
    fill(image, getColor(255, 255, 255));
    fillRect(
      image,
      image.width ~/ 10,
      image.height ~/ 10,
      image.width * 2 ~/ 3,
      image.height * 2 ~/ 3,
      background,
    );
    fillRect(
      image,
      image.width ~/ 3,
      image.height ~/ 3,
      image.width - image.width ~/ 10,
      image.height - image.height ~/ 10,
      background,
    );
    // generate random control points
    var size = rand.nextInt(20) + 10;
    var points = List.generate(
      size,
      (index) => index.isEven
          ? Point(
              rand.nextInt(image.width),
              math.min(index * image.height ~/ size, image.height),
            )
          : Point(
              math.min(index * image.width ~/ size, image.width),
              rand.nextInt(image.height),
            ),
    );
    for (var i = 0; i < points.length; i++) {
      var begin = i;
      var end = i + 1 >= points.length ? 0 : i + 1;
      drawLine(
        image,
        points[begin].x,
        points[begin].y,
        points[end].x,
        points[end].y,
        line,
        thickness: 14,
      );
    }
    for (final point in points) {
      fillCircle(image, point.x, point.y, 30, circle);
    }
    drawStringCentered(image, arial_48, "${image.width}x${image.height}",
        color: text);
    var imageName = "${i}_${image.width}x${image.height}.png";
    imageNames.add(imageName);
    File("test_images/$imageName").writeAsBytesSync(encodePng(image));
  }
  return imageNames;
}
