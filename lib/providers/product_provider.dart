// lib/providers/product_provider.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// NOTE: I've added a 'category' key to each product map. This is crucial.
final List<Map<String, dynamic>> _allProducts = [
  {
    'id': '1',
    'name': 'Fresh Banana',
    'category': 'Fruits',
    'price': '\$1.99',
    'image':
        'https://images.pexels.com/photos/2280927/pexels-photo-2280927.jpeg?auto=compress&cs=tinysrgb&w=1260&h=750&dpr=2',
  },
  {
    'id': '2',
    'name': 'Organic Apples',
    'category': 'Fruits', 
    'price': '\$2.49',
    'image':
        'https://images.pexels.com/photos/102104/pexels-photo-102104.jpeg?auto=compress&cs=tinysrgb&w=1260&h=750&dpr=2',
  },
  {
    'id': '3',
    'name': 'Broccoli Bunch',
    'category': 'Vegetables', 
    'price': '\$1.50',
    'image':
        'https://images.pexels.com/photos/1435903/pexels-photo-1435903.jpeg?auto=compress&cs=tinysrgb&w=1260&h=750&dpr=2',
  },
  {
    'id': '4',
    'name': 'Fresh Carrots',
    'category': 'Vegetables', 
    'price': '\$0.99',
    'image':
        'https://images.pexels.com/photos/143133/pexels-photo-143133.jpeg?auto=compress&cs=tinysrgb&w=1260&h=750&dpr=2',
  },
  {
    'id': '5',
    'name': 'Whole Milk',
    'category': 'Dairy', 
    'price': '\$3.20',
    'image':
        'https://images.pexels.com/photos/248412/pexels-photo-248412.jpeg?auto=compress&cs=tinysrgb&w=1260&h=750&dpr=2',
  },
  {
    'id': '6',
    'name': 'Cheddar Cheese',
    'category': 'Dairy', 
    'price': '\$4.50',
    'image':
        'https://images.pexels.com/photos/821365/pexels-photo-821365.jpeg?auto=compress&cs=tinysrgb&w=1260&h=750&dpr=2',
  },
];
final categoriesProvider = Provider<List<Map<String, dynamic>>>((ref) {
  return const [
    {'id': '1', 'icon': Icons.eco, 'label': 'Fruits'},
    {'id': '2', 'icon': Icons.grass, 'label': 'Vegetables'},
    {'id': '3', 'icon': Icons.icecream, 'label': 'Dairy'},
  ];
});

final featuredProductsProvider = FutureProvider<List<Map<String, dynamic>>>((
  ref,
) async {
  await Future.delayed(const Duration(seconds: 2));

  return const [
    {
      'id': 'p1',
      'name': 'Organic Apples',
      'price': '\$2.99',
      'image':
          'https://cdn.pixabay.com/photo/2017/09/26/13/31/apple-2788616_1280.jpg',
    },
    {
      'id': 'p2',
      'name': 'Fresh Bananas',
      'price': '\$1.49',
      'image':
          'https://media.istockphoto.com/id/509533014/photo/raw-organic-bunch-of-bananas.jpg?s=612x612&w=0&k=20&c=eZg53yOtUf-H2vXQovAyAP2FbhWIgfO0KLEX_nYoXxQ=',
    },
    {
      'id': 'p3',
      'name': 'Whole Wheat Bread',
      'price': '\$3.29',
      'image':
          'https://sallysbakingaddiction.com/wp-content/uploads/2024/01/whole-wheat-sandwich-bread-2.jpg',
    },
    {
      'id': 'p4',
      'name': 'Free Range Eggs',
      'price': '\$4.99',
      'image':
          'https://images.pexels.com/photos/162712/egg-white-food-protein-162712.jpeg?auto=compress&cs=tinysrgb&w=1260&h=750&dpr=2',
    },
  ];
});

final allProductsProvider = FutureProvider<List<Map<String, dynamic>>>((
  ref,
) async {
  await Future.delayed(const Duration(seconds: 1));
  return _allProducts;
});


final productsByCategoryProvider =
    FutureProvider.family<List<Map<String, dynamic>>, String>((
  ref,
  categoryName,
) async {
  final allProducts = await ref.watch(allProductsProvider.future);

 return allProducts
      .where((product) => product['category'] == categoryName) 
      .toList();
});