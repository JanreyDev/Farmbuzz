import 'dart:io';
import 'package:image/image.dart' as img;

void main() {
  final file = File('assets/images/logo.png');
  final image = img.decodeImage(file.readAsBytesSync());

  if (image == null) return;

  final size = image.width > image.height ? image.width : image.height;
  // Pad with 10% margin
  final paddedSize = (size * 1.2).toInt();

  final square = img.Image(width: paddedSize, height: paddedSize);
  
  // Fill with white background
  img.fill(square, color: img.ColorRgba8(255, 255, 255, 255));

  final x = (paddedSize - image.width) ~/ 2;
  final y = (paddedSize - image.height) ~/ 2;

  img.compositeImage(square, image, dstX: x, dstY: y);

  File('assets/images/logo_square.png').writeAsBytesSync(img.encodePng(square));
  print('Done padding image to ' + paddedSize.toString() + 'x' + paddedSize.toString());
}
