import 'dart:typed_data';

import 'package:flutter/services.dart' show rootBundle;

class StockImageService {
  static final StockImageService instance = StockImageService._init();

  StockImageService._init();

  final List<String> stockImagePaths = [
    'assets/images/stock_images/one_person.jpeg',
    'assets/images/stock_images/one_person2.jpeg',
    'assets/images/stock_images/one_person3.jpeg',
    'assets/images/stock_images/one_person4.jpeg',
    'assets/images/stock_images/group_of_people.jpeg',
    'assets/images/stock_images/largest_group.jpg',
  ];

  Future<(Uint8List, String)> getNextStockImage(int counter) async {
    final path = stockImagePaths[counter % stockImagePaths.length];
    final byteData = await rootBundle.load(path);
    return (byteData.buffer.asUint8List(), path);
  }
}